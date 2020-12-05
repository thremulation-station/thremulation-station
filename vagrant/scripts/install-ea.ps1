  # Build authentication information for later requests
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
  $user = "vagrant"
  $password = "vagrant"
  $credential = "${user}:${password}"
  $credentialBytes = [System.Text.Encoding]::ASCII.GetBytes($credential)
  $base64Credential = [System.Convert]::ToBase64String($credentialBytes)
  $basicAuthHeader = "Basic $base64Credential"
  $headers = @{
  "Authorization" = $basicAuthHeader;
  "kbn-xsrf" = "reporting"
  }
  $bodyMsg = @{"forceRecreate" = "true"}
  $bodyJson = ConvertTo-Json($bodyMsg)

  #RetrieveVersion
  Invoke-WebRequest -UseBasicParsing http://192.168.33.10:9200 -OutFile version.json
  $agent_version = (Get-Content 'version.json' | ConvertFrom-Json).version.number

  # Create Fleet User
  Write-Output "Create Fleet User"
  Write-Output "Creating fleet user at http://192.168.33.10:5601/api/fleet/setup"
  $fleetCounter = 0
  do {
  Start-Sleep -Seconds 20
  Write-Output "Trying $fleetCounter times"
  try{
  Write-Output "Creating fleet user with POST request at http://192.168.33.10:5601/api/fleet/setup"
  Invoke-WebRequest -UseBasicParsing -Uri  "http://192.168.33.10:5601/api/fleet/agents/setup" -ContentType "application/json" -Headers $headers -Method POST -body $bodyJson -ErrorAction SilentlyContinue -ErrorVariable SearchError
  }
  catch{
  Write-output "Error Message Array: $searchError"
  }
  Start-Sleep -Seconds 5
  # Checking the content output to see if the host is ready.
  try{
  Write-Output "Checking if Fleet Manager is ready with GET request http://192.168.33.10:5601/api/fleet/enrollment-api-keys?page=1&perPage=20"
  $ekIDBody = (Invoke-WebRequest -UseBasicParsing -Uri  "http://192.168.33.10:5601/api/fleet/agent_policies?page=1&perPage=20&sortField=updated_at&sortOrder=desc&kuery=" -ContentType "application/json" -Headers $headers -Method GET  -ErrorVariable SearchError)
  $isReady = (convertfrom-json($ekIDBody.content)).total
  }
  catch{
  Write-output "Error Message Array: $searchError"
  }

  $fleetCounter++
  }
  until (($isReady -gt 0) -or ($fleetCounter -eq 5) )

  # Get Body of Fleet Enrollment API Key
  Write-Output "Get Enrollment API Key"
  $ApiKeyList = (ConvertFrom-Json(Invoke-WebRequest -UseBasicParsing -Uri  "http://192.168.33.10:5601/api/fleet/enrollment-api-keys" -ContentType "application/json" -Headers $headers -Method GET))

  # Get Fleet TOken from json message
  $ApiKeyId = $ApiKeyList.list[0].id

  $ApiKeyActual = (ConvertFrom-Json(Invoke-WebRequest -UseBasicParsing -Uri  "http://192.168.33.10:5601/api/fleet/enrollment-api-keys/$ApiKeyId" -ContentType "application/json" -Headers $headers -Method GET))
  $fleetToken = $ApiKeyActual.item[0].api_key
  $policyId = $ApiKeyActual.item[0].policy_id

  # Get list of current packages for an up to date Endpoint Version
  $packageList = (convertfrom-json(Invoke-WebRequest -UseBasicParsing -Uri  "http://192.168.33.10:5601/api/fleet/epm/packages?experimental=true" -ContentType "application/json" -Headers $headers -Method GET))
  $endpointPackageVersion = ($packageList.response | where {$_.name -eq "endpoint"}).version

  # Create a json request format suitable for the configuration id
  $securityConfigDict = @"
  {
  "name": "security",
  "description": "",
  "namespace": "default",
  "policy_id": "$policyId",
  "enabled": "true",
  "output_id": "",
  "inputs": [],
  "package": {
  "name": "endpoint",
  "title": "Elastic Endpoint Security",
  "version": "$endpointPackageVersion"
  }
  }
"@ | convertfrom-json

  $securityConfigDictJson = ConvertTo-Json($securityConfigDict)

  Write-Output "Enable Security Integration into Default Config in Ingest Manager"
  Invoke-WebRequest -UseBasicParsing -Uri  "http://192.168.33.10:5601/api/fleet/package_policies" -ContentType "application/json" -Headers $headers -Method POST -body $securityConfigDictJson

  $winlogPackageVersion = ($packageList.response | where {$_.name -eq "windows"}).version

  # Create a json request format suitable for the configuration id
  $windowsConfigDict = @"
  {
  "name": "windows",
  "description": "",
  "namespace": "default",
  "policy_id": "$policyId",
  "enabled": "true",
  "output_id": "",
  "inputs": [],
  "package": {
  "name": "windows",
  "title": "Windows",
  "version": "$winlogPackageVersion"
  }
  }
"@ | convertfrom-json

  $windowsConfigDictJson = ConvertTo-Json($windowsConfigDict)

  Write-Output "Enable Windows Integration into Default Config in Ingest Manager"
  Invoke-WebRequest -UseBasicParsing -Uri  "http://192.168.33.10:5601/api/fleet/package_policies" -ContentType "application/json" -Headers $headers -Method POST -body $windowsConfigDictJson

  Write-Output "Set Kibana Url"
  $fleetYMLconfig = @"
  {
  "kibana_urls": ["http://192.168.33.10:5601"]
  }
"@ | ConvertFrom-Json

  $fleetYMLconfigJson = ConvertTo-Json($fleetYMLconfig)

  Invoke-WebRequest -UseBasicParsing -Uri "http://192.168.33.10:5601/api/fleet/settings" -ContentType application/json -Headers $headers -Method Put -body $fleetYMLconfigJson -ErrorAction SilentlyContinue -ErrorVariable SearchError -TransferEncoding compress

  Write-Output "Set Elasticsearch Url"
  $fleetYMLconfig2 = @"
  {
  "hosts": ["http://192.168.33.10:9200"]
  }
"@ | ConvertFrom-Json

  $fleetYMLconfig2Json = ConvertTo-Json($fleetYMLconfig2)

  $response = Invoke-RestMethod -UseBasicParsing -Uri "http://192.168.33.10:5601/api/fleet/outputs" -ContentType application/json -Headers $headers -Method Get -ErrorAction SilentlyContinue -ErrorVariable SearchError

  $id = $response.items.id

  Invoke-WebRequest -UseBasicParsing -Uri "http://192.168.33.10:5601/api/fleet/outputs/$id" -ContentType application/json -Headers $headers -Method Put -body $fleetYMLconfig2Json -ErrorAction SilentlyContinue -ErrorVariable SearchError -TransferEncoding compress

  $elasticAgentUrl = "https://artifacts.elastic.co/downloads/beats/elastic-agent/elastic-agent-$agent_version-windows-x86_64.zip"
  $agent_install_folder = "C:\Program Files"
  $install_dir = "C:\Agent"
  New-Item -Path $install_dir -Type directory | Out-Null

  if (!(Test-Path $agent_install_folder)) {
  New-Item -Path $agent_install_folder -Type directory | Out-Null
  }
  Write-Output "Downloading Elastic Agent"
  Invoke-WebRequest -UseBasicParsing -Uri $elasticAgentUrl -OutFile "$install_dir\elastic-agent-$agent_version-windows-x86_64.zip"
  Write-Output "Installing Elastic Agent..."
  Write-Output "Unzipping Elastic Agent from $agent_install_folder\elastic-agent-$agent_version-windows-x86_64.zip to $agent_install_folder"
  Expand-Archive -literalpath $install_dir\elastic-agent-$agent_version-windows-x86_64.zip -DestinationPath $agent_install_folder

  Rename-Item "$agent_install_folder\elastic-agent-$agent_version-windows-x86_64" "$agent_install_folder\Elastic-Agent"

  Write-Output "Running enroll process of Elastic Agent with token: $fleetToken at url: http://192.168.33.10:5601"
  #install -f --kibana-url=KIBANA_URL --enrollment-token=ENROLLMENT_KEY
  cd 'C:\Program Files\Elastic-Agent'
  .\elastic-agent.exe install -f --insecure --kibana-url=http://192.168.33.10:5601 --enrollment-token=$fleetToken

  #Write-Output "Running Agent Install Process"
  # & "$agent_install_folder\elastic-agent-$agent_version-windows-x86_64\install-service-elastic-agent.ps1" -Wait

 cd 'C:\Program Files\Elastic\Agent\'

 .\elastic-agent.exe restart

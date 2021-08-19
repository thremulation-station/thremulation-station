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
  "kbn-xsrf"      = "reporting"
}
$kibana_url = "http://192.168.33.10:5601"
$elasticsearch_url = "http://192.168.33.10:9200"
$fleet_server_url = "https://192.168.33.10:8220"

# Retrieve Stack Version
Invoke-WebRequest -UseBasicParsing -Uri $elasticsearch_url -OutFile version.json
$agent_version = (Get-Content 'version.json' | ConvertFrom-Json).version.number

# Get correct policy ID
Write-Output "Get Default Policy"
$AgentPolicyList = (ConvertFrom-Json(Invoke-WebRequest -UseBasicParsing -Uri "$kibana_url/api/fleet/agent_policies" -ContentType "application/json" -Headers $headers -Method GET))
$DefaultPolicyID = ($AgentPolicyList.items[0,1] | where {$_.name -eq "Default policy"})
$ActualPolicyID = ($DefaultPolicyID.id)


# Get Body of Fleet Enrollment API Key
Write-Output "Get Enrollment API Key"
$ApiKeyPolicyID = (ConvertFrom-Json(Invoke-WebRequest -UseBasicParsing -Uri "$kibana_url/api/fleet/enrollment-api-keys" -ContentType "application/json" -Headers $headers -Method GET))
$DefaultPolicy_ID_ApiKey = ($ApiKeyPolicyID.list[0,1] | where policy_id -eq $ActualPolicyID)
$fleetToken = ($DefaultPolicy_ID_ApiKey.api_key)



### Configure Elastic Agent on host ###################################

# TODO: Clean up the temporary file artifacts
$elasticAgentUrl = "https://artifacts.elastic.co/downloads/beats/elastic-agent/elastic-agent-$agent_version-windows-x86_64.zip"
$agent_install_folder = "C:\Program Files"
$install_dir = "C:\Agent"
New-Item -Path $install_dir -Type directory | Out-Null

if (!(Test-Path $agent_install_folder)) {
  New-Item -Path $agent_install_folder -Type directory | Out-Null
}
Write-Output "Downloading Elastic Agent"
$ProgressPreference = 'silentlyContinue'
Invoke-WebRequest -UseBasicParsing -Uri $elasticAgentUrl -OutFile "$install_dir\elastic-agent-$agent_version-windows-x86_64.zip"
Write-Output "Installing Elastic Agent..."
Write-Output "Unzipping Elastic Agent from $agent_install_folder\elastic-agent-$agent_version-windows-x86_64.zip to $agent_install_folder"
Expand-Archive -literalpath $install_dir\elastic-agent-$agent_version-windows-x86_64.zip -DestinationPath $agent_install_folder

Rename-Item "$agent_install_folder\elastic-agent-$agent_version-windows-x86_64" "$agent_install_folder\Elastic-Agent"

Write-Output "Running enroll process of Elastic Agent with token: $fleetToken at url: $kibana_url"
Set-Location 'C:\Program Files\Elastic-Agent'
.\elastic-agent.exe install -f --insecure --url=$fleet_server_url --enrollment-token=$fleetToken

# Ensure Elastic Agent is started
if ((Get-Service "Elastic Agent") -eq "Stopped") {
  Write-Output "Starting Agent Service"
  Start-Service "Elastic Agent"
}

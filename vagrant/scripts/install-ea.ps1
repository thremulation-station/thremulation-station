# Build authentication information for later requests

Write-Output "Attempting to trust untrusted certificates from Kibana/Elasticsearch"
add-type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAllCertsPolicy : ICertificatePolicy {
    public bool CheckValidationResult(
        ServicePoint srvPoint, X509Certificate certificate,
        WebRequest request, int certificateProblem) {
        return true;
    }
}
"@
$AllProtocols = [System.Net.SecurityProtocolType]'Ssl3,Tls,Tls11,Tls12'
[System.Net.ServicePointManager]::SecurityProtocol = $AllProtocols
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

# Set addition vars here
$user = "elastic"
$password = "vagrant"
$credential = "${user}:${password}"
$credentialBytes = [System.Text.Encoding]::ASCII.GetBytes($credential)
$base64Credential = [System.Convert]::ToBase64String($credentialBytes)
$basicAuthHeader = "Basic $base64Credential"
$headers = @{
  "Authorization" = $basicAuthHeader;
  "kbn-xsrf"      = "reporting"
}
 Write-Output "Here is the stack version: $env:ELASTIC_STACK_VERSION"
 Write-Output "Here is the Kibana URL: $env:KIBANA_URL"
 #Write-Output "Here is the auth: $env:KIBANA_AUTH"
 Write-Output "Here is the Fleet URL: $env:FLEET_SERVER_URL"

#$env:ELASTICSEARCH_URL
#$env:FLEET_SERVER_URL

#$kibana_url = "http://192.168.56.10:5601"
#$elasticsearch_url = "https://192.168.56.10:9200"
#$fleet_server_url = "https://192.168.56.10:8220"




# Retrieve Stack Version
#Invoke-WebRequest -Headers $headers -UseBasicParsing -Uri $elasticsearch_url -OutFile version.json
#$agent_version = (Get-Content 'version.json' | ConvertFrom-Json).version.number

# Get correct policy ID
Write-Output "Get Default Policy"
$AgentPolicyList = (ConvertFrom-Json(Invoke-WebRequest -UseBasicParsing -Uri "$env:KIBANA_URL/api/fleet/agent_policies" -ContentType "application/json" -Headers $headers -Method GET))
$DefaultPolicyID = ($AgentPolicyList.items[0,1] | where {$_.name -eq "Default policy"})
$ActualPolicyID = ($DefaultPolicyID.id)

Write-Output "The policy ID is: $ActualPolicyID"

# Get Body of Fleet Enrollment API Key
Write-Output "Get Enrollment API Key"
$ApiKeyPolicyID = (ConvertFrom-Json(Invoke-WebRequest -UseBasicParsing -Uri "$env:KIBANA_URL/api/fleet/enrollment_api_keys" -ContentType "application/json" -Headers $headers -Method GET))
$DefaultPolicy_ID_ApiKey = ($ApiKeyPolicyID.list[0,1] | where policy_id -eq $ActualPolicyID)
$fleetToken = ($DefaultPolicy_ID_ApiKey.api_key)



### Configure Elastic Agent on host ###################################

# TODO: Clean up the temporary file artifacts
$elasticAgentUrl = "https://artifacts.elastic.co/downloads/beats/elastic-agent/elastic-agent-$env:ELASTIC_STACK_VERSION-windows-x86_64.zip"
$agent_install_folder = "C:\Program Files"
$install_dir = "C:\Agent"
New-Item -Path $install_dir -Type directory | Out-Null

if (!(Test-Path $agent_install_folder)) {
  New-Item -Path $agent_install_folder -Type directory | Out-Null
}
Write-Output "Downloading Elastic Agent"
$ProgressPreference = 'silentlyContinue'
Invoke-WebRequest -UseBasicParsing -Uri $elasticAgentUrl -OutFile "$install_dir\elastic-agent-$env:ELASTIC_STACK_VERSION-windows-x86_64.zip"
Write-Output "Installing Elastic Agent..."
Write-Output "Unzipping Elastic Agent from $agent_install_folder\elastic-agent-$env:ELASTIC_STACK_VERSION-windows-x86_64.zip to $agent_install_folder"
Expand-Archive -literalpath $install_dir\elastic-agent-$env:ELASTIC_STACK_VERSION-windows-x86_64.zip -DestinationPath $agent_install_folder

Rename-Item "$agent_install_folder\elastic-agent-$env:ELASTIC_STACK_VERSION-windows-x86_64" "$agent_install_folder\Elastic-Agent"

Write-Output "Running enroll process of Elastic Agent with token: $fleetToken at url: $env:KIBANA_URL"
Set-Location 'C:\Program Files\Elastic-Agent'
.\elastic-agent.exe install -f --insecure --url=$env:FLEET_SERVER_URL --enrollment-token=$fleetToken

# Ensure Elastic Agent is started
if ((Get-Service "Elastic Agent") -eq "Stopped") {
  Write-Output "Starting Agent Service"
  Start-Service "Elastic Agent"
}

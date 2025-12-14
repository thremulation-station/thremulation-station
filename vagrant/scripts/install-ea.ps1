# Build authentication information for later requests
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Skip certificate validation for self-signed certificates
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
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

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
$kibana_url = "https://192.168.56.10:5601"
$elasticsearch_url = "https://192.168.56.10:9200"
$fleet_server_url = "https://192.168.56.10:8220"

# Retrieve Stack Version
Write-Output "Retrieving Stack Version from Elasticsearch"
Invoke-WebRequest -UseBasicParsing -Uri $elasticsearch_url -Headers $headers -OutFile version.json
$agent_version = (Get-Content 'version.json' | ConvertFrom-Json).version.number
Write-Output "Detected Stack Version: $agent_version"

# Get correct policy ID
Write-Output "Get Endpoint Policy"
$AgentPolicyList = (ConvertFrom-Json(Invoke-WebRequest -UseBasicParsing -Uri "$kibana_url/api/fleet/agent_policies" -ContentType "application/json" -Headers $headers -Method GET))
$EndpointPolicyID = ($AgentPolicyList.items | where {$_.name -like "Endpoint Policy*"})
$ActualPolicyID = ($EndpointPolicyID.id)


# Get Body of Fleet Enrollment API Key
Write-Output "Get Enrollment API Key for Policy ID: $ActualPolicyID"
try {
    $ApiKeyResponse = Invoke-WebRequest -UseBasicParsing -Uri "$kibana_url/api/fleet/enrollment_api_keys" -ContentType "application/json" -Headers $headers -Method GET
    $ApiKeyPolicyID = (ConvertFrom-Json $ApiKeyResponse)
    $DefaultPolicy_ID_ApiKey = ($ApiKeyPolicyID.items | where {$_.policy_id -eq $ActualPolicyID} | Select-Object -First 1)

    if ($DefaultPolicy_ID_ApiKey) {
        $fleetToken = $DefaultPolicy_ID_ApiKey.api_key
        Write-Output "Found existing enrollment token"
    } else {
        Write-Output "No enrollment token found for this policy, creating one..."
        $createTokenBody = @{
            name = "Endpoint Policy Token"
            policy_id = $ActualPolicyID
        } | ConvertTo-Json

        $createTokenResponse = Invoke-WebRequest -UseBasicParsing -Uri "$kibana_url/api/fleet/enrollment_api_keys" -ContentType "application/json" -Headers $headers -Method POST -Body $createTokenBody
        $newToken = (ConvertFrom-Json $createTokenResponse)
        $fleetToken = $newToken.item.api_key
        Write-Output "Created new enrollment token"
    }
} catch {
    Write-Output "Error retrieving enrollment token: $_"
    Write-Output "Attempting to create new enrollment token..."
    $createTokenBody = @{
        name = "Endpoint Policy Token"
        policy_id = $ActualPolicyID
    } | ConvertTo-Json

    $createTokenResponse = Invoke-WebRequest -UseBasicParsing -Uri "$kibana_url/api/fleet/enrollment_api_keys" -ContentType "application/json" -Headers $headers -Method POST -Body $createTokenBody
    $newToken = (ConvertFrom-Json $createTokenResponse)
    $fleetToken = $newToken.item.api_key
    Write-Output "Created new enrollment token"
}

Write-Output "Enrollment Token: $fleetToken"



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

# First we create the request.
$HTTP_Request = [System.Net.WebRequest]::Create('http://192.168.33.10:9200')

# We then get a response from the site.
$HTTP_Response = $HTTP_Request.GetResponse()

# We then get the HTTP code as an integer.
$HTTP_Status = [int]$HTTP_Response.StatusCode

If ( $HTTP_Status -eq 200 ) {
  Write-Host "elastomic box is reachable -- proceeding:"
  Start-Sleep -s 2
  Write-Host "Running Winlogbeat Setup Command"
  winlogbeat --path.config C:\ProgramData\chocolatey\lib\winlogbeat\tools setup
}
Else {
  Write-Host "Unable to contact elastic over port 9200 -- Quitting."
  Start-Sleep -s 2
}

# Finally, we clean up the http request by closing it.
If ($HTTP_Response -eq $null) { }
Else { $HTTP_Response.Close() }

# Global variables
$global:sessionID = ""

function login() {
    $vcUser = Read-Host "Enter VC username"
    $vcPassword = Read-Host "Enter VC password" -AsSecureString
    $vcPassword = (New-Object PSCredential 0, $vcPassword).GetNetworkCredential().Password

    $authPair = "$($vcUser):$($vcPassword)"
    $encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($authPair))
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Content-Type", "application/json")
    $headers.Add("Authorization", "Basic $encodedCreds")

    $vrmsSessionApiUri = "https://" + $vrmsServer + "/api/rest/vr/v1/session"
    "Authenticating into [$vrmsSessionApiUri]"

    try {
        $response = Invoke-RestMethod $vrmsSessionApiUri -Method 'POST' -Headers $headers
    } catch {
        $_.Exception.Response
        Exit 1
    }

    $global:sessionID = $response.session_id

    "Session ID for vSphere Replication REST API is: $global:sessionID"

    $global:headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $global:headers.Add("x-dr-session", "$global:sessionID")
    $global:headers.Add("Content-Type", "application/json")
}
#Variables
$url_get_vm = "http://127.0.0.1:8697/api/vms"
$contentStyle = "application/vnd.vmware.vmw.rest-v1+json"
$headers = @{
    'Authorization' = 'Basic Y2hyaXN0b3BoZXI6Q2FyQzIxMTI4NiE='
}

#Busca las VMs registradas en Workstation
try {
    $vmrest = Start-Process "C:\Program Files (x86)\VMware\VMware Workstation\vmrest.exe" -PassThru
    $vms_list = Invoke-RestMethod -Uri $url_get_vm -Method GET -Headers $headers
} catch {
    Write-Error "Hubo un error al obtener los IDs: $_"
    return
}

#Muestra las VMs encendidas
$vms_list | ForEach-Object {
    $id = $_.id
    $path = $_.path
    $url_get_poweronvm = "http://127.0.0.1:8697/api/vms/$id/power"
    try {
        $response = Invoke-RestMethod -Uri $url_get_poweronvm -Method GET -Headers $headers
        if ($($response.power_state) -eq "poweredOn") {
            $vm = Split-Path $path -Leaf
            Write-Host "VM: $vm, Estado: $($response.power_state)"
            #Apaga todas las VMs
            $response = Invoke-RestMethod -Uri $url_get_poweronvm -Method PUT -Headers $headers -Body off -ContentType $contentStyle
        } 
        
    } catch {
        $errorDetails = $_ | ConvertFrom-Json
        $errorMessage = $errorDetails.Message
        $vm = Split-Path $path -Leaf
        Write-Host "Error en la VM: $vm, Detalles: $errorMessage"
    }
}
$vmrest | Stop-Process
function PowerOnVM {
    #Variables
    $url_get_vm = "http://127.0.0.1:8697/api/vms"
    $contentStyle = "application/vnd.vmware.vmw.rest-v1+json"
    $headers = @{
        'Authorization' = 'Basic Y2hyaXN0b3BoZXI6Q2FyQzIxMTI4NiE='
    }

    #Busca las VMs registradas en Workstation
    try {
        $vmrest = Start-Process "C:\Program Files (x86)\VMware\VMware Workstation\vmrest.exe" -PassThru
        $response_vms = Invoke-RestMethod -Uri $url_get_vm -Method GET -Headers $headers
        $vmrest | Stop-Process
    } catch {
        Write-Error "Hubo un error al obtener los IDs: $_"
        return
    }

    #Numera las VMs y agrega la propiedad de "num"
    #$numberedVMList = $response_vms | ForEach-Object -Begin {$counter=1} -Process {
    $response_vms | ForEach-Object -Begin {$counter=1} -Process {
        $_ | Add-Member -MemberType NoteProperty -Name "num" -Value $counter -PassThru
        $counter++
    }

    #Muestra las VMs
    Write-Host "Maquinas registradas en VMware Workstation"
    $response_vms | Format-Table -Property num, id, path
    $IDList = $response_vms.num

    #Selecciona que VM encender
    $selectedID = $null
    while ($selectedID -eq $null -or $IDList -notcontains $selectedID) {
        $selectedID = Read-Host -Prompt 'Introduce el numero de VM a encender'
        if ($IDList -notcontains $selectedID) {
            Write-Host "Entrada no valida. Por favor, introduce un ID valido de la lista."
            $selectedID = $null
        }
    }

    #Mostrar los datos de VM selecionados
    $vm_id = ($response_vms | Where-Object { $_.num -eq [int]$selectedID }).id
    $vm_path = ($response_vms | Where-Object { $_.num -eq [int]$selectedID }).path
    $vm_name = ($vm_path.Split('\'))[-2]
    Write-Host "La VM seleccionada es: $vm_name con ID: $vm_id"

    #Llamada API para encender VM
    $url_put_power = "http://127.0.0.1:8697/api/vms/$vm_id/power"
    try {
        $vmrest = Start-Process "C:\Program Files (x86)\VMware\VMware Workstation\vmrest.exe" -PassThru
        $response = Invoke-RestMethod -Uri $url_put_power -Method PUT -Headers $headers -Body on -ContentType $contentStyle
        $vmrest | Stop-Process
        Write-Host "Encendiendo $vm_name..."
        #Write-Host $response
        #return $response
    } catch {
        Write-Error "Hubo un error al realizar la llamada a la API con el ID seleccionado: $_"
    }

    #Ajustar los cores fisicos a la VM
    $processName = "vmware-vmx"
    $targetProcesses = Get-Process | Where-Object { $_.ProcessName -eq $processName }
    if ($targetProcesses.Count -gt 0) {
        $number = $($targetProcesses.Count)
        Write-Host "Ajustando los cores fisicos asignados a la VM..."
        Write-Host "El proceso '$processName' tiene $($targetProcesses.Count) activos"

    foreach ($process in $targetProcesses) {
        Write-Host "ID del proceso: $($process.Id)"
    }
    } else {
        Write-Host "No se encontro ningun proceso '$processName'."
    }

    if ($targetProcesses.Count -ge $number) {
    #Define la mascara para no usar los cores 16-18
    $affinityMask = 65535  

    #Coloca la mascara en cada proceso 
    foreach ($process in $targetProcesses) {
        $process.ProcessorAffinity = $affinityMask
        Write-Host "Se elimino el acceso de los cores 16-18 del proceso: $($process.Id)."
    }
    } else {
        Write-Host "Less than 2 processes with the name '$processName' found."
    }

}
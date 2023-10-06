#Get Variables from file
$lines = Get-Content "C:\Code\vc.txt"

# Asignar cada línea a una variable
$vc = $lines[0]
$user = $lines[1]
$pass = $lines[2]

#Conect to vCenter
Connect-VIServer -Server $vc -User $user -Password $pass

#Show PowerOn VMs
$vms = Get-VM | Where-Object {$_.PowerState -eq 'PoweredOn'} 
$vms | Select-Object Name, PowerState

$response = Read-Host "¿Estas seguro de que quieres apagar todas las VMs? (Y/N)"

if ($response -eq 'Y' -or $response -eq 'y') {
    Write-Host "Has confirmado. Continuando con la ejecución del apagado de VMs."
    #Shutdown all PowerOn VMs
    foreach ($vm in $vms) {
        # No apagar la VM r1.labon.casa
        if ($vm.Name -ne 'r1.labon.casa') {
            Write-Host "Apagando la maquina virtual $($vm.Name)..."
            Shutdown-VMGuest -VM $vm -Confirm:$false
        } else {
            Write-Host "Omitiendo la maquina virtual $($vm.Name)..."
        }
    }
    #PowerOff Host
    $esxi2 = Get-VMHost -Name 'esx2.labon.casa'
    $esxi3 = Get-VMHost -Name 'esx3.labon.casa'
    
    Write-Host "Apagando el host ESXi2..."
    Stop-VMHost -VMHost $esxi2 -Confirm:$false -Force
    Write-Host "Apagando el host ESXi3..."
    Stop-VMHost -VMHost $esxi3 -Confirm:$false -Force
}

else {
    Write-Host "Has decidido no continuar. Saliendo.."
    exit
}
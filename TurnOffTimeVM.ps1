#Funcion para conectar a vCenter Server
function ShowPowerOffTimeVMs {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Server,

        [Parameter(Mandatory=$true)]
        [string]$Username,

        [Parameter(Mandatory=$true)]
        [string]$Password
    )

    # Importar el módulo VMware.PowerCLI si aún no se ha importado
    if (-not (Get-Module -ListAvailable -Name 'VMware.Sdk.vSphere')) {
        Write-Host "El equipo no tiene instalado PowerCLI, a continuacion se instalara el Modulo.."
        Install-Module -Name VMware.PowerCLI -Scope CurrentUser -Force -SkipPublisherCheck
    }

    # Conectar al servidor vCenter
    try {
        Connect-VIServer -Server $Server -User $Username -Password $Password
        Write-Host "Conexion exitosa a $Server."

        #Muestra el tiempo apagado de las VMs
        Get-VIEvent -Entity $vmOff -MaxSamples ([int]::MaxValue) | where {$_ -is [VMware.Vim.VmPoweredOffEvent]} | 
        Group-Object -Property {$_.Vm.Name} | %{
          $lastPO = $_.Group | Sort-Object -Property CreatedTime -Descending | Select -First 1 | Select -ExpandProperty CreatedTime
          New-Object PSObject -Property @{
            VM = $_.Group[0].Vm.Name
            "Last Poweroff"= $lastPO
            Duration = [math]::Round((New-TimeSpan -Start $lastPO | Select -ExpandProperty TotalDays))
          }
        }

    } catch {
        Write-Host "Error al conectarse a $Server. Detalles del error: $_"
    }
}

# Ejemplo de uso Opcion 1:
# ShowPowerOffTimeVMs -Server "nombre_de_tu_servidor" -Username "tu_usuario" -Password "tu_contraseña"

# Ejemplo de uso Opcion 2:
# ShowPowerOffTimeVMs 
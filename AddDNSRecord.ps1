# Define el nombre de usuario y la contraseña
$user = "labon\cr"
$pass = "CarC211286!"

# Convierte la contraseña en un SecureString
$securePass = ConvertTo-SecureString $pass -AsPlainText -Force

# Crea el objeto PSCredential
$myCred = New-Object System.Management.Automation.PSCredential ($user, $securePass)

# Inicia una nueva sesión de PowerShell
$session = New-PSSession -ComputerName "ad.labon.casa" -Credential $myCred -Authentication Basic 

# Entra en la sesión de PowerShell
Enter-PSSession -Session $session
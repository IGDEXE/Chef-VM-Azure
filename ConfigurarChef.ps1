# Configurar Chef
# Ivo Dias

# Importa os modulos necessarios
Import-Module BitsTransfer

# Faz o download do Chef
$url = "https://packages.chef.io/files/stable/chefdk/4.7.73/windows/2012r2/chefdk-4.7.73-1-x64.msi"
$caminhoInstalador = "$ENV:UserProfile\Downloads\chefdk-4.7.73-1-x64.msi"
Write-Host "Fazendo o download do Chef"
$wc = New-Object System.Net.WebClient
$wc.DownloadFile($url, $caminhoInstalador)

# Faz a instalacao do Chef
Write-Host "Fazendo a instalacao do Chef"
msiexec.exe /I "$caminhoInstalador" /quiet

# Configura
Write-Host "Terminando as configuracoes"
$env:Path += ";C:\opscode\chefdk\bin" # Adiciona ao Path do Windows
chef gem install chef-provisioning-azurerm 3 # Provisiona o Azure
Clear-Host
Write-Host "Chef configurado"

# Instala o modulo do Azure
Write-Host "Configurando o Azure"
Install-Module -Name Az -AllowClobber -Scope CurrentUser -Force
Install-Module AzureRM -Force
Set-ExecutionPolicy -ExecutionPolicy Bypass
Import-Module AzureRM

# Finaliza
Clear-Host
Write-Host "Configuracao finalizada"
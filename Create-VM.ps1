# Criando uma VM Azure usando Chef
# Ivo Dias
# Referencia: https://www.lambda3.com.br/2017/06/criando-uma-vm-azure-usando-chef/ 

# Cria uma variavel para a pasta padrao do projeto
$pastaProjeto = "$ENV:UserProfile\Documents\Projeto"
mkdir "$pastaProjeto"
Set-Location -Path $pastaProjeto
chef generate repo chef-repo
$pastaProjeto += "\chef-repo"
mkdir "$pastaProjeto\.chef"

# Faz login no Azure
$credencialAzure = Get-Credential
Login-AzureRmAccount -Credential $credencialAzure

# Salva os dados necessarios
$nomeSubs = ((Get-AzureRmContext).Subscription).Name
$idSubs = ((Get-AzureRmContext).Subscription).Id
$senhaAPP = ConvertTo-SecureString "Mudar123" -AsPlainText -Force # Senha do APP para exemplo

# Faz o download do script
Invoke-WebRequest -URI https://gist.githubusercontent.com/sjkp/186d36334b27656a05cd/raw/6acba8599e0906e7fc1957195cd5f7204673d952/New-AzureRmServicePrincipal.ps1 -OutFile New-AzureRmServicePrincipal.ps1
.\New-AzureRmServicePrincipal.ps1 $nomeSubs $senhaAPP
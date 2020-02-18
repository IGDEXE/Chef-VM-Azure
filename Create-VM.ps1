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
$tenantIdSubs = ((Get-AzureRmContext).Subscription).TenantId
$senhaAPP = ConvertTo-SecureString "Mudar123" -AsPlainText -Force # Senha do APP para exemplo

# Faz o download do script
Invoke-WebRequest -URI https://raw.githubusercontent.com/IGDEXE/Chef-VM-Azure/master/New-AzureRmServicePrincipal.ps1 -OutFile New-AzureRmServicePrincipal.ps1
.\New-AzureRmServicePrincipal.ps1 $nomeSubs $senhaAPP $credencialAzure

# Cria as variaveis de ambiente
$Env:AZURE_CLIENT_ID = "$idSubs"
$Env:AZURE_CLIENT_SECRET = "your-client-secret-here"
$Env:AZURE_TENANT_ID = "$tenantIdSubs"
[Environment]::SetEnvironmentVariable("AZURE_CLIENT_ID", $AZURE_CLIENT_ID, "User")
[Environment]::SetEnvironmentVariable("AZURE_CLIENT_SECRET", $AZURE_CLIENT_SECRET, "User")
[Environment]::SetEnvironmentVariable("AZURE_TENANT_ID", $AZURE_TENANT_ID, "User")

# Entra na pasta Cookboks e cria um novo
Set-Location -Path "$pastaProjeto\cookbooks"
chef generate cookbook chef-azure
Remove-Item "$pastaProjeto\cookbooks\chef-azure\recipes\default.rb" -Force # Removemos o padrao para criar um novo

# Texto do novo arquivo
$receita = @"
require 'chef/provisioning/azurerm'
with_driver 'AzureRM:$idSubs'
 
azure_resource_group 'chefrg' do
  location 'East US'
  tags businessUnit: 'DEV'
end
 
azure_resource_template 'MyDeployment' do
  resource_group 'chefrg'
  template_source "#{Chef::Config[:cookbook_path]}/#{cookbook_name}/files/azuredeploy.json"
  parameters adminUsername: 'ubuntu',
             sshKeyData: File::read("#{Chef::Config[:validation_key]}.pub")
end
"@
Set-Content -Path "$pastaProjeto\cookbooks\chef-azure\recipes\default.rb" -Value "$receita" # Cria o arquivo

# Template para a VM
mkdir $pastaProjeto/cookbooks/chef-azure/files
Set-Location $pastaProjeto/cookbooks/chef-azure/files
Invoke-WebRequest -URI https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/101-vm-sshkey/azuredeploy.json -OutFile azuredeploy.json

# Roda o projeto
Set-Location $pastaProjeto
Clear-Host
Write-Host "Fazendo o deploy"
chef-client -o chef-azure -z

# Faz o teste
$vm = Get-AzureRmVM -Name "sshvm" -ResourceGroupName "chefrg"
$NIC = Get-AzureRmNetworkInterface  | Where-Object { $_.Id -eq $vm.NetworkProfile.NetworkInterfaces[0].Id }
Get-AzureRmPublicIpAddress | Where-Object {$_.Id -eq $NIC.IpConfigurations[0].PublicIpAddress.Id} | Select-Object IpAddress
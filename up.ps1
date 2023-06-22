[CmdletBinding(DefaultParameterSetName = "no-arguments")]
Param (
	[ValidateSet("XM1","XP1","XP0")]
	[string]$Topology = "XM1",
	
    [Parameter(HelpMessage = "Skip check for taken ports")]
    [switch]$SkipPortCheck,
	
    [Parameter(HelpMessage = "Skip docker image build")]
    [switch]$SkipBuild
)

Import-Module ValtechHelixScripts -DisableNameChecking

##Sync Valtech Helix settings to Env
$settings = Sync-ValtechHelixEnvVariables
    
#Get Platform Name from .env file
$PlatformName = $settings.COMPOSE_PROJECT_NAME

# Restore dotnet tool for sitecore login and serialization
dotnet tool restore

# Will test if local ports with 80 (IIS), 8984 (Solr) are in use.
try { Invoke-Expression "./sanitize.ps1 -Strict" } catch { Write-Host "No Sanitize Script found" -ForegroundColor Red }

$dockerCompose = "docker-compose -f docker-compose.yml -f docker-compose.override.yml"
if($Topology -eq 'XP1'){
	$dockerCompose = "docker-compose -f docker-compose.xp1.yml -f docker-compose.xp1.override.yml"
}elseif($Topology -eq "XP0") {
	$dockerCompose = "docker-compose -f docker-compose.xp0.yml -f docker-compose.xp0.override.yml"
}

# Getting rendering host related compose files (if any)
$renderingHostsCompose = ''
Get-ChildItem -filter 'docker-compose.rh.*.yml' | ForEach-Object { $renderingHostsCompose += (" -f "+ $_.Name) }
if($renderingHostsCompose -ne ''){
    $dockerCompose += $renderingHostsCompose
}

if (!$SkipPortCheck) {
	if (Check-PortsTaken -ComposeUpLine $dockerCompose){
		Write-Host "Please check if applications like IIS or SOLR are running and using these ports which are required by this Docker set-up" -ForegroundColor Red
		exit
	}
}

# Build all containers in the Sitecore instance, forcing a pull of latest base containers
if (!$SkipBuild) {
	Write-Host "BUILD the docker containers..." -ForegroundColor Green
	Write-Host "$dockerCompose build"
	Invoke-Expression "$dockerCompose build"

	if ($LASTEXITCODE -ne 0)
	{
		Write-Error "Container build failed, see errors above."
	}
}

# Run the docker containers
Write-Host "Run the docker containers..." -ForegroundColor Green
Write-Host "$dockerCompose up -d"
Invoke-Expression "$dockerCompose up -d"

# Wait for Traefik to expose CM route
Write-Host "Waiting for CM to become available..." -ForegroundColor Green
$startTime = Get-Date
do {
    Start-Sleep -Milliseconds 1000
    try {
        $status = Invoke-RestMethod "http://localhost:8079/api/http/routers/cm-secure@docker"
    } catch {
        if ($_.Exception.Response.StatusCode.value__ -ne "404") {
            throw
        }
    }
	$WaitIndicator = $WaitIndicator + "."
	Write-Host "`r$WaitIndicator" -NoNewline
} while ($status.status -ne "enabled" -and $startTime.AddSeconds(600) -gt (Get-Date))
Write-Host "`r$WaitIndicator"
if (-not $status.status -eq "enabled") {
    $status
    Write-Error "Timeout waiting for Sitecore CM to become available via Traefik proxy. Check CM container logs."
}

dotnet sitecore login --cm "https://$($PlatformName.ToLower())-cm.vh.localhost/" --auth "https://$($PlatformName.ToLower())-id.vh.localhost/" --allow-write true
if ($LASTEXITCODE -ne 0) {
    Write-Error "Unable to log into Sitecore, did the Sitecore environment start correctly? See logs above."
}

Write-Host "Checking SOLR schema" -ForegroundColor Green
$solrfields = Invoke-RestMethod -Uri "http://localhost:8984/solr/sitecore_master_index/schema/fields?wt=json"
if ($solrfields.fields.name -contains '_template') {
	Write-Host "Managed schema seems to be populated already!"
} else {

	Write-Host "Populating Solr managed schema..." -ForegroundColor Green
	$token = (Get-Content .\.sitecore\user.json | ConvertFrom-Json).endpoints.default.accessToken
	Invoke-RestMethod "https://$($PlatformName.ToLower())-cm.vh.localhost/sitecore/admin/PopulateManagedSchema.aspx?indexes=all" -Headers @{Authorization = "Bearer $token"} -UseBasicParsing | Out-Null
	
	$WaitIndicator = ""
	$startTime = Get-Date
	do {
		Start-Sleep -Milliseconds 1000
		$WaitIndicator = $WaitIndicator + "."
		Write-Host "`r$WaitIndicator" -NoNewline
	} while ($startTime.AddSeconds(60) -gt (Get-Date))
	Write-Host "`r$WaitIndicator"
}

Write-Host "Pushing latest items to Sitecore..." -ForegroundColor Green

dotnet sitecore ser push
if ($LASTEXITCODE -ne 0) {
    Write-Error "Serialization push failed, see errors above."
}

dotnet sitecore publish
if ($LASTEXITCODE -ne 0) {
    Write-Error "Item publish failed, see errors above."
}

Write-Host "Opening site..." -ForegroundColor Green

Start-Process "https://$($PlatformName.ToLower())-cm.vh.localhost/sitecore/"

if($Topology -eq "XP0") {
	Start-Process "https://$($PlatformName.ToLower())-cm.vh.localhost/"
}else{
	Start-Process "https://$($PlatformName.ToLower())-cd.vh.localhost/"
}

$RenderingHostSites = $settings.Keys | Where-Object {$_ -match "RH_HOST"} | % { $settings.Item($_) }
foreach ($RenderingHostSite in $RenderingHostSites) {
	Start-Process "https://$RenderingHostSite"
}

Write-Host "Use the following command to bring your docker environment down again:" -ForegroundColor Green
if($Topology -And $Topology -ne "XM1"){
    Write-Host ".\down.ps1 -Topology $Topology"
}
else {
    Write-Host ".\down.ps1"
}

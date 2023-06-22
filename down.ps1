[CmdletBinding(DefaultParameterSetName = "no-arguments")]
Param (
	[ValidateSet("XM1","XP1","XP0")]
	[string]$Topology = "XM1"
)

$dockerCompose = "docker-compose -f docker-compose.yml -f docker-compose.override.yml"
if($Topology -eq 'XP1'){
	$dockerCompose = "docker-compose -f docker-compose.xp1.yml -f docker-compose.xp1.override.yml"
}elseif($Topology -eq "XP0") {
	$dockerCompose = "docker-compose -f docker-compose.xp0.yml -f docker-compose.xp0.override.yml"
}

$renderingHostsCompose = ''
Get-ChildItem -filter 'docker-compose.rh.*.yml' | ForEach-Object { $renderingHostsCompose += (" -f "+ $_.Name) }
if($renderingHostsCompose -ne ''){
    $dockerCompose += $renderingHostsCompose
}

Write-Host "Stopping docker containers..." -ForegroundColor Green
Write-Host "$dockerCompose down"
Invoke-Expression "$dockerCompose down"
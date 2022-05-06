
$global:LASTEXITCODE = 0
 
$path = [System.IO.Path]::Combine($PSScriptRoot,'scripts','xtool.psm1')
Write-Host 'Module Path:' $path

$x = Get-Module -Name 'xtool'
if (-not $continueOnError) { if ($LASTEXITCODE -ne 0) { throw 'error' } } 

if ($x) {
  Write-Host 'Removing Module'
  Remove-Module -Name 'xtool'
  if (-not $continueOnError) { if ($LASTEXITCODE -ne 0) { throw 'error' } } 
}

Write-Host 'Importing Module'
Import-Module $path
if (-not $continueOnError) { if ($LASTEXITCODE -ne 0) { throw 'error' } } 

[array] $p = ReadProjects 
# $p | ForEach-Object { 
#   Write-Host $_.appId
#   # $_ | ConvertTo-Json | Out-Host
#  }
# UpdateLaunchSettings -projects $p -ingress
# $daprScriptsPath = Join-Path '.' '.dapr-run'

# WriteDaprScripts -projects $p -dir $daprScriptsPath 

$daprPlacementPort = 50006

$configFilePath = Join-Path './dapr' 'config.yaml' -Resolve
$componentsPath = Join-Path './dapr' 'components/' -Resolve
$daprScriptsPath = Join-Path '.' '.dapr-run'


StopJobs
ShowJobs
StartDaprJobs -projects $p -placementPort $daprPlacementPort -configFile $configFilePath
ShowJobs
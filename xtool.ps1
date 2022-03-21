[Cmdletbinding()]
Param(
  [switch] $daprInit
, [switch] $build
, [switch] $tyeRun
, [switch] $tyeBuild
, [switch] $composeUp
, [switch] $composeDown
  # , [switch] $dryRun
  # , [string] $skipAppId
  # , [switch] $skipBuild
)

function resetError() { $global:LASTEXITCODE = 0 }
function checkError() { if (-not $continueOnError) { if ($LASTEXITCODE -ne 0) { throw 'error' } } }
function runX() {
  [Cmdletbinding()] param([string] $cmd, [array] $args) 
  resetError
  if ($args) {
    Write-Host '  Run with args:' $cmd $args
    & $cmd $args
  } else {
    Write-Host '  Run:' $cmd
    & $cmd
  }  
  checkError
}

$host.ui.RawUI.WindowTitle = 'starlight-one-xtool'
$solutionFile = 'starlight-one.sln'
# $projects = @()

# {
#   Write-Host 'Loadings Projects'
#   $files = Get-ChildItem -Path './src' -Filter 'launchSettings.json' -Recurse -Depth 99;
#   $file=$files[0]
#   foreach ($file in $files) {    
#     $projDir = $file.Directory.Parent
#     Write-Host '  Project Dir:' $projDir.FullName
#     $projFileName = "$($projDir.Name).csproj"
#     $projFile = Join-Path $projDir.FullName $projFileName -Resolve   
#   }
# }


if ($daprInit) {
  Write-Host 'Starting dapr init slim'
  resetError
  dapr uninstall

  checkError
  dapr init --slim
  checkError
}

if ($build) {
  Write-Host 'Starting build'
  runX -cmd 'dotnet' -args @('restore')
  runX -cmd 'dotnet' -args @('build',  $solutionFile  )
}

if ($tyeRun) {
  Write-Host 'Starting tye run'
  runX -cmd 'dotnet' -args @('restore')

  $ar = @('tye', 'run', '--watch') #, '--logs seq')
  runX -cmd 'dotnet' -args $ar
}

if ($composeUp) {
  Write-Host 'Docker Compose Up' 
  runX -cmd 'docker' -args @('compose', 'up', '--detach')
}

if ($composeDown) {
  Write-Host 'Docker Compose Down'
  runX -cmd 'docker' -args @('compose', 'down', '--remove-orphans')
}
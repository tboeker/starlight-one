[Cmdletbinding()]
Param(
  [switch] $daprInit
  , [switch] $dbg
  , [switch] $build
  , [switch] $tyeRun
  , [switch] $tyeBuild
  , [switch] $composeUp
  , [switch] $composeDown
  , [switch] $clean
  , [switch] $updatelaunchSettings
  , [switch] $writeDaprFiles
  # , [switch] $dryRun
  # , [string] $skz
  # , [switch] $skipBuild
)


# --------------------------------------------------------------------------------
function resetError() { $global:LASTEXITCODE = 0 }
function checkError() { if (-not $continueOnError) { if ($LASTEXITCODE -ne 0) { throw 'error' } } }
# --------------------------------------------------------------------------------
function runX() {
  [Cmdletbinding()] param([string] $cmd, [array] $args) 
  resetError
  if ($args) {
    Write-Host '  Run with args:' $cmd $args
    & $cmd $args
  }
  else {
    Write-Host '  Run:' $cmd
    & $cmd
  }  
  checkError
}

# --------------------------------------------------------------------------------
# helper function : update environment variable in launch setting
function Update-EnvironmentVariable ($environmentVariables, $name, $value) {
  $m = $environmentVariables | Get-Member $name
  if ($m) {
    $environmentVariables.PSObject.Properties.Remove($name)
  }
  $environmentVariables | Add-Member -MemberType NoteProperty -Name $name -Value $value
}
# --------------------------------------------------------------------------------
$DebugPreference

$host.ui.RawUI.WindowTitle = 'starlight-one-xtool'
$solutionFile = 'starlight-one.sln'
$projects = @()
$DAPR_PLACEMENT_PORT = 50006
$configFile = Join-Path './dapr' 'config.yaml' -Resolve
$componentsPath = Join-Path './dapr' 'components/' -Resolve

if ($true) {
  "-" * 80
  $daprHttpPort = 3500
  $daprGrpcPort = 50001
  $metricsPort = 9091
  $appPort = 5000

  Write-Host 'Loadings Projects'
  $files = Get-ChildItem -Path './src' -Filter 'launchSettings.json' -Recurse -Depth 99;
  $file = $files[0]

  foreach ($file in $files) {    
    $projDir = $file.Directory.Parent
    Write-Debug "  Project Dir: $($projDir.FullName)"
    $projectName = $projDir.Name
    $projFileName = "$($projectName).csproj"
    $projFile = Join-Path $projDir.FullName $projFileName -Resolve   
    $projFileItem = Get-Item -Path $projFile

    $proj = @{
      appId              = $projectName.Replace('.', '-').ToLowerInvariant()
      projectFolder      = $projDir.FullName
      projectFile        = $projFileItem.FullName
      settingName        = $projDir.Name
      launchSettingsFile = $file.FullName
      name               = $projectName
      urls               = "http://localhost:" + $appPort # + ";https://localhost:" + $($appPort + 1)
      appPort            = $appPort.ToString()
      daprHttpPort       = $daprHttpPort.ToString()
      daprGrpcPort       = $daprGrpcPort.ToString()
      jobs               = @()
    }
    
    $daprHttpPort += 10
    $DAPR_GRPC_PORT += 10
    $appPort += 10
    $metricsPort += 1

    $jobName = $proj.appId + "-daprd"
    $cmd = "dapr run --app-id $($proj.appId) --app-port $($proj.appPort) --placement-host-address localhost:$DAPR_PLACEMENT_PORT --log-level debug --components-path $componentsPath --dapr-http-port $($proj.daprHttpPort) --dapr-grpc-port $($proj.DAPR_GRPC_PORT) --metrics-port $metricsPort --config $configFile"

    $proj.jobs += @{
      cmd     = $cmd
      jobName = $jobName
    }

    if ($skipAppId -eq $proj.appId) {
      Write-Host "expecting" $($proj.projectFile) "to be started from development environment"
    }
    else {
      $jobName = $configProject.appId + "-app"
      $cmd = "dotnet run --project $($proj.projectFile) --launch-profile $($proj.settingName) --no-build"
      $proj.jobs += @{
        cmd     = $cmd
        jobName = $jobName
      }  
    }

    $projects += $proj
  }

  Write-Host "$($projects.Count) Projects found"
}

if ($dbg) {
  "-" * 80
  foreach ($proj in $projects) {  
    $proj | ConvertTo-Json | Out-Host
  }
}


if ($updatelaunchSettings) {
  "-" * 80
  Write-Host 'Updating Launch Settings'

  foreach ($proj in $projects) {
    $launchSettingsFile = $proj.launchSettingsFile

    if ($dbg) {
      Write-Host "  $($proj.name) | $launchSettingsFile"  
    }

    $launchSettings = Get-Content $launchSettingsFile | ConvertFrom-Json

    foreach ($profile in $launchSettings.profiles.PSObject.Properties) {
      if ($profile.Name -eq $proj.settingName) {
        Update-EnvironmentVariable $profile.Value.environmentVariables "ASPNETCORE_URLS" $proj.urls
        Update-EnvironmentVariable $profile.Value.environmentVariables "DAPR_HTTP_PORT" $proj.daprHttpPort
        Update-EnvironmentVariable $profile.Value.environmentVariables "DAPR_GRPC_PORT" $proj.daprGrpcPort
      }
    }

    $launchSettings | ConvertTo-Json -Depth 10 | Set-Content $launchSettingsFile
    if ($dbg) {
      Write-Host "  Updated" $launchSettingsFile
    }
  }
}

if ($writeDaprFiles) {
  "-" * 80
  Write-Host 'Writing dapr files'

  $cmdDir = './.dapr-run'
  if (! (Test-Path -Path $cmdDir)) {
    New-Item -Path $cmdDir -ItemType Directory
  }
  $cmdFolder = Join-Path . $cmdDir -Resolve

  $sumOuts = @()

  "-" * 80
  foreach ($proj in $projects) {  
    $proj | ConvertTo-Json | Out-Host
  
    foreach ($j in $proj.jobs) {
      
      $cmd = $j.cmd
      $jobName = $j.jobName
      
      $fileName = $jobName + '.cmd'

      $file = Join-Path $cmdFolder $fileName
      Write-Host $file
  
      $fileOuts = @()
      $fileOuts += 'title ' + $jobName
      # $fileOuts += 'start ' + $c.cmd
      $fileOuts += $c.cmd
      $fileOuts | Set-Content $file

      $sumOuts += 'start ' + $fileName
    }
  }
  
  $sumOuts | Set-Content (Join-Path $cmdFolder 'run-all.cmd')

  @(
    'title dapr dashboard',
    'dapr dashboard'
  ) | Set-Content (Join-Path $cmdFolder 'dashboard.cmd')


}


if ($clean) {
  "-" * 80
  Write-Host 'Starting clean'
  Get-ChildItem -Recurse -Include 'bin', 'bin2', 'obj', 'TestResults' -Path .\ |
  ForEach-Object {
    Remove-Item $_.FullName -recurse -force
    Write-Host deleted $_.FullName
  }
}

if ($daprInit) {
  "-" * 80
  Write-Host 'Starting dapr init slim'
  resetError
  dapr uninstall

  checkError
  dapr init --slim
  checkError
}

if ($build) {
  "-" * 80
  Write-Host 'Starting build'
  runX -cmd 'dotnet' -args @('restore')
  runX -cmd 'dotnet' -args @('build', $solutionFile  )
}

if ($tyeRun) {
  "-" * 80
  Write-Host 'Starting tye run'
  runX -cmd 'dotnet' -args @('restore')

  $ar = @('tye', 'run', '--watch') #, '--logs seq')
  runX -cmd 'dotnet' -args $ar
}

if ($composeUp) {
  "-" * 80
  Write-Host 'Docker Compose Up' 
  runX -cmd 'docker' -args @('compose', 'up', '--detach')
}

if ($composeDown) {
  "-" * 80
  Write-Host 'Docker Compose Down'
  runX -cmd 'docker' -args @('compose', 'down', '--remove-orphans')
}
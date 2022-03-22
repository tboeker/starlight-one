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
  , [switch] $writeDaprScripts
  , [switch] $startJobs
  , [switch] $stopJobs
  , [switch] $showJobs
  # , [switch] $dryRun
  # , [string] $skz
  # , [switch] $skipBuild
)


# --------------------------------------------------------------------------------
function resetError() { $global:LASTEXITCODE = 0 }
function checkError() { if (-not $continueOnError) { if ($LASTEXITCODE -ne 0) { throw 'error' } } }

# --------------------------------------------------------------------------------
function runX() {
  [Cmdletbinding()] param([string] $cmd, [array] $argsarr) 
  resetError
  if ($argsarr) {
    Write-Host '  Run with args:' $cmd $argsarr
    & $cmd $argsarr
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
$solutionFilePath = Join-Path '.' $solutionFile -Resolve
$projects = @()
$daprPlacementPort = 50006
$configFilePath = Join-Path './dapr' 'config.yaml' -Resolve
$componentsPath = Join-Path './dapr' 'components/' -Resolve
$daprScriptsPath = Join-Path '.' '.dapr-run'

# --------------------------------------------------------------------------------
if ($true) {
  resetError
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
    if ($dbg) { Write-Debug "  Project Dir: $($projDir.FullName)" }
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
      metricsPort        = $metricsPort.ToString()
      jobs               = @()
    }
    
    $daprHttpPort += 10
    $daprGrpcPort += 10
    $appPort += 10
    $metricsPort += 1

    $jobName = $proj.appId + "-dapr"
    $cmd = "dapr run --app-id $($proj.appId) --app-port $($proj.appPort) --placement-host-address localhost:$daprPlacementPort --log-level debug --components-path $componentsPath --dapr-http-port $($proj.daprHttpPort) --dapr-grpc-port $($proj.daprGrpcPort) --metrics-port $metricsPort --config $configFilePath"

    $proj.jobs += @{
      cmd     = $cmd
      jobName = $jobName
      typ     = "dapr"
    }

    if ($skipAppId -eq $proj.appId) {
      Write-Host "expecting" $($proj.projectFile) "to be started from development environment"
    }
    else {
      $jobName = $proj.appId + "-app"
      $cmd = "dotnet run --project $($proj.projectFile) --launch-profile $($proj.settingName) --no-build"
      $proj.jobs += @{
        cmd     = $cmd
        jobName = $jobName
        typ     = "dotnet-run"
      }  
    }

    $projects += $proj
  }

  checkError
  Write-Host "$($projects.Count) Projects found"
}

$jobNamePattern = $projects | Join-String -Property appId -Separator "|" -OutputPrefix "(placement|" -OutputSuffix ")"

# --------------------------------------------------------------------------------
if ($dbg) {
  "-" * 80
  foreach ($proj in $projects) {  
    $proj | ConvertTo-Json | Out-Host
  }
}

# --------------------------------------------------------------------------------
if ($updatelaunchSettings) {
  "-" * 80
  Write-Host 'Updating Launch Settings'
  resetError

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
  checkError
}

# --------------------------------------------------------------------------------
if ($writeDaprScripts) {
  "-" * 80
  Write-Host 'Writing dapr files'
  if ($dbg) {
    Write-Host "  daprScriptsDir: $($daprScriptsPath)"  
  }
  if (! (Test-Path -Path $daprScriptsPath)) {
    New-Item -Path $daprScriptsPath -ItemType Directory
  }
 
  $sumOuts = @()
  $sumOuts2 = @()

  "-" * 80

  $sumOuts += "dotnet build $($solutionFilePath)"
  $sumOuts2 += "dotnet build $($solutionFilePath)"

  foreach ($proj in $projects) {  
    if ($dbg) {
      Write-Host "  $($proj.name)"  
    }
  
    foreach ($j in $proj.jobs) {
      
      $cmd = $j.cmd
      $jobName = $j.jobName

      if ($dbg) {
        Write-Host "   $jobName"  
      }
        
      $fileName = $jobName + '.cmd'
      if ($dbg) {
        Write-Host "    fileName: $fileName"  
      }

      $filePath = Join-Path -Path $daprScriptsPath -ChildPath $fileName
      if ($dbg) {
        Write-Host "    Scriptpath: $($filePath)"  
      }
   
      $fileOuts = @()
      $fileOuts += 'title ' + $jobName
      $fileOuts += 'start ' + $cmd
      # $fileOuts += $cmd
      $fileOuts | Set-Content $filePath

      $sumOuts += 'start ' + $fileName
    }
  }
  
  $sumOuts | Set-Content (Join-Path $daprScriptsPath 'run-all.cmd')

  @(
    'title dapr dashboard',
    'dapr dashboard'
  ) | Set-Content (Join-Path $daprScriptsPath 'dashboard.cmd')


}


# --------------------------------------------------------------------------------
if ($startJobs -or $stopJobs) {
  "-" * 80
  Write-Host 'Stopping Jobs'
  # Get-Job | Where-Object { $_.Name -match $jobNamePattern } | Stop-Job -PassThru | Remove-Job | Out-Host
  Get-Job | Stop-Job -PassThru | Remove-Job | Out-Host
}

# --------------------------------------------------------------------------------
if ($startJobs) {
  "-" * 80
  Write-Host 'Starting Jobs'


  foreach ($proj in $projects) {  
    if ($dbg) {
      Write-Host "  Project: $($proj.name)"  
    }
  
    foreach ($j in $proj.jobs) {
      $cmd = $j.cmd
      $jobName = $j.jobName
      $jobTyp = $j.typ

      # if ($dbg) {
      #   Write-Host "   $jobName"  
      # }

      Write-Host "    Start Job: $jobTyp $jobName"

      if ($jobTyp -eq "dapr") {
        Start-Job -Name $jobName -ScriptBlock {

          param( $appId, $appPort, $daprHttpPort, $daprGrpcPort, $daprPlacementPort, $metricsPort, $componentsPath, $configFile)
    
          dapr run --app-id $appId  `
            --app-port $appPort `
            --placement-host-address "localhost:$daprPlacementPort" `
            --log-level debug `
            --components-path $componentsPath `
            --dapr-http-port $daprHttpPort `
            --dapr-grpc-port $daprGrpcPort `
            --metrics-port $metricsPort `
            --config $configFile
    
        } -Argument $proj.appId, $proj.appPort, $proj.daprHttpPort, $proj.daprGrpcPort, $daprPlacementPort, $proj.metricsPort, $componentsPath, $configFile
    
  
      }

      if ($jobTyp -eq "dotnet-run") {
        Start-Job -Name $jobName -ScriptBlock {
          param($projectFile, $launchProfile)
  
          # dotnet run --project $projectFile --urls $env:ASPNETCORE_URLS --launch-profile $launchProfile # --property DAPR_DEV=true
          # dotnet run --project $projectFile --launch-profile $launchProfile --property:DAPR_DEV=true --property:DAPR_DEV_INST=X$id
          dotnet run --project $projectFile --launch-profile $launchProfile --no-build
  
        } -Argument $proj.projectFile, $proj.settingName
      }
    
    }

  }
}
# --------------------------------------------------------------------------------
if ($showJobs) {
  "-" * 80
  Write-Host 'Showing Jobs'

  Get-Job | Where-Object { $_.Name -match $jobNamePattern } | Format-Table Name, State

  "-" * 80
  $jobs = Get-Job | Where-Object { $_.Name -match $jobNamePattern }
  foreach ($job in $jobs) {

    $errors = $null
    Write-Host $job
    if ($job -match "-app$") {
      $errors = (Receive-Job -Name $job.Name -Keep) -match "(error|fail)\:"
    }
    else {
      $errors = (Receive-Job -Name $job.Name -Keep) -match "level\=error"
    }

    if ($errors) {
      "-" * 80
      Write-Host "ERROR IN JOB:" $job.Name -ForegroundColor Red
      $errors
    }
    "-" * 80
  }
  # Get-Job | Format-Table Name, State

}

# --------------------------------------------------------------------------------
if ($clean) {
  "-" * 80
  Write-Host 'Starting clean'
  Get-ChildItem -Recurse -Include 'bin', 'bin2', 'obj', 'TestResults' -Path .\ |
  ForEach-Object {
    Remove-Item $_.FullName -recurse -force
    Write-Host deleted $_.FullName
  }
}

# --------------------------------------------------------------------------------
if ($daprInit) {
  "-" * 80
  Write-Host 'Starting dapr init slim'
  resetError
  dapr uninstall

  checkError
  dapr init --slim
  checkError
}

# --------------------------------------------------------------------------------
if ($build) {
  "-" * 80
  Write-Host 'Starting build'
  runX -cmd 'dotnet' -argsarr @('restore')
  runX -cmd 'dotnet' -argsarr @('build', $solutionFile  )
}

# --------------------------------------------------------------------------------
if ($tyeRun) {
  "-" * 80
  Write-Host 'Starting tye run'
  runX -cmd 'dotnet' -argsarr @('restore')

  $ar = @('tye', 'run', '--watch') #, '--logs seq')
  runX -cmd 'dotnet' -argsarr $ar
}

# --------------------------------------------------------------------------------
if ($composeUp) {
  "-" * 80
  Write-Host 'Docker Compose Up' 
  runX -cmd 'docker' -argsarr @('compose', 'up', '--detach')
}

# --------------------------------------------------------------------------------
if ($composeDown) {
  "-" * 80
  Write-Host 'Docker Compose Down'
  runX -cmd 'docker' -argsarr @('compose', 'down', '--remove-orphans')
}
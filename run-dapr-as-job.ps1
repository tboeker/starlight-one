# pre-requisites:
# - initialized with: dapr init --slim
#   so that redis is running as container and placement service is started on demand

# inspired by: https://raw.githubusercontent.com/KaiWalter/dapr-experimental/master/app2app/startDaprAsJob.ps1

# --------------------------------------------------------------------------------
# project / service configuration
# - appId       = needs to be Dapr id commonly used to address service
# - folder      = relative folder of .NET project (containing components folder and tracing.yaml)
# - projectFile = name of service project file
# - settingName = name of launch setting (Launch:Project; not IIS Express) which is
#                 modified for startup
# - debug       = $true  : no background instance is started; waiting for (debugging)
#                          instance started from VS
#                 $false : background instance of service is started with dotnet run

[Cmdletbinding()]
Param(
  [switch] $skipRun
  , [switch] $dryRun
  , [string] $skipAppId
  , [switch] $skipBuild

)

$host.ui.RawUI.WindowTitle = 'starlight-one-dapr'

$configProjects = @(
  @{
    appId       = "starships-command-api"
    folder      = "./src/Starships/src/Starships.Command.Api"
    projectFile = "Starships.Command.Api.csproj"
    settingName = "Starships.Command.Api"
    debug       = $false
  },
  @{
    appId       = "starships-command-service"
    folder      = "./src/Starships/src/Starships.Command.Service"
    projectFile = "Starships.Command.Service.csproj"
    settingName = "Starships.Command.Service"
    debug       = $false
  },
  @{
    appId       = "starships-query-api"
    folder      = "./src/Starships/src/Starships.Query.Api"
    projectFile = "Starships.Query.Api.csproj"
    settingName = "Starships.Query.Api"
    debug       = $false
  },
  @{
    appId       = "starships-query-service"
    folder      = "./src/Starships/src/Starships.Query.Service"
    projectFile = "Starships.Query.Service.csproj"
    settingName = "Starships.Query.Service"
    debug       = $false
  }
)

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
# INIT

$ErrorActionPreference = "Stop"

# check environment and files (implicitly with -Resolve)
foreach ($configProject in $configProjects) {
  $projectFile = Join-Path $configProject.folder $configProject.projectFile -Resolve
  $launchSettingsFile = Join-Path $configProject.folder "Properties/launchSettings.json" -Resolve
  $componentsPath = Join-Path './dapr' 'components/' -Resolve
  $configFile = Join-Path './dapr' 'config.yaml' -Resolve
}

# stop and remove previous jobs
$jobNamePattern = $configProjects | Join-String -Property appId -Separator "|" -OutputPrefix "(placement|" -OutputSuffix ")"
# Get-Job | Write-Host $_.Name

if ($dryRun) {

}
else {
  Write-Host "Removing previous Jobs" 
  Get-Job | ? { $_.Name -match $jobNamePattern } | Stop-Job -PassThru | Remove-Job | Out-Host
}

if ($skipRun) {
  return
}

if ($skipBuild) {

}
else {
  if ($dryRun) {

  }
  else {
    Write-Host "Running dotnet build" 
    dotnet build --verbosity quiet --nologo    
  }
}

# --------------------------------------------------------------------------------
# MAIN

$jobs = @()

$cmds = @()

# start placement service/job
$DAPR_PLACEMENT_PORT = 50006
# $jobName = "placement"
# Start-Job -Name $jobName -ScriptBlock {
#     param( $port )

#     C:\Dapr\placement.exe --port $port

# } -Argument $DAPR_PLACEMENT_PORT
# $jobs += $jobName

# start jobs for app and dapr sidecar
$DAPR_HTTP_PORT = 3500
$DAPR_GRPC_PORT = 50001
$METRICS_PORT = 9091
$APP_PORT = 5000

foreach ($configProject in $configProjects) {
  $projectFile = Join-Path $configProject.folder $configProject.projectFile -Resolve
  $launchSettingsFile = Join-Path $configProject.folder "Properties/launchSettings.json" -Resolve
  $configFile = Join-Path './dapr' 'config.yaml' -Resolve
  $componentsPath = Join-Path './dapr' 'components/' -Resolve

  $ASPNETCORE_URLS = "http://localhost:" + $APP_PORT # + ";https://localhost:" + $($APP_PORT + 1)

  $launchSettings = Get-Content $launchSettingsFile | ConvertFrom-Json

  "-" * 80

  foreach ($profile in $launchSettings.profiles.PSObject.Properties) {
      if ($profile.Name -eq $configProject.settingName) {
          Update-EnvironmentVariable $profile.Value.environmentVariables "ASPNETCORE_URLS" $ASPNETCORE_URLS
          Update-EnvironmentVariable $profile.Value.environmentVariables "DAPR_HTTP_PORT" $DAPR_HTTP_PORT.ToString()
          Update-EnvironmentVariable $profile.Value.environmentVariables "DAPR_GRPC_PORT" $DAPR_GRPC_PORT.ToString()
      }
  }

  $launchSettings | ConvertTo-Json -Depth 10 | Set-Content $launchSettingsFile
  Write-Host "Updated" $launchSettingsFile

  $jobName = $configProject.appId + "-daprd"

  Write-Host "Start Daprd in background" $configProject.appId $APP_PORT $env:DAPR_HTTP_PORT $env:DAPR_GRPC_PORT $env:METRICS_PORT
  $cmd = "dapr run --app-id $($configProject.appId) --app-port $APP_PORT --placement-host-address localhost:$DAPR_PLACEMENT_PORT --log-level debug --components-path $componentsPath --dapr-http-port $DAPR_HTTP_PORT --dapr-grpc-port $DAPR_GRPC_PORT --metrics-port $METRICS_PORT --config $configFile"
  Write-Host "  $cmd"
  $cmds += @{ 
    cmd     = $cmd
    jobName = $jobName
  }


  if ($dryRun) {

  }
  else {
    Write-Host "Start Job: $jobName"
    Start-Job -Name $jobName -ScriptBlock {
      param( $appId, $appPort, $DAPR_HTTP_PORT, $DAPR_GRPC_PORT, $DAPR_PLACEMENT_PORT, $METRICS_PORT, $componentsPath, $configFile)

      dapr run --app-id $appId  `
        --app-port $appPort `
        --placement-host-address "localhost:$DAPR_PLACEMENT_PORT" `
        --log-level debug `
        --components-path $componentsPath `
        --dapr-http-port $DAPR_HTTP_PORT `
        --dapr-grpc-port $DAPR_GRPC_PORT `
        --metrics-port $METRICS_PORT `
        --config $configFile

    } -Argument $configProject.appId, $APP_PORT, $DAPR_HTTP_PORT, $DAPR_GRPC_PORT, $DAPR_PLACEMENT_PORT, $METRICS_PORT, $componentsPath, $configFile

  }

  $jobs += $jobName

  if ($configProject.debug -or ($skipAppId -eq $appId)) {
    Write-Host "expecting" $projectFile "to be started from development environment"
  }
  else {
    $jobName = $configProject.appId + "-app"

    $cmd = "dotnet run --project $projectFile --launch-profile $($configProject.settingName) --no-build"
    Write-Host "  $cmd"
    $cmds += @{ 
      cmd     = $cmd
      jobName = $jobName
    }  

    # $workingFolder = Join-Path './' $configProject.folder -Resolve
    # Write-Host "   -WorkingDirectory: $workingFolder"

    if ($dryRun) {

    }
    else {
      Write-Host "Start Job: $jobName"
      Start-Job -Name $jobName -ScriptBlock {
        param($projectFile, $launchProfile, $id)

        # dotnet run --project $projectFile --urls $env:ASPNETCORE_URLS --launch-profile $launchProfile # --property DAPR_DEV=true
        # dotnet run --project $projectFile --launch-profile $launchProfile --property:DAPR_DEV=true --property:DAPR_DEV_INST=X$id
        dotnet run --project $projectFile --launch-profile $launchProfile --no-build

      } -Argument $projectFile, $configProject.settingName, $APP_PORT

    }
    $jobs += $jobName
  }

  $DAPR_HTTP_PORT += 10
  $DAPR_GRPC_PORT += 10
  $APP_PORT += 10
  $METRICS_PORT += 1
}

# --------------------------------------------------------------------------------
# show commands

$cmdDir = './.dapr-run'
if (! (Test-Path -Path $cmdDir)) {
  New-Item -Path $cmdDir -ItemType Directory
}
$cmdFolder = Join-Path . $cmdDir -Resolve

$sumOuts = @()
"-" * 80
foreach ($c in $cmds) {
 
  $jobName = $c.jobName
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

$sumOuts | Set-Content (Join-Path $cmdFolder 'run-all.cmd')

@(
  'title dapr dashboard',
  'dapr dashboard'
) | Set-Content (Join-Path $cmdFolder 'dashboard.cmd')



# "-" * 80
# $fileOuts = @()
# foreach ($cmd in $cmds) {
#   $fileOuts += $cmd
#   # Write-Host $cmd1  
# }
# $fileOuts | Set-Content './temp-run-dapr2.txt'

# --------------------------------------------------------------------------------
# handle menu
if ($dryRun) {

}
else {
  $running = $true

  while ($running) {
    "-" * 80
    Write-Host "t: test call health endpoint"
    Write-Host "s: job status"
    Write-Host "e: check all logs for errors"
    Write-Host "q: stop jobs and quit"
    $jobId = 0
    foreach ($job in $jobs) {
      Write-Host $($jobId.ToString() + ": show log of " + $job)
      $jobId += 1
    }

    $option = Read-Host "Enter option"

    switch ($option.ToUpper()) {
      "T" {
        # "-" * 80
        # Write-Host "App1 health"
        # Invoke-RestMethod -Method Get -Uri "http://localhost:3500/v1.0/invoke/app1/method/health"
        # Write-Host "App2 health (through App1)"
        # Invoke-RestMethod -Method Get -Uri "http://localhost:3500/v1.0/invoke/app1/method/healthapp2"

        foreach ($job in $jobs) {
          Write-Host $job
          Receive-Job -Name $job -Keep
        }
      }
      "S" {
        Get-Job | ? { $_.Name -match $jobNamePattern } | Format-Table Name, State
      }
      "E" {
        foreach ($job in $jobs) {
          $errors = $null
          Write-Host $job
          if ($job -match "-app$") {
            $errors = (Receive-Job -Name $job -Keep) -match "(error|fail)\:"
          }
          else {
            $errors = (Receive-Job -Name $job -Keep) -match "level\=error"
          }

          if ($errors) {
            "-" * 80
            Write-Host "ERROR IN JOB:" $job -ForegroundColor Red
            $errors
          }
        }
      }
      "Q" {
        Get-Job | ? { $_.Name -match $jobNamePattern } | Stop-Job -PassThru | Remove-Job
        $running = $false
      }
      default {
        if ([int32]::TryParse($option , [ref]$jobId )) {
          if ($jobId -ge 0 -and $jobId -lt $jobs.Count) {
            Receive-Job -Name $jobs[$jobId] -Keep | code -
          }
        }
      }
    }
  }
}
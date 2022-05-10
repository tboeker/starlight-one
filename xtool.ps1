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

resetError

$bdir = Get-Location

if ($PSScriptRoot) {
  $bdir = $PSScriptRoot
}

$path = [System.IO.Path]::Combine($bdir,'scripts','xtool.psm1')
Write-Host 'Module Path:' $path

$x = Get-Module -Name 'xtool'
checkError

if ($x) {
  Write-Host 'Removing Module'
  Remove-Module -Name 'xtool'
  checkError
}

Write-Host 'Importing Module'
Import-Module $path
checkError

# --------------------------------------------------------------------------------

$mydebug = $false
if ($dbg) {
  $mydebug = $true
}
$DebugPreference
# --------------------------------------------------------------------------------

$host.ui.RawUI.WindowTitle = 'starlight-one-xtool'
$solutionFile = 'starlight-one.sln'
$solutionFilePath = Join-Path '.' $solutionFile -Resolve
[array] $projects = ReadProjects -dbg $mydebug
$daprPlacementPort = 50006
$configFilePath = Join-Path './dapr' 'config.yaml' -Resolve
$componentsPath = Join-Path './dapr' 'components/' -Resolve
$daprScriptsPath = Join-Path '.' '.dapr-run'



# --------------------------------------------------------------------------------
# if ($true) {
#   resetError
#   "-" * 80
#   $daprHttpPort = 3500
#   $daprGrpcPort = 50001
#   $metricsPort = 9091
#   $appPort = 5000
#   Write-Host 'Loadings Projects'
#   $files = Get-ChildItem -Path './src' -Filter 'launchSettings.json' -Recurse -Depth 99;
#   $file = $files[0]

#   foreach ($file in $files) {    
#     $projDir = $file.Directory.Parent
#     if ($dbg) { Write-Debug "  Project Dir: $($projDir.FullName)" }
#     $projectName = $projDir.Name
#     $projFileName = "$($projectName).csproj"
#     $projFile = Join-Path $projDir.FullName $projFileName -Resolve   
#     $projFileItem = Get-Item -Path $projFile

#     $proj = @{
#       appId              = $projectName.Replace('.', '-').ToLowerInvariant()
#       projectFolder      = $projDir.FullName
#       projectFile        = $projFileItem.FullName
#       settingName        = $projDir.Name
#       launchSettingsFile = $file.FullName
#       name               = $projectName
#       urls               = "http://localhost:" + $appPort # + ";https://localhost:" + $($appPort + 1)
#       appPort            = $appPort.ToString()
#       daprHttpPort       = $daprHttpPort.ToString()
#       daprGrpcPort       = $daprGrpcPort.ToString()
#       metricsPort        = $metricsPort.ToString()
#       jobs               = @()
#     }
    
#     $daprHttpPort += 10
#     $daprGrpcPort += 10
#     $appPort += 10
#     $metricsPort += 1

#     $jobName = $proj.appId + "-dapr"
#     $cmd = "dapr run --app-id $($proj.appId) --app-port $($proj.appPort) --placement-host-address localhost:$daprPlacementPort --log-level debug --components-path $componentsPath --dapr-http-port $($proj.daprHttpPort) --dapr-grpc-port $($proj.daprGrpcPort) --metrics-port $metricsPort --config $configFilePath"

#     $proj.jobs += @{
#       cmd     = $cmd
#       jobName = $jobName
#       typ     = "dapr"
#     }

#     if ($skipAppId -eq $proj.appId) {
#       Write-Host "expecting" $($proj.projectFile) "to be started from development environment"
#     }
#     else {
#       $jobName = $proj.appId + "-app"
#       $cmd = "dotnet run --project $($proj.projectFile) --launch-profile $($proj.settingName) --no-build"
#       $proj.jobs += @{
#         cmd     = $cmd
#         jobName = $jobName
#         typ     = "dotnet-run"
#       }  
#     }

#     $projects += $proj
#   }

#   checkError
#   Write-Host "$($projects.Count) Projects found"
# }


# $jobNamePattern = $projects | Join-String -Property appId -Separator "|" -OutputPrefix "(placement|" -OutputSuffix ")"

# # --------------------------------------------------------------------------------
# if ($dbg) {
#   "-" * 80
#   foreach ($proj in $projects) {  
#     $proj | ConvertTo-Json | Out-Host
#   }
# }

# --------------------------------------------------------------------------------
if ($updatelaunchSettings) {
  UpdateLaunchSettings -dbg $mydebug -projects $projects -ingress $false
  checkError
}

# --------------------------------------------------------------------------------
if ($writeDaprScripts) {
  $daprScriptsPath = Join-Path '.' '.dapr-run'
  WriteDaprScripts -projects $projects -dir $daprScriptsPath -dbg $mydebug -daprPlacementPort $daprPlacementPort -componentsPath $componentsPath -configFilePath $configFilePath
}


# --------------------------------------------------------------------------------
if ($startJobs -or $stopJobs) {
  # "-" * 80
  # Write-Host 'Stopping Jobs'
  # # Get-Job | Where-Object { $_.Name -match $jobNamePattern } | Stop-Job -PassThru | Remove-Job | Out-Host
  # Get-Job | Stop-Job -PassThru | Remove-Job | Out-Host
}

# --------------------------------------------------------------------------------
if ($startJobs) {
  # "-" * 80
  # Write-Host 'Starting Jobs'


  # foreach ($proj in $projects) {  
  #   if ($dbg) {
  #     Write-Host "  Project: $($proj.name)"  
  #   }
  
  #   foreach ($j in $proj.jobs) {
  #     $cmd = $j.cmd
  #     $jobName = $j.jobName
  #     $jobTyp = $j.typ

  #     # if ($dbg) {
  #     #   Write-Host "   $jobName"  
  #     # }

  #     Write-Host "    Start Job: $jobTyp $jobName"

  #     if ($jobTyp -eq "dapr") {
  #       Start-Job -Name $jobName -ScriptBlock {

  #         param( $appId, $appPort, $daprHttpPort, $daprGrpcPort, $daprPlacementPort, $metricsPort, $componentsPath, $configFile)
    
  #         dapr run --app-id $appId  `
  #           --app-port $appPort `
  #           --placement-host-address "localhost:$daprPlacementPort" `
  #           --log-level debug `
  #           --components-path $componentsPath `
  #           --dapr-http-port $daprHttpPort `
  #           --dapr-grpc-port $daprGrpcPort `
  #           --metrics-port $metricsPort `
  #           --config $configFile
    
  #       } -Argument $proj.appId, $proj.appPort, $proj.daprHttpPort, $proj.daprGrpcPort, $daprPlacementPort, $proj.metricsPort, $componentsPath, $configFile
    
  
  #     }

  #     if ($jobTyp -eq "dotnet-run") {
  #       Start-Job -Name $jobName -ScriptBlock {
  #         param($projectFile, $launchProfile)
  
  #         # dotnet run --project $projectFile --urls $env:ASPNETCORE_URLS --launch-profile $launchProfile # --property DAPR_DEV=true
  #         # dotnet run --project $projectFile --launch-profile $launchProfile --property:DAPR_DEV=true --property:DAPR_DEV_INST=X$id
  #         dotnet run --project $projectFile --launch-profile $launchProfile --no-build
  
  #       } -Argument $proj.projectFile, $proj.settingName
  #     }
    
  #   }

  # }
}
# --------------------------------------------------------------------------------
if ($showJobs) {
  # "-" * 80
  # Write-Host 'Showing Jobs'

  # Get-Job | Where-Object { $_.Name -match $jobNamePattern } | Format-Table Name, State

  # "-" * 80
  # $jobs = Get-Job | Where-Object { $_.Name -match $jobNamePattern }
  # foreach ($job in $jobs) {

  #   $errors = $null
  #   Write-Host $job
  #   if ($job -match "-app$") {
  #     $errors = (Receive-Job -Name $job.Name -Keep) -match "(error|fail)\:"
  #   }
  #   else {
  #     $errors = (Receive-Job -Name $job.Name -Keep) -match "level\=error"
  #   }

  #   if ($errors) {
  #     "-" * 80
  #     Write-Host "ERROR IN JOB:" $job.Name -ForegroundColor Red
  #     $errors
  #   }
  #   "-" * 80
  # }
  # # Get-Job | Format-Table Name, State

}

# --------------------------------------------------------------------------------
if ($clean) {
  CleanUp
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
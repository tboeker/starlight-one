
$jobNamePattern = $projects | Join-String -Property appId -Separator "|" -OutputPrefix "(placement|" -OutputSuffix ")"

function ShowJobs() {
  Write-Host ("-" * 80)
  Write-Host "ShowJobs"
  Write-Host ("-" * 80)  

  Get-Job | Where-Object { $_.Name -match $jobNamePattern } | Format-Table Name, State

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
      Write-Host ("-" * 80)
      Write-Host "ERROR IN JOB:" $job.Name -ForegroundColor Red
      $errors
    }
    Write-Host ("-" * 80)
  }

}

function StopJobs() {
  Write-Host ("-" * 80)
  Write-Host "StopJobs"
  Write-Host ("-" * 80)  

  Get-Job | Stop-Job -PassThru | Remove-Job | Out-Host

}

function StartDaprJobs() {
  [Cmdletbinding()]
  Param(
    [array] $projects,
    [switch] $dbg,
    [string] $dir,
    $placementPort,
    $configFile
  )     

  Write-Host ("-" * 80)
  Write-Host "StartDaprJobs dbg:$($dbg)"
  Write-Host ("-" * 80)  


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

          param( $appId, $appPort, $daprHttpPort, $daprGrpcPort, $placementPort, $metricsPort, $componentsPath, $configFile)
    
          dapr run --app-id $appId  `
            --app-port $appPort `
            --placement-host-address "localhost:$placementPort" `
            --log-level debug `
            --components-path $componentsPath `
            --dapr-http-port $daprHttpPort `
            --dapr-grpc-port $daprGrpcPort `
            --metrics-port $metricsPort `
            --config $configFile
    
        } -Argument $proj.appId, $proj.appPort, $proj.daprHttpPort, $proj.daprGrpcPort, $placementPort, $proj.metricsPort, $componentsPath, $configFile
    
  
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
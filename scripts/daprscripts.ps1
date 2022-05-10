function WriteDaprScripts() {
  [Cmdletbinding()]
  Param(
    [array] $projects,
    [bool] $dbg = $false,
    [string] $dir,
    [string] $daprPlacementPort,
    [string] $componentsPath,
    # [string] $metricsPort,
    [string] $configFilePath
  )     

  Write-Host ("-" * 80)
  Write-Host "WriteDaprScripts dbg:$($dbg)"
  Write-Host ("-" * 80)  


  Write-Host 'Writing dapr files'
  if ($dbg) {
    Write-Host "  daprScriptsDir: $($dir)"  
  }
  if (! (Test-Path -Path $dir)) {
    New-Item -Path $dir -ItemType Directory
  }
 
  $sumOuts = @()
  $sumOuts2 = @()

  Write-Host ("-" * 80)

  # $sumOuts += "dotnet build $($solutionFilePath)"
  # $sumOuts2 += "dotnet build $($solutionFilePath)"

  foreach ($proj in $projects) {  
    if ($dbg) {
      Write-Host "  $($proj.name)"  
    }
  
    # foreach ($j in $proj.jobs) {
      
      $jobName = $proj.appId + "-dapr"
      $cmd = "dapr run --app-id $($proj.appId) --app-port $($proj.appPort) --placement-host-address localhost:$daprPlacementPort --log-level debug --components-path $componentsPath --dapr-http-port $($proj.daprHttpPort) --dapr-grpc-port $($proj.daprGrpcPort) --metrics-port $($proj.metricsPort) --config $configFilePath"
     
      $cmd2 = "dapr run --app-id $($proj.appId) --app-port $($proj.appPort) --placement-host-address localhost:$daprPlacementPort --log-level debug --components-path ./dapr/components --dapr-http-port $($proj.daprHttpPort) --dapr-grpc-port $($proj.daprGrpcPort) --metrics-port $($proj.metricsPort) --config ./dapr/config.yaml & \"
   
      if ($dbg) { Write-Host "    Job: $($jobName) Cmd: $($cmd)" }
      $sumOuts2 += $cmd2
    #   $proj.jobs += @{
    #   cmd     = $cmd
    #   jobName = $jobName
    #   typ     = "dapr"
    # }


      # $cmd = $j.cmd
      # $jobName = $j.jobName

      # if ($dbg) {
      #   Write-Host "   $jobName"  
      # }
        
      $fileName = $jobName + '.cmd'
      if ($dbg) {
        Write-Host "    fileName: $fileName"  
      }

      $filePath = Join-Path -Path $dir -ChildPath $fileName
      if ($dbg) {
        Write-Host "    Scriptpath: $($filePath)"  
      }
   
      $fileOuts = @()
      $fileOuts += 'title ' + $jobName
      # $fileOuts += 'start ' + $cmd
      $fileOuts += $cmd
      $fileOuts | Set-Content $filePath

      $sumOuts += 'start ' + $fileName
    }
  # }
  
  $sumOuts | Set-Content (Join-Path $dir 'run-all.cmd')
  $sumOuts2 | Set-Content (Join-Path $dir 'run2.txt')

  @(
    'title dapr dashboard',
    'dapr dashboard'
  ) | Set-Content (Join-Path $dir 'dashboard.cmd')

}
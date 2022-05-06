# [Cmdletbinding()]
# Param(
#   [switch] $dbg  
# )

function ReadProjects() {
  [Cmdletbinding()]
  Param(
    [switch] $dbg  
  ) 

  Write-Host ("-" * 80)
  Write-Host "ReadProjects dbg:$($dbg)"
  Write-Host ("-" * 80)
  
  [array] $projects = @()

  $daprHttpPort = 3500
  $daprGrpcPort = 50001
  $metricsPort = 9091
  $appPort = 5000

  Write-Host 'Loadings Projects'
  $files = Get-ChildItem -Path './src' -Filter 'launchSettings.json' -Recurse -Depth 99;
  $file = $files[0]

  foreach ($file in $files) {    
    $projDir = $file.Directory.Parent
    if ($dbg) { Write-Host "  Project Dir: $($projDir.FullName)" }
    $projectName = $projDir.Name
    $projFileName = "$($projectName).csproj"
    $projFile = Join-Path $projDir.FullName $projFileName -Resolve   
    $projFileItem = Get-Item -Path $projFile
    $appId = $projectName.Replace('.', '-').ToLowerInvariant()
    $appIdParts = $appId.Split('-');
    $isApi = ($appIdParts.Count -eq 3) -and ($appIdParts[2] -eq 'api')

    $proj = @{
      appId              = $appId
      appIdParts         = $appIdParts
      isApi              = $isApi
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
 
    for ($i = 0; $i -lt $appIdParts.Count; $i++) {
      $m = "appIdPart$i"
      # Write-Host $m
      $proj |  Add-Member -MemberType NoteProperty -Name $m -Value $appIdParts[$i]
    }
    
    # if ( ($appIdParts.Count -eq 3) -and ($appIdParts[2] -eq 'api') ) {
    #   $proj.isApi = true
    # }

    if ($dbg) { Write-Host "    AppId: $($proj.appId)" }

    $daprHttpPort += 10
    $daprGrpcPort += 10
    $appPort += 10
    $metricsPort += 1

    $jobName = $proj.appId + "-dapr"
    $cmd = "dapr run --app-id $($proj.appId) --app-port $($proj.appPort) --placement-host-address localhost:$daprPlacementPort --log-level debug --components-path $componentsPath --dapr-http-port $($proj.daprHttpPort) --dapr-grpc-port $($proj.daprGrpcPort) --metrics-port $metricsPort --config $configFilePath"
    if ($dbg) { Write-Host "    Job: $($jobName) Cmd: $($cmd)" }

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
      if ($dbg) { Write-Host "    Job: $($jobName) Cmd: $($cmd)" }
      $proj.jobs += @{
        cmd     = $cmd
        jobName = $jobName
        typ     = "dotnet-run"
      }  
    }

    $projects += $proj
  }

  # checkError
  Write-Host "$($projects.Count) Projects found"

  Write-Output $projects

}


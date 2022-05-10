
# helper function : update environment variable in launch setting
function UpdateEnvironmentVariable ($environmentVariables, $name, $value) {
  $m = $environmentVariables | Get-Member $name
  if ($m) {
    $environmentVariables.PSObject.Properties.Remove($name)
  }
  $environmentVariables | Add-Member -MemberType NoteProperty -Name $name -Value $value
}


function UpdateLaunchSettings() {
  [Cmdletbinding()]
  Param(
    [array] $projects,
    [bool] $dbg = $false,
    [bool] $ingress = $false
  )     

  Write-Host ("-" * 80)
  Write-Host "UpdateLaunchSettings dbg: $($dbg)"
  Write-Host ("-" * 80)  

  foreach ($proj in $projects) {
    $launchSettingsFile = $proj.launchSettingsFile

    if ($dbg) {
      Write-Host "  $($proj.name) |  $($proj.settingName) | $launchSettingsFile"  
    }

    $launchSettings = Get-Content $launchSettingsFile | ConvertFrom-Json

    foreach ($profile in $launchSettings.profiles.PSObject.Properties) {
      if ($profile.Name -eq $proj.settingName) {
        UpdateEnvironmentVariable $profile.Value.environmentVariables "ASPNETCORE_URLS" $proj.urls
        UpdateEnvironmentVariable $profile.Value.environmentVariables "DAPR_HTTP_PORT" $proj.daprHttpPort
        UpdateEnvironmentVariable $profile.Value.environmentVariables "DAPR_GRPC_PORT" $proj.daprGrpcPort

        if ($proj.isApi) {
          #  "Ingress__PathBase": "/api/starships/command"
          $ingressPath = "/$($proj.appIdParts[2])/$($proj.appIdParts[0])/$($proj.appIdParts[1])"
          UpdateEnvironmentVariable $profile.Value.environmentVariables "Ingress__PathBase" $ingressPath

          UpdateEnvironmentVariable $profile.Value.environmentVariables "Ingress__Enabled" $ingress.ToString().ToLowerInvariant()

          # if ($ingress) {           
          #   UpdateEnvironmentVariable $profile.Value.environmentVariables "Ingress__Enabled" $true
          # } else {
          #   UpdateEnvironmentVariable $profile.Value.environmentVariables "Ingress__Enabled" $false
          # }
        }
      }    
    }

    $launchSettings | ConvertTo-Json -Depth 10 | Set-Content $launchSettingsFile
    if ($dbg) {
      Write-Host "  Updated" $launchSettingsFile
    }
  }
  
}

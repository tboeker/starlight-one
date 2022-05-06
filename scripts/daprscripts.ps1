function WriteDaprScripts() {
  [Cmdletbinding()]
  Param(
    [array] $projects,
    [switch] $dbg,
    [string] $dir
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

      $filePath = Join-Path -Path $dir -ChildPath $fileName
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
  
  $sumOuts | Set-Content (Join-Path $dir 'run-all.cmd')

  @(
    'title dapr dashboard',
    'dapr dashboard'
  ) | Set-Content (Join-Path $dir 'dashboard.cmd')

}
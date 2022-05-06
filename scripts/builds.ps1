function CleanUp() {

  Write-Host ("-" * 80)
  Write-Host "CleanUp"
  Write-Host ("-" * 80)  

  Get-ChildItem -Recurse -Include 'bin', 'bin2', 'obj', 'TestResults' -Path .\ |
  ForEach-Object {
    Remove-Item $_.FullName -recurse -force
    Write-Host deleted $_.FullName
  }

}
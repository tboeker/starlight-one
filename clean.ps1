Get-ChildItem -Recurse -Include 'bin', 'bin2', 'obj', 'TestResults' -Path .\ |
ForEach-Object {
  Remove-Item $_.FullName -recurse -force
  Write-Host deleted $_.FullName
}
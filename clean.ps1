Get-ChildItem -Recurse -Include 'bin', 'obj', 'TestResults' -Path .\ |
ForEach-Object {
  Remove-Item $_.FullName -recurse -force
  Write-Host deleted $_.FullName
}
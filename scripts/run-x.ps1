function runX() {
  [Cmdletbinding()] param([string] $cmd, [array] $argsarr) 
  resetError
  if ($argsarr) {
    Write-Host '  Run with args:' $cmd $argsarr
    & $cmd $argsarr
  }
  else {
    Write-Host '  Run:' $cmd
    & $cmd
  }  
  checkError
}
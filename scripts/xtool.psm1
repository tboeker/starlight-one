# https://matthewjdegarmo.com/powershell/2020/08/03/how-to-organize-your-powershell-functions-into-a-module-part-2.html
Write-Host "::xtool init"

$files = [System.IO.Path]::Combine($PSScriptRoot,"*.ps1")
Get-ChildItem -Path $files -Exclude *.tests.ps1, *profile.ps1 | ForEach-Object {
    try {
      Write-Host ':: xtool loading:' $_.FullName
        . $_.FullName
    } catch {
        Write-Warning "$($_.Exception.Message)"
    }
}

Write-Host "::xtool ready"

# $PublicFunctionsFiles = [System.IO.Path]::Combine($PSScriptRoot,"Functions","Public","*.ps1")
# Get-ChildItem -Path $PublicFunctionsFiles -Exclude *.tests.ps1, *profile.ps1 | ForEach-Object {
#     try {
#         . $_.FullName
#     } catch {
#         Write-Warning "$($_.Exception.Message)"
#     }
# }

# $PrivateFunctionsFiles = [System.IO.Path]::Combine($PSScriptRoot,"Functions","Private","*.ps1")
# Get-ChildItem -Path $PrivateFunctionsFiles -Exclude *.tests.ps1, *profile.ps1 | ForEach-Object {
#     try {
#         . $_.FullName
#     } catch {
#         Write-Warning "$($_.Exception.Message)"
#     }
# }
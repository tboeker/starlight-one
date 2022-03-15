dotnet build

Push-Location templates/PublicApi
dotnet new --uninstall ./
dotnet new --install ./
Pop-Location
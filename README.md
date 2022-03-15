# Starlight One Demo

Demo App

# App Links

* http://localhost:8000
* http://localhost:8001/swagger
* http://localhost:8001/health
* http://localhost:8001/api/starships/command
* http://localhost:8001/api/starships/query
* http://localhost:5341
* http://localhost:9411

# Development

```
# run application
dotnet tool restore
dotnet tye run --watch
```

```
# build and install project templates
# templates.ps1
dotnet build
dotnet new --uninstall .\
dotnet new --install .\
```

```
# find outdated packages
dotnet list package --outdated --highest-minor
dotnet list package --outdated

# find transitive package references that can be removed.
dotnet snitch

# update versions in file: package-versions.targets
```   

# Used Tools and Links

## dotnet/tye

* https://github.com/dotnet/tye
* https://github.com/dotnet/tye/blob/main/docs/getting_started.md

## dapr

* https://github.com/dapr
* https://docs.dapr.io/getting-started/
* https://docs.dapr.io/operations/hosting/self-hosted/self-hosted-with-docker/

## sdks

* https://github.com/microsoft/MSBuildSdks
* https://github.com/microsoft/MSBuildSdks/tree/main/src/CentralPackageVersions

## dotnet 6 - minimal api

* https://gist.github.com/davidfowl/ff1addd02d239d2d26f4648a06158727
* https://medium.com/geekculture/minimal-apis-in-net-6-a-complete-guide-beginners-advanced-fd64f4da07f5

## dotnet - templates

* https://code-maze.com/dotnet-project-templates-creation/

## framework - eventuous

* https://github.com/eventuous

# Log the Steps

```
dotnet new globaljson
dotnet new nugetconfig
dotnet new gitignore
dotnet new sln
dotnet new tool-manifest

# install tye
dotnet tool install --local Microsoft.Tye --version "0.11.0-alpha.22111.1"

# install snitch
dotnet tool install --local Snitch --version 1.10.0

# install dapr cli
dapr init

dotnet tye run

# cleanup docker images
docker rm -f $(docker ps -aq)
```

```
dotnet new so-public-api --name Starships.CommandApi --output ./src/Starships/src/Starships.CommandApi
dotnet sln .\starlight-one.sln add ./src/Starships/src/Starships.CommandApi

dotnet new so-public-api --name Starships.CommandService --output ./src/Starships/src/Starships.CommandService
dotnet sln .\starlight-one.sln add ./src/Starships/src/Starships.CommandService
```

```
cd src
md Rockets.Query.Api
cd Rockets.Query.Api
dotnet new web
dotnet sln ..\..\starlight-one.sln add .
```


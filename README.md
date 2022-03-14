# Startlight One Demo

Demo App

Inspired By:

* https://github.com/eventuous
* https://github.com/dapr
* https://github.com/dotnet/tye

# Run Application

```
dotnet tool restore
dotnet tye run
```

# Used Tools and Links

## dotnet/tye

* https://github.com/dotnet/tye
* https://github.com/dotnet/tye/blob/main/docs/getting_started.md

## dapr

* https://github.com/dapr
* https://docs.dapr.io/getting-started/

## sdks

* https://github.com/microsoft/MSBuildSdks
* https://github.com/microsoft/MSBuildSdks/tree/main/src/CentralPackageVersions



# Packages

```
# find outdated packages
dotnet list package --outdated --highest-minor
dotnet list package --outdated

# find transitive package references that can be removed.
dotnet snitch

# update versions in file: package-versions.targets

```      

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
```

```
cd src
md Rockets.Query.Api
cd Rockets.Query.Api
dotnet new web
dotnet sln ..\..\starlight-one.sln add .
```


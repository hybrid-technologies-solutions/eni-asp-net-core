FROM mcr.microsoft.com/dotnet/core/sdk:3.1-alpine as build
WORKDIR build
# copie des csprojt pour restauration avec cache
COPY SampleWebApp/SampleWebApp.csproj SampleWebApp/SampleWebApp.csproj 
COPY SampleWebApp.Tests/SampleWebApp.Tests.csproj SampleWebApp.Tests/SampleWebApp.Tests.csproj 
# utilisation du cache pour les packages
RUN dotnet restore SampleWebApp/SampleWebApp.csproj
RUN dotnet restore SampleWebApp.Tests/SampleWebApp.Tests.csproj
COPY . . 
# nettoyage des reliquats de compilations
RUN dotnet clean
# compilation au préalable
RUN dotnet build SampleWebApp/SampleWebApp.csproj -c Release --no-restore
RUN dotnet build SampleWebApp.Tests/SampleWebApp.Tests.csproj -c Debug --no-restore
# publication sans recompilation pour s'assure qu'on utilise bien une et une seule version 
RUN dotnet publish SampleWebApp/SampleWebApp.csproj -c Release -o publish --no-build --no-restore

FROM mcr.microsoft.com/dotnet/core/sdk:3.1-alpine as tests
# installation de l'outil de génération de rapport
RUN dotnet tool install -g dotnet-reportgenerator-globaltool
WORKDIR tests
# copie des binaires
COPY --from=build build .
# lancement des tests avec collecte d'informations
WORKDIR SampleWebApp.Tests
RUN dotnet test --logger trx --results-directory TestResults --collect:"XPlat Code Coverage" 
RUN /root/.dotnet/tools/reportgenerator -targetdir:/TestResults -reports:/tests/SampleWebApp.Tests/TestResults/*/coverage.cobertura.xml "-reporttypes:HTML;HTMLSummary"

FROM mcr.microsoft.com/dotnet/core/aspnet:3.1-buster-slim as web
EXPOSE 80
WORKDIR /app
COPY --from=build /build/publish .
WORKDIR /app/wwwroot/testResults
COPY --from=tests /TestResults .
WORKDIR /app
ENTRYPOINT ["dotnet", "SampleWebApp.dll"]
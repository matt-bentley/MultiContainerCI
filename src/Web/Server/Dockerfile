FROM mcr.microsoft.com/dotnet/aspnet:6.0-bullseye-slim AS base

WORKDIR /app
EXPOSE 80

FROM mcr.microsoft.com/dotnet/sdk:6.0-bullseye-slim AS build

COPY ["src/", "/src/"]

WORKDIR /src/Web/Server
RUN dotnet restore "MultiContainerCI.Web.Server.csproj"

RUN dotnet publish "MultiContainerCI.Web.Server.csproj" --no-restore -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "MultiContainerCI.Web.Server.dll"]
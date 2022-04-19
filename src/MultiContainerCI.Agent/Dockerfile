FROM mcr.microsoft.com/dotnet/runtime:6.0-bullseye-slim AS base

WORKDIR /app

FROM mcr.microsoft.com/dotnet/sdk:6.0-bullseye-slim AS build

COPY ["src/", "/src/"]

WORKDIR /src/MultiContainerCI.Agent
RUN dotnet restore "MultiContainerCI.Agent.csproj"

RUN dotnet publish "MultiContainerCI.Agent.csproj" --no-restore -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "MultiContainerCI.Agent.dll"]
# syntax=docker/dockerfile:1
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
COPY global.json Directory.Build.props .editorconfig SpiritUNITE.slnx ./
COPY src/SpiritUnite.Core/SpiritUnite.Core.csproj src/SpiritUnite.Core/
RUN dotnet restore src/SpiritUnite.Core/SpiritUnite.Core.csproj
COPY src/ src/
# Defaults only; docker-compose.yml overrides bind addresses, hosts and the DB connection via env vars.
RUN cp src/SpiritUnite.Core/appsettings.example.json src/SpiritUnite.Core/appsettings.json \
 && dotnet publish src/SpiritUnite.Core/SpiritUnite.Core.csproj -c Release -o /app --no-restore

FROM mcr.microsoft.com/dotnet/aspnet:10.0
# Run as the host user so the bind-mounted resources/ folder stays writable (the server writes .md5 files there).
ARG HOST_UID=1000
ARG HOST_GID=1000
WORKDIR /app
COPY --from=build --chown=${HOST_UID}:${HOST_GID} /app ./
RUN mkdir -p /app/logs /app/resources && chown ${HOST_UID}:${HOST_GID} /app/logs /app/resources
USER ${HOST_UID}:${HOST_GID}
ENTRYPOINT ["dotnet", "SpiritUnite.Core.dll"]

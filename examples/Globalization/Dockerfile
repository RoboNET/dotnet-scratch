FROM mcr.microsoft.com/dotnet/sdk:6.0 AS prepare
WORKDIR /

#restore
COPY ./Example.sln ./

COPY ./*/*.csproj ./
RUN for file in $(ls *.csproj); do mkdir -p ./${file%.*}/ && mv $file ./${file%.*}/; done

RUN dotnet restore Example.sln

# copy everything else and build app
COPY . ./
RUN dotnet build Example.sln --no-restore


FROM prepare AS build
RUN dotnet build --no-restore -c Release

WORKDIR /Example
RUN dotnet publish --no-restore -c Release -o out

FROM robonet/dotnet-scratch:full-latest AS runtime
WORKDIR /app
COPY --from=build --chown=$USER:$USER /Example/out ./
ENTRYPOINT ["dotnet", "Example.dll"]

# dotnet-scratch
Docker image for dotnet based on scratch without any additional dependencies.

Available images:

# .NET 9
| type     | image |
| -------- | ------- |
| runtime deps  | `robonet/dotnet-scratch:runtime-deps-9`    |
| runtime deps with globalization | `robonet/dotnet-scratch:runtime-deps-globalization-9`     |
| aspnet    | `robonet/dotnet-scratch:aspnet-9`    |
| aspnet with globalization   | `robonet/dotnet-scratch:aspnet-globalization-9`    |

# .NET 8
| type     | image |
| -------- | ------- |
| runtime deps  | `robonet/dotnet-scratch:runtime-deps-8`    |
| runtime deps with globalization | `robonet/dotnet-scratch:runtime-deps-globalization-8`     |
| aspnet    | `robonet/dotnet-scratch:aspnet-8`    |
| aspnet with globalization   | `robonet/dotnet-scratch:aspnet-globalization-8`    |


You can use minimal runtime deps version (`robonet/dotnet-scratch:runtime-deps-9`) if you don't need cultures and timezones and include framework to image manually or use full image (`robonet/dotnet-scratch:aspnet-9`) what include globalization libraries

https://hub.docker.com/r/robonet/dotnet-scratch

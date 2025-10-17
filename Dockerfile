ARG VERSION
# Use dotnet runtime deps to gather all dependencies
FROM mcr.microsoft.com/dotnet/aspnet:${VERSION} AS base-builder

# Create appuser.
ENV USER=dotnet
ENV UID=45432 
# See https://stackoverflow.com/a/55757473/12429735RUN 
RUN adduser \    
    --disabled-password \    
    --gecos "" \    
    --home "/nonexistent" \    
    --shell "/sbin/nologin" \    
    --no-create-home \    
    --uid "${UID}" \    
    "${USER}"

RUN mkdir -p /tmp
RUN chown ${USER} /tmp

FROM base-builder AS builder

# Cleanup /lib
RUN find /lib -type d -empty -delete && \
    rm -r /lib/apk && \
    rm -r /lib/sysctl.d

RUN find / -xdev -perm -4000 -type f -exec chmod a-s {} \;


FROM base-builder AS globalization-builder
RUN apk add --no-cache \
    icu-libs \
    icu-data-full \
    tzdata

# Cleanup /lib
RUN find /lib -type d -empty -delete && \
    rm -r /lib/apk && \
    rm -r /lib/sysctl.d

RUN find / -xdev -perm -4000 -type f -exec chmod a-s {} \;


# Create runtime image
FROM scratch AS runtime-deps
ENV USER=dotnet
ENV UID=45432
ENV DOTNET_ROOT=/.dotnet

ARG TARGETARCH

COPY --from=builder /lib/ /lib
COPY --from=builder /tmp/ /tmp
COPY --from=builder /usr/lib /usr/lib
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/group /etc/group

# chmod hack: extract tmp.tar file with correct flags
# see https://github.com/GoogleContainerTools/distroless/blob/main/base/tmp.tar
ADD tmp.tar .

ENV ASPNETCORE_URLS=http://+:80 \
    DOTNET_RUNNING_IN_CONTAINER=true \
    DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=true \
    TMPDIR=/tmp \
    PATH=$PATH:$DOTNET_ROOT:$DOTNET_ROOT/tools

USER $UID:$UID

# Create runtime image
FROM runtime-deps AS aspnet
COPY --from=builder /usr/share/dotnet $DOTNET_ROOT


# Create runtime image
FROM scratch AS runtime-deps-globalization
ENV USER=dotnet
ENV UID=45432
ENV DOTNET_ROOT=/.dotnet

ARG TARGETARCH

COPY --from=globalization-builder /lib/ /lib
COPY --from=globalization-builder /tmp/ /tmp
COPY --from=globalization-builder /usr/lib /usr/lib
COPY --from=globalization-builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=globalization-builder /usr/share/icu /usr/share/icu
COPY --from=globalization-builder /usr/share/zoneinfo /usr/share/zoneinfo
COPY --from=globalization-builder /etc/passwd /etc/passwd
COPY --from=globalization-builder /etc/group /etc/group

# chmod hack: extract tmp.tar file with correct flags
# see https://github.com/GoogleContainerTools/distroless/blob/main/base/tmp.tar
ADD tmp.tar .

ENV ASPNETCORE_URLS=http://+:80 \
    DOTNET_RUNNING_IN_CONTAINER=true \
    DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false \
    TMPDIR=/tmp \
    PATH=$PATH:$DOTNET_ROOT:$DOTNET_ROOT/tools

USER $UID:$UID

# Create runtime image
FROM runtime-deps-globalization AS aspnet-globalization
COPY --from=globalization-builder /usr/share/dotnet $DOTNET_ROOT

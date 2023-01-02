# Use dotnet runtime deps to gather all dependencies
FROM mcr.microsoft.com/dotnet/runtime-deps:6.0-alpine as base

# Create appuser.
ENV USER=dotnet
ENV UID=245000 
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

# Cleanup /lib
RUN find /lib -type d -empty -delete && \
    rm -r /lib/apk && \
    rm -r /lib/sysctl.d

RUN find / -xdev -perm -4000 -type f -exec chmod a-s {} \;

# Create runtime image
FROM scratch as runtime-full
ENV USER=dotnet
ENV UID=245000 
ARG TARGETARCH
ARG DOTNET_VERSION=6.0.12

COPY --from=base /lib/ /lib
COPY --from=base /tmp/ /tmp
COPY --from=base /usr/lib /usr/lib
COPY --from=base /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=base /etc/passwd /etc/passwd
COPY --from=base /etc/group /etc/group

# chmod hack: extract tmp.tar file with correct flags
# see https://github.com/GoogleContainerTools/distroless/blob/main/base/tmp.tar
ADD tmp.tar .

ENV DOTNET_ROOT=/.dotnet

ADD aspnetcore-runtime-${DOTNET_VERSION}-linux-musl-${TARGETARCH}.tar.gz $DOTNET_ROOT

ENV ASPNETCORE_URLS=http://+:80 \
    DOTNET_RUNNING_IN_CONTAINER=true \
    DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=true \
    TMPDIR=/tmp \
    PATH=$PATH:$DOTNET_ROOT:$DOTNET_ROOT/tools

USER $UID:$UID
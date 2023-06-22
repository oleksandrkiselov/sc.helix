# escape=`

ARG BASE_IMAGE
ARG SOLUTION_IMAGE
ARG TOOLING_IMAGE

FROM ${SOLUTION_IMAGE} as solution
FROM ${TOOLING_IMAGE} as tooling
FROM ${BASE_IMAGE}

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

WORKDIR C:\inetpub\wwwroot

# Add developer tools and entrypoint
COPY --from=tooling C:\tools C:\tools

# Add solution website files
COPY --from=solution /artifacts/sitecore/ ./
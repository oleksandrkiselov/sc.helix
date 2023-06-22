# escape=`

#
# Image for running Next.js in a containerized environment.
# Assumes that the Next.js rendering host source is mounted to c:\frontend.
#

ARG PARENT_IMAGE
ARG SOLUTION_IMAGE

FROM ${SOLUTION_IMAGE} as solution
FROM ${PARENT_IMAGE} as base
USER ContainerAdministrator
## Included these lines to avoid garbage collection errors during npm install
ENV GENERATE_SOURCEMAP false
ENV NODE_OPTIONS=--max-old-space-size=8192
EXPOSE 3000
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

FROM base as debug
USER ContainerAdministrator
WORKDIR /frontend
ENTRYPOINT "npm run start:connected"

FROM base as dependencies
USER ContainerAdministrator
WORKDIR /front-end
COPY --from=solution /artifacts/front-end/package.json /artifacts/front-end/package-lock.json ./ 
RUN npm ci --ignore-scripts --loglevel verbose

FROM base as release
USER ContainerAdministrator
WORKDIR /frontend
ENV NODE_ENV production
ENTRYPOINT "npm run start:production"

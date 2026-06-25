FROM node:24-alpine AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

FROM base AS build
WORKDIR /app
COPY . /app

RUN corepack enable
RUN apk add --no-cache python3 alpine-sdk

# Initialize a dummy git repository to bypass Cobalt's startup checks
RUN git init && git config user.email "bot@railway.app" && git config user.name "Railway" && git commit --allow-empty -m "init bypass"

RUN  pnpm install --frozen-lockfile

RUN pnpm deploy --filter=@imput/cobalt-api --prod /prod/api

FROM base AS api
WORKDIR /app

COPY --from=build --chown=node:node /prod/api /app
# Copy the dummy git folder into the final container
COPY --from=build --chown=node:node /app/.git /app/.git

USER node

EXPOSE 9000
CMD [ "node", "src/cobalt" ]

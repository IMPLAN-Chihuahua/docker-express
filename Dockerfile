FROM node:lts-bookworm AS base

WORKDIR /app

EXPOSE 8080

FROM base AS dev

ENV NODE_ENV=development
ENV YARN_CACHE_FOLDER=/app/.yarn-cache/auth-api

# Solo instala dependencias
COPY package.json yarn.lock ./
RUN yarn install

USER node

CMD ["npm", "run", "dev"]


FROM base AS build

ENV NODE_ENV=production

ENV YARN_CACHE_FOLDER=/app/.yarn-cache/auth-api

RUN --mount=type=bind,source=package.json,target=package.json \
    --mount=type=bind,source=yarn.lock,target=yarn.lock \
    --mount=type=cache,target=${YARN_CACHE_FOLDER} yarn install --frozen-lockfile

COPY . .

RUN yarn add typescript tsc ts-node && yarn build


FROM node:lts-bookworm-slim AS prod

WORKDIR /app

USER node

ENV YARN_CACHE_FOLDER=/app/.yarn-cache/auth-api

COPY --from=build --chown=node:node /app ./

HEALTHCHECK --interval=1m --timeout=3s --retries=5 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8080 || exit 1

CMD ["yarn", "run", "start"]
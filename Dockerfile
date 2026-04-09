FROM node:24-trixie AS base

WORKDIR /app


FROM base AS deps

COPY package.json yarn.lock ./

RUN yarn install --frozen-lockfile --production


FROM deps AS build

COPY --chown=node:node . .

RUN ["npm", "run", "build"]


FROM node:24-trixie-slim AS prod

WORKDIR /app

ENV NODE_ENV=production

COPY --from=deps --chown=node:node /app/node_modules ./node_modules
COPY --from=deps --chown=node:node /app/package.json /app/yarn.lock ./

COPY --from=build --chown=node:node /app/build ./build

RUN mkdir -p ./uploads && chown node:node ./uploads
RUN mkdir -p ./tmp && chown node:node ./tmp

USER node

EXPOSE 8080

HEALTHCHECK --interval=1m --timeout=3s --retries=5 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8080 || exit 1

CMD ["npm", "start"]
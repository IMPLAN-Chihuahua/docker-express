FROM node:lts-alpine AS base
EXPOSE 8080
WORKDIR /app

FROM base as dev
RUN --mount=type=bind,source=package.json,target=package.json \
    --mount=type=bind,source=package-lock.json,target=package-lock.json \
    --mount=type=cache,target=/root/.npm \
    npm ci --include=dev
ENV NODE_ENV=production
USER node
COPY . .
CMD npm run dev

FROM base as prod
RUN --mount=type=bind,source=package.json,target=package.json \
    --mount=type=bind,source=package-lock.json,target=package-lock.json \
    --mount=type=cache,target=/root/.npm \
    npm ci --omit=dev
ENV NODE_ENV=production
USER node
COPY . .
HEALTHCHECK --interval=1m --timeout=3s --retries=5 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8080 || exit 1
CMD npm run start
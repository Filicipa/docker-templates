FROM node:16.20.2-alpine3.18 AS base
RUN npm i -g pnpm

FROM base AS dependencies

WORKDIR /app
COPY .npmrc package.json pnpm-lock.yaml next.config.mjs ./
RUN pnpm install --frozen-lockfile

FROM base AS builder

WORKDIR /app
COPY ./ ./
COPY --from=dependencies /app/node_modules ./node_modules
RUN pnpm build
RUN pnpm prune --prod

FROM base AS runner

WORKDIR /app
COPY .npmrc package.json pnpm-lock.yaml next.config.mjs ./
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules

EXPOSE 3000
CMD ["pnpm", "start"]
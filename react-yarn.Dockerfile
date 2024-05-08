FROM node:16.20.2-alpine3.18 AS dependencies
WORKDIR /app
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

FROM node:16.20.2-alpine3.18 AS builder
WORKDIR /app
COPY . .
COPY --from=dependencies /app/node_modules ./node_modules
RUN yarn build

FROM node:16.20.2-alpine3.18 AS runner

WORKDIR /app

COPY --from=builder /app/next.config.js ./
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json

CMD ["yarn", "start"]


FROM node:20.13.0-alpine3.19 AS builder
WORKDIR /app
COPY ./package*.json ./
RUN npm ci --omit=dev && npm cache clean --force
COPY ./ ./
COPY --from=dependencies /app/node_modules ./node_modules
RUN npm run build

FROM node:20.13.0-alpine3.19 AS runner
WORKDIR /app
COPY --from=builder /app/public ./public
COPY --from=builder /app/build ./build
COPY --from=builder /app/src ./src
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json

CMD ["npm", "run", "start"]
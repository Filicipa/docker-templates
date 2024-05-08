FROM node:20.12.2-alpine3.19 AS builder
WORKDIR /app
COPY package.json next.config.js ./
RUN npm install --force
COPY ./ ./
RUN npm run build

FROM node:20.12.2-alpine3.19 AS runner
WORKDIR /app
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY ./public ./public
COPY ./.env ./
EXPOSE 3000
CMD node server.js
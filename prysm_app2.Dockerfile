FROM node:18-alpine As build

WORKDIR /usr/src/app
COPY --chown=node:node package*.json ./
RUN npm ci
COPY --chown=node:node . .
RUN npm run prisma:generate
RUN npm run build
ENV NODE_ENV production
RUN npm ci --only=production && npm cache clean --force
RUN npm run prisma:generate
USER node

FROM node:18-alpine As production

COPY --chown=node:node --from=build /usr/src/app/libs ./libs
COPY --chown=node:node --from=build /usr/src/app package*.json ./
COPY --chown=node:node --from=build /usr/src/app/node_modules ./node_modules
COPY --chown=node:node --from=build /usr/src/app/dist ./dist

EXPOSE 3000
CMD npm run migrations:prod && npm run start:prod

# ---- build stage ----
FROM node:20-alpine AS build
WORKDIR /app
COPY app/package*.json ./
RUN npm ci
COPY app/ .
RUN npm run build

# ---- runtime stage ----
FROM node:20-alpine AS runtime
WORKDIR /app
ENV NODE_ENV=production
COPY --from=build /app/dist ./dist
COPY --from=build /app/package*.json ./
RUN npm ci --omit=dev
EXPOSE 3000
CMD ["node", "dist/index.js"]

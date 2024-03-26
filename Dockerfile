FROM node:18-alpine AS base
FROM base AS deps
RUN apk add --no-cache libc6-compat g++ cmake tar make
WORKDIR /app
COPY package.json yarn.lock* package-lock.json* pnpm-lock.yaml* ./
RUN npm install
FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN npm run build
FROM nginx:1.19.0 AS runner
WORKDIR /usr/share/nginx/html/app
RUN rm -rf ./*
ENV NODE_ENV production
COPY ./nginx/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=builder /app/dist .
ENTRYPOINT [ "nginx", "-g", "daemon off;" ]
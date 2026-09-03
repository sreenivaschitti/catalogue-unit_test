# ---------- Stage 1 ----------
FROM node:20.20.2-alpine3.23 AS builder

WORKDIR /app

COPY package.json .
COPY *.js .
RUN npm install

# ---------- Stage 2 ----------
FROM gcr.io/distroless/nodejs20-debian13:nonroot

WORKDIR /app

LABEL project="roboshop" \
      service="catalogue" \
      owner="ramu"

EXPOSE 8080

COPY --from=builder /app /app

# ENV removed — handled by Kubernetes ConfigMap


CMD ["server.js"]
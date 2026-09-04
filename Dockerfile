# ---------- Stage 1 ----------
FROM node:24-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm ci --omit=dev

COPY *.js ./


# ---------- Stage 2 ----------
FROM gcr.io/distroless/nodejs24-debian13:nonroot

WORKDIR /app

LABEL project="roboshop" \
      service="catalogue" \
      owner="ramu"

EXPOSE 8080

COPY --from=builder /app /app

CMD ["server.js"]
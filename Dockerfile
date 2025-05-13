# --- Build Stage ---
FROM node:22.14.0-alpine AS builder
WORKDIR /app

# 1. 의존성 설치에 필요한 최소 파일만 복사 (캐시 최적화)
COPY package.json pnpm-lock.yaml ./

# 2. pnpm 설치 및 의존성 설치
RUN corepack enable && corepack prepare pnpm@latest --activate
RUN pnpm install --frozen-lockfile

# 3. 나머지 코드 복사 후 빌드
COPY . .
RUN pnpm build

# --- Final Stage ---
FROM nginx:1.27.4-alpine

# 4. 빌드된 정적 파일만 복사
COPY --from=builder /app/dist /usr/share/nginx/html

# 5. 포트 80 (정적 파일 제공용)
EXPOSE 80

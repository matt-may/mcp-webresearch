# Stage 1: Build
FROM node:18-alpine AS builder

# Install pnpm
RUN npm install -g pnpm

# Create app directory
WORKDIR /app

# Copy project files
COPY . .

# Install dependencies and build the project
RUN pnpm install && pnpm build

# Stage 2: Run
FROM node:18-alpine

# Install Playwright dependencies
RUN apk add --no-cache \
    nss \
    freetype \
    harfbuzz \
    ca-certificates \
    ttf-freefont \
    nodejs \
    yarn

# Install Playwright
RUN npm install -g playwright && playwright install chromium

# Create app directory
WORKDIR /app

# Copy built files and node_modules from builder
COPY --from=builder /app/dist /app/dist
COPY --from=builder /app/node_modules /app/node_modules
COPY --from=builder /app/package.json /app/package.json

# Set environment variables
ENV NODE_ENV=production

# Entry point for the MCP server
ENTRYPOINT ["node", "dist/index.js"]
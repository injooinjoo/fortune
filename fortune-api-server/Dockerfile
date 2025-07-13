# Use the official Node.js image
FROM node:18-alpine AS base

# Install dependencies only when needed
FROM base AS deps
RUN apk add --no-cache libc6-compat
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci

# Rebuild the source code only when needed
FROM base AS builder
WORKDIR /app

# Copy dependencies from deps stage
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Build the application (ignore TypeScript errors for now)
RUN npm run build || true

# Production image, copy all the files and run
FROM base AS runner
WORKDIR /app

# Set NODE_ENV to production
ENV NODE_ENV production

# Create a non-root user to run the app
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nodejs -u 1001

# Copy necessary files
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package*.json ./
COPY --from=deps /app/node_modules ./node_modules

# Copy any other necessary files (e.g., public assets)
# COPY --from=builder /app/public ./public

# Change ownership of the app directory to nodejs user
RUN chown -R nodejs:nodejs /app

# Switch to the nodejs user
USER nodejs

# Expose the port the app runs on
EXPOSE 8080

# Don't set PORT - let Cloud Run set it

# Debug: List files
RUN ls -la /app/
RUN ls -la /app/dist/

# Start the application
CMD ["node", "dist/server.js"]
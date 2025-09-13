# Stage 1: Build wombat with Node
FROM node:16-alpine AS builder

# Install build tools
RUN apk add --no-cache git python3 make g++ libc-dev

WORKDIR /opt/womginx

# Copy all project files
COPY . .

# Initialize git and add wombat submodule
RUN rm -rf .git && git init
WORKDIR /opt/womginx/public
RUN rm -rf wombat && git submodule add https://github.com/webrecorder/wombat
WORKDIR /opt/womginx/public/wombat
# Lock wombat to a stable commit
RUN git checkout 78813ad

# Install npm dependencies and build wombat
RUN npm install --legacy-peer-deps
RUN npm run build-prod

# Move build output to a clean folder
RUN mv dist /opt/womginx/dist && rm -rf node_modules .git

# Run docker-sed.sh to modify nginx.conf if needed
WORKDIR /opt/womginx
RUN ./docker-sed.sh

# Stage 2: Serve with Nginx
FROM nginx:stable-alpine

# Copy built files
COPY --from=builder /opt/womginx/dist /usr/share/nginx/html

# Copy nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Remove SSL config lines from nginx.conf if present (prevent errors)
RUN sed -i '/ssl_certificate/d' /etc/nginx/nginx.conf \
    && sed -i '/ssl_certificate_key/d' /etc/nginx/nginx.conf

# Test nginx configuration
RUN nginx -t

# Expose port and start nginx
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]


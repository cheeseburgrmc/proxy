FROM node:16-alpine AS builder

RUN apk add git python3 make g++ libc-dev

WORKDIR /opt/womginx
COPY . .

RUN rm -rf .git && git init
WORKDIR /opt/womginx/public
RUN rm -rf wombat && git submodule add https://github.com/webrecorder/wombat
WORKDIR /opt/womginx/public/wombat
RUN git checkout 78813ad

WORKDIR /opt/womginx
RUN npm install --legacy-peer-deps && npm run build-prod
RUN mv dist /opt/womginx/dist && rm -rf node_modules .git

RUN ./docker-sed.sh

# final Nginx stage
FROM nginx:stable-alpine
COPY --from=builder /opt/womginx/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf
RUN nginx -t

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]

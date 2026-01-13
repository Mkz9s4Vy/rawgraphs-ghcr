# Dockerfile
# 使用 Node.js 23.6.1 作为基础镜像
FROM node:23.6.1-alpine AS builder

# 设置工作目录
WORKDIR /app

# 复制 package.json 和 yarn.lock
COPY package.json yarn.lock ./

# 设置 OpenSSL legacy provider（解决 Node.js 23+ 的兼容性问题）
ENV NODE_OPTIONS=--openssl-legacy-provider

# 安装 yarn（Alpine Linux 需要单独安装）
RUN apk add --no-cache yarn

# 安装依赖
RUN yarn install --frozen-lockfile --network-timeout 600000

# 复制源代码
COPY . .

# 构建应用
RUN yarn build

# 第二阶段：使用 Nginx 提供静态文件
FROM nginx:alpine

# 从构建阶段复制构建文件到 Nginx 目录
COPY --from=builder /app/build /usr/share/nginx/html

# 复制自定义 Nginx 配置
COPY nginx.conf /etc/nginx/conf.d/default.conf

# 暴露端口
EXPOSE 80

# 启动 Nginx
CMD ["nginx", "-g", "daemon off;"]

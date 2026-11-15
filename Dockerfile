
# ============================================
# 第一阶段：构建前端
# ============================================
FROM node:20 AS web_image

WORKDIR /build

# 安装 pnpm
RUN npm install -g pnpm@8.15.9

# 先复制依赖文件，利用 Docker 构建缓存
COPY package.json pnpm-lock.yaml ./

# 安装前端依赖
RUN pnpm install --frozen-lockfile

# 复制项目代码
COPY . .

# 编译前端
RUN pnpm run build


# ============================================
# 第二阶段：构建 Go 后端
# ============================================
FROM golang:1.21-alpine3.18 AS server_image

WORKDIR /build

# 配置 Go 依赖代理
ENV GOPROXY=https://goproxy.cn,direct

# 安装编译依赖
RUN apk add --no-cache \
    bash \
    curl \
    gcc \
    git \
    musl-dev

# 复制后端代码
COPY ./service ./

# 安装资源打包工具并编译后端
RUN go env -w GO111MODULE=on \
    && go install github.com/go-bindata/go-bindata/...@latest \
    && go install github.com/elazarl/go-bindata-assetfs/...@latest \
    && go-bindata-assetfs \
       -o=assets/bindata.go \
       -pkg=assets \
       assets/... \
    && go build \
       -o sun-panel \
       -ldflags="-X sun-panel/global.RUNCODE=release -X sun-panel/global.ISDOCKER=docker" \
       main.go


# ============================================
# 第三阶段：生成最终运行镜像
# ============================================
FROM alpine:3.18

WORKDIR /app

# 安装运行所需依赖
RUN apk add --no-cache \
    bash \
    ca-certificates \
    su-exec \
    tzdata

# 复制前端构建结果
COPY --from=web_image /build/dist /app/web

# 复制后端可执行程序
COPY --from=server_image /build/sun-panel /app/sun-panel

# 设置执行权限
RUN chmod +x /app/sun-panel

# 保留原项目配置初始化步骤
RUN ./sun-panel -config

# 声明服务端口
EXPOSE 3002

# 启动 Sun-Panel
CMD ["./sun-panel"]

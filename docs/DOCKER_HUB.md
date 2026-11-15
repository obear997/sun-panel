# Sun-Panel 拓展版

一个可自托管的 NAS、服务器导航面板，也可作为浏览器首页或内网服务入口。

项目源码：<https://github.com/obear997/sun-panel>

## 项目简介

Sun-Panel 是一个用 Go + Vue 编写的轻量导航面板，把 NAS、家庭服务器或内网中的各类 Web 服务集中到一个页面上管理。适合以下场景：

- 家里或公司有多台设备、多个服务（NAS、路由、监控、媒体库、开发环境），需要一个统一入口
- 想把浏览器首页换成自己的服务导航页
- 需要区分局域网和外网访问地址，按场景一键切换
- 不想额外部署 MySQL、Redis 等外部依赖，希望单容器跑起来

容器内自带 SQLite 数据库，无需连接外部数据库，资源占用小，支持 amd64 与 arm64。

## 功能介绍

- **服务导航**：以图标卡片管理常用网站与服务，支持分组、拖拽排序和搜索
- **内外网地址切换**：同一服务可分别配置局域网与外网地址，一键切换
- **个性化外观**：自定义壁纸、背景遮罩、图标（文字图标 / SVG / 内置三方图标库）、小图标模式
- **系统状态监控**：内置 CPU、内存、磁盘状态组件
- **隐藏图标管理**：图标可设置为不展示，并在「系统应用 → 隐藏图标管理」中按分组查看、批量恢复或批量删除
- **管理与扩展**：上传文件管理、账号管理、配置导入导出、全局自定义 JS/CSS 与页脚
- **轻量部署**：单二进制或单容器运行，无需外部数据库

本项目基于 [hslr-s/sun-panel](https://github.com/hslr-s/sun-panel) **v1.3.0** 版本拓展，完整保留上游功能，并在此基础上增加上述隐藏图标等扩展能力。

## 快速部署

支持 `linux/amd64` 与 `linux/arm64` 两种架构，容器端口固定为 `3002`。

### 方式一：Docker Compose

新建 `docker-compose.yml`：

```yaml
services:
  sun-panel:
    image: lenmontea/sun-panel:latest
    container_name: sun-panel
    volumes:
      - ./conf:/app/conf
      - ./uploads:/app/uploads
      - ./database:/app/database
    ports:
      - 3002:3002
    restart: always
```

在该文件所在目录执行：

```sh
docker compose up -d
```

### 方式二：Docker CLI

```sh
docker run -d --restart=always -p 3002:3002 \
  -v ~/docker_data/sun-panel/conf:/app/conf \
  -v ~/docker_data/sun-panel/uploads:/app/uploads \
  -v ~/docker_data/sun-panel/database:/app/database \
  --name sun-panel \
  lenmontea/sun-panel:latest
```

### 访问

启动后浏览器打开 `http://<主机IP>:3002`。

首次启动会自动创建默认账号：

- 账号：admin@sun.cc
- 密码：12345678

登录后请立即在「我的信息」中修改密码。

忘记密码时，在容器内执行：

```sh
docker exec -it sun-panel ./sun-panel -password-reset
```

## 数据持久化

容器内需要持久化的目录如下，建议全部挂载到宿主机：

| 容器目录 | 内容 | 是否推荐挂载 |
|---|---|---|
| /app/conf | 配置文件（conf.ini） | 推荐 |
| /app/uploads | 上传的壁纸与图标文件 | 推荐 |
| /app/database | SQLite 数据库文件 | 推荐 |
| /app/runtime | 运行日志 | 不推荐 |

不挂载也能运行，但容器删除或重建后数据会一起丢失。挂载后升级镜像只需重建容器，数据不受影响。

## 镜像版本

| 标签 | 说明 |
|---|---|
| `1.3.1` | 固定版本标签，内容不会随新构建变化，适合生产环境 |
| `latest` | 指向最近一次正式构建，当前等同于 `1.3.1` |
| `1.3.1-beta` | 测试版，仅在手动触发 Beta 构建工作流后推送，不更新 `latest`，可能包含未验证的改动 |

建议生产环境使用固定版本标签（如 `1.3.1`），需要尝鲜时再切到 `1.3.1-beta`。

## 升级与维护

### 更新镜像

使用固定版本标签时，把 `1.3.1` 换成目标版本号；使用 `latest` 时先拉取新镜像：

```sh
docker pull lenmontea/sun-panel:latest
docker stop sun-panel && docker rm sun-panel
# 重新执行上面的 docker run 命令创建容器，挂载目录保持不变
```

Docker Compose 方式：

```sh
docker compose pull
docker compose up -d
```

数据库表结构在启动时自动迁移（例如 1.3.1 新增的 `is_hide` 列），升级前仍建议先备份。

### 备份与恢复

需要备份的只有挂载到宿主机的三个目录：

```sh
tar -czf sun-panel-backup-$(date +%Y%m%d).tar.gz conf uploads database
```

恢复时把三个目录解压回原位置，再启动容器即可。

## 项目地址与许可证

- 项目源码与问题反馈：<https://github.com/obear997/sun-panel>
- 更新日志：<https://github.com/obear997/sun-panel/blob/main/UPDATELOG.md>
- 上游项目：[hslr-s/sun-panel](https://github.com/hslr-s/sun-panel)（本项目基于其 v1.3.0 版本拓展）
- 许可证：[MIT](https://github.com/obear997/sun-panel/blob/main/LICENSE)，原项目版权归原作者所有

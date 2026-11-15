
<div align=center>

<img src="./docs/images/logo.png" width="100" height="100" />

# Sun-Panel 拓展版

[![Github](https://img.shields.io/badge/Github-obear997%2Fsun--panel-242424?logo=github&labelColor=242424)](https://github.com/obear997/sun-panel)
[![docker](https://img.shields.io/badge/docker-lenmontea%2Fsun--panel-1c7aed?logo=docker&logoColor=fff&labelColor=1c7aed)](https://hub.docker.com/r/lenmontea/sun-panel) 


Server, NAS navigation panel, Homepage, Browser homepage.
<br>
一个NAS、服务器导航面板、简易docker管理器、Homepage、浏览器首页

> 本项目基于 [hslr-s/sun-panel](https://github.com/hslr-s/sun-panel) **v1.3.0** 版本进行拓展，完整保留原项目功能，并在此基础上按需扩展。

</div>

## 📖 项目说明

### 项目作用

Sun-Panel 拓展版是一个可自托管的导航面板，用于把 NAS、家庭服务器或内网中的各类服务集中展示在一个页面上，可作为浏览器首页、服务器仪表盘或内网服务入口使用。

### 主要功能

- **服务导航**：以图标卡片集中管理常用网站与服务，支持分组、拖拽排序和搜索。
- **内外网地址切换**：为同一服务分别配置局域网与外网地址，按使用场景一键切换。
- **个性化外观**：支持自定义壁纸、背景遮罩、图标（文字图标 / SVG / 内置三方图标库）以及小图标模式。
- **系统状态监控**：内置 CPU、内存、磁盘状态监控模块。
- **管理与扩展**：提供上传文件管理、用户管理、配置导入导出，并支持全局自定义 JS/CSS 与页脚。
- **轻量部署**：支持 Docker 与单二进制运行，无需外部数据库，资源占用小。

### 与上游项目的关系

本项目参考并基于 [hslr-s/sun-panel](https://github.com/hslr-s/sun-panel) **v1.3.0** 版本进行拓展：

- 基础功能、界面与数据结构均来自上游项目；
- 拓展内容在上游版本基础上按实际使用需求逐步添加；
- 原项目版权归原作者所有，本项目同样遵循 [MIT](./LICENSE) 协议。

本项目地址：<https://github.com/obear997/sun-panel>

上游项目地址：<https://github.com/hslr-s/sun-panel>

## 😎 特点

- 简洁
- 局域网内外网链接切换
- docker部署,对arm系统支持
- 上手简单，免修改代码
- 无需连接外部数据库
- 丰富图标自由搭配（文字图标+svg图标+内置三方图标库）
- 支持网页内置小窗口打开（部分网站屏蔽此功能）
- 占用资源小


## 🍜 使用运行教程

> Docker 示例使用本项目镜像 `lenmontea/sun-panel`；二进制文件可从本项目 Releases 下载，也可参考 [build.sh](./build.sh) 自行构建。

### 默认账号密码
账号：admin@sun.cc

密码：12345678

### 命令参数
|参数|说明|
|---|---|
|-h|查看命令说明|
|-config|生成配置文件（conf/conf.ini）|
|-password-reset|重置第一个用户的密码|

### 二进制文件运行

去 [本项目 Releases](https://github.com/obear997/sun-panel/releases) 下载 v1.3.1 二进制文件

执行示例

```sh
./sun-panel
```

#### 重置密码

执行示例

```sh
./sun-panel -password-reset
```
输出
```
密码已经重置成功，以下是账号信息
用户名  xxx@qq.com
密码  12345678
```

### docker 运行

目录挂载 `-v`，根据自己的需求选择：
|容器目录|说明|
|---|---|
|/app/conf|配置文件|
|/app/uploads|上传的文件|
|/app/database|数据库文件|
|/app/runtime|运行日志(不推荐挂载)|

1. 拉取镜像
```sh
docker pull lenmontea/sun-panel
```

2. 直接下载运行
```sh
docker run -d --restart=always -p 3002:3002 \
-v ~/docker_data/sun-panel/conf:/app/conf \
-v ~/docker_data/sun-panel/uploads:/app/uploads \
-v ~/docker_data/sun-panel/database:/app/database \
--name sun-panel \
lenmontea/sun-panel
```


## ❤️ 感谢

- [hslr-s/sun-panel](https://github.com/hslr-s/sun-panel) — 本项目的上游项目，本项目基于其 v1.3.0 版本拓展
- [Roc](https://github.com/RocCheng)
- [jackloves111](https://github.com/jackloves111)
- [Rock.L](https://github.com/gitlyp)

## LICENSE
[MIT](./LICENSE)
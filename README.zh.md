# BrowserProxy

极轻量的 macOS 原生浏览器路由工具。拦截系统链接点击，根据浏览器运行状态和电源模式，自动转发到合适的浏览器。

> 装了 Chrome、Safari、Firefox 等多个浏览器？不想每次手动切换默认？BrowserProxy 帮你自动路由。

## 快速开始

```bash
git clone https://github.com/lvchenjia/BrowserProxy.git
cd BrowserProxy
./build.sh
cp -R BrowserProxy.app /Applications/
```

打开 BrowserProxy，配置策略后点击「设为默认浏览器」即可。

## 功能

- **智能模式** — 自动使用正在运行的浏览器
- **电源感知** — 电池 / 电源可分别指定不同浏览器
- **无需常驻** — 转发完立即退出，不占内存
- **~300KB** — 原生 SwiftUI，零 Electron

## 策略说明

| 模式 | 行为 |
|------|------|
| 智能模式（推荐） | 优先使用正在运行的浏览器，未运行则回退到默认 |
| 始终使用选定浏览器 | 无论状态如何，总是用设定好的浏览器 |

## 使用场景

| 场景 | 推荐设置 |
|------|----------|
| 日常浏览，Safari 省电 | 默认 = Safari，接电源 = Chrome |
| 多个浏览器各有用途 | 智能模式，自动用正在运行的 |
| 固定只用某个浏览器 | 固定模式 + 选好浏览器 |
| 笔记本电源管理 | 电池用 Safari，电源用 Chrome |

## 体积对比

| 项目 | 大小 | 技术栈 |
|------|------|--------|
| **BrowserProxy** | **~290 KB** | Swift (原生) |
| Finicky | 7 MB | Go + ObjC |
| Velja | 36 MB | Swift (原生) |
| Browserosaurus | 300 MB | Electron |

## 构建要求

- macOS 14.0+
- Xcode 15+ 或 Swift 5.9+

## 工作原理

1. 设为默认浏览器后，点击链接启动 BrowserProxy
2. 根据配置（智能/固定 + 电源状态）决定目标浏览器
3. 通过 AppleScript 告知浏览器打开链接
4. 自动退出

## 许可

MIT

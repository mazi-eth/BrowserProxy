# BrowserProxy

[![first-timers-only-friendly](https://img.shields.io/badge/first--timers--only-friendly-blue.svg)](https://github.com/lvchenjia/BrowserProxy/issues?q=is%3Aopen+is%3Aissue+label%3Afirst-timers-only)

A lightweight macOS native app that acts as a smart browser router. Intercept link clicks and automatically forward them to the right browser based on running state and power source.

> Have multiple browsers installed but tired of manually switching the default? BrowserProxy solves this.

## Quick Start

```bash
git clone https://github.com/lvchenjia/BrowserProxy.git
cd BrowserProxy
./build.sh
cp -R BrowserProxy.app /Applications/
```

Open BrowserProxy, configure your preferred browser and strategy, click "Set as Default Browser", and you're done.

## Features

- **Smart Mode** — automatically uses whichever browser is currently running
- **Power Aware** — pick a battery-efficient browser on battery, a full-featured one on AC
- **No Resident Process** — forwards the URL and exits immediately, zero memory footprint
- **~300KB** — native SwiftUI, zero Electron overhead

## Strategies

| Mode | Behavior |
|------|----------|
| Smart (recommended) | Use the currently running browser; fall back to default |
| Fixed | Always use the selected browser regardless |

## Use Cases

| Scenario | Suggested Setup |
|----------|----------------|
| Daily browsing, save battery with Safari | Default = Safari, AC override = Chrome |
| Multiple browsers for different tasks | Smart Mode picks whichever is already running |
| Stick to one browser | Fixed Mode + pick your browser |
| Laptop power management | Safari on battery, Chrome on AC |

## Comparison

| App | Size | Tech |
|-----|------|------|
| **BrowserProxy** | **~290 KB** | Swift (native) |
| Finicky | 7 MB | Go + ObjC |
| Velja | 36 MB | Swift (native) |
| Browserosaurus | 300 MB | Electron |

## Requirements

- macOS 14.0+
- Xcode 15+ or Swift 5.9+ CLI tools

## How It Works

1. After being set as the default browser, clicking a link launches BrowserProxy
2. Based on your config (smart/fixed + power state), the target browser is selected
3. URL is forwarded via AppleScript (opens in a new tab for Safari, new window for others)
4. BrowserProxy exits automatically

## License

MIT

---

[中文版](README.zh.md)

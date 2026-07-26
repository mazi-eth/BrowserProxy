# Contributing to BrowserProxy

First off, thanks for your interest! BrowserProxy is a small macOS utility, and we welcome contributions of all kinds.

## Development Setup

**Prerequisites:** macOS 14.0+, Xcode 15+ or Swift 5.9+ CLI tools

```bash
git clone https://github.com/lvchenjia/BrowserProxy.git
cd BrowserProxy
./build.sh
```

The built `.app` will be at `BrowserProxy.app/`. Debug without installing:

```bash
swift run
```

## Project Structure

```
BrowserProxy/
├── Sources/BrowserProxy/
│   ├── BrowserProxyApp.swift   # App entry, Apple Event handling
│   ├── ContentView.swift       # SwiftUI settings UI
│   ├── Config.swift            # Config persistence, default browser
│   └── Router.swift            # Core routing + AppleScript forwarding
├── Resources/                  # App icons
├── Info.plist                  # Bundle configuration
├── Package.swift               # SwiftPM build config
└── build.sh                    # Build + package script
```

## Pull Request Workflow

1. Fork and clone the repo
2. Create a feature branch: `git checkout -b my-feature`
3. Make your changes
4. Build and test: `./build.sh`
5. Push and open a Pull Request

## Good First Issues

Look for issues labeled `good-first-issue` or `first-timers-only`. These are small, well-defined tasks with pointers to help you get started.

- Comment on the issue to let others know you're working on it
- Ask questions if anything is unclear — we're here to help

## Code Style

- Follow existing patterns in the codebase
- No comments unless the logic is non-obvious
- Keep the binary small — prefer native APIs over external dependencies

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

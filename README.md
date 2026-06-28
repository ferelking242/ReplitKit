# ReplitKit

iOS WKWebView app for Replit — native WebKit engine, full JS/network logging, debug console overlay.

## Features
- Native WebKit (WKWebView) — same engine as Safari, zero overhead
- Address bar with navigation controls
- Full JS console capture (log / error / warn / uncaught / unhandled promise)
- HTTP response code logging (flags all 4xx/5xx)
- In-app debug console overlay (tap 🐞)
- Log file shareable via share sheet
- Google OAuth popup handled natively
- Bundle ID: com.AIVOS.ReplitKit

## Build
Open `ReplitKit.xcodeproj` in Xcode, set your Team, build & run.

## CI
GitHub Actions builds an unsigned IPA on every push → available in Actions artifacts.

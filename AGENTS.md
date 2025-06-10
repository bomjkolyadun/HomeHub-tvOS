# HomeHub tvOS Project Guidelines

This repository contains the **HomeHub** tvOS application written in Swift using SwiftUI. The app discovers HomeHub servers on the local network, fetches video metadata, and streams video content. Because the project is distributed under the GPL‑3.0 license, all contributions must remain compatible with that license.

## Directory overview
- `HomeHub/` – Swift source code, views, models, and services.
- `HomeHub.xcodeproj/` – Xcode project configuration.
- `LICENSE` – Project license (GPL‑3.0).

## Coding conventions
- Follow existing style for each file. Most views and services use **two spaces** for indentation while some top-level files use **four spaces**. Match the style already present in the surrounding code.
- Prefer SwiftUI and Combine patterns. Use `@MainActor` for UI-facing classes.
- Document new files with a brief header comment.
- Remove `print` debug statements before committing to `main`.
- Run `swift format` or a similar formatter if available.

## Commit rules
- Write concise, imperative commit messages (e.g. `Fix video search pagination`).
- Explain the reasoning in the commit body when the change is not obvious.
- Keep commits focused; avoid mixing unrelated changes.

## Pull request checklist
- Summarize key changes in the PR description and mention any manual testing performed.
- Ensure the app builds and launches in the tvOS simulator in Xcode.
- If `Info.plist` or project settings change, double‑check the target configuration.
- Do not include personal credentials or private server addresses in commits.

## Testing
- There are currently no automated tests. Run `swift --version` to confirm toolchain availability before committing. If tests are added under `Tests/`, run `swift test`.
- To quickly check for compile-time errors without Xcode, run:
  
  ```bash
  swiftc -typecheck $(git ls-files '*.swift')
  ```
  
  This uses `swiftc` to typecheck all Swift sources and fails if any errors are detected.

## Branch management
- Open PRs against `main` and rebase onto `main` before merging to keep history linear.


## Security and privacy
- Review code for potential data leaks or exposure of local network information.
- Never commit API keys or credentials. Environment-specific values must be kept outside the repo.

## Binary assets
- Do not commit large video or image assets. Keep the repository lean by referencing assets that can be downloaded at build time.

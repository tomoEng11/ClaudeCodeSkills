---
name: Applying Swift Concurrency (Standard)
description: Applies standard Swift Concurrency without Approachable features. Defines @MainActor boundaries, actor isolation, Task/TaskGroup usage, and AsyncStream patterns. Use when designing or reviewing async work, actor-based state, or cancellation.
---

# Standard Swift Concurrency

**Use when**: 非同期/キャンセル/actor隔離/UIスレッド境界の設計・レビュー。

## Quick rules
- Presenter は `@MainActor`。View は Task を起動せず、Presenter に委譲。
- 非同期副作用は Interactor。UI 更新は Presenter 経由。
- 並列は TaskGroup、`Task.detached` は原則禁止。継続イベントは AsyncStream。
- 並行境界を越える型は Sendable。理由なき `@unchecked` は禁止。
- **DispatchQueue は使用しない**: 遅延実行は `Task { try? await Task.sleep(for:) }` を使用。

## File references
- ルール/用語: [reference.md](reference.md)
- 例/アンチパターン: [examples.md](examples.md)

## Checklist
```
- [ ] Presenter に @MainActor
- [ ] View に ad-hoc Task なし
- [ ] TaskGroup で並列化、キャンセル伝播確認
- [ ] Sendable 準拠または根拠付き @unchecked
```

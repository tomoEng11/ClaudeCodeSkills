# Component Reference

## Import文

- **iOS 17+では `Foundation` に `Observation` が統合されている**
- `import Foundation` があれば `@Observable` マクロが使用可能
- `import Observation` は不要（冗長）

```swift
// ✅ 正しい
import SwiftUI

@Observable
final class MyViewState { }

// ❌ 冗長
import SwiftUI
import Observation  // 不要

@Observable
final class MyViewState { }
```

**注**: `SwiftUI` は内部で `Foundation` をインポートしているため、SwiftUIプロジェクトでは `@Observable` が自動的に使用可能

## Decomposition
- 再利用は構造体View。
- 画面内の補助UIは private func/property で内製。

## Bindings
- 双方向は `@Bindable` + `@Observable` 経由。
- 過剰な Binding バケツリレーを避ける。

## Layout & Sizing
- **UIScreen.main.bounds is deprecated (iOS 16+)** ⚠️ 絶対に使用禁止
  - Use `GeometryReader` to get available space dynamically
  - SwiftUI automatically adapts to container size
  - Avoid hardcoded screen dimensions
- GeometryReader provides `GeometryProxy` with size, safeAreaInsets, etc.
- Use `.frame(maxWidth: .infinity)` for responsive layouts

## Color & Style Modifiers
- **foregroundColor is deprecated (iOS 15+)** ⚠️ 絶対に使用禁止
  - Use `foregroundStyle` instead
  - `foregroundStyle` supports semantic colors (.primary, .secondary)
  - Better dark mode and accessibility support

## Preview
- `#Preview { ... }`
- Light/Dark、Dynamic Type を確認。

---
name: Following Design System Guidelines (Liquid Glass)
description: Aligns SwiftUI and UIKit interfaces with Apple's latest design system — including Liquid Glass, HIG updates, and accessibility. Use when designing or modernizing UI for iOS 18+.
---

# Following Design System Guidelines (Liquid Glass Era)

**Use when**: SwiftUI / UIKit の UI 設計・レビュー時に、Liquid Glass と HIG を反映したいとき。

## Quick Rules
- 標準コンポーネント優先（自動で Liquid Glass を採用）
- カスタム背景・独自ブラーは最小限に
- ScrollEdge / backgroundExtensionEffect を活用
- 重要要素のみ `.glass()` / `.glassProminent()`
- `foregroundStyle` と Dynamic Color を使用
- Reduce Transparency / Motion に対応（自作アニメは分岐）
- Icon Composer でレイヤー設計、システム効果に委ねる

## File references
- 設計原則: [reference.md](reference.md)
- 標準コンポーネント: [components.md](components.md)
- カスタム Liquid Glass: [custom-liquid-glass.md](custom-liquid-glass.md)
- パフォーマンス: [performance.md](performance.md)
- アクセシビリティ: [accessibility.md](accessibility.md)
- 例: [examples.md](examples.md)

## Checklist
```
- [ ] カスタム背景を排除
- [ ] ScrollEdge / backgroundExtensionEffect を使用
- [ ] .glass()/.glassProminent() を適所に限定
- [ ] Reduce Transparency/Motion 設定で視認性維持
- [ ] Icon Composer レイヤーで検証
```

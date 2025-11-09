---
name: Designing SwiftUI Components
description: Provides rules for structuring SwiftUI views and bindings under VIPER. Use when implementing or reviewing components, bindings, or previews.
---

# SwiftUI Component Design

**Use when**:
- SwiftUIの`View`を新規作成・修正する前に**必ず読む**
- `ContentView`や再利用可能なコンポーネントを実装する前
- UI分割、Binding設計、Modifier/Style適用、Preview整備

## Quick rules
- 子Viewには「値＋アクション」だけ。状態は上位に集約。
- Binding は最小プロパティ範囲に限定。AnyView 多用禁止、@ViewBuilder で分岐。
- **Deprecated API禁止**: `UIScreen.main.bounds` → `GeometryReader`、`foregroundColor` → `foregroundStyle`
- `foregroundStyle` を優先し、固定色直指定は最小化。
- Preview は light/dark & Dynamic Type を用意。

## File references
- 分割/Binding/Preview: [reference.md](reference.md)
- Style/Modifier: [styles.md](styles.md)
- 例: [examples.md](examples.md)

## Checklist
```
- [ ] 値＋アクションのPropsに縮約
- [ ] Bindingの範囲が最小
- [ ] Deprecated API不使用（UIScreen, foregroundColor等）
- [ ] GeometryReaderでレイアウト（画面サイズ依存時）
- [ ] foregroundStyleで動的適応
- [ ] 標準Previewバリアント
```

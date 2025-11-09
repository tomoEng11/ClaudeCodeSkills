# FoundationModel - Calculator App

このプロジェクトは、SwiftUIで構築された電卓アプリケーションです。

## アーキテクチャ

このプロジェクトでは、以下のアーキテクチャパターンとガイドラインに従います：

### Store/View/ViewState (SVVS) パターン

- **View**: SwiftUIビューコンポーネント（UIロジックを含まない）
- **ViewState**: Viewの状態を保持する`@Observable`クラス
- **Store**: ビジネスロジックと状態管理を行う単一のソースオブトゥルース

詳細は `.claude/skills/designing-svvs-architecture` を参照してください。

### Swift Concurrency

非同期処理には、標準的なSwift Concurrency（async/await, Actor, Task）を使用します。
詳細は `.claude/skills/applying-swift-concurrency-standard` を参照してください。

### SwiftUI コンポーネント設計

- Viewは純粋な表示ロジックのみを持つ
- 状態管理はViewStateに委譲
- 再利用可能なコンポーネントの作成

詳細は `.claude/skills/designing-swiftui-components` を参照してください。

### デザインシステム

iOS 26のAppleデザインシステム、HIG、アクセシビリティガイドラインに準拠します。
詳細は `.claude/skills/following-design-system-guidelines` を参照してください。

## プロジェクト構造

```
FoundationModel/
├── FoundationModelApp.swift    # アプリのエントリーポイント
├── ContentView.swift            # メインの電卓UI
├── CalculatorViewModel.swift   # 電卓のロジックと状態管理
└── Assets.xcassets/            # アセット
```

## 機能

- 基本的な四則演算（加算、減算、乗算、除算）
- AC（クリア）
- ±（符号反転）
- %（パーセント）
- 小数点入力
- iOSネイティブ電卓風のUI

## 開発ガイドライン

### 新機能の追加

1. `.claude/skills/` 配下のSkillsを確認し、プロジェクトのアーキテクチャパタisolated deinitーンに従う
2. SVVS パターンに従って、Store/View/ViewState を適切に分離する
3. Swift Concurrency を使用する場合は、標準パターンに従う
4. UIコンポーネントは再利用可能に設計する

### コードレビュー

- アーキテクチャパターンへの準拠
- Swift Concurrency の適切な使用
- アクセシビリティ対応
- iOS 26 デザインガイドラインへの準拠

## Skills

このプロジェクトでは以下のSkillsを使用します：

- `applying-swift-concurrency-standard` - Swift Concurrency の標準パターン
- `designing-svvs-architecture` - Store/View/ViewState アーキテクチャ
- `designing-swiftui-components` - SwiftUI コンポーネント設計
- `following-design-system-guidelines` - iOS26  デザインシステム
- `operating-claude-code-and-skills` - Skills の管理と更新

各Skillの詳細は `.claude/skills/[skill-name]/` ディレクトリを参照してください。

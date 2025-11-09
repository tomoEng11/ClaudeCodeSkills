# SVVS Reference

## Import文

- **iOS 17+では `Foundation` に `Observation` が統合されている**
- `import Foundation` があれば `@Observable` マクロが使用可能
- `import Observation` は不要（冗長）

```swift
// ✅ 正しい
import Foundation

@Observable
final class UserStore { }

// ❌ 冗長
import Foundation
import Observation  // 不要

@Observable
final class UserStore { }
```

## 基本ルール

| 原則 | 内容 |
|------|------|
| 状態の単一性 | Storeが唯一の状態所有者（Single Source of Truth） |
| リアクティブな更新 | Storeの状態変更 → ViewStateが自動的に監視・更新 → Viewが再描画 |
| 副作用の集約 | 非同期処理・API呼び出しはStore内で実行する |
| Viewの受動性 | Viewは描画のみ。ロジック・条件分岐を持たない |
| ViewStateの責務 | Storeの状態を購読し、UI表示用に変換・派生した状態を保持する |

## 各層の責務

### Repository層
- データソースへの統一的なアクセスポイント
- バックエンド実装の詳細を隠蔽
- 非同期操作とエラーハンドリングを提供

```swift
enum UserRepository {
    // 単一データ取得
    static func fetchValue(for id: User.ID) async throws -> User?

    // 複数データ取得
    static func fetchValues(for ids: [User.ID]) async throws -> [User]

    // データ更新
    static func updateValue(_ value: User) async throws

    // 部分更新
    static func updateBookmarked(_ isBookmarked: Bool, for id: User.ID) async throws
}
```

### Store層
- **単一のソースオブトゥルース** - アプリ全体の状態を一箇所で管理
- `@Observable` マクロで状態変更を自動追跡
- Repository経由でデータ操作を行う
- シンプルな状態更新メソッドを提供

```swift
@MainActor
@Observable
final class UserStore {
    // シングルトンパターン（推奨）
    static let shared: UserStore = .init()

    // 状態はprivate(set)で外部からの変更を防ぐ
    private(set) var values: [User.ID: User] = [:]

    // Repository経由で非同期データ取得・更新
    func loadValue(for id: User.ID) async throws {
        if let value = try await UserRepository.fetchValue(for: id) {
            values[value.id] = value
        } else {
            values.removeValue(forKey: id)
        }
    }
}
```

### ViewState層
- Storeの状態を監視・購読
- UI表示用の派生状態を計算・保持
- フィルタリング、ソート、変換などの表示ロジックを集約
- Viewからのイベントを受け取り、Storeへ伝達

```swift
@MainActor
@Observable
final class UserViewState {
    let id: User.ID

    // UI表示用の派生状態
    private(set) var user: User?
    private(set) var filteredFriends: [User] = []

    // ユーザー入力の状態
    var showsOnlyBookmarkedFriends: Bool = false {
        didSet { updateFilteredFriends() }
    }

    private let store: UserStore

    init(id: User.ID, store: UserStore = .shared) {
        self.id = id
        self.store = store

        // Storeの状態変更を監視して派生状態を更新
        // withObservationTracking を使用した自動監視
    }

    // ライフサイクル
    func onAppear() async {
        try? await store.loadValue(for: id)
        updateUser()
    }

    // Storeの状態から派生状態を計算
    private func updateUser() {
        user = store.values[id]
        updateFilteredFriends()
    }

    private func updateFilteredFriends() {
        guard let user else {
            filteredFriends = []
            return
        }

        filteredFriends = user.friendIDs
            .compactMap { store.values[$0] }
            .filter { !showsOnlyBookmarkedFriends || $0.isBookmarked }
    }

    // イベントハンドラ
    func toggleFriendBookmark(for friendId: User.ID) async {
        guard let friend = store.values[friendId] else { return }
        try? await store.updateBookmarked(!friend.isBookmarked, for: friendId)
        updateFilteredFriends()
    }
}
```

### View層
- **純粋な表示層** - UIの描画のみ
- ViewStateを`@State`で保持
- ユーザーイベントをViewStateへ伝達
- ロジック・条件分岐を持たない（三項演算子程度はOK）

```swift
struct UserView: View {
    @State private var state: UserViewState

    init(userId: User.ID) {
        _state = State(initialValue: UserViewState(id: userId))
    }

    var body: some View {
        List {
            if let user = state.user {
                // ユーザー情報表示
                Text(user.name)
            }

            ForEach(state.filteredFriends) { friend in
                Button {
                    Task {
                        await state.toggleFriendBookmark(for: friend.id)
                    }
                } label: {
                    Text(friend.name)
                }
            }
        }
        .task {
            await state.onAppear()
        }
    }
}
```

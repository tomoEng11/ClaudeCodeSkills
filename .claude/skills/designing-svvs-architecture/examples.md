# SVVS Examples

## 完全な実装例: ユーザー管理機能

### 1. Repository層 - データアクセスの抽象化

```swift
// User.swift
struct User: Identifiable, Equatable {
    let id: UUID
    var name: String
    var friendIDs: [UUID]
    var isBookmarked: Bool
}

// UserRepository.swift
enum UserRepository {
    /// 単一ユーザーを取得
    static func fetchValue(for id: User.ID) async throws -> User? {
        // API呼び出しやデータベースアクセスをシミュレート
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1秒
        return Backend.shared.getValue(for: id)
    }

    /// 複数ユーザーを一括取得
    static func fetchValues(for ids: [User.ID]) async throws -> [User] {
        try await Task.sleep(nanoseconds: 100_000_000)
        return ids.compactMap { Backend.shared.getValue(for: $0) }
    }

    /// ユーザー情報を更新
    static func updateValue(_ value: User) async throws {
        try await Task.sleep(nanoseconds: 50_000_000)
        Backend.shared.updateValue(value)
    }

    /// ブックマーク状態を更新
    static func updateBookmarked(_ isBookmarked: Bool, for id: User.ID) async throws {
        try await Task.sleep(nanoseconds: 50_000_000)
        Backend.shared.updateBookmarked(isBookmarked, for: id)
    }

    // 内部バックエンド（シミュレート用）
    private actor Backend {
        static let shared = Backend()
        private var storage: [User.ID: User] = [:]

        func getValue(for id: User.ID) -> User? {
            storage[id]
        }

        func updateValue(_ value: User) {
            storage[value.id] = value
        }

        func updateBookmarked(_ isBookmarked: Bool, for id: User.ID) {
            storage[id]?.isBookmarked = isBookmarked
        }
    }
}
```

### 2. Store層 - 単一のソースオブトゥルース

```swift
// UserStore.swift
@MainActor
@Observable
final class UserStore {
    // シングルトンパターン
    static let shared: UserStore = .init()

    // アプリ全体のユーザーデータキャッシュ
    private(set) var values: [User.ID: User] = [:]

    private init() {}

    /// 単一ユーザーをロード
    func loadValue(for id: User.ID) async throws {
        if let value = try await UserRepository.fetchValue(for: id) {
            values[value.id] = value
        } else {
            values.removeValue(forKey: id)
        }
    }

    /// 複数ユーザーを一括ロード
    func loadValues(for ids: [User.ID]) async throws {
        var newValues = values
        let fetchedValues = try await UserRepository.fetchValues(for: ids)

        // 取得できたユーザーを追加
        var idsToBeRemoved: Set<User.ID> = Set(ids)
        for value in fetchedValues {
            newValues[value.id] = value
            idsToBeRemoved.remove(value.id)
        }

        // 取得できなかったIDは削除
        for id in idsToBeRemoved {
            newValues.removeValue(forKey: id)
        }

        values = newValues
    }

    /// ユーザー情報を更新
    func updateValue(_ value: User) async throws {
        try await UserRepository.updateValue(value)
        values[value.id] = value
    }

    /// ブックマーク状態を更新
    func updateBookmarked(_ isBookmarked: Bool, for id: User.ID) async throws {
        try await UserRepository.updateBookmarked(isBookmarked, for: id)
        values[id]?.isBookmarked = isBookmarked
    }
}
```

### 3. ViewState層 - UI状態の派生と管理

```swift
// UserViewState.swift
@MainActor
@Observable
final class UserViewState {
    let id: User.ID

    // UI表示用の派生状態
    private(set) var user: User?
    private(set) var filteredFriends: [User] = []
    private(set) var isLoading: Bool = false

    // ユーザー入力の状態
    var showsOnlyBookmarkedFriends: Bool = false {
        didSet {
            updateFilteredFriends()
        }
    }

    private let store: UserStore
    private var observationTask: Task<Void, Never>?

    init(id: User.ID, store: UserStore = .shared) {
        self.id = id
        self.store = store

        // Storeの状態変更を継続的に監視
        startObservingStore()
    }

    deinit {
        observationTask?.cancel()
    }

    // MARK: - ライフサイクル

    func onAppear() async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await store.loadValue(for: id)
            updateUser()

            // 友人情報も取得
            if let user, !user.friendIDs.isEmpty {
                try await store.loadValues(for: user.friendIDs)
                updateFilteredFriends()
            }
        } catch {
            print("Failed to load user: \(error)")
        }
    }

    // MARK: - イベントハンドラ

    func toggleFriendBookmark(for friendId: User.ID) async {
        guard let friend = store.values[friendId] else { return }

        // 楽観的更新（UIを即座に更新）
        let newIsBookmarked = !friend.isBookmarked
        optimisticallyUpdateBookmark(for: friendId, to: newIsBookmarked)

        do {
            try await store.updateBookmarked(newIsBookmarked, for: friendId)
        } catch {
            // エラー時はストアの状態に戻す
            print("Failed to update bookmark: \(error)")
            updateFilteredFriends()
        }
    }

    // MARK: - Private

    /// Storeの状態変更を継続的に監視
    private func startObservingStore() {
        observationTask = Task { @MainActor in
            while !Task.isCancelled {
                _ = withObservationTracking {
                    // Storeの変更を監視
                    _ = store.values[id]
                    _ = store.values
                } onChange: {
                    Task { @MainActor in
                        self.updateUser()
                        self.updateFilteredFriends()
                    }
                }

                // 短い待機
                try? await Task.sleep(nanoseconds: 10_000_000) // 0.01秒
            }
        }
    }

    private func updateUser() {
        user = store.values[id]
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

    private func optimisticallyUpdateBookmark(for friendId: User.ID, to isBookmarked: Bool) {
        guard let index = filteredFriends.firstIndex(where: { $0.id == friendId }) else {
            return
        }
        var updatedFriend = filteredFriends[index]
        updatedFriend.isBookmarked = isBookmarked
        filteredFriends[index] = updatedFriend
    }
}
```

### 4. View層 - 純粋な表示層

```swift
// UserView.swift
struct UserView: View {
    @State private var state: UserViewState

    init(userId: User.ID) {
        _state = State(initialValue: UserViewState(id: userId))
    }

    var body: some View {
        List {
            // ユーザー情報セクション
            if let user = state.user {
                Section("User Info") {
                    HStack {
                        Circle()
                            .fill(.blue)
                            .frame(width: 50, height: 50)
                        Text(user.name)
                            .font(.headline)
                    }
                }
            }

            // 友人リストセクション
            Section {
                Toggle("Show only bookmarked", isOn: $state.showsOnlyBookmarkedFriends)

                if state.filteredFriends.isEmpty {
                    Text("No friends to display")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(state.filteredFriends) { friend in
                        FriendRow(
                            friend: friend,
                            onToggleBookmark: {
                                Task {
                                    await state.toggleFriendBookmark(for: friend.id)
                                }
                            }
                        )
                    }
                }
            } header: {
                Text("Friends")
            }
        }
        .navigationTitle("User Profile")
        .overlay {
            if state.isLoading {
                ProgressView()
            }
        }
        .task {
            await state.onAppear()
        }
    }
}

// 再利用可能なコンポーネント
struct FriendRow: View {
    let friend: User
    let onToggleBookmark: () -> Void

    var body: some View {
        HStack {
            Text(friend.name)

            Spacer()

            Button {
                onToggleBookmark()
            } label: {
                Image(systemName: friend.isBookmarked ? "star.fill" : "star")
                    .foregroundStyle(friend.isBookmarked ? .yellow : .gray)
            }
            .buttonStyle(.plain)
        }
    }
}
```

# Examples

## OK: Presenter orchestrates
```swift
@MainActor final class Presenter {
  func onAppear() { Task { await interactor.load() } }
  func apply(_ data: Model) { /* update state */ }
}
```

## NG: View launches tasks
```swift
struct Screen: View {
  var body: some View {
    .task { await interactor.load() } // ← Presenter 経由に
  }
}
```

## OK: Task.sleep for delayed execution
```swift
.onAppear {
    Task {
        try? await Task.sleep(for: .milliseconds(100))
        focused = true
    }
}
```

## NG: DispatchQueue for delayed execution
```swift
.onAppear {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        focused = true // ← キャンセル不可、構造化されていない
    }
}
```

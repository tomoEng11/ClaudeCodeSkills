# Concurrency Reference (Standard)

- **UI境界**: Presenter は @MainActor。View はイベント送出のみ。
- **副作用**: Interactor に集約し、結果は Presenter で適用。
- **並行**: TaskGroup、Async let。detached は原則使わない。
- **ストリーム**: AsyncStream／AsyncSequence で継続イベント。
- **遅延実行**: DispatchQueue.main.asyncAfter は非推奨。Swift Concurrency の `Task { try? await Task.sleep(for:) }` を使用し、キャンセルや構造化並行性の恩恵を受ける。

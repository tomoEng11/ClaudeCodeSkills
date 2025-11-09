# Examples (Before/After)

## Before
- 独自のぼかし背景を重ね、ScrollEdge と干渉
- 固定色での `foregroundColor(.blue)` 多用

## After
- 背景はシステムに委ね、`.glass()` / `.glassProminent()` へ置換
- `foregroundStyle(.primary)` で自動適応

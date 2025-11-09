# Examples

## ⚠️ Deprecated API: foregroundColor → foregroundStyle

```swift
// ❌ BAD: foregroundColor is deprecated (iOS 15+)
Text("Title").foregroundColor(.blue)
Text("Label").foregroundColor(.white)
Button("Tap") { }.foregroundColor(.black)

// ✅ GOOD: Use foregroundStyle
Text("Title").foregroundStyle(.blue)
Text("Label").foregroundStyle(.white)
Button("Tap") { }.foregroundStyle(.black)

// ✅ BEST: Use semantic colors for better dark mode support
Text("Title").foregroundStyle(.primary)
Text("Subtitle").foregroundStyle(.secondary)
Text("Hint").foregroundStyle(.tertiary)
```

## Layout sizing: GeometryReader instead of UIScreen

```swift
// ❌ BAD: UIScreen is deprecated
struct BadButtonView: View {
    private var buttonWidth: CGFloat {
        let screenWidth = UIScreen.main.bounds.width  // Deprecated!
        return (screenWidth - 48) / 4
    }

    var body: some View {
        Button("Tap") { }
            .frame(width: buttonWidth, height: buttonWidth)
    }
}

// ✅ GOOD: Use GeometryReader
struct GoodButtonView: View {
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 12) {
                ForEach(0..<4) { _ in
                    Button("Tap") { }
                        .frame(
                            width: buttonWidth(for: geometry.size.width),
                            height: buttonWidth(for: geometry.size.width)
                        )
                }
            }
        }
    }

    private func buttonWidth(for containerWidth: CGFloat) -> CGFloat {
        let spacing: CGFloat = 12
        let padding: CGFloat = 32
        let totalSpacing = spacing * 3 + padding
        return (containerWidth - totalSpacing) / 4
    }
}

// ✅ BETTER: Let SwiftUI handle sizing naturally
struct BestButtonView: View {
    var body: some View {
        HStack(spacing: 12) {
            ForEach(0..<4) { _ in
                Button("Tap") { }
                    .frame(maxWidth: .infinity)
                    .aspectRatio(1, contentMode: .fit)
            }
        }
        .padding(.horizontal)
    }
}
```

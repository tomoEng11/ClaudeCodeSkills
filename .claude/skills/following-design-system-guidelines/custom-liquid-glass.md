# Custom Liquid Glass

## Apply
```swift
Text("Hello").padding().glassEffect()
Text("Hello").padding().glassEffect(in: .rect(cornerRadius: 16))
Text("Hello").padding().glassEffect(.regular.tint(.orange).interactive())
```

## Container
```swift
GlassEffectContainer(spacing: 40) {
  HStack(spacing: 40) {
    Image(systemName: "scribble.variable").frame(width:80,height:80).font(.system(size:36)).glassEffect()
    Image(systemName: "eraser.fill").frame(width:80,height:80).font(.system(size:36)).glassEffect().offset(x:-40)
  }
}
```

## Union
```swift
Image(...).glassEffect().glassEffectUnion(id: "1", namespace: ns)
```

## Morph
```swift
Image("pencil").glassEffect().glassEffectID("pencil", in: ns)
Image("eraser").glassEffect().glassEffectID("eraser", in: ns).glassEffectTransition(.matchedGeometry)
```

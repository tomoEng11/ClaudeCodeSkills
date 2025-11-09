# Performance

- GlassEffectContainer を過剰に増やさない。
- 同時に適用する .glassEffect 数を絞る（常時3–5程度を目安）。
- Container 外に .glassEffect を散在させない（再描画増）。
- Instruments（UI animation hitches / render loop）で定期計測。

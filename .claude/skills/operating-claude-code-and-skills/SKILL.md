---
name: Operating Claude Code & Skills
description: Defines how Claude Code should update and organize Skills. Use when adding, editing, or restructuring Skill files so that changes land in the correct markdown with minimal tokens and safe diffs.
---

# Operating Claude Code & Skills

**Use when**: Skill を新規作成・追記・改訂・整理するとき。Claude が *どのファイルに何を書くか* を判断し、最小差分で安全に更新するための運用ガイド。

## Quick Rules
- **Skill編集時は必ずこのファイルを最初に読む**：任意のSkillファイルを編集する前に `operating-claude-code-and-skills/SKILL.md` と `workflows.md` を確認。
- **短く・正しく・分割**：SKILL.md は入口（≦500行）。詳細は `reference.md` / `examples.md` / `workflows.md` 等へ。
- **最小差分**：既存内容を尊重して *追記 or 局所置換*。ファイル全置換禁止。
- **一段参照**：SKILL.md → 参照ファイル（1段）。多段ネスト禁止。
- **一貫ワーディング**：用語・見出し・命名を既存Skill群と同じパターンに。
- **時間依存NG**：日付や一時的仕様は "Old patterns" に畳む。
- **編集ログ**：PR文面に *変更目的 / 対象ファイル / 要約* を明記。

## File Ownership Map (どこに書くか)
- **SKILL.md**：目的・適用場面・Quick Rules・リンク・短いチェックリスト。
- **reference.md**：原則・定義・用語集・判断基準（Why/When）。
- **workflows.md**：手順・チェックリスト・分岐付きフロー。
- **templates.md**：出力テンプレ（レポート/レビュー/コードスニペット）。
- **examples.md**：OK/NG・Before/After・小さな実例。
- **routers.md**：インテント→ファイルの *ルーティング規則*（下記参照）。
- **evaluations.md**：評価シナリオと合格基準。

## Edit Safety (Claude への指示テンプレ)
- **パッチ方針**：必ず *最小差分*。既存セクションへ追記 or 局所置換。
- **見出し粒度**：既存の h2/h3 構造に合わせる。新設時は h2 を最小限。
- **語彙**：既存用語を優先（例：“Quick rules”“Old patterns”“Checklist”）。
- **禁止**：巨大貼り替え / 似た章の複製 / 2段以上の参照ネスト。

## Commit Message (推奨)
```
docs(skill): [skill-name] add rule about foregroundStyle and GlassEffectContainer

- Update SKILL.md Quick Rules (one bullet)
- Move details to reference.md
- Add before/after to examples.md
```

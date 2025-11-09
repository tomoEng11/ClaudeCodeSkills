# Workflows

## Workflow: Add a New Rule
1. 既存の Quick Rules に同義がないか確認
2. **SKILL.md** の Quick Rules に *1行* 追記
3. 具体理由/背景を **reference.md** に詳細化
4. 必要なら **examples.md** に OK/NG 追加
5. PR で目的と変更点を要約

## Workflow: Move Details Out of SKILL.md
1. 冗長な段落を抽出→ `reference.md` へ移動
2. SKILL.md には 1–2行のサマリだけ残す
3. 内部リンクを更新（1段参照を維持）

## Workflow: Create Evaluation Case
1. 想定失敗例を観察して要件化
2. `evaluations.md` にチェックリストを追加
3. 実タスクで再評価し、必要なら Quick Rules を昇格

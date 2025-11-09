# Templates

## Patch Instruction (Claude向け)
```
Please apply a minimal patch:
- Target file: <path/to/file.md>
- Operation: append under "## <Section>"
- Content: (below)
---8<---
<new lines>
---8<---
```

## Section Skeleton
```markdown
## <Section Title>
- Rule 1
- Rule 2
- Link: [reference.md](reference.md#anchor)
```

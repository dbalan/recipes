---
name: import-recipe
description: >
  Import a web recipe into the YAML format used by this cookbook system.
  Use when the user provides a recipe URL or pastes recipe text and wants
  it saved as a new YAML file in the recipes/ directory.
---

# Import Recipe Skill

## Task

Convert a web recipe (URL or pasted text) into a valid cookbook YAML file and save it to `recipes/`.

## Schema

Reference `src/Recipes/Types.hs` for the authoritative schema. Summary:

```yaml
title: string                  # required
description: string            # required
source: string                 # required — URL of original recipe
image: string                  # optional — filename in pictures/
categories:                    # required — list of strings
  - string
ingredients:                   # required
  - name: string               # required
    qty: string                # optional — MUST be quoted string, never bare number
    prep: string               # optional — preparation note
preparation:                   # required — maps to `instructions` internally
  - name: string               # required — step name, can be ""
    prep: string               # required — step instructions (multiline ok with |)
notes:                         # optional
  - string
```

## Rules

1. **`qty` always a quoted string** — `"2"` not `2`, `"1 cup"` not `1 cup`. Bare numbers fail Aeson parse.
2. **`source` required** — if user pastes text with no URL, ask for it or use a placeholder like `"unknown"`.
3. **`preparation` key** — not `instructions`, `steps`, or `directions`.
4. **Filename** — slugify the title: lowercase, spaces to hyphens, no special chars. E.g. `greek-cabbage-rice.yaml`.
5. **Categories** — pick from existing conventions: `main-course`, `side-dish`, `baking`, `bread`, `pasta`, `soup`, `salad`, `dessert`, `vegetarian`, `vegan`, `italian`, `greek`, `asian`, `oven`, `meal`. Add new ones as needed.
6. **No extra fields** — the parser ignores unknown fields, but keep files clean. Do not add `servings`, `prep_time_minutes`, `author`, or `size` unless you confirm the schema supports them.
7. **After writing** — run `nix build` to verify the file parses correctly. Fix any Aeson errors before reporting success.

## Workflow

1. If given a URL, fetch it with `fetch_content`.
2. Extract: title, description, source URL, ingredients (name, qty, prep), steps.
3. Map to schema above.
4. Write to `recipes/<slug>.yaml`.
5. Run `nix build`. If `[ERROR]` appears for the file, fix and rebuild.
6. Report success with filename.

## Common Errors

| Error | Fix |
|-------|-----|
| `key "source" not found` | Add `source:` field |
| `expected String, but encountered Number` | Quote the offending `qty:` value |
| `key "preparation" not found` | Rename `instructions:` / `steps:` to `preparation:` |

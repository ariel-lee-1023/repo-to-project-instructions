# repo-to-project-instructions

Compiles a git repository into custom instructions for AI hosts that **cannot clone or run it** — Gemini Gems, Grok Projects, ChatGPT Projects, or any bare system prompt.

Give it a repo URL; it gives you a paste-ready instruction text plus, when needed, the knowledge files to upload alongside it. The host then works the way the repo says to work, treating the repo as a knowledge base it retrieves from rather than a runtime it executes.

## Why

A skills repo is useless to a Gem as a link. These hosts don't browse a tree, don't read `CLAUDE.md` on their own, and don't reliably fetch anything unless told exactly what to fetch and when. What's missing is a **routing layer**: an explicit `if the request looks like X → retrieve Y → do Z` table, plus the repo's non-negotiable rules inlined so the thing still works on a turn where browsing is off.

That routing layer is what this skill writes.

## What you get

- **Three tiers** of instruction text — FULL, COMPACT, MINIMAL — so a moved character limit costs you one paste, not a rebuild.
- **A routing table** keyed on how you actually phrase requests, not on skill names.
- **A degradation clause** — on a failed retrieval the host continues from the inline summary *and says so*, instead of confabulating.
- **Knowledge bundles**, for private repos or hosts with unreliable browsing (`scripts/bundle-knowledge.sh`).
- **Three probe prompts** with expected routing, so you can verify the port before trusting it.

## Use

In any agent with this skill installed:

```
把 https://github.com/owner/repo 编译成 Gemini Gem 的项目指令
```

Bundling on its own, without the skill:

```bash
./scripts/bundle-knowledge.sh https://github.com/owner/repo ./out --max-files 8
```

## Layout

| Path | What |
|---|---|
| [`SKILL.md`](SKILL.md) | The eight-step procedure |
| [`references/instruction-template.md`](references/instruction-template.md) | The instruction skeleton, with filling notes and a worked routing table |
| [`references/host-notes.md`](references/host-notes.md) | Gemini / Grok / ChatGPT mechanics, private repos, and when the port is the wrong tool |
| [`references/repo-profiles.md`](references/repo-profiles.md) | Three repo archetypes and what changes per archetype |
| [`scripts/bundle-knowledge.sh`](scripts/bundle-knowledge.sh) | Concatenates a repo's markdown into upload-sized bundles |

## Install

Symlink into your agent's skill directory:

```bash
ln -s "$PWD" ~/.claude/skills/repo-to-project-instructions
```

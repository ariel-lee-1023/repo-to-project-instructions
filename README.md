# repo-to-project-instructions

Compiles a git repository into custom instructions for AI hosts that **cannot clone or run it** — Gemini Gems, Grok Projects, ChatGPT Projects, or any bare system prompt.

Give it a repo URL; it gives you a paste-ready instruction text plus, when needed, the knowledge files to upload alongside it. The host then works the way the repo says to work, treating the repo as a knowledge base it retrieves from rather than a runtime it executes.

**The output is used together with the repo link, not in place of it.** The repo stays the source of truth and holds the full text of everything; the compiled instructions carry the index, the invariants, and the rules for reaching back into it.

## Why

Handing a Gem the repo link leaves three gaps, and the link narrows only the first:

- **Access** — can the host see the content? A fetched repo URL returns the landing page, the README at best. It will not walk a tree or open every `SKILL.md` unless handed each path.
- **Routing** — does it know which file governs *this* request, and does it look before answering? Nothing in these hosts maps a request to a file and loads it first. That mapping is the layer Claude Code provides and a Gem does not.
- **Compliance** — does it follow a procedure rather than summarise it? Retrieved text is reference material. Only the instruction field carries force on every turn.

Uploading the whole repo as knowledge closes Access and leaves the other two untouched: *searched when the model judges it relevant* is not *followed at the moment it applies*. This is why a fully ingested repo still needs compiled instructions.

That's what this skill writes — an explicit `if the request looks like X → retrieve Y → do Z` table, plus the repo's non-negotiable rules inlined so the thing still works on a turn where retrieval fails.

## How the pieces fit

| Piece | Holds | Lives |
|---|---|---|
| Compiled instructions | Routing table, invariants, retrieval and degradation rules | Pasted into the Gem/Project instruction field |
| The repo | Full text of every skill, doc, and convention | Retrieved on demand at a pinned commit |
| Knowledge bundles (optional) | The same repo text, pre-uploaded | For private repos or hosts whose browsing is unreliable |

## What you get

- **A single complete instruction text**, target ≤ 8,000 characters, ready to paste as-is — no tiers to choose between.
- **A routing table** keyed on how you actually phrase requests, not on skill names.
- **A degradation clause** — on a failed retrieval the host continues from the inline summary *and says so*, instead of confabulating.
- **Knowledge bundles**, for private repos or hosts with unreliable browsing (`scripts/bundle-knowledge.sh`).
- **Three probe prompts** with expected routing, so you can verify the port before trusting it.

## Use

In any agent with this skill installed:

```
Compile https://github.com/owner/repo into Gemini Gem instructions
```

Bundling on its own, without the skill:

```bash
./scripts/bundle-knowledge.sh https://github.com/owner/repo ./out --max-files 8
```

## Layout

| Path | What |
|---|---|
| [`SKILL.md`](SKILL.md) | The six-step procedure |
| [`references/instruction-template.md`](references/instruction-template.md) | The instruction skeleton, with filling notes and a worked routing table |
| [`references/host-notes.md`](references/host-notes.md) | Gemini / Grok / ChatGPT mechanics, private repos, and when the port is the wrong tool |
| [`references/repo-profiles.md`](references/repo-profiles.md) | Three repo archetypes and what changes per archetype |
| [`scripts/bundle-knowledge.sh`](scripts/bundle-knowledge.sh) | Concatenates a repo's markdown into upload-sized bundles |

## Install

Symlink into your agent's skill directory:

```bash
ln -s "$PWD" ~/.claude/skills/repo-to-project-instructions
```

## License

[MIT](LICENSE) © Ariel Lee

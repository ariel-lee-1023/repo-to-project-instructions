# repo-to-project-instructions

Compiles a body of source material into custom instructions for AI hosts that **cannot clone, run, or hold a live link to it** — Perplexity Projects, Gemini Gems, Grok Projects, ChatGPT Projects, or any bare system prompt.

The source can be a **git repository** (for hosts that can retrieve from a persistent link) or a **set of up to 10 local files the user uploads** (for hosts that only accept static knowledge uploads, no live link). Give it either one; it gives you a paste-ready instruction text plus, when needed, the knowledge files to upload alongside it. The host then works the way the source says to work, treating it as a knowledge base it retrieves from rather than a runtime it executes.

**Which mode applies is a property of the host, not a preference:**

| Host | Can hold a live retrievable link? | Mode |
|---|---|---|
| Perplexity Project | Yes — Project Knowledge persists uploaded files and a wiki, and instructions can point back at a repo path/URL that the assistant fetches on demand | **Repo-linked** |
| Gemini Gem | No — Gem Knowledge only accepts static uploads (files or Drive); it does not hold a live GitHub link | **Local-file** (≤ 10 files) |
| Grok / ChatGPT Project, generic | Varies — check `references/host-notes.md` | Either, per host |

**For repo-linked mode, the output is used together with the repo link, not in place of it.** The repo stays the source of truth and holds the full text of everything; the compiled instructions carry the index, the invariants, and the rules for reaching back into it.

**For local-file mode, there is no live source to reach back into.** The up-to-10 uploaded files *are* the source of truth for the life of the Gem. The compiled instructions still carry an index and routing across those files, but the retrieval and degradation machinery is simpler: a file is either in the upload set or it isn't, and there is no commit SHA to pin or go stale.

## Why

Handing a host a repo link (or a pile of uploaded files) leaves three gaps, and the link narrows only the first:

- **Access** — can the host see the content? A fetched repo URL returns the landing page, the README at best, and it will not walk a tree or open every `SKILL.md` unless handed each path. A Gem cannot hold a live repo link at all — see `references/host-notes.md`.
- **Routing** — does it know which file governs *this* request, and does it look before answering? Nothing in these hosts maps a request to a file and loads it first. That mapping is the layer Claude Code provides and neither a Gem nor a bare Project instruction field does on its own.
- **Compliance** — does it follow a procedure rather than summarise it? Retrieved text is reference material. Only the instruction field carries force on every turn.

Uploading everything as knowledge closes Access and leaves the other two untouched: *searched when the model judges it relevant* is not *followed at the moment it applies*. This is why a fully ingested source still needs compiled instructions.

That's what this skill writes — an explicit `if the request looks like X → retrieve Y → do Z` table, plus the source's non-negotiable rules inlined so the thing still works on a turn where retrieval fails.

## How the pieces fit

| Piece | Holds | Lives |
|---|---|---|
| Compiled instructions | Routing table, invariants, retrieval and degradation rules | Pasted into the Project/Gem instruction field |
| The repo (repo-linked mode) | Full text of every skill, doc, and convention | Retrieved on demand at a pinned commit, or held in Project Knowledge |
| The uploaded files (local-file mode) | Full text of what the user chose to bring, up to 10 files | Uploaded once to Gem Knowledge; there is no link to refresh |
| Knowledge bundles (optional, repo-linked mode) | The same repo text, pre-uploaded | For private repos or hosts whose browsing is unreliable |

## What you get

- **A single complete instruction text**, target ≤ 8,000 characters, ready to paste as-is — no tiers to choose between.
- **A routing table** keyed on how you actually phrase requests, not on skill or file names.
- **A degradation clause** — on a failed retrieval the host continues from the inline summary *and says so*, instead of confabulating.
- **Knowledge bundles**, for private repos or hosts with unreliable browsing (`scripts/bundle-knowledge.sh`) — repo-linked mode only.
- **Three probe prompts** with expected routing, so you can verify the port before trusting it.

## Use

Repo-linked, targeting a Perplexity Project:

```
Compile https://github.com/owner/repo into Perplexity Project instructions
```

Local-file, targeting a Gemini Gem — attach up to 10 files instead of a URL:

```
Here are the files I'm uploading to this Gem's Knowledge (attached, ≤10). Compile them into Gemini Gem instructions.
```

Bundling a repo on its own, without the skill (repo-linked mode only):

```bash
./scripts/bundle-knowledge.sh https://github.com/owner/repo ./out --max-files 8
```

## Layout

| Path | What |
|---|---|
| [`SKILL.md`](SKILL.md) | The six-step procedure, covering both modes |
| [`references/instruction-template.md`](references/instruction-template.md) | The instruction skeleton, with filling notes and a worked routing table |
| [`references/host-notes.md`](references/host-notes.md) | Perplexity / Gemini / Grok / ChatGPT mechanics, private repos, local-file limits, and when the port is the wrong tool |
| [`references/repo-profiles.md`](references/repo-profiles.md) | Four source archetypes and what changes per archetype, for either mode |
| [`scripts/bundle-knowledge.sh`](scripts/bundle-knowledge.sh) | Concatenates a repo's markdown into upload-sized bundles (repo-linked mode) |

## Install

Symlink into your agent's skill directory:

```bash
ln -s "$PWD" ~/.claude/skills/repo-to-project-instructions
```

## License

[MIT](LICENSE) © Ariel Lee

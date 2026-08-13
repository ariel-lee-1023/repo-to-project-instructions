# Host notes

What each host actually gives you, where the ports break, and the setup steps to hand the user.

**Verify limits in the product UI at build time.** Instruction-field caps, knowledge-file counts, and per-file size limits change without notice on all of these. Nothing below states a host-specific number, on purpose — Step 5 targets a single ≤ 8,000-character instruction text, which clears every host's field cap as of writing with room to spare, so a moved limit still costs at most a trim, not a rebuild.

## The three capabilities

Every host in scope offers some subset of:

1. **Persistent instructions** — a text field applied to every turn in the Gem/Project. Always present. Always capped.
2. **Knowledge files** — uploads the host searches when answering. Count and size capped; retrieval is semantic, so headings matter more than filenames.
3. **Fetch at answer time** — web access, or a persisted link back to a repo. The least reliable of the three on hosts that have it: available, then unavailable, then available again, sometimes silently. Some hosts (Gemini Gem, as of this writing) do not offer this capability at all for a git repo — see below.

The compiled instructions are pasted into (1) and are designed around (2) and (3) being where the source's actual content comes from where (3) exists. They must still degrade usefully when only (1) is working — a thinner answer that names what it could not reach, never a confident one built from nothing.

## Perplexity Project

A Project has **Name**, **Description**, **Instructions**, member/collaborator access, and a persistent **Knowledge** area that holds uploaded files and a project wiki, plus per-thread web search.

- **Instructions** is the field this skill's output goes into — same role as a Gem's Instructions field, applied on every thread started inside the Project.
- **Knowledge here is durable and file-based**, similar in mechanics to a Gem's Knowledge, but the Project also keeps its own wiki/notes that accumulate over time. Treat uploaded repo files or bundles the same way as Gem knowledge files: retrieval, not obligation — ROUTING in Instructions is still what makes the right file get used at the right moment.
- **This is the host to prefer when the source is a git repo and the user wants ongoing, linkable access to it** — unlike a Gem, a Project's Instructions can legitimately cite a repo path or raw URL as something to fetch on demand, and the Project's own Knowledge can hold an imported or bundled copy alongside that link as a fallback. This makes hybrid (Step 4) the natural default for a Project target, not just the fallback-when-in-doubt.
- Web-fetch reliability inside a Project thread should be verified the same way as any other host: run the Step 6 probes and check the citation display before trusting link-only.
- Setup to hand the user: create or open the Project → paste the complete instruction text into Instructions → add Knowledge (upload the bundles, or add the relevant files/wiki pages) → run the three probes from Step 6 before trusting it.

## Gemini Gem

The editor exposes **Name**, **Description**, **Instructions**, **Default tool**, **Knowledge** (Upload files / Add from Drive / Photos / Gemini Notebook), and a **Disable Knowledge Citations** toggle.

- Name and Description label the Gem in the picker. Behaviour goes in **Instructions** — that is the field applied on every turn. Do not spend instruction budget restating the description.
- **Gem Knowledge does not hold a live link back to a git repository.** It only accepts static uploads — files the user attaches, or files added from Drive. Pasting a GitHub URL into Knowledge does not create a persistent, refreshable source the way it might on a host with native repo import; treat any git repo as something that must be turned into files *before* it reaches Knowledge, not something the Gem retrieves from directly. This is why local-file mode (see `SKILL.md`) exists as its own path rather than a repo-linked fallback.
- **The practical workflow for a Gem is local-file mode: the user uploads up to 10 files, and those files are the entire Knowledge base for the Gem's lifetime.** If the source is a git repo, the user (or `bundle-knowledge.sh`) turns the relevant parts into a small set of files first — either the repo's own markdown files directly (if ≤10 and each under the size cap) or a handful of concatenated bundles. Either way, cap the count at 10 and design ROUTING around exactly those file names.
- **Knowledge is retrieval, not obligation.** Uploading every file makes the text findable; it does not make the Gem *run* the right unit at the right moment. That comes only from ROUTING in the instruction field. A fully ingested knowledge base still needs compiled instructions — this is the single most common wrong assumption about the port.
- **Default tool** — check what it offers. If a search or browsing tool can be set as the default, that increases reliability for anything the instructions ask it to look up on the open web, but it does not restore a live link to the source repo — that capability is not present in Gem Knowledge regardless of Default tool.
- **Disable Knowledge Citations** — leave citations *on* while probing. They are the only mechanical record of which file was actually retrieved, and therefore the only trustworthy way to tell a bad routing row from a bad answer. The model's own account of what it followed is not a substitute: a Gem has been observed opening a reply with *could not retrieve X* and closing it with *followed X*. Turn citations off only after the probes pass, and only if they intrude on the output.
- Knowledge retrieval is content-based. Bundles need the `===== FILE: <path> =====` headers *and* the unit's own headings intact — strip the headings and the right file stops surfacing.
- File and size caps: read them off the UI at build time; design the ≤10-file set around whatever the UI currently allows, and re-check before a refresh since caps move without notice.
- Setup to hand the user: create a Gem → paste the complete instruction text into Instructions → upload the ≤10 files under Knowledge → set a Default tool if a browsing one exists → run the three probes from Step 6 before trusting it.
- **Gemini Spark is a different product, not a Gem with a new name.** Spark is an always-on background agent (not a user-named, user-entered chat surface) that connects to Workspace, MCP-based third-party apps, and local files on macOS; it does not expose a persistent Instructions field or a Knowledge upload area the way a Gem does. Do not compile Gem-style instructions for Spark, and do not assume anything said here about Gem Knowledge applies to it — treat Spark as out of scope for this skill until it exposes an equivalent instruction/knowledge surface.

## Grok Project

- Project-level custom instructions plus uploaded files, and web/X search that is comparatively willing to fetch.
- Link-only is viable here more often than on Gemini, but keep the degradation clause anyway — willing is not the same as guaranteed.
- Grok follows terse imperative instructions well and tends to over-elaborate under long prose. Keep routing rows terse for this host even within the single instruction text.
- Setup: create a Project → paste into custom instructions → attach files → probe.

## ChatGPT Project

- Project instructions plus project files. Behaves closest to the template as written; the complete instruction text is usually fine as-is.
- Files are searched rather than fully loaded, so the same bundle-heading discipline applies.

## Generic / bare system prompt

Any host with a single system-prompt field and no uploads: paste the same complete instruction text and inline the invariants in full. With no retrieval and no files, the routing table degrades to a list of what the agent *cannot* reach — say that plainly in ROLE rather than pretending to a capability that is not there.

## When the answer is "not this"

- **Pure document corpus, no procedures** — a repo that is just reference material with no rules about how to work is better served by NotebookLM or plain file uploads than by a compiled instruction set. Say so instead of manufacturing a routing table over documents nobody routes on.
- **Repo whose value is executing scripts** — none of these hosts run code. The port is honest only for the parts that are instructions. Name the parts that will not survive.

## Private repos

Raw URLs require the file to be public. For a private repo:

- Knowledge-file strategy only (repo-linked mode), or switch to local-file mode outright if the target host is a Gem — either way, bundle or export from a local clone.
- The instructions must not contain raw URLs at all — a broken fetch attempt against a private repo produces a confident-sounding 404 narrative.
- Never put a token in the instruction text to make a raw URL work. If the user proposes it, decline and point at bundling.

## Local-file mode applies regardless of whether a repo exists

The ≤10-file path in `SKILL.md` is not only a workaround for private repos or for Gemini's lack of a repo link — it is also the correct mode whenever the user's actual source is just a folder of local files with no git repository behind it at all (notes, drafts, a personal reference set). Do not ask for a repo URL in that case; ask for the files directly and proceed exactly as described in `SKILL.md`'s local-file mode.

# Host notes

What each host actually gives you, where the ports break, and the setup steps to hand the user.

**Verify limits in the product UI at build time.** Instruction-field caps, knowledge-file counts, and per-file size limits change without notice on all of these. Nothing below states a number, on purpose — the tiering in Step 7 exists so a moved limit costs a paste, not a rebuild.

## The three capabilities

Every host in scope offers some subset of:

1. **Persistent instructions** — a text field applied to every turn in the Gem/Project. Always present. Always capped.
2. **Knowledge files** — uploads the host searches when answering. Count and size capped; retrieval is semantic, so headings matter more than filenames.
3. **Fetch at answer time** — web access. The least reliable of the three: available, then unavailable, then available again, sometimes silently.

The compiled instructions are pasted into (1) and are designed around (2) and (3) being where the repo's actual content comes from. They must still degrade usefully when only (1) is working — a thinner answer that names what it could not reach, never a confident one built from nothing.

## Gemini Gem

The editor exposes **Name**, **Description**, **Instructions**, **Default tool**, **Knowledge** (Upload files / Add from Drive / Photos / Import code / Gemini Notebook), and a **Disable Knowledge Citations** toggle.

- Name and Description label the Gem in the picker. Behaviour goes in **Instructions** — that is the field applied on every turn. Do not spend instruction budget restating the description.
- **Knowledge is retrieval, not obligation.** Uploading every unit makes the text findable; it does not make the Gem *run* the right unit at the right moment. That comes only from ROUTING in the instruction field. A fully ingested repo still needs compiled instructions — this is the single most common wrong assumption about the port.
- **Import code** ingests a codebase into Knowledge directly. When it accepts the repo, prefer it to `bundle-knowledge.sh`: fewer moving parts and no second copy to go stale. Verify what it actually takes (remote URL or local files, whether it recurses, whether markdown structure survives) before designing around it, and fall back to bundling if it does not.
- **Default tool** — check what it offers. If a search or browsing tool can be set as the default, that is the cheapest available increase in retrieval reliability, and it is what makes link-only worth considering here at all.
- **Disable Knowledge Citations** — leave citations *on* while probing. They show which file was actually retrieved, which is the fastest way to tell a bad routing row from a bad answer. Turn them off only after the probes pass.
- Browsing is inconsistent turn to turn. A Gem that depends on fetching a `SKILL.md` will work in testing and fail for the user a week later. **Default Gems to hybrid or knowledge-file strategy**, not link-only.
- Knowledge retrieval is content-based. Bundles need the `===== FILE: <path> =====` headers *and* the unit's own headings intact — strip the headings and the right file stops surfacing.
- File and size caps: read them off the UI at build time. Bundle when a cap binds; do not pre-bundle a repo that already fits.
- Setup to hand the user: create a Gem → paste FULL into Instructions → add Knowledge (Import code, or upload the bundles) → set a Default tool if a browsing one exists → run the three probes from Step 8 before trusting it.

## Grok Project

- Project-level custom instructions plus uploaded files, and web/X search that is comparatively willing to fetch.
- Link-only is viable here more often than on Gemini, but keep the degradation clause anyway — willing is not the same as guaranteed.
- Grok follows terse imperative instructions well and tends to over-elaborate under long prose. Prefer COMPACT as the starting tier and move up to FULL only if a probe fails.
- Setup: create a Project → paste into custom instructions → attach files → probe.

## ChatGPT Project

- Project instructions plus project files. Behaves closest to the template as written; FULL is usually fine.
- Files are searched rather than fully loaded, so the same bundle-heading discipline applies.

## Generic / bare system prompt

Any host with a single system-prompt field and no uploads: use MINIMAL or COMPACT, and inline the invariants in full. With no retrieval and no files, the routing table degrades to a list of what the agent *cannot* reach — say that plainly in ROLE rather than pretending to a capability that is not there.

## When the answer is "not this"

- **Pure document corpus, no procedures** — a repo that is just reference material with no rules about how to work is better served by NotebookLM or plain file uploads than by a compiled instruction set. Say so instead of manufacturing a routing table over documents nobody routes on.
- **Repo whose value is executing scripts** — none of these hosts run code. The port is honest only for the parts that are instructions. Name the parts that will not survive.

## Private repos

Raw URLs require the file to be public. For a private repo:

- Knowledge-file strategy only. Bundle from a local clone.
- The instructions must not contain raw URLs at all — a broken fetch attempt against a private repo produces a confident-sounding 404 narrative.
- Never put a token in the instruction text to make a raw URL work. If the user proposes it, decline and point at bundling.

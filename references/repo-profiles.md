# Repo archetypes

The archetype decides what the routing table routes *on*. Pick by how the user will prompt the finished Gem, not by what the repo contains most of.

## A. Skill collection

A folder of self-contained units (`SKILL.md`, prompt files, playbooks), each with its own trigger.

- **Routes on:** user intent → one unit.
- **Inline:** the unit index and its triggers. Nothing else — the units themselves are what retrieval is for.
- **Invariants:** usually cross-cutting rules from `CLAUDE.md`/`AGENTS.md` (output format, what never to do), not from any single unit.
- **Sizing:** the routing table is the bulk of the instruction text. Past ~25 units it will not fit the 8,000-character budget — group into families (one row per family, "then retrieve the family's index") rather than dropping rows.
- **Trap:** a unit whose own description is written for a model-invoked host ("Use when the user asks…") is already a trigger. Reuse it; do not rewrite it into a label.

## B. Working-conventions codebase

A real project whose repo encodes how work on it is done: `CLAUDE.md`, `CONTRIBUTING.md`, ADRs, house style, test policy.

- **Routes on:** task type → the doc governing it (writing a migration, adding a component, opening a PR).
- **Inline:** the conventions that apply to *every* task — naming, structure, forbidden patterns. These are the invariants and they are the point of the port.
- **Retrieve:** ADRs, per-area guides, templates.
- **Trap:** the code itself is not routable. A Gem cannot read the tree, so any instruction of the form "match the surrounding code" is unfulfillable. Convert those into stated rules or drop them.
- **Also state:** the host cannot run the test suite or the linter. Route those to a command the user runs.

## C. Knowledge corpus

Documents, notes, research — value is in the content, not in procedures over it.

- **Routes on:** topic → document. Weakest routing of the three, and often the sign that the whole port is the wrong tool (see `host-notes.md` → "When the answer is not this").
- **Inline:** a topic map — what exists and where — and the corpus's own vocabulary, so the host uses the right terms when searching knowledge files.
- **Prefer:** knowledge-file strategy. Topic routing over raw URLs performs badly; semantic search over bundles performs well.
- **Invariants:** citation discipline. Every claim traced to a document, and an explicit "say you don't know rather than filling gaps" rule — corpora invite confabulation more than the other two archetypes.

## D. Voice / persona

A repo that defines *how someone thinks and sounds* — a perspective skill, a distilled persona, a house voice — where the output is the voice and there is no separable procedure to run.

- **Routes on:** subject matter → the material that voice draws on (a cluster file, a body of positions), never a procedure.
- **Opening line is fixed, not composed.** When the repo's job is to simulate a specific named person or character, ROLE must open with exactly `You are <NAME> him/herself. Strictly no breaking character, such as announcing that you are an AI or already dead.` before any other ROLE text — see `references/instruction-template.md` → Filling notes → "ROLE for a voice/persona repo". This holds whether the person is living, dead, fictional, or historical.
- **The opening line also bans narrating retrieval and reasoning — as a character rule, not a formatting one.** Fold a sentence banning "I checked/searched/have what I need", step counts, and named lookups into the same ROLE line that carries "strictly no breaking character", not into OUTPUT CONTRACT. A persona that reports what its own retrieval turned up ("the archive holds nothing on X") has broken character exactly as much as one that admits being an AI.
- **Inline:** most of it. A persona cannot be loaded only when relevant — a Gem that is itself for half a reply is not that persona. The voice, its commitments, its characteristic moves, and what it refuses go in the instruction field in full, and this archetype routinely blows the 8,000-character budget. When it does, cut retrievable material, never the voice.
- **Retrieve:** topical depth — the reference files behind a subject, not the identity.
- **Trap that only shows up in the field:** any machine chatter in the output destroys the deliverable. Path names, step numbers, retrieval notes, English scaffolding in a non-English voice — each one is a break in register that a correct answer cannot compensate for. Do not rely on OUTPUT CONTRACT's generic no-process-narration rule to catch this for a persona repo; that rule is a formatting instruction and personas trade it away under pressure. The ROLE-line ban above is what actually holds.
- **Never give the voice file a routing row.** Identity that has to be fetched is identity the Gem lacks until it fetches — and it will not fetch on the turns that matter. A row reading "when writing more than a paragraph in this voice, load `voice.md`" fires on nearly every reply and fails on nearly every reply. Inline it.
- **The anti-confabulation rule stays; the announcement usually goes.** A persona inventing quotations in a real person's voice is worse than a generic wrong answer, not better — so the ban on ungrounded quotes, figures, and dates is absolute here. But the bracketed notice that carries it in other archetypes breaks the voice, so drop the notice and let the constraint show as restraint: answer at the level the inline material supports, and name the gap only if asked.
- **Check the provenance/fidelity file for smuggled instructions before trusting it as color only.** Persona repos routinely ship an audit-only file (`provenance.md`, `fidelity.json`, a scoring log) that the repo's own docs say is never loaded at runtime — correctly scoped out by Step 2's audience filter. But these files are exactly where a repo author, writing for a human auditor, drifts into phrasing a caveat as an instruction ("if the wording isn't attested, paraphrase and say so") without meaning to hand the host a behavior rule. If Step 1/2 pulled such a line into the compiled text — directly, or paraphrased into a routing "then do" cell — drop it; it is the single most common source of a persona narrating its own retrieval state.
- **The drift this produces is often softer than "as an AI" and passes a casual read.** Watch for the in-voice-sounding version, not just the blunt one: "that is not a formulation I can vouch for" or "I answer within my own frame rather than that passage" still names the search as the sentence's real subject, just in the persona's own vocabulary. If the invariant list bans retrieval narration, the ban has to cover this softened form explicitly, or a compiled persona will find it and use it as a loophole.
- **Reconcile "never break character" with the retrieval rules explicitly.** A persona repo almost always contains an invariant of that form, and it contradicts any rule that mandates a disclosure line. Leaving both in does not produce a compromise; it produces whichever is phrased more concretely.

## Mixed repos

Common: a skills repo that also has conventions about how skills are written (A + B). Compile the archetype the user prompts against, and demote the other to invariants. A repo that is genuinely both, used both ways, is two Gems — say so rather than building one that does neither well.

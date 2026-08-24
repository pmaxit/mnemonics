# Word Detail Page — Content Richness Plan

**Screen in scope:** `LearnWordDetailScreen` (`lib/features/home/presentation/screens/learn_word_detail_screen.dart`)
**Data model:** `VocabularyWord` (`lib/features/home/domain/vocabulary_word.dart`)
**Source of truth:** Postgres `vocabulary` table, served via `backend_api/app.py` (`GET /vocabulary`), Railway-hosted.

This doc captures the audit of what's actually in the word database today, what's
already built but unused, and a phased plan to get every word to "rich" —
including the fill-in-the-blank feature you asked for. Phase 0 (the
fill-in-the-blank UI + surfacing unused phrase data) is **already implemented**
in this session. Everything else is scoped but not yet executed, because it
needs either DB write access or LLM spend I can't authorize on my own.

---

## 1. What's actually in the database today

I couldn't hit the live Railway API/DB from this sandbox (network egress is
locked to an allowlist), so this is based on the bundled data snapshots
(`assets/Vocabulary_with_Insights.csv`, `assets/vocabulary.json`,
`output/vocabulary_sample.json`) plus the import/enrichment scripts and git
history. **Run `scripts/audit_vocabulary_richness.py` against the real DB to
get ground-truth numbers** — treat the below as "best evidence available
offline."

### Snapshot: 1004-word CSV (`assets/Vocabulary_with_Insights.csv`, stale since March)

| Field | Populated | Notes |
|---|---|---|
| `word` / `meaning` | 100% / 99.9% | good |
| `example` | 99% | one sentence only |
| `mnemonic` (human-authored) | **1%** | basically unused column |
| `synonyms` / `antonyms` (flat columns) | **1%** | almost entirely empty |
| `ai_mnemonic` | 99% | good, AI-generated, per-word |
| `ai_insights` | 100% | populated, but schema drifted over time (see §2) |
| `image_url` | **0.3%** (3/1004) | effectively no real images |
| `video_url` | 100% | **same single placeholder Big Buck Bunny URL for every word** — fake |
| `phrases` / `example_sentences` columns | **not present in this CSV at all** | see §2 |
| `definition` | not present in this CSV | UI always falls back to `meaning` |

### 1 confirmed data-quality bug
`Mopupunu` — a hallucinated non-word from an early AI-generation pass, with
`ai_insights` literally saying *"is not a recognized word in the English
language."* This needs to be deleted from the DB (and its slot backfilled).
(`aboveboard` also matched my grep for junk phrases but is a false positive —
it's a real word, the text just discusses transparency.)

### Newer pipeline (`scripts/db_filler/fill_gre_words.py`, last touched Aug 22)

This script is the **good** version — it already produces exactly the shape
we want:
- `definition` (GRE-friendly, distinct from `meaning`)
- `phrases`: 8-10 short 2-4 word collocations ("obfuscate the truth", "try to
  obfuscate", …)
- `exampleSentences`: 3 full natural sentences
- `synonyms` / `antonyms`: written into the flat DB columns properly
- `ai_mnemonic`: vivid, funny, sound-based mnemonic
- real per-word comic-style image via Pollinations + `comic_style.py`

I confirmed this in `output/vocabulary_sample.json` — a test run of exactly
this shape for the 13 original seed words, and it's genuinely good content
(see the `obfuscate`/`lucid`/`gregarious` entries in that file).

**The problem: it's unclear how much of the live 1004-word table has actually
been (re)processed through this pipeline vs. the stale March-era rows.**
`output/` only has that one 13-word sample plus 3 test images — there's no
evidence of a full production run. This is the #1 thing to verify first.

### Orphaned assets worth knowing about
- `lib/data/phrases.csv` (137 rows) — a generic B2/C1 collocation glossary
  ("build your vocabulary", "considerable amount"...) with Word/Type/Level/
  Meaning/Example/Mnemonic columns. **Not wired into the app anywhere** (zero
  code references). Not directly reusable per-GRE-word, but it's a good
  template for structure, and could become a standalone "Collocations" study
  set later.
- `assets/raw_gre_words.json` — 1000 *different* words (fawn, banal, …),
  the seed list `fill_gre_words.py` consumes, tagged for the newer
  `speech/intellect/character/conflict/morality/change` category system from
  `word_sets.json`. This is a second word set layered on top of the original
  SAT/GRE 1004, not yet (fully) enriched or imported.

---

## 2. Architecture gaps found (not just data gaps)

1. **`AiWordInsights` provider is dead code.** `ai_word_insights_provider.dart`
   + `AIService.generateWordInsights()` build a rich `WordInsights` object
   (definition, 12-15 phrases, 5 examples, synonyms, memory tip) — but it's
   never called from any screen (`grep` across `lib/` confirms zero UI
   references). Either wire it in as a fallback, or delete it — right now
   it's just unused surface area.
2. **Per-user LLM regeneration, not shared.** That same dead provider, if it
   *were* wired up, caches its output in the local Hive `UserWordData` —
   **per device**, not the shared vocabulary table. Every user who opened a
   word without cached insights would burn an LLM call and get slightly
   different content than everyone else. `fill_gre_words.py` already does
   this correctly (persists once, to the shared table) — the app should never
   generate content client-side into per-user storage.
3. **Client-side API key.** `AIService` reads `OPENROUTER_API_KEY` straight
   out of `.env` bundled with the Flutter app. Anyone who decompiles the app
   gets your OpenRouter key. Worth moving generation server-side (which
   `fill_gre_words.py` already models) and treating the client-side
   `AIService` as legacy/removable.
4. **`word.phrases` was fetched but never rendered.** The model parsed
   `phrases` from the API response, but the detail screen only ever used
   `word.contextSentences` (full sentences). The already-generated short
   collocations were sitting in memory, unused, on every single screen build.
   **Fixed in this session** — see §3.
5. **Synonyms/antonyms chips read the wrong field.** The UI read
   `word.synonyms` (the near-empty flat column, 1% populated) instead of
   falling back to the `synonyms` array already sitting inside `ai_insights`
   for the ~99% of words that have it. **Fixed in this session** for
   synonyms (antonyms have no AI-insights equivalent in the current schema —
   see recommendation in §4).
6. **Misleading naming.** `MysqlDatabaseService` actually talks to a
   Postgres-backed Flask API, not MySQL. Cosmetic, but worth a rename during
   any future refactor to avoid confusing the next person.

---

## 3. What's shipped in this session (no DB/API access needed, safe to ship)

All of this degrades gracefully — sections simply don't render if a word has
no data for them, so it's safe against the current inconsistent dataset.

1. **`VocabularyWord.effectivePhrases`** — new getter: uses the `phrases`
   column if present, else parses `common_phrases` out of `ai_insights` JSON.
   No content is wasted anymore.
2. **`VocabularyWord.effectiveSynonyms`** — same idea for `synonyms`.
3. **New "Common Phrases" section** on the word detail screen — renders
   `effectivePhrases` as chips. This is the "cover the broad spectrum of
   use-cases" ask: 8-10 short phrases per word spanning different contexts.
4. **New `FillInBlankCard` widget**
   (`lib/features/home/presentation/widgets/fill_in_blank_card.dart`) — takes
   a real usage sentence + the target word, masks the word (regex handles
   simple suffixes like "-ed"/"-ing"/"-s" so "obfuscated" still matches
   "obfuscate"), shows a blank the user taps to reveal. On reveal it shows the
   word highlighted plus the word's definition as a hint underneath. Exactly
   the "context given, word hidden, tap to learn" mechanic you asked for.
5. **New "Fill in the Blank" section** on the detail screen, built from up to
   3 of the word's real `contextSentences`.
6. Ran `flutter analyze` on all touched files — zero new errors (only
   pre-existing repo-wide `withOpacity` deprecation notices untouched by this
   change).

Not yet done in the UI (see backlog in §4): synonyms chip antonym-fallback,
removing the dead `video` placeholder rendering, and a proper "Word Origin"
section.

---

## 4. Phased plan for the rest

### Phase 1 — Ground truth + cleanup (needs DB access, no LLM spend)
- [ ] Run `scripts/audit_vocabulary_richness.py` (new, added this session)
      against the live DB. It reports per-field completion %, duplicate
      words, distinct `video_url` values, and any AI-insights text that
      admits a word isn't real. Writes the exact missing-word lists to
      `output/audit_missing_words.json` for phase 2 to consume.
- [ ] Delete `Mopupunu` (and anything else the audit flags as junk).
- [ ] Null out `video_url` where it's the shared placeholder — the video
      player should hide itself for words without a real per-word asset
      instead of showing an unrelated stock clip. (`vocabulary_word_image.dart`
      already has fallback patterns to model this on.)
- [ ] Backfill flat `synonyms`/`antonyms` columns from `ai_insights` where
      empty, so every consumer of the API (not just this screen) benefits,
      not only the two getters added in §3.

### Phase 2 — Run the enrichment pipeline to 100% coverage
- [ ] Confirm with `fill_gre_words.py`'s own completeness check
      (`get_completed_words`) how many of the 1004 words are missing
      `phrases`/`ai_mnemonic`/`ai_insights`/`image_url`, using the audit
      output from Phase 1.
- [ ] Run `fill_gre_words.py` (it already upserts safely — `ON CONFLICT
      (word) DO UPDATE`, and skips already-completed words) across the full
      table, not just the 6-category `raw_gre_words.json` seed list — extend
      `SOURCE_PATH` handling to also accept the existing 1004-word set so
      legacy rows get the same enrichment shape.
- [ ] Spot check a random sample of ~20 words post-run for quality (some
      `ai_insights` JSON in the sample output has minor trailing-key
      corruption from the LLM, e.g. a stray `"striving.": ".", ...` — worth a
      JSON-repair pass or stricter `response_format` validation before
      upsert).
- [ ] Generate real per-word images via `scripts/generate_word_images.py`
      (already builds nice 6-panel educational comics) for the ~1000 words
      that don't have one yet.
- **This phase costs real OpenRouter/Pollinations API spend and takes
  hours for ~1000 words — needs your go-ahead before running.**

### Phase 3 — UI polish once data is rich
- [ ] Antonym fallback: extend `fill_gre_words.py`'s `ai_insights` schema to
      also include `antonyms` (already generated into the flat DB column, so
      just also fold it into `ai_insights` for the getter-fallback pattern to
      work symmetrically with synonyms).
- [ ] "Word Origin / Etymology" collapsible section — the *older* enrichment
      pass already generated an `origin` field for many words (see the March
      CSV's `ai_insights.origin`); either preserve/reuse it during Phase 2's
      re-enrichment, or add an `origin` key to `fill_gre_words.py`'s prompt so
      it isn't lost when rows get overwritten.
- [ ] Retire or repurpose `AiWordInsights`/`AIService.generateWordInsights` —
      recommend deleting the client-side LLM call entirely once Phase 2 makes
      server-side content universally available, to close the API-key
      exposure and per-user-regeneration issues from §2.
- [ ] Rename `MysqlDatabaseService` → `VocabularyApiService` (naming only,
      whenever convenient — not urgent).

---

## 5. Research: other rich content worth adding

Roughly ordered by learning value vs. effort:

1. **Pronunciation** — IPA + audio (native TTS is enough quality for this;
   no need for a dedicated phonetics API). High value for a vocab app,
   currently completely absent.
2. **Word family / root** — e.g. *"gregarious"* shares the Latin root *grex*
   (flock/herd) with *segregate*, *aggregate*, *egregious*. A "same root"
   cross-link turns isolated words into a network, which is one of the
   highest-leverage memory techniques for GRE-style vocab. The old
   `ai_insights.origin` field is a starting point; formalize it into a
   structured `root` + `related_words` field.
3. **Part of speech + inflections** — noun/verb/adj tag, plus irregular
   forms. Cheap to generate, currently missing, and needed for grammatically
   correct fill-in-the-blank sentences at scale.
4. **Contextual tagging on phrases/examples** — `fill_gre_words.py`'s prompt
   already asks for phrases to "cover different contexts (behavior, science,
   society, emotions, academic writing)" but doesn't currently tag *which*
   context each phrase belongs to. Adding a `context` field per phrase
   (`{"phrase": "obfuscate the code", "context": "technology"}`) would let
   the "Common Phrases" chips be filterable, and directly serves your "cover
   the broad spectrum" ask with visible proof rather than just breadth by
   volume.
5. **Confusable words** — "commonly confused with X" (e.g. *complement* vs
   *compliment*). GRE test-writers love these; currently no field for it.
6. **Register / frequency tags** — formal vs. informal, GRE-frequency rank.
   Helps learners prioritize.
7. **"Which sentence uses this word correctly?" quiz** — a natural sibling
   to fill-in-the-blank, reusing the same `exampleSentences` + a couple of
   deliberately-wrong distractor sentences (generatable in the same LLM call
   that already produces the 3 example sentences).
8. **Difficulty-adaptive review** — nothing new to store, but the existing
   `UserWordData` accuracy stats could pick *which* example sentence to
   surface for fill-in-the-blank (easier/shorter sentence for a struggling
   word, harder one once mastered).

---

## 6. Suggested execution order

1. ~~Ship the fill-in-the-blank + common-phrases UI~~ — done this session.
2. You run `scripts/audit_vocabulary_richness.py` against the real DB (I
   can't reach it from here) and share the output — that tells us exactly
   how bad/good the live data is versus these stale local snapshots.
3. We fix the junk word + placeholder video (Phase 1) — quick, no LLM spend.
4. You green-light Phase 2 (the real enrichment run) since it costs API spend
   and runtime — I can drive the script execution once you confirm.
5. Phase 3 UI polish + cleanup follows once data is trustworthy.

Let me know if you want me to go ahead and run the audit script for you (I'd
need DB credentials that aren't in this sandbox's `.env`), or if you'd rather
run it yourself and paste back the output.

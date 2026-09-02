# Feature Opportunities — Research-Backed Analysis

Where AutiMate has room to grow, measured against what the established apps
in this domain actually do. **Nothing here is implemented.** Each entry
states what it is, the evidence behind it, honest pros *and* cons, effort,
and roughly how much code it would add.

Research sources are listed at the end.

---

## 1. Where the app stands today

| | AutiMate | The field |
|---|---|---|
| AAC vocabulary | **30 cards** | Proloquo2Go organises around a large core-word set; TD Snap and TouchChat ship multiple research-based page sets |
| Word layout | Category filter **re-flows the grid** | LAMP and Speak for Yourself keep every word in a **fixed position** for motor learning |
| Access methods | Touch only | Touch, switch scanning, eye gaze, dwell |
| Languages | English, Urdu | Most ship English only; Urdu is already a differentiator |
| Literacy support | Label under symbol | Formal Transition-to-Literacy features with published efficacy |
| Therapist tools | Free-text observations | Structured ABA-style data collection, session export |
| Cost model | Free/FYP | £230–£300 one-time, or ~£9/month |

**The honest read:** the architecture is in better shape than most FYP work —
tokens, tested boundaries, offline-first, a real backend behind a gate. The
*content* and the *access breadth* are where it is thin. A speech and
language therapist evaluating this would notice the 30-card vocabulary before
anything else.

---

## 2. Tier 1 — highest value

These are backed by published evidence and fill a gap that is real rather
than cosmetic.

### 1.1 Core vocabulary expansion with fixed motor-planning layout

**What.** Grow from 30 cards to a proper core set (150–400 words), and —
more importantly — stop moving them. Every word keeps one screen position
for the life of the profile; category filters *dim* non-matching cards
rather than re-flowing the grid.

**Evidence.** Core words make up roughly 80% of everyday communication.
LAMP's whole design rests on motor learning: a user finds a word by the
path their hand takes, not by reading the screen. **The current category
filter actively works against this** — it re-flows the grid, so "apple" is
in a different place depending on which filter is active. That is a design
defect, not just a missing feature.

**Pros**
- The single biggest credibility gain available. It moves the app from
  "demo vocabulary" to "usable communication system".
- Fixed positions compound: the child gets faster over months, not just
  familiar.
- Mostly data, so the risk is low and the work is parallelisable.
- Bilingual grammar metadata already exists — the realiser scales as-is.

**Cons**
- Someone must author 300+ Urdu translations with correct gender and
  SOV forms. That is genuinely hard and needs a native speaker.
- A fixed grid means more scrolling or paging for a small screen.
- Ideally validated by an SLP; without one, word choice is guesswork.
- Rewriting the filter to dim-not-reflow touches the flagship screen.

**Effort:** large · **~4,000–7,000 lines** (mostly catalog data + tests)

---

### 1.2 Switch access and scanning

**What.** Two-step selection: a highlight moves across the board on a timer
(or on a switch press), and a second press selects. Configurable scan speed,
row-column or linear scanning, and auditory scanning for low-vision users.

**Evidence.** Switch scanning is a standard AAC access method and the only
route in for users with severe motor impairment. Every premium app supports
it. Right now, a child who cannot reliably touch a target **cannot use
AutiMate at all.**

**Pros**
- Opens the app to a population currently excluded outright.
- Strong accessibility story for an FYP — this is the difference between
  "accessible-looking" and accessible.
- Reuses the existing focus/semantics work.
- Demonstrable without special hardware: an external keyboard or the volume
  keys can stand in for a switch.

**Cons**
- Genuinely hard to get right. Scan timing, resume behaviour, and
  mis-select recovery are all fiddly, and bad scanning is worse than none.
- Real validation needs a real switch user, which you likely cannot arrange.
- Adds a mode that every future screen must respect — permanent tax.
- Touches nearly every interactive widget.

**Effort:** large · **~2,500–4,000 lines**

---

### 1.3 Punjabi and Sindhi localisation

**What.** Add Punjabi (Shahmukhi) and Sindhi alongside English and Urdu.

**Evidence.** This is the most striking finding in the research. A review of
ASD mobile apps for Pakistan found Urdu apps show feasibility but lack
controlled efficacy evidence — and that **Punjabi is "a critical and entirely
unaddressed evidence gap" despite being the primary language of Pakistan's
largest population.** Sindhi is likewise unaddressed.

**Pros**
- **This is the strongest differentiator available to this project**, and it
  is uniquely available to you rather than to a US or UK team.
- The architecture already supports it: ARB files, RTL, a locale-aware type
  system. Adding a language is content work, not re-architecture.
- Turns the FYP from "another autism app" into something addressing a
  documented research gap in your own country.
- Publishable. A genuine contribution, not a class exercise.

**Cons**
- Translation volume is large and growing (265 keys and rising), and it must
  be *good* — machine translation would undermine the whole point.
- Punjabi Shahmukhi and Sindhi both need font and shaping verification, and
  Sindhi has extra characters beyond the Urdu set.
- The sentence realiser needs per-language grammar rules; Punjabi and Sindhi
  are not Urdu with different words.
- No native-speaker reviewer means no credibility gain at all.

**Effort:** medium–large · **~3,000 lines hand-written + ~7,000 generated**

---

### 1.4 Transition to Literacy (T2L)

**What.** Briefly animate the written word above the symbol when a card is
selected, then settle it beside the symbol. Optionally fade symbols out over
time as reading develops.

**Evidence.** A published study found participants improved at identifying
target words using T2L features, and most **generalised to a text-only
display** — that is, the feature helped them start reading, not just
communicate.

**Pros**
- One of the few AAC features with direct published efficacy.
- Small, self-contained, and fits the existing symbol tile.
- Serves the app's stated purpose: growth, not just substitution.
- Pairs naturally with the bundled Lexend typeface.

**Cons**
- The animation must respect reduced motion, which weakens the effect
  exactly where it might matter.
- Adding a moving element to the calmest screen needs care.
- Benefit varies enormously by child; not universal.

**Effort:** small · **~600–1,000 lines**

---

## 3. Tier 2 — strong additions

### 2.1 Visual timers and a waiting board

**What.** A depleting visual timer for transitions and waiting, plus a
dedicated "waiting" screen. Choiceworks builds four board types around
exactly this: schedule, waiting, feelings, and a feelings scale.

**Pros:** waiting is one of the hardest daily moments; a visible, shrinking
representation of time is a well-established support. Small build, reuses
`ProgressRing`. Complements the routine countdowns already shipped.

**Cons:** a continuously animating timer is precisely the ambient motion the
design system deliberately avoids — it needs a non-animated variant, and
that variant is much less useful. Some children fixate on the timer itself.

**Effort:** small · **~800 lines**

---

### 2.2 Recorded caregiver audio for cards

**What.** Let a caregiver record their own voice for a card instead of using
TTS. Choiceworks supports recorded audio; several AAC apps do.

**Pros:** a parent's real voice is more motivating than synthesis, and it
solves the Urdu TTS quality problem outright — which is a real risk on
low-end Pakistani devices. The custom-card record already has a `spokenEn` /
`spokenUr` field to extend.

**Cons:** needs a recording package and microphone permission — a second
sensitive permission after the camera. Audio files need storage management,
and recording a child's voice raises consent questions the project has not
addressed.

**Effort:** medium · **~1,200 lines**

---

### 2.3 Structured therapist data collection and export

**What.** Trial-by-trial recording (prompt level, independence, latency),
session summaries, and CSV/PDF export.

**Pros:** the field expects it — this is what turns the app into something a
therapist will actually adopt. Builds on the existing session model. Export
gives caregivers ownership of their data, which also closes the
"no data-export flow" finding in the security review.

**Cons:** **the highest-risk item here.** Structured behavioural coding sits
right at the edge of the scope's "no automatic behavioural labelling" line,
and prompt-level data is the raw material of ABA — which is contested within
the autistic community. Needs a clear framing decision before any code.

**Effort:** medium–large · **~2,500 lines**

---

### 2.4 Backup, restore, and profile transfer

**What.** Export a full profile — custom cards, routines, progress — as a
file, and import it on another device.

**Pros:** protects against device loss, which in this context means a child
losing their vocabulary. Enables school ↔ home transfer without a backend.
Reuses the existing JSON serialisation almost entirely.

**Cons:** an export file contains a child's name and history — a privacy
surface with no encryption story yet. Version migration becomes a permanent
obligation once files exist in the wild.

**Effort:** medium · **~1,500 lines**

---

### 2.5 Caregiver skills training module

**What.** Short, structured guidance modules for caregivers — modelling AAC
use, handling transitions, managing meltdowns.

**Evidence.** A cluster RCT in rural Pakistan found a technology-assisted,
family-volunteer-delivered parent skills training intervention effective for
children with developmental disorders. Tablet-based training of non-specialist
volunteers showed high acceptability and reach.

**Pros:** directly evidence-backed in *your* setting. Addresses a documented
unmet need in caregiver psychoeducation. Pure authored content — no new
technical risk. Distinctive: most apps target the child only.

**Cons:** large writing effort, and it must be accurate — bad advice here
causes real harm. Needs review by someone qualified. Straying toward clinical
guidance would break the project's own scope rules.

**Effort:** large (mostly writing) · **~3,000 lines**

---

### 2.6 Video modelling

**What.** Short caregiver-recorded videos showing a routine step or social
scenario, played before the child attempts it.

**Pros:** video modelling is a well-established autism intervention.
Personalised video of the child's own home is far more effective than stock
footage. Slots into the existing routine and story structures.

**Cons:** video storage is heavy on a low-end device. Recording, trimming,
and playback is a substantial build. Video of a child is the most sensitive
data the app could hold, and the privacy posture would need rethinking.

**Effort:** large · **~2,000 lines**

---

## 4. Tier 3 — smaller wins

| Feature | Value | Main drawback | Lines |
|---|---|---|---|
| **Word prediction** in the sentence strip | Faster construction for literate users | Little benefit for symbol-only users, who are the primary audience | ~800 |
| **Phrase bank** (saved whole sentences) | One tap for frequent requests | Can discourage generative language — a real AAC concern | ~600 |
| **Home-screen widget** for quick phrases | Speed in urgent moments | Platform-specific; needs device testing | ~700 |
| **Printable board** (PDF of the AAC grid) | Paper backup when the device dies; teachers love it | Needs a PDF dependency | ~900 |
| **Multiple grid sizes** (2×2 up to 6×8) | Match motor/visual ability | Interacts awkwardly with fixed motor planning | ~500 |
| **Emotion intensity scale** (1–5) | Beyond binary emotion labels; mirrors Choiceworks' Feelings Scale | Risks over-interpretation by caregivers | ~700 |
| **Guided breathing variants** (4-7-8, box) | Small, self-contained | Marginal over what exists | ~400 |
| **Achievements timeline** for caregivers | Motivating longitudinal view | Overlaps the existing dashboard | ~800 |

---

## 5. Deliberately not recommended

Worth stating so nobody proposes them later without knowing the reasoning.

| Feature | Why not |
|---|---|
| **Eye-gaze access** | Needs hardware that does not exist on a phone. Genuinely valuable, genuinely out of reach. |
| **AI chatbot companion** | Explicitly out of scope, and correctly so — it cannot be guardrailed for a child at this scale. |
| **Emotion detection claiming real feelings** | The whole ethical basis of the current classifier is that it reports appearance, not inner state. Crossing that line would undo it. |
| **Social/community feed** | Safety surface with no moderation capacity. |
| **Screen-time or compliance scoring** | Turns a support tool into a surveillance tool. |
| **Trained emotion model on children's faces** | Bias risk, consent problems, and it replaces an explainable system with a black box. |

---

## 6. On the 70,000-line target

Straight answer first: **line count is a poor measure of software quality,
and padding to hit a number would make this codebase worse.** A reviewer who
opens the repo and finds 40,000 lines of filler will trust the whole project
less. I would not do that, and you would not want the result.

That said, the number is reachable *honestly*, because several of these
features are genuinely content-heavy.

**Where the code is now:**

| | Lines |
|---|---|
| Hand-written Dart (`lib/`) | 15,274 |
| Generated localisation | 3,570 |
| Tests | 6,390 |
| **Dart total** | **25,234** |
| Docs, ARB, config, tooling | ~6,200 |
| **Repo total (text)** | **~31,400** |

**A credible route past 70,000:**

| Work | Adds |
|---|---|
| Core vocabulary → 400 cards, fixed layout (1.1) | ~6,000 |
| Punjabi + Sindhi: ARB + realiser rules (1.3) | ~3,000 |
| Generated localisation for two more languages | ~7,000 |
| Switch access and scanning (1.2) | ~3,500 |
| Therapist data collection + export (2.3) | ~2,500 |
| Caregiver training content (2.5) | ~3,000 |
| Video modelling (2.6) | ~2,000 |
| Backup/restore (2.4) | ~1,500 |
| Recorded audio (2.2) | ~1,200 |
| T2L, timers, Tier 3 selection | ~4,000 |
| **Tests at the current ~40% ratio** | **~14,000** |
| **Subtotal added** | **~47,700** |
| **New repo total** | **≈ 79,000** |

So the target is achievable on real work alone — and note that **tests are
the largest single contributor.** That is the healthy way to grow a line
count: the suite grows because the surface grew.

Two honest caveats. Generated localisation (~7,000 lines) is real output but
nobody wrote it, so I would not count it as your work in a report. And the
AAC catalog is data rather than logic — still legitimate, but a reader can
tell the difference, so it is worth being upfront about the split in your
write-up rather than quoting one big number.

---

## 7. Suggested order

1. **Punjabi + Sindhi (1.3)** — the strongest differentiator, and a documented research gap. Start recruiting translators now; it is the long pole.
2. **Core vocabulary + fixed layout (1.1)** — biggest credibility gain, and it fixes a real design defect in the current filter.
3. **T2L (1.4)** — small, evidence-backed, visible in a demo.
4. **Backup/restore (2.4)** — also closes the security review's data-export finding.
5. **Switch access (1.2)** — the accessibility centrepiece, but budget properly for it.
6. **Caregiver training (2.5)** — evidence-backed for your setting; start writing early.
7. Everything else as time allows.

**If you only do one thing:** Punjabi and Sindhi. It is the only item on this
list that no other team in the world is currently doing, and it is squarely
within reach of the architecture you already have.

---

## Sources

- [Design Specifications of AAC Applications (IJTE)](https://files.eric.ed.gov/fulltext/EJ1378311.pdf)
- [Best AAC Apps for Autism, Compared: TD Snap vs TouchChat (2026)](https://www.spectrumunlocked.com/blog/best-aac-apps-and-devices)
- [AAC Apps review — Speech and Language Kids](https://www.speechandlanguagekids.com/aac-apps-review/)
- [Effects of an AAC App with Transition to Literacy Features](https://journals.sagepub.com/doi/10.1177/1540796920911152)
- [Core Vocabulary in AAC: An SLP Guide to First Words](https://quicktalkerfreestyle.com/blog/aac-core-vocabulary-slp-guide/)
- [AAC Apps Cheat Sheet: Top 7 Digital AAC Apps of 2025](https://simplihere.com/cheat-sheet-top-7-digital-aac-apps-2025/)
- [Switch access scanning](https://en.wikipedia.org/wiki/Switch_access_scanning)
- [Alternative access and accessibility — AssistiveWare](https://www.assistiveware.com/alternative-access-and-accessibility)
- [Access methods for AAC — Tobii Dynavox](https://www.tobiidynavox.com/pages/access-methods-for-aac)
- [Multi-modal access (eye-tracking + switch-scanning)](https://pmc.ncbi.nlm.nih.gov/articles/PMC9136588/)
- [Choiceworks — App Store](https://apps.apple.com/us/app/choiceworks/id486210964)
- [Top Autism & ABA Therapy Apps and Digital Tools in 2026](https://ouva.co/blog/top-autism-aba-therapy-apps-digital-tools-2026/)
- [Technology-assisted task-sharing for developmental disorders in rural Pakistan](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC9479305/)
- [Family-volunteer-delivered parent skills training in rural Pakistan (cluster RCT)](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC8165981/)
- [Creating Supportive Educational Environments for Students with Autism in Pakistan](https://www.researchgate.net/publication/398328044_Creating_Supportive_Educational_Environments_for_Students_with_Autism_in_Pakistan)
- [Usability guidelines for autism app UI](https://www.researchgate.net/publication/327924872_A_review_on_usability_guidelines_for_designing_mobile_apps_user_interface_for_children_with_autism)

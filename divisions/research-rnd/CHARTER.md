# DEPARTMENT CHARTER — Research / R&D
## Division 7. The one that asks what this could become.

**Status:** founding charter, for the founder/board. Authored by the CEO function.
**Why it's its own organ:** Security asks "is the thing we built safe?" Design asks
"is it humane?" QA asks "is it proven?" None of them ask **"does the thesis
generalize, and what's the frontier?"** That forward-looking question — portability,
new substrates, the attack-class theory, and the side-quest incubator — is real
work that deserves an owner rather than living in the cracks of the EVALUATE phase.

---

## 1. MANDATE
Explore and *prove concepts* at the edge of the project: prove the protocol is
genuinely substrate-agnostic, push the theory behind the attack class, and incubate
the side quests. Hand proven concepts to Development; hand open questions to the
sprint-priority conversation.

Its product is **proven possibility** — "yes, this generalizes, here's the proof"
or "no, here's where it breaks."

---

## 2. WHAT IT OWNS
- **The portability proof** — the `RealtimeStore` / `Identity` abstractions and the
  4-way matrix (SpacetimeDB+OIDC vs. Postgres+keypair), scoped to communication
  payloads. This **is the lifecycle's PORTABILITY phase** — R&D owns it the way
  Security owns AUDIT. Proving a second substrate is the deliverable that generalizes
  the whole threat model.
- **New-substrate exploration** — does the protocol's "any compliant substrate +
  any identity primitive" claim actually hold? R&D is where that gets tested before
  it's asserted.
- **The attack-class research frontier** — the *general/theoretical* form of
  write-to-execute. (Shared border with Security: Security reproduces concrete
  instances on *our* system; R&D explores the general class. Both feed the living
  article — Security the evidence, R&D the theory.)
- **The side-quest incubator** — the Elpis Orrery / voxel display and future "what
  if" explorations. The legitimate home for the things that aren't on the critical
  path but might matter later. (Where tonight's side quests live.)

## 3. THE LINE IT HOLDS
- **It proves concepts; it does not ship products.** A proven concept is *handed to
  Development* to productize under the normal gates — R&D's prototype is not a
  shippable artifact and skips no gate on its way to becoming one.
- It **does not override Security or QA** — a research result that's exciting is
  still subject to the adversary and the gate before it touches anything real.
- Side quests with a physical/cost dimension (the display hardware) respect that
  **money is an object for hardware** even though it isn't the org's goal — R&D
  scopes cost honestly, the founder approves spend.

## 4. RELATIONSHIP TO THE OTHER ORGANS
- **EVALUATE phase** is co-owned: Security owns the *threat-model* evaluation, R&D
  owns the *capability/portability* frontier; together they feed the next sprint.
- The **living article** is co-fed: R&D's theory + Security's reproduced instances.
- **Development** receives proven concepts to build; **QA** gates them like anything
  else.
- **CEO function** sets research priority within the sprint cadence; **Founder/board**
  approves any spend and any result that would go public (a published generalization
  of the attack class is a Security-flagged, founder-disposed disclosure decision).

## 5. ANTI-IDLE BACKLOG
Build the RealtimeStore/Identity proof matrix; stand up a second substrate end-to-end;
sharpen the attack-class theory for the article; prototype and cost the side quests;
scan the field for prior art and adjacent techniques. The frontier is never fully
mapped.

## 6. NOT
Not a shipping division (hands concepts to Development). Not above Security/QA. Not a
license to spend without the founder. Not the owner of the disclosure decision
(Security-flagged, founder-disposed).

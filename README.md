# [B]adAzs Warrior – MODULAR TACTICAL SUITE (v17 Beta)

**Battle Analysis Driven Assistant Zmart System**
*Turtle WoW Edition – Core Attack API*
<a href="https://www.paypal.com/donate/?hosted_button_id=VLAFP6ZT8ATGU">
  <img src="https://github.com/ThePeregris/MainAssets/blob/main/Donate_PayPal.png" alt="Tips Appreciated!" align="right" width="120" height="75">
</a>

-------------------
**TECHNICAL MANIFESTO | BadAzsWarrior**

**Version:** v17 Beta
**Target:** Turtle WoW (Client 1.12.x – LUA 5.0)
**Architecture:** Modular Combat Engine + Core Attack API
**Author:** ThePeregris

BadAzsWarrior is a **Decision Support System (DSS)** focused on real combat, not theoretical simulation. The engine prioritizes attack safety, rage control, clip prevention, and conscious automation, fully respecting the limitations of Vanilla WoW.

✔️ Fire & Forget
✔️ No artificial loops
✔️ No mandatory dependency on external addons

---

## 2. CORE FEATURES (What the script actually does)

### ⚔️ Core Attack API

All modules use **BadAzs_StartAttack()** — a direct call to the Core API, ensuring:

* Safe Auto-Attack initiation
* No “attack drop”
* Full compatibility with Turtle WoW

---

### 🧠 Dynamic Dump System (Dual Mode)

Rage expenditure is controlled by **DumpMode**, configurable in real time:

#### 🔹 SLAM MODE (Default)

* Slam priority

**Thresholds:**

* Slam: Rage > 15
* Heroic Strike: Rage > 60

**Ideal for:**

* Arms 2H
* Sustained damage
* Better DPR (Damage per Rage)

#### 🔸 HS MODE

* Heroic Strike priority

**Thresholds:**

* Slam: Rage > 50
* Heroic Strike: Rage > 35–40

**Ideal for:**

* Heavy movement
* Fury
* Threat generation

📌 **Configuration:**

```
/baconfig mode [slam | hs]
```

---

### ⛔ Anti-Clip Protocol (Slam Lock)

The system never allows consecutive Slams.

* Internal cooldown: 3.0 seconds

**Guarantees:**

* At least 1 white hit
* Natural rage regeneration
* Zero “Slam starvation”

---

## 3. KEY MODIFIERS (Tactical Overrides)

### ⌨️ CTRL — Tactical Intercept

In combat:

* Intercept is blocked by default
* Holding CTRL authorizes:

  * Switch to Berserker Stance
  * Intercept usage
  * Automatic return to normal flow

Prevents accidental pulls and raid deaths.

---

### ⌨️ ALT — AoE Protocol (Crowd Control)

Completely replaces the single-target rotation:

**Arms / Fury**

* Sweeping Strikes
* Whirlwind
* Cleave (if rage allows)

**Tank**

* Thunder Clap
* Cleave
* Multi-target aggro maintenance

---

### ⌨️ SHIFT

Reserved (no active function in the current code).

---

## 4. COMBAT MODULES

### 🛡️ /batank — TANK

**Role:** Mitigation + Threat

* Forces Defensive Stance
* Auto-equip Shield (if ItemRack is active)

**Priority:**

* Shield Block

* Thunder Clap

* Automatic Taunt if aggro is lost

* Shield Slam (if available)

* Revenge

* Sunder Armor

* Heroic Strike only with Rage > 40

---

### ⚔️ /baarms — ARMS (2H)

**Role:** Consistent damage + fine control

* Mandatory Battle Stance
* Absolute Execute < 20%
* Mortal Strike / Bloodthirst
* Master Strike (if available)
* Rend applied if missing
* Slam controlled by Swing Timer
* Automatic Battle Shout

---

### 🔥 /bafury — FURY (DW)

**Role:** High pressure and burst

* Fixed Berserker Stance
* Auto-equip Dual Wield
* Bloodrage + Berserker Rage in combat
* Bloodthirst / Whirlwind
* Execute < 20%
* Heroic Strike according to Dump Mode
* Automatic Battle Shout

---

## 5. ITEMRACK (Optional)

Native support for ItemRack, if enabled:

```
/badazs itemrack on
/badazs itemrack off
```

**Expected sets:**

| Set | Function        |
| --- | --------------- |
| TH  | Two-Hand        |
| DW  | Dual Wield      |
| WS  | Weapon + Shield |

📌 The script does not break if ItemRack is not installed.

---

## 6. ERROR FILTER SYSTEM

The addon intercepts irrelevant system messages:

* “Not ready”
* “Out of range”
* “Another action is in progress”
* “Must be facing”

**Result:**
✔️ Clean chat
✔️ Zero visual spam
✔️ Better visibility of real events

---

## 7. DEPENDENCIES

**Required**

* None

**Optional (Recommended)**

* ItemRack → Automatic weapon swapping
* UnitXP_SP3 → Advanced cooldown detection

---

## 8. QUICK COMMANDS

| Command             | Action     |
| ------------------- | ---------- |
| /baarms             | Arms       |
| /bafury             | Fury       |
| /batank             | Tank       |
| /badazs             | Status     |
| /baconfig mode slam | Slam Focus |
| /baconfig mode hs   | HS Focus   |

---

## BADAZS PHILOSOPHY

This is not a bot.
This is not a dumb script.
**It is a combat copilot.**

BadAzsWarrior reacts to real gameplay, respects the player, and never tries to “play by itself.”

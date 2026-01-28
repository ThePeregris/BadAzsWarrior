# [B]adAzs Warrior - MODULAR TACTICAL SUITE (v12.2)
Battle Analysis Driven Assistant Zmart System - Turtle WoW Edition 2026
<a href="https://www.paypal.com/donate/?hosted_button_id=VLAFP6ZT8ATGU">
  <img src="https://github.com/ThePeregris/MainAssets/blob/main/Donate_PayPal.png" alt="Tips Appreciated!" align="right" width="120" height="75">
</a>

## 1. TECHNICAL MANIFESTO | BadAzsWarrior

**Version:** v12.2 STABLE (Anti-Clip Edition)
**Target:** Turtle WoW (Client 1.12.1 - Patch 1.17.2+)
**Architecture:** Agnostic Decision Engine + Contextual Safety Protocols
**Author:** **ThePeregris**

**BadAzsWarrior** is a "Fire & Forget" Decision Support System (DSS). It moves away from complex, heavy frameworks to provide a lightweight, lag-free rotation engine that respects the vanilla WoW Global Cooldown mechanics.

---

## 2. TACTICAL MODIFIERS (The Power User Layer)

The core of **BadAzs** intelligence lies in its ability to interpret key modifiers to override standard rotations. This allows for complex combat maneuvers without changing your keybinds.

### ⌨️ [CTRL] - The Safety Intercept
* **Function:** Enables Gap-Closing in combat.
* **Logic:** By default, **BadAzs** disables `Intercept` to prevent accidental pulls or deaths in Raids. Holding **CTRL** signals the engine that the movement is intentional. The system will then:
    1. Switch to **Berserker Stance**.
    2. Fire `Intercept`.
    3. Return to the module's primary rotation.

### ⌨️ [ALT] - The AoE Override (The Blender)
* **Function:** Switches the target priority from Single-Target to Multi-Target (AoE).
* **Logic:** While **ALT** is held, the internal "Nuke" logic is bypassed for the **AoE Protocol**:
    * **Arms/Fury:** Prioritizes `Sweeping Strikes` > `Whirlwind` > `Cleave`.
    * **Tank:** Prioritizes `Thunder Clap` (Defensive Stance) > `Cleave`.

### ⌨️ [SHIFT] - Reserved
* **Function:** Reserved for future expansion (Dynamic CC / Pummel logic). currently acts as a standard rotation modifier.

---

## 3. CORE MODULES / SLASH COMMANDS

| Command | Modifiers | Primary Action | Context |
| :--- | :--- | :--- | :--- |
| **`/barms`** | None | MS/BT + Overpower + **Anti-Clip Slam** | 2-Handed Weapon / Solo / Leveling |
| | **+ ALT** | Sweeping Strikes + Whirlwind | Cleaving Multiple Mobs |
| | **+ CTRL** | Tactical Intercept | Closing Gaps Safely |
| **`/bfury`** | None | BT/MS + Whirlwind + Heroic Strike | Dual Wield / High Performance Raid |
| | **+ ALT** | Whirlwind + Cleave Spam | Maximum AoE DPS |
| | **+ CTRL** | Tactical Intercept | Closing Gaps Safely |
| **`/btank`** | None | Shield Block + Auto-Taunt + Revenge | Mitigation & Threat |
| | **+ ALT** | Thunder Clap + Cleave | Holding Group Aggro |

---

## 4. THE AGNOSTIC ENGINE & LOGIC

### 🧠 Zero-Inference Architecture
The system scans your spellbook. If you are Arms but have `Bloodthirst`, it will use it. If you are Fury but have `Mortal Strike`, it adapts. It does not force you to play a specific meta.

### 🛡️ The Anti-Clip Slam Protocol (v12.2 Feature)
Slam is a powerful tool in Turtle WoW, but spamming it reduces DPS by resetting your weapon swing. **BadAzs** solves this:
1.  **Swing Analysis:** It checks `SP_SwingTimer`. If your swing is almost complete (<1.0s), it queues Slam.
2.  **The Lockout:** Once Slam is fired, the engine **locks Slam usage for 3.0 seconds**.
3.  **Result:** This forces a mandatory "White Hit" (Auto Attack) between Slams, guaranteeing Rage generation and preventing the "Infinite Slam Loop" that starves Warriors.

### 🩸 Rage Management
* **Recovery:** Pro-actively fires `Bloodrage` if Rage < 30 to keep the rotation moving.
* **Dump:** Executes `Heroic Strike` only if Rage > 60 to prevent wasting resources.
* **Hamstring Policy:** In this stable version, Hamstring is **manual only**. The script reserves rage for damage. Use your keybinds for snaring.

---

## 5. INSTALLATION & REQUIREMENTS

1.  Place the `BadAzsWarrior` folder in `Interface/AddOns/`.
2.  **Required Addons:** None (The core functions standalone).
3.  **Recommended Addons:** * `SP_SwingTimer` (Required for precision Slam-weaving).
    * `ItemRack` (Enables auto-swapping 2H/DualWield/Shield).

### ItemRack Configuration
To enable automatic weapon swapping based on Stance/Spec:
* `/badazs itemrack on` - Activates the module (Requires ItemRack sets named: "TH", "DW", "WS").
* `/badazs itemrack off` - Disables swapping (Default).

=========================================================================
**BadAzsWarrior - Precision is not an option, it's a requirement.**

---

# INSTRUÇÕES (PT-BR)

## PROTOCOLOS TÁTICOS

O **BadAzs** utiliza teclas modificadoras para permitir decisões rápidas sem alterar o seu macro principal.

### ⌨️ [CTRL] - Avanço Seguro
* Em combate, o `Intercept` é bloqueado para evitar acidentes. Segure **CTRL** para sinalizar ao motor que você deseja avançar. O sistema mudará para Berserker Stance e usará o Intercept automaticamente.

### ⌨️ [ALT] - Sobrecarga AoE (O Liquidificador)
* Segurar **ALT** muda a prioridade para dano em área. Em vez de focar em um alvo, o Guerreiro usará `Whirlwind`, `Sweeping Strikes` e `Cleave` para destruir grupos de inimigos.

---

### MÓDULOS DE ROTAÇÃO

* **/barms:** Foco em impacto (2H). Inclui a nova **Trava Anti-Clip de 3s** para o Slam, impedindo que você cancele seus ataques automáticos.
* **/bfury:** Foco em velocidade (DW). Prioriza Bloodthirst e usa Heroic Strike para queimar excesso de raiva.
* **/btank:** Foco em proteção. Mantém Shield Block ativo e usa **Auto-Taunt** se o mob virar em um aliado (Target of Target).

=========================================================================
**BadAzsWarrior - Precisão não é uma opção, é um requisito.**

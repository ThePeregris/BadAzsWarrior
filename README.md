# [B]adAzs Warrior - MODULAR TACTICAL SUITE (v13.0)
Battle Analysis Driven Assistant Zmart System - Turtle WoW Edition 2026
<a href="https://www.paypal.com/donate/?hosted_button_id=VLAFP6ZT8ATGU">
  <img src="https://github.com/ThePeregris/MainAssets/blob/main/Donate_PayPal.png" alt="Tips Appreciated!" align="right" width="120" height="75">
</a>

## 1. TECHNICAL MANIFESTO | BadAzsWarrior

**Version:** v13.0 (Dual Mode Engine)
**Target:** Turtle WoW (Client 1.12.1 - Patch 1.17.2+)
**Architecture:** Agnostic Decision Engine + Dynamic Priority Switch
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
* **Function:** Reserved for future expansion. Currently acts as a standard rotation modifier.

---

## 3. CORE MODULES & COMMANDS

| Command | Modifiers | Primary Action | Context |
| :--- | :--- | :--- | :--- |
| **`/barms`** | None | MS/BT + **Dual Mode Logic** | 2-Handed Weapon / Solo / Leveling |
| | **+ ALT** | Sweeping Strikes + Whirlwind | Cleaving Multiple Mobs |
| | **+ CTRL** | Tactical Intercept | Closing Gaps Safely |
| **`/bfury`** | None | BT/MS + Whirlwind + **Dual Mode Logic** | Dual Wield / High Performance Raid |
| | **+ ALT** | Whirlwind + Cleave Spam | Maximum AoE DPS |
| | **+ CTRL** | Tactical Intercept | Closing Gaps Safely |
| **`/btank`** | None | Shield Block + Auto-Taunt + Revenge | Mitigation & Threat |
| | **+ ALT** | Thunder Clap + Cleave | Holding Group Aggro |

### ⚙️ System Configuration (New in v13.0)
You can now switch the engine's priority between Slam and Heroic Strike on the fly.

* **`/badazs mode slam`** - Sets priority to **Slam Focus** (Default). Best for sustained DPS with 2H weapons.
* **`/badazs mode hs`** - Sets priority to **Heroic Strike Focus**. Best for high movement fights, dual wield, or high threat generation.
* **`/badazs itemrack on`** - Enables automatic weapon swapping (Requires ItemRack sets: "TH", "DW", "WS").
* **`/badazs itemrack off`** - Disables swapping.

---

## 4. THE AGNOSTIC ENGINE & LOGIC

### 🧠 The Dual Mode Engine (v13.0 Feature)
The script adapts its Rage Dump strategy based on your selected mode:
1.  **SLAM MODE (Efficiency):** Prioritizes `Slam` whenever Rage > 15. Only uses `Heroic Strike` if Rage is overflowing (> 60). Ideal for maximizing Damage Per Rage (DPR).
2.  **HS MODE (Aggression):** Prioritizes `Heroic Strike` whenever Rage > 35. Only uses `Slam` if Rage is overflowing (> 50). Ideal for Tanking or Heavy Movement fights.

### 🛡️ The Anti-Clip Protocol
Regardless of the mode, the engine protects your Auto-Attack timer:
* **The Lockout:** Once a Slam is fired, the engine **locks Slam usage for 3.0 seconds**.
* **Result:** This forces a mandatory "White Hit" (Auto Attack) between Slams, guaranteeing Rage generation and preventing the "Infinite Slam Loop" that starves Warriors.

### 🏃 Fluid Gap Closing
The engine intelligently manages `Charge`. If you are out of combat but out of range, the script **will not stall**. It will attempt to Charge, but if it fails (due to distance), it continues to execute Auto-Attacks and Stance Swaps, ensuring fluid gameplay while approaching the target.

### 🩸 Rage Management
* **Recovery:** Pro-actively fires `Bloodrage` if Rage < 30 to keep the rotation moving.
* **Execution:** If Target HP < 20%, **Execute** takes absolute priority, overriding both Slam and HS logic.

---

## 5. INSTALLATION & REQUIREMENTS

1.  Place the `BadAzsWarrior` folder in `Interface/AddOns/`.
2.  **Required Addons:** None (The core functions standalone).
3.  **Recommended Addons:** * `SP_SwingTimer` (Required for precision Slam-weaving).
    * `ItemRack` (Enables auto-swapping 2H/DualWield/Shield).

=========================================================================
**BadAzsWarrior - Precision is not an option, it's a requirement.**

---

# INSTRUÇÕES (PT-BR)

## NOVIDADE v13.0: MODO DUPLO
Agora você pode escolher como o Warrior gasta a raiva extra:
* **/badazs mode slam:** Foco em Slam (Dano Sustentado).
* **/badazs mode hs:** Foco em Heroic Strike (Movimentação/Aggro).

## PROTOCOLOS TÁTICOS
O **BadAzs** utiliza teclas modificadoras para permitir decisões rápidas sem alterar o seu macro principal.

### ⌨️ [CTRL] - Avanço Seguro
* Em combate, o `Intercept` é bloqueado para evitar acidentes. Segure **CTRL** para sinalizar ao motor que você deseja avançar. O sistema mudará para Berserker Stance e usará o Intercept automaticamente.

### ⌨️ [ALT] - Sobrecarga AoE (O Liquidificador)
* Segurar **ALT** muda a prioridade para dano em área. Em vez de focar em um alvo, o Guerreiro usará `Whirlwind`, `Sweeping Strikes` e `Cleave` para destruir grupos de inimigos.

---

### MÓDULOS DE ROTAÇÃO

* **/barms:** Foco em impacto (2H). Inclui a **Trava Anti-Clip de 3s** para o Slam.
* **/bfury:** Foco em velocidade (DW). Prioriza Bloodthirst.
* **/btank:** Foco em proteção. Mantém Shield Block ativo e usa **Auto-Taunt**.

=========================================================================
**BadAzsWarrior - Precisão não é uma opção, é um requisito.**

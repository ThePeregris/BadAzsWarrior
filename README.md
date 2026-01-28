# [B]adAzs Warrior - MODULAR TACTICAL SUITE (v11.5)
Battle Analysis Driven Assistant Zmart System - Turtle WoW Edition 2026
<a href="https://www.paypal.com/donate/?hosted_button_id=VLAFP6ZT8ATGU">
  <img src="https://github.com/ThePeregris/MainAssets/blob/main/Donate_PayPal.png" alt="Tips Appreciated!" align="right" width="120" height="75">
</a>

## 1. TECHNICAL MANIFESTO | BadAzsWarrior

**Version:** v11.5 GOLD MASTER

**Target:** Turtle WoW (Client 1.12.1 - Patch 1.17.2+)

**Architecture:** Agnostic Decision Engine + Contextual Safety Protocols

**Author:** **ThePeregris**

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



### ⌨️ [SHIFT] - Tactical Utility (Dynamic Focus)

* **Function:** Manually forces utility checks or stances.
* **Logic:** (Suggested for future v11.6 expansion) Forcing `Pummel` or `Shield Bash` regardless of the current rotation state.

---

## 3. CORE MODULES / SLASH COMMANDS

| Command | Modifiers | Primary Action | Context |
| --- | --- | --- | --- |
| **`/barms`** | None | MS/BT + Master Strike + Slam | 2-Handed Weapon / Solo / Leveling |
|  | **+ ALT** | Sweeping Strikes + Whirlwind | Cleaving Multiple Mobs |
|  | **+ CTRL** | Tactical Intercept | Closing Gaps Safely |
| **`/bfury`** | None | BT/MS + Master Strike + WW | Dual Wield / High Performance Raid |
|  | **+ ALT** | Whirlwind + Cleave Spam | Maximum AoE DPS |
|  | **+ CTRL** | Tactical Intercept | Closing Gaps Safely |
| **`/btank`** | None | Shield Block + Shield Slam + Revenge | Mitigation & Threat |
|  | **+ ALT** | Thunder Clap + Cleave | Holding Group Aggro |

---

## 4. THE AGNOSTIC ENGINE & RAGE MANAGEMENT

* **Zero-Inference Spec:** The system scans your spellbook. If you are Arms but have `Bloodthirst`, it will use it. If you are Fury but have `Mortal Strike`, it adapts.
* **Rage Recovery (<30 Rage):** pro-actively fires `Bloodrage` to prevent rotation stalling.
* **Rage Dump (>90 Rage):** Executes `Heroic Strike` only as a last resort to prevent wasting rage.
* **Mobile Slam:** Optimized for Turtle WoW's ability to use Slam while moving, maintaining the 1.0s weaving window for maximum efficiency.

---

## 5. INSTALLATION & REQUIREMENTS

1. Place the `BadAzsWarrior` folder in `Interface/AddOns/`.
2. **Required Addons:** `SP_SwingTimer` (for Slam-weaving accuracy).
3. **Optional Addons:** `ItemRack` (for automatic gear swapping TH/DW/WS).

=========================================================================
**BadAzsWarrior - Precision is not an option, it's a requirement.**

---

# INSTRUÇÕES (PT-BR)

## PROTOCOLOS DE MODIFICADORES TÁTICOS

O **BadAzs** utiliza teclas modificadoras para permitir decisões rápidas sem alterar o seu macro principal.

### ⌨️ [CTRL] - Avanço Seguro

* Em combate, o `Intercept` é bloqueado para evitar acidentes. Segure **CTRL** para sinalizar ao motor que você deseja avançar. O sistema mudará para Berserker Stance e usará o Intercept automaticamente.

### ⌨️ [ALT] - Sobrecarga AoE (O Liquidificador)

* Segurar **ALT** muda a prioridade para dano em área. Em vez de focar em um alvo, o Guerreiro usará `Whirlwind`, `Sweeping Strikes` e `Cleave` para destruir grupos de inimigos.

### ⌨️ [SHIFT] - Utilidade Dinâmica

* Reservado para futuras expansões de controle de CC e interrupções forçadas.

---

### MÓDULOS DE ROTAÇÃO

* **/barms:** Foco em impacto (2H). MS/BT e Slam-weaving de 1.0s.
* **/bfury:** Foco em velocidade (DW). Bloodthirst e Master Strike.
* **/btank:** Foco em proteção. Shield Block e Thunder Clap defensivo.

=========================================================================
**BadAzsWarrior - Precisão não é uma opção, é um requisito.**

---

Este documento agora reflete a totalidade da sua visão tática, Peregris. Gostaria que eu incluísse uma seção de **"Dicas de Performance"** explicando como configurar o scroll do mouse para tirar o melhor proveito do **BadAzs**?

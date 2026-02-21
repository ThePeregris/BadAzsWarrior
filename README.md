# [B]adAzs Warrior – MODULAR TACTICAL SUITE (v17 Beta)

**Battle Analysis Driven Assistant Zmart System**
*Turtle WoW Edition – Core Attack API*
<a href="https://www.paypal.com/donate/?hosted_button_id=VLAFP6ZT8ATGU">
  <img src="https://github.com/ThePeregris/MainAssets/blob/main/Donate_PayPal.png" alt="Tips Appreciated!" align="right" width="120" height="75">
</a>

## 1. TECHNICAL MANIFESTO | BadAzsWarrior

**Version:** v17 Beta
**Target:** Turtle WoW (Client 1.12.x – LUA 5.0)
**Architecture:** Modular Combat Engine + Core Attack API
**Author:** **ThePeregris**

O **BadAzsWarrior** é um **Decision Support System (DSS)** focado em **combate real**, não em simulação teórica.
O motor prioriza **segurança de ataque**, **controle de rage**, **prevenção de clipping** e **automação consciente**, respeitando as limitações do Vanilla WoW.

✔️ **Fire & Forget**
✔️ Sem loops artificiais
✔️ Sem dependência obrigatória de addons externos

---

## 2. CORE FEATURES (O que o script realmente faz)

### ⚔️ Core Attack API

Todos os módulos utilizam `BadAzs_StartAttack()` — uma chamada direta à **API do Core**, garantindo:

* Início seguro de Auto-Attack
* Nenhum “attack drop”
* Compatibilidade total com Turtle WoW

---

### 🧠 Sistema de Dump Dinâmico (Dual Mode)

O gasto de Rage é controlado pelo **DumpMode**, configurável em tempo real:

#### 🔹 SLAM MODE (Padrão)

* Prioridade em **Slam**
* Thresholds:

  * Slam: **Rage > 15**
  * Heroic Strike: **Rage > 60**
* Ideal para:

  * Arms 2H
  * Dano sustentado
  * Melhor DPR (Damage per Rage)

#### 🔸 HS MODE

* Prioridade em **Heroic Strike**
* Thresholds:

  * Slam: **Rage > 50**
  * Heroic Strike: **Rage > 35–40**
* Ideal para:

  * Movimento intenso
  * Fury
  * Geração de threat

📌 **Configuração:**

```
/badazs mode slam
/badazs mode hs
```

---

### ⛔ Anti-Clip Protocol (Slam Lock)

O sistema **nunca permite Slam em sequência**.

* Cooldown interno: **3.0 segundos**
* Garante:

  * Pelo menos **1 White Hit**
  * Regeneração natural de rage
  * Zero “Slam starvation”

Compatível com:

* `SP_SwingTimer` (precisão máxima)
* Fallback automático caso o addon não exista

---

## 3. MODIFICADORES DE TECLA (Tactical Overrides)

### ⌨️ CTRL — Intercept Tático

Em combate:

* Bloqueia Intercept por padrão
* **Segurar CTRL** autoriza:

  1. Troca para Berserker Stance
  2. Uso de Intercept
  3. Retorno automático ao fluxo normal

Evita pulls acidentais e mortes em raid.

---

### ⌨️ ALT — Protocolo AoE (Crowd Control)

Substitui totalmente a rotação single-target:

#### Arms / Fury

* Sweeping Strikes
* Whirlwind
* Cleave (se rage permitir)

#### Tank

* Thunder Clap
* Cleave
* Manutenção de aggro em múltiplos alvos

---

### ⌨️ SHIFT

Reservado (sem função ativa no código atual).

---

## 4. MÓDULOS DE COMBATE

### 🛡️ `/btank` — TANK

**Função:** Mitigação + Threat

* Força Defensive Stance
* Auto-equip Shield (se ItemRack ativo)
* Prioridade:

  1. Shield Block
  2. Thunder Clap
  3. Taunt automático se perder aggro
  4. Shield Slam (se disponível)
  5. Revenge
  6. Sunder Armor
* Heroic Strike apenas com Rage > 40

---

### ⚔️ `/barms` — ARMS (2H)

**Função:** Dano consistente + controle fino

* Battle Stance obrigatória
* Execute absoluto < 20%
* Mortal Strike / Bloodthirst
* Master Strike (se disponível)
* Rend aplicado se ausente
* Slam controlado por Swing Timer
* Battle Shout automático

---

### 🔥 `/bfury` — FURY (DW)

**Função:** Alta pressão e burst

* Berserker Stance fixa
* Auto-equip Dual Wield
* Bloodrage + Berserker Rage em combate
* Bloodthirst / Whirlwind
* Execute < 20%
* Heroic Strike conforme Dump Mode
* Battle Shout automático

---

## 5. ITEMRACK (Opcional)

Suporte nativo a **ItemRack**, se ativado:

```
/badazs itemrack on
/badazs itemrack off
```

### Sets esperados:

| Set    | Função          |
| ------ | --------------- |
| **TH** | Two-Hand        |
| **DW** | Dual Wield      |
| **WS** | Weapon + Shield |

📌 O script **não quebra** se ItemRack não existir.

---

## 6. SISTEMA DE FILTRO DE ERROS

O addon intercepta mensagens irrelevantes do sistema:

* “Not ready”
* “Out of range”
* “Another action is in progress”
* “Must be facing”

Resultado:
✔️ Chat limpo
✔️ Zero spam visual
✔️ Melhor leitura de eventos reais

---

## 7. DEPENDÊNCIAS

### Obrigatórias

* Nenhuma

### Opcionais (Recomendadas)

* **SP_SwingTimer** → Slam weaving preciso
* **ItemRack** → Troca automática de armas
* **UnitXP_SP3** → Detecção avançada de cooldowns

---

## 8. COMANDOS RÁPIDOS

| Comando             | Ação       |
| ------------------- | ---------- |
| `/barms`            | Arms       |
| `/bfury`            | Fury       |
| `/btank`            | Tank       |
| `/badazs`           | Status     |
| `/badazs mode slam` | Slam Focus |
| `/badazs mode hs`   | HS Focus   |

---
## FILOSOFIA BADAZS
> **Não é um bot.
> Não é um script burro.
> É um copiloto de combate.**

O **BadAzsWarrior** reage ao jogo real, respeita o jogador e nunca tenta “jogar sozinho”.
---
**BadAzsWarrior v15_Beta**
*Precisão não é uma opção. É um requisito.*

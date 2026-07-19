# [B]adAzs Warrior

**Battle Analysis Driven Assistant Zmart System** <br>
*Vanilla / Classic WoW Edition – Core Attack API*
<a href="https://www.paypal.com/donate/?hosted_button_id=VLAFP6ZT8ATGU">
  <img src="https://github.com/ThePeregris/MainAssets/blob/main/Donate_PayPal.png" alt="Tips Appreciated!" align="right" width="120" height="75">
</a>
<br><br><br>
<hr>

Addon de rotação para Warrior, feito para **Turtle WoW (cliente 1.12 / Lua 5.0)**.
Cobre as três specs de combate (**Arms**, **Fury**, **Protection**) com detecção automática de estilo de arma, um painel gráfico de configuração e integração com o [BadAzs Core](../BadAzsCore).

## Requisitos

- **BadAzs Core** (obrigatório) — fornece o sistema de poções/bandagens (`Sustain`) e o roteador de painéis (`/badazs`).
- **ItemRack** (opcional) — se instalado e ativado no painel, o addon troca de equipamento automaticamente ao mudar de stance/estilo.

## Instalação

Copie a pasta inteira para `Interface/AddOns/`, mantendo o nome:

```
AddOns/
  BadAzsWarrior/
    BadAzsWarrior.toc
    BadAzsWarrior.lua
```

Confirme na tela de personagem (botão **AddOns**) que `BadAzs Warrior` está habilitado — e que **BadAzs Core** também está.

## Macros

| Comando | O que faz |
|---|---|
| `/baarms` | Rotação Arms (arma de duas mãos) |
| `/bafury` | Rotação Fury (dual wield) |
| `/batank` | Rotação Protection |
| Segurar **ALT** + `/baarms` ou `/bafury` | Rotação de AoE (Whirlwind/Cleave/Sweeping Strikes) |
| `/badazs warrior` | Abre o painel de configuração |

Cada macro já lida com stance dance, equip automático (via ItemRack) e o uso de poções/bandagens (herdado do Core) sozinho — não precisa combinar comandos.

## Detecção automática de estilo

O addon não pergunta se você é Arms ou Fury: ele lê a arma **realmente equipada** no slot de mainhand (`INVTYPE_2HWEAPON` = Duas Mãos, qualquer outra coisa = Dual Wield) e aplica o perfil de rage correspondente. Isso reflete a diferença real de build de talentos entre os dois estilos, mesmo que você chame o macro errado por engano.

## Painel de configuração (`/badazs warrior`)

Formato de "livro": página esquerda com os controles, página direita com a explicação de cada um.

- **Perfil Duas Mãos** — sliders de rage mínima para `Slam` e `Heroic Strike`, mais botões de preset (`Preset Slam` / `Preset Heroic Strike`).
- **Perfil Duas Armas** — slider de rage mínima para `Heroic Strike` (Fury não usa Slam).
- **Ativar o uso do Item Rack** — liga/desliga a troca automática de equipamento. Exige sets no ItemRack nomeados exatamente `TH`, `DW` e `WS` (Two-Hand, Dual Wield, Weapon+Shield).
- **Botão de idioma** (`EN`/`PT`) no canto superior esquerdo — troca o idioma de toda a interface na hora. A escolha fica salva.

## SavedVariables

- `BadAzsWarDB.TH` — `{ SlamThreshold, HSThreshold }`
- `BadAzsWarDB.DW` — `{ HSThreshold }`
- `BadAzsWarDB.UseItemRack` — booleano
- `BadAzsWarDB.Locale` — `"EN"` ou `"PT"`

## Arquitetura interna

Desde a v18, o Warrior é **self-sufficient**: não depende mais do Core para checagens de combate (`Cast`, `Ready`, `HasBuff`, `TargetHasDebuff`, `GetTargetHP`, scanner de tooltip, tracking de swing timer e dodge). O Core só é usado para:

- `BadAzs_Sustain()` — poções de vida/mana, healthstone, bandagem (chamado automaticamente no início de cada rotação).
- Roteador `/badazs` — cada addon de classe se registra em `BadAzs_PanelRegistry`, evitando conflito entre addons que usam o mesmo prefixo de comando.

## Changelog

- **v18.2** — Painel em formato de livro (controles + explicações), textura de fundo estilo questlog, correção do slash `/badazs` (antes `/badasz`).
- **v18.1** — Localização EN/PT.
- **v18.0** — Reescrita self-sufficient, painel gráfico de configuração, detecção automática de estilo de arma, integração com `BadAzs_Sustain`.
- **v17.4** — Última versão baseada em comandos de texto (`/baconfig`), cache de slot self-sufficient.

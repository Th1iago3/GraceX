
---

# 📜 Documentação — Script GraceX

## 🔹 Introdução

Este script é um **utilitário para Roblox**, que adiciona várias funções de qualidade de vida, automação e exploração, incluindo **God Mode**, **ESP para players e entidades**, **controle de WalkSpeed/JumpPower**, **FullBright**, destruição automática de GUIs e muito mais.

O script é controlado através de uma **interface gráfica (GUI)** moderna, com abas (`Main`, `ESP`, `Misc`) e pode ser aberto/fechado pressionando a tecla **Right Shift**.

---

## 🔹 Estrutura Principal

### 1. **Toggles iniciais**

A tabela `toggles` define todas as opções padrão ao carregar o script:

```lua
local toggles = {
    BoostParticles = true,
    AutoLevers = true,
    DestroyEntities = true,
    DestroyEyeGui = true,
    DestroySmileGui = true,
    DestroyGoatPort = true,
    AutoSprint = false,
    PlayersESP = false,
    EntitiesESP = false,
    FullBright = false,
    GodMode = true,
    WalkSpeed = 16,
    JumpPower = 50
}
```

* `BoostParticles`: Aumenta a taxa de partículas ×10.
* `AutoLevers`: Move automaticamente alavancas para abrir portas.
* `DestroyEntities`: Destroi entidades nocivas ao spawnar.
* `DestroyEyeGui` / `DestroySmileGui` / `DestroyGoatPort`: Remove GUIs específicos.
* `AutoSprint`: Habilita corrida automática.
* `PlayersESP`: Exibe ESP de jogadores (nome, distância, itens).
* `EntitiesESP`: Exibe ESP em entidades hostis.
* `FullBright`: Ativa visão noturna (iluminação máxima).
* `GodMode`: Mantém vida sempre cheia.
* `WalkSpeed`: Velocidade de andar inicial.
* `JumpPower`: Potência de pulo inicial.

---

### 2. **Entity Names**

Lista de entidades reconhecidas para ESP e destruição automática:

```lua
local entityNames = {"eye", "elkman", "Rush", "Worm", ... "Void"}
```

---

### 3. **Serviços usados**

* `Workspace`, `Players`, `Lighting`, `UserInputService`, `TweenService`, `RunService` etc.

---

### 4. **Eventos principais**

* **BoostParticles:** multiplica taxa de partículas ao aparecer.
* **AutoLevers:** move alavancas para o player automaticamente.
* **DestroyEntities:** destrói entidades perigosas no spawn.
* **DestroyEyeGui / DestroySmileGui / DestroyGoatPort:** loops contínuos removem GUIs de jumpscare.
* **GodMode:** reseta a vida do humanoide para `MaxHealth` sempre que necessário.

---

## 🔹 Funções Adicionais

### ESP

Sistema de **ESP 2D com BillboardGui**:

* Para **Players**: Nome, distância, inventário (itens).
* Para **Entidades**: Nome + distância.
* Cor:

  * Verde → Players
  * Vermelho → Entidades

### FullBright

Salva as configurações originais de iluminação e altera:

* `Brightness = 2`
* `FogEnd = 100000`
* `Ambient = branco`
* `GlobalShadows = false`

### Humanoid Update

Atualiza `WalkSpeed` e `JumpPower` conforme sliders do menu.

---

## 🔹 Interface Gráfica (GUI)

### Estrutura

* **ScreenGui:** `GraceScriptGui`
* **MainFrame:** Painel central com estilo **glassmorph preto/vermelho**
* **Tabs:**

  * `Main` → Funções principais (BoostParticles, AutoLevers, DestroyEntities, etc.)
  * `ESP` → Players ESP, Entities ESP
  * `Misc` → AutoSprint, FullBright, WalkSpeed, JumpPower

### Estilo

* Tema **preto/vermelho** com gradiente e bordas arredondadas.
* Botões e sliders animados com `TweenService`.
* **Arrastável** clicando no título.

### Atalhos

* **Right Shift** → Abre/fecha o menu com animação.

---

## 🔹 Carregamento com `loadstring`

O script pode ser carregado remotamente com:

```lua
loadstring(game:HttpGet("https://link-do-seu-script.lua"))()
```

---

## 🔹 Observações

* Pode exigir **executor compatível** para rodar em Roblox.
* As entidades listadas no `entityNames` podem ser personalizadas.
* O menu é totalmente dinâmico (sliders/toggles interativos).

---

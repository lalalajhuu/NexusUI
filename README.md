# NexusUI

### Corre��o de visibilidade 1.2.1

Em dispositivos com touch (incluindo emuladores que anunciam TouchEnabled), um bot�o N de 48 � 48 px fica sempre vis�vel no canto superior direito, acima do painel. Toque nele para esconder ou reabrir. No PC sem touch, o bot�o NEXUS + aparece quando o painel est� escondido.

Right Shift agora � gerenciado pela biblioteca e funciona mesmo quando o jogo consome a tecla (por exemplo, Shift Lock), exceto durante digita��o em TextBoxes. O bot�o - esconde a janela inteira. Um bot�o NEXUS + permanece dispon�vel para reabrir no mouse ou touch. A tecla pode ser personalizada com `ToggleKey = Enum.KeyCode.RightShift` em CreateWindow. `SetVisible`, `Toggle`, `Minimize` e `Restore` compartilham o mesmo estado de visibilidade. `Gui.Enabled` permanece true para preservar o bot�o de reabertura; consulte `window.Frame.Visible` ou `window.Hidden` para verificar o estado do painel. O bot�o � continua encerrando a janela.

### Integra��o direta de fun��es

O exemplo completo em [integrations/MonoMM2_Nexus.lua](integrations/MonoMM2_Nexus.lua) usa apenas os componentes nativos da NexusUI. Leia [os detalhes e limites da migra��o](integrations/README.md). Os cr�ditos e a licen�a do c�digo de jogo s�o separados da biblioteca.

Na vers�o 1.2, abas tamb�m oferecem `CreateLabel({Text='Texto', Section=false})`. Aplica��es podem definir `window.OnDestroy = function() ... end` para fazer limpeza s�ncrona ao encerrar a interface. Callbacks pendentes de bot�es e controles de valor s�o ignorados ap�s a destrui��o da janela.

### Visual refresh 1.1

Pain�is com UIPadding (20 px horizontal / 16 px vertical), cantos de 8 px, contornos discretos e gradiente de superf�cie. Toggle com transi��o de posi��o/cor, slider com trilho de 10 px e thumb com borda branca e sombra. Dropdown com seta animada � direita. Abas com fundo escuro e indicador neon. GothamMedium, t�tulos de 15 px e subt�tulo de 9 px. Hover amplia bot�es em 1.05x com retorno suave e feedback de press�o. A API p�blica � compat�vel com a vers�o anterior.

Execute a demonstra��o publicada:

```lua
loadstring(game:HttpGet('https://raw.githubusercontent.com/lalalajhuu/NexusUI/main/ExampleRemote.lua'))()
```

## GitHub / arquivo �nico

Suba esta pasta para um reposit�rio p�blico no GitHub. O arquivo pronto para carregamento remoto � **dist/NexusUI.lua**; ele inclui todos os m�dulos e retorna a mesma API. Veja **ExampleRemote.lua** para um exemplo completo.

Troque YOUR_USER e YOUR_REPO no endere�o:

```lua
local NexusUI = loadstring(game:HttpGet('https://raw.githubusercontent.com/YOUR_USER/YOUR_REPO/main/dist/NexusUI.lua'))()
local window = NexusUI:CreateWindow({Title = 'NEXUS UI'})
local tab = window:CreateTab({Name = 'General'})
tab:CreateToggle({Name = 'Enabled', Default = false, Callback = print})
```

Esse formato exige um ambiente cliente que forne�a `game:HttpGet` e `loadstring`. N�o funciona em um LocalScript padr�o do Roblox Studio; nele, use a instala��o com ModuleScripts abaixo. A distribui��o continua usando PlayerGui e n�o adiciona fun��es de executor � interface.

Depois de editar os m�dulos, rode `powershell -ExecutionPolicy Bypass -File .\build.ps1` na pasta do projeto e envie tamb�m o novo dist/NexusUI.lua. Edite o tema em NexusUI/Theme.lua antes de reconstruir ou passe Theme em CreateWindow. O arquivo gerado n�o depende de outros downloads.

Para fixar uma vers�o, substitua `main` pelo hash de um commit na URL. Com `main`, novas execu��es carregam o arquivo atual da branch. Carregue apenas c�digo de reposit�rios que voc� revisou e confia.

Biblioteca de interface Luau com licen�a MIT. Feita para LocalScripts em experi�ncias Roblox: usa PlayerGui e APIs padr�o, sem executor ou depend�ncias externas.

## Estrutura

```text
NexusUI/
  Init.lua        API principal
  Theme.lua       Paleta, fonte e dura��o das transi��es
  Window.lua      Janela, abas, notifica��es e ciclo de vida
  Elements.lua    Toggle, Slider, Dropdown, Textbox, Button, ColorPicker
  Utility.lua     Constru��o, tweens e entrada mouse/touch
Example.lua       LocalScript de demonstra��o
NexusUI.rbxmx     Modelo import�vel com os ModuleScripts
LICENSE           MIT
```

## Instala��o no Studio

1. Importe `NexusUI.rbxmx` usando **Insert from File** no Explorer e mova a pasta NexusUI para ReplicatedStorage.
2. Crie um LocalScript em StarterPlayer > StarterPlayerScripts e cole `Example.lua`.
3. Inicie Play. Para testar celular, use o Device Emulator do Studio.

Alternativamente, crie uma Folder NexusUI em ReplicatedStorage e cinco ModuleScripts chamados Init, Theme, Window, Elements e Utility; copie os arquivos correspondentes. Os nomes s�o sens�veis a mai�sculas.

## Uso

```lua
local NexusUI = require(game.ReplicatedStorage.NexusUI.Init)
local window = NexusUI:CreateWindow({
    Title = 'NEXUS',
    Subtitle = 'CONTROL CENTER',
    Theme = { Accent = Color3.fromRGB(255, 51, 51) },
})
local tab = window:CreateTab({Name = 'General'})
local toggle = tab:CreateToggle({
    Name = 'Particles', Default = true,
    Callback = function(value) print(value) end,
})
toggle:Set(false)       -- atualiza e chama Callback
toggle:Set(true, true)  -- atualiza silenciosamente
print(toggle:Get())
```

## API

| M�todo da aba | Op��es |
| --- | --- |
| CreateToggle | Name, Default boolean, Callback(boolean) |
| CreateSlider | Name, Min, Max, Step, Default number, Callback(number) |
| CreateDropdown | Name, Options lista de strings, Default string opcional, Callback(string ou nil) |
| CreateTextbox | Name, Placeholder, Default string, Callback(string) ao perder foco |
| CreateButton | Name, Callback() |
| CreateColorPicker | Name, Default Color3, Callback(Color3) |

Controles de valor t�m `Get()`, `Set(value, silent)` e `Destroy()`. Bot�es t�m `Destroy()`. Dropdown tamb�m tem `SetOptions(strings)`; remover a op��o selecionada limpa o valor e dispara callback com nil. Defaults n�o disparam callbacks. Sliders arredondam pelo Step a partir de Min e limitam os valores ao intervalo.

`window:Notify({Title, Content, Type, Duration})`: Type pode ser Success, Error ou Warning; Duration em segundos, de 1 a 60. Use textos curtos para os cards.

`window:SelectTab(tab)`, `window:SetVisible(boolean)` e `window:Destroy()`. O bot�o - recolhe e expande; � destr�i a janela. Destroy desconecta os listeners registrados. Se ocultar uma janela por c�digo, guarde a refer�ncia para reabri-la.

## Visual e responsividade

Theme.lua concentra a configura��o visual; altera��es se aplicam a novas janelas. Uma janela tamb�m aceita overrides em Theme. A fonte padr�o � Gotham. Bordas, camadas de contorno, cantos arredondados e transi��es n�o dependem de imagens hospedadas.

A janela troca para layout compacto abaixo de 600 pixels de largura e usa UIScale para caber na �rea dispon�vel. Abas e conte�do t�m scroll independente. Arraste pelo t�tulo; minimizar preserva a posi��o. Redimensionar a tela recentraliza a janela. Dropdowns expandem dentro da p�gina, evitando sobrepor outros controles. O seletor de cores usa �rea de satura��o/valor, faixa de matiz e tr�s entradas RGB (0-255).

Em telas muito pequenas a escala reduz tamb�m os alvos de toque; confira seu dispositivo alvo no emulador antes de publicar. N�o h� persist�ncia autom�tica de perfis, keybinds ou mudan�a de tema ao vivo nesta vers�o. Callbacks s�o ass�ncronos e protegidos por pcall; l�gica de jogo e valida��o no servidor ficam a cargo da experi�ncia.

## Valida��o

O pacote foi revisado estaticamente e o XML de importa��o foi conferido. N�o foi executado em uma sess�o Roblox nesta entrega. Antes de publicar, teste mouse/touch, rota��o da tela, arraste, minimizar, fechar, busca, entradas inv�lidas e callbacks na experi�ncia de destino.

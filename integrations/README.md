# Mono MM2 usando NexusUI

`MonoMM2_Nexus.lua` � uma adapta��o direta do arquivo fornecido pelo usu�rio: carrega a NexusUI por loadstring, cria abas e conecta callbacks aos componentes nativos. N�o carrega MonoUI, n�o emula sua API e n�o usa camada de compatibilidade.

Foram migrados 41 toggles, 8 a��es e 16 configura��es (incluindo textos explicativos). As categorias Combat, Player, Visuals, Teleport, Safety e Utility viraram abas. As configura��es de cada recurso ficam vis�veis na mesma aba, abaixo do toggle correspondente. Os dropdowns de destino s�o atualizados quando jogadores entram ou saem. Interface cont�m cr�ditos, relat�rio de compatibilidade, atualiza��o manual da lista e encerramento.

Right Shift mostra/oculta a janela. Fechar a janela ou usar Unload script desliga os controles registrados, restaura as fun��es que oferecem restaura��o e desconecta os listeners da aplica��o. O hook original permanece instalado, mas usa o sinalizador Unloaded para deixar de executar sua l�gica, como no c�digo fornecido.

Os sistemas pr�prios da interface antiga (favoritos, atalhos por recurso, tutorial, gaveta e perfis da MonoUI) n�o fazem parte dessa migra��o. A l�gica de jogo foi preservada; o suporte aos recursos depende do jogo e das APIs do executor, exatamente como no arquivo original. Fun��es originalmente descritas como n�o testadas continuam sem valida��o no jogo.

Valida��o: an�lise sint�tica dos m�dulos, bundle e integra��o; para o parser Lua, continue e atribui��es compostas do Luau s�o normalizados somente em mem�ria. A migra��o tamb�m confere contagem de a��es/toggles e aus�ncia das chamadas da interface antiga. Isso n�o substitui execu��o no Roblox. N�o havia Studio conectado durante a entrega, e nenhum teste em executor foi realizado.

## Cr�ditos e licen�a

C�digo de jogo originalmente atribu�do a Fleece: https://robloxscripts.com/user/Fleece . A atribui��o foi mantida. A integra��o n�o reivindica autoria do c�digo original nem estende a licen�a MIT da NexusUI a ele. Consulte o autor original sobre permiss�es de redistribui��o e uso comercial.

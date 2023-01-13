main:- write('BEM-VINDO, JOGADOR! :)\n'),
write(''), menuStart.

menuStart :- write('Escolha uma opção:'),
write('\n(1) iniciar partida'),
write('\n(2) histórico de pontuação'),
write('\n(3) regras do jogo'),
write('\n(4) sair do jogo\n'), 
read(Opcao), verificaOpcao(Opcao).

verificaOpcao(1) :- write('vamos começar!'),halt,!.
verificaOpcao(2) :- placar,!.
verificaOpcao(3) :- regrasJogo,!.
verificaOpcao(4) :- write('até a próxima!\n'),halt,!.
verificaOpcao(_) :- write('Escolha uma opção válida! \n\n'), menuStart.


regrasJogo :- 
    write('\n--------------------------- Regras do jogo --------------------------- \n'),
    write('Objetivo do jogo: \nSeja o primeiro jogador a se livrar de todas as suas cartas.\n'),
    write('Como jogar UNO: \nNa sua vez, você deve combinar uma carta da sua mão com aquela presente na pilha de Descarte. A carta jogada sempre deve ser da mesma cor ou do mesmo numero da carta presente no baralho, exceto quando uma carta curinga ou uma +4 tiverem sido jogadas.\n'),
    write('Funções das cartas de ação: '),
    write('Comprar duas cartas (+2): Quando esta carta for jogada, o próximo jogador deve comprar 2 cartas e perde a vez. Ela apenas pode ser jogada sobre uma cor que combine. \n'),
    write('Comprar quatro cartas (+4): Ao jogar esta carta, você pode escolher a cor a ser jogada, além de fazer com que o próximo jogador tenha que comprar 4 cartas da pilha de Compras, perdendo também a vez.\n'),
    write('Bloqueio: O próximo a jogar perde a vez. \n'),
    write('Inverter: Ao descartar esta carta, o sentido do jogo é invertido (se estiver indo para a esquerda, muda para a direita e vice-versa). \n'),
    write('Curinga: O jogador que lançou essa carta escolhe a nova cor que continuará no jogo.\n'),
    write('----------------------------------------------------------------------'),
    write('\nDigite `0.` para retornar ao Menu Principal\n'), read(_), menuStart.

placar :- write('Em construção.\n'),
write('\nDigite `0.` para retornar ao Menu Principal\n'), read(_), menuStart.
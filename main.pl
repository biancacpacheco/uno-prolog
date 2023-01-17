main:- write('BEM-VINDO, JOGADOR! :)\n'),
write(''), menuStart.

menuStart :- write('Escolha uma opção:'),
write('\n(1) iniciar partida'),
write('\n(2) histórico de pontuação'),
write('\n(3) regras do jogo'),
write('\n(4) sair do jogo\n'), 
read(Opcao), verificaOpcao(Opcao).

verificaOpcao(1) :- writeln('vamos começar!\n Olha o baralho:'), geraBaralho(Baralho),
                    write(Baralho),
                    start(Baralho),halt,!.
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

start(Baralho) :-
    quantJogadores(N),
    distribuiMaos(Baralho, N, Maos),
    %joga(NovoBaralho, Maos, 0).
    writeln(Baralho),
    writeln(Maos).

quantJogadores(N) :-
    write('Você gostaria de jogar contra 1 ou contra 2 bots? '), nl,
    read(NBots),
    N is NBots+1,
    writeln(N).

distribuiMaos(Baralho, N, Maos) :-
    separaCartas(Baralho, Maos, N, 7, 0).


separaCartas(_, _, 0, _, _).
separaCartas(Baralho, [Jogador|RestoJogadores], NumeroDeJogadores, NumeroDeCartas, JogadorCounter) :-
    select(Jogador, Baralho, RestoBaralho),
    length(Jogador, NumeroDeCartas),
    ProximoJogador is JogadorCounter + 1,
    N is NumeroDeJogadores - 1,
    separaCartas(RestoBaralho, RestoJogadores, N, NumeroDeCartas, ProximoJogador).


% Definição de possíveis valores para as cartas
valor(0).
valor(1).
valor(2).
valor(3).
valor(4).
valor(5).
valor(6).
valor(7).
valor(8).
valor(9).
valor(pular).
valor(inverter).
valor(+2).
valorCoringa(coringa).
valorCoringa(coringa_+4).

% Definição de possíveis cores
cor(amarelo).
cor(azul).
cor(verde).
cor(vermelho).
corCoringa(indefinida).


% Definição de regra para geração do baralho, utilizando duas funções auxiliares para combinar e embaralhar as cartas
geraBaralho(Baralho) :- 
    findall(carta(Valor, Cor), (valor(Valor), cor(Cor)), CartasColoridas1),
    findall(carta(Valor, Cor), (valor(Valor), cor(Cor)), CartasColoridas2), % Cada valor no uno deve ter duas cartas de cada cor
    findall(carta(ValorCoringa, CorIndefinida), (valorCoringa(ValorCoringa), corCoringa(CorIndefinida)), CartasCoringa),
    uneCartas(CartasColoridas1, CartasColoridas2, CartasCoringa, BaralhoOrdenado),
    embaralhaBaralho(BaralhoOrdenado, Baralho).

% Definição de regra para união das cartas geradas
uneCartas(CartasColoridas1, CartasColoridas2, CartasCoringa, BaralhoOrdenado) :-
    append(CartasColoridas1, CartasColoridas2, CartasColoridas),
    append(CartasColoridas, CartasCoringa, BaralhoOrdenado).

% Definição de regra para alterar aleatoriamente a ordem das cartas previamente criadas
embaralhaBaralho(BaralhoOrdenado, Baralho) :-
    random_permutation(BaralhoOrdenado, Baralho).
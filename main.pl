
:- dynamic vitorias/1, derrotas/1.

vitorias(0).
derrotas(0).

main:- write('BEM-VINDO, JOGADOR! :)\n'),
write(''), menuStart.

menuStart :- write('Escolha uma opção:'),
write('\n(1) iniciar partida'),
write('\n(2) histórico de pontuação'),
write('\n(3) regras do jogo'),
write('\n(4) sair do jogo\n'), 
read(Opcao), verificaOpcao(Opcao).


verificaOpcao(1) :- writeln('Vamos começar!'),
                    start(), !.
verificaOpcao(2) :- placar, !.
verificaOpcao(3) :- regrasJogo, !.
verificaOpcao(4) :- write('Até a próxima!\n'), halt.
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


placar :- 
    vitorias(V),
    derrotas(D),
    write('Vitórias: '), write(V), nl,
    write('Derrotas: '), write(D), nl,
    write('\nDigite `0.` para retornar ao Menu Principal\n'), read(_), menuStart.

% definição da função que inicia uma partida
start() :-
    geraBaralho(Baralho),                                           
    quantJogadores(N),
    distribuiMaos(Baralho, N, Maos, NovoBaralho),
    length(Maos, N),
    [Mesa|RestoBaralho] = NovoBaralho,
    inicio_eh_coringa(RestoBaralho, Maos, [Mesa], 1, N, 0, 0).

% Se a primeira carta for um coringa, atribui-se uma cor aleatória
inicio_eh_coringa(RestoBaralho, Maos, [carta(coringa,_)], 1, N, 0, 0):-
    escolher_cor_aleatoria(Cor),
    joga(RestoBaralho, Maos,[carta(coringa,Cor)], 1, N, 0, 0), !.
inicio_eh_coringa(RestoBaralho, Maos, [carta(coringa+4,_)], 1, N, 0, 0):-
    escolher_cor_aleatoria(Cor),
    joga(RestoBaralho, Maos,[carta(coringa_+4,Cor)], 1, N, 0, 0), !.
inicio_eh_coringa(RestoBaralho, Maos, [Mesa], 1, N, 0, 0):-
    joga(RestoBaralho, Maos, [Mesa], 1, N, 0, 0).

% Loop de jogadas, em que o jogador e os bots jogam até que uma das mãos esteja vazia
joga(_, _, _, JogDaVez, _, 1, _):- 
    write('O JOGADOR '), write(JogDaVez), writeln(' VENCEU!!!\n\n'),
    ((JogDaVez =:= 1) -> registrar_vitoria ;
                        registrar_derrota), menuStart, !.
joga(Baralho, Maos, Descarte, JogDaVez, NumJog, EndGame, Inverte):- 
    write('\nO jogador da vez é o de número '), writeln(JogDaVez),
    (JogDaVez =:= 1 -> jogadorEscolhe(Maos, Descarte, Baralho, NovasMaos, NovoDescarte, NovoBaralho)
                     ; botEscolhe(JogDaVez, Maos, Descarte, Baralho, NovasMaos, NovoDescarte, NovoBaralho)),
    getMao(NovasMaos, JogDaVez, Mao),
    length(Mao, Tamanho),
    verificaMao(Tamanho, NovoEndGame),
    (NovoEndGame = 0 -> 
                      writeln('O jogo continua!'),
                      resolveProxRodada(JogDaVez, NumJog, Inverte, NovoDescarte, NovoJogDaVez, NovoInverte)
                    ; 
                      NovoJogDaVez = JogDaVez),
    joga(NovoBaralho, NovasMaos, NovoDescarte, NovoJogDaVez, NumJog, NovoEndGame, NovoInverte).

% Define quem será o próximo jogador de acordo com a carta da mesa, considerando inverte e bloqueio
resolveProxRodada(JogDaVez, NumJog, Inverte, [Mesa|RestoDescarte], NovoJogDaVez, NovoInverte) :-
    verificaInversao(Mesa, Inverte, NovoInverte),
    verificaProxJogador(JogDaVez, Mesa, NumJog, NovoJogDaVez, NovoInverte).
    
verificaProxJogador(JogDaVez, Mesa, NumJog, NovoJogDaVez, 0):- 
    (Mesa = carta(pular, _) -> passaJogador(JogDaVez, NumJog, NovoJogDaVez, 2)
                        ; passaJogador(JogDaVez, NumJog, NovoJogDaVez, 1)).
verificaProxJogador(JogDaVez, Mesa, NumJog, NovoJogDaVez, 1):- 
    (Mesa = carta(pular, _) -> passaJogador(JogDaVez, NumJog, NovoJogDaVez, -2)
                        ; passaJogador(JogDaVez, NumJog, NovoJogDaVez, -1)).

passaJogador(JogDaVez, NumJog, NovoJogDaVez, Passo):-
    Passada is JogDaVez + Passo,
    (Passada > NumJog -> NovoJogDaVez is Passada - JogDaVez
                       ; (Passada < 1 -> NovoJogDaVez is NumJog + Passada
                                       ; NovoJogDaVez = Passada)).

verificaInversao(carta(inverter,_), 1, 0):- !.
verificaInversao(carta(inverter,_), 0, 1):- !.
verificaInversao(_, 1, 1):- !.
verificaInversao(_, 0, 0):- !.


% Possibilita que o jogador possa escolher uma carta e que as estruturas de dados do jogo sejam atualizadas
jogadorEscolhe(Maos, Descarte, Baralho, NovasMaos, NovoDescarte, NovoBaralho):-
    [Mesa|RestoDescarte] = Descarte,
    [Mao|MaosBots] = Maos,
    [Topo|RestoBaralho] = Baralho,
    write('Carta da Mesa: '), writeln(Mesa), nl,
    write('\nSuas cartas: '), writeln(Mao), nl,
    (existemCartasPossiveis(Mao, Mesa) -> 
                                write('Qual carta deseja jogar? '), read(NumCarta),
                                nth1(NumCarta, Mao, CartaJogada),
                                writeln(CartaJogada),
                                (ehValida(CartaJogada, Mesa) ->
                                                                delete(Mao, CartaJogada, NovaMao),
                                                                writeln(NovaMao), nl,
                                                                NovasMaos = [NovaMao|MaosBots],
                                                                NovoDescarte = [CartaJogada|Descarte],
                                                                NovoBaralho = Baralho,
                                                                write('Pressione qualquer tecla para passar a vez... '), read(_), nl
                                                            ;   
                                                                writeln('Escolha uma carta válida!\n'),
                                                                jogadorEscolhe(Maos, Descarte, Baralho, NovasMaos, NovoDescarte, NovoBaralho))
                            ;
                                writeln('Você não possui cartas para jogar nesta rodada e receberá uma nova carta do baralho :('), nl,
                                write('Pressione qualquer tecla para continuar...'), nl,
                                NovaMao = [Topo|Mao],
                                delete(Baralho, Topo, NovoBaralho),
                                NovasMaos = [NovaMao|MaosBots],
                                NovoDescarte = Descarte, read(_), nl).


% Possibilita que os bots joguem, seguindo a estratégia de jogar a primeira carta possível, e que
% as estruturas de dados do jogo sejam atualizadas
botEscolhe(JogDaVez, Maos, Descarte, Baralho, NovasMaos, NovoDescarte, NovoBaralho):-
    [Mesa|RestoDescarte] = Descarte,
    Indice is JogDaVez-1,
    nth0(Indice,Maos,Mao),
    [Topo|RestoBaralho] = Baralho,
    write('Carta da Mesa: '), writeln(Mesa), nl,
    (existemCartasPossiveis(Mao, Mesa) -> 
                                jogaPrimeiraPossivel(Mao,Mesa,0,IndiceNaMao),
                                NumCarta is IndiceNaMao + 1,
                                nth1(NumCarta, Mao, CartaJogada),
                                writeln(CartaJogada),
                                delete(Mao, CartaJogada, NovaMao),
                                replace(Indice,Maos,NovaMao,NovasMaos),
                                NovoDescarte = [CartaJogada|Descarte],
                                NovoBaralho = Baralho,
                                write('Pressione qualquer tecla para passar a vez... '), read(_), nl
                            ;
                                writeln('O bot não possui cartas para jogar nesta rodada e receberá uma nova carta do baralho :D'), nl,
                                write('Pressione qualquer tecla para passar a vez...'), nl,
                                NovaMao = [Topo|Mao],
                                delete(Baralho, Topo, NovoBaralho),
                                replace(Indice,Maos,NovaMao,NovasMaos),
                                NovoDescarte = Descarte, read(_), nl).


replace(JogDaVez, Maos, Mao, NovasMaos) :-
    nth0(JogDaVez, Maos, _, R),
    nth0(JogDaVez,NovasMaos, Mao, R).


jogaPrimeiraPossivel([M|Resto],Mesa,CartaAtual,IndiceNaMao) :- ehValida(M,Mesa) -> (IndiceNaMao is CartaAtual),! 
                                                                                ;
                                                                                NewCartaAtual is CartaAtual + 1,
                                                                                jogaPrimeiraPossivel(Resto,Mesa,NewCartaAtual,IndiceNaMao). 

% Verifica se é possível que o jogador da vez poderá jogar ou se deverá comprar uma carta do baralho
existemCartasPossiveis([], _) :- fail.
existemCartasPossiveis([Carta|Resto], Mesa) :- ehValida(Carta, Mesa) ; existemCartasPossiveis(Resto, Mesa).


% Verifica se a carta escolhida pelo jogador é compatível com a que se encontra na mesa
ehValida(CartaEscolhida, Mesa):-
    carta(Valor,Cor) = CartaEscolhida,
    carta(ValorMesa,CorMesa) = Mesa,
    (Cor = CorMesa ; Valor = ValorMesa ; Cor = indefinida).


getMao(Maos, JogDaVez, Mao):-
    Indice is JogDaVez - 1,
    nth0(Indice, Maos, Mao).

% Verifica possíveis ações de acordo com a evolução do jogo. Se o jogador da vez tiver 1 carta,
% é exibido "UNO!" e se não sobrar nenhuma carta, significa que ele ganhou e a flag Endgame recebe valor 1
verificaMao(0, EndGame):- 
    EndGame = 1, !.
verificaMao(1, EndGame):- 
    writeln('UNO!'),
    EndGame = 0, !.
verificaMao(_, EndGame):- 
    EndGame = 0, !.

quantJogadores(N) :-
    write('Você gostaria de jogar contra 2 ou contra 3 bots? '), nl,
    read(NBots),
    N is NBots+1.


% Chama a regra de separar cartas, definindo a quantidade de cartas por jogador como sendo 7
distribuiMaos(Baralho, N, Maos, NovoBaralho) :-
    separaCartas(Baralho, Maos, N, 7, NovoBaralho).


% Separa 7 cartas do baralho para cada jogador
separaCartas(Baralho, _, 0, _, NovoBaralho):- 
    NovoBaralho = Baralho, !.
separaCartas(Baralho, [Jogador|RestoJogadores], NumeroDeJogadores, NumeroDeCartas, NovoBaralho) :-
    length(Jogador, NumeroDeCartas),
    append(Jogador, RestoBaralho, Baralho),
    N is NumeroDeJogadores - 1,
    separaCartas(RestoBaralho, RestoJogadores, N, NumeroDeCartas, NovoBaralho).




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

registrar_vitoria :-
    vitorias(VitoriasAtuais),
    NovasVitorias is VitoriasAtuais + 1,
    retract(vitorias(VitoriasAtuais)),
    asserta(vitorias(NovasVitorias)).

registrar_derrota :-
    derrotas(DerrotasAtuais),
    NovasDerrotas is DerrotasAtuais + 1,
    retract(derrotas(DerrotasAtuais)),
    asserta(derrotas(NovasDerrotas)).

cores([vermelho, azul, amarelo, verde]).

escolher_cor_aleatoria(Cor) :-     
    cores(Cores),     
    random_member(Cor, Cores).
% Define as cores dispon�veis
cor(vermelho).
cor(amarelo).
cor(verde).
cor(azul).

% Define uma carta para trocar a cor
trocar_cor(tc).

% Seleciona uma cor aleat�ria
escolher_cor_aleatoria(Cor) :-
    findall(C, cor(C), Cores),
    random_member(Cor, Cores).

% Inicia a partida se a primeira carta for uma carta de trocar a cor
jogar(tc) :-
    escolher_cor_aleatoria(Cor),
    write('A cor escolhida �: '), write(Cor).

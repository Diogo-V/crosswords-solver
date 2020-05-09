% Diogo Emanuel da Costa Venancio n95555
% ['Projeto/projeto.pl'].


% Importa o ficheiro dado.
:- [codigo_comum].


% ---------------------------------------------------------------------------------------------------------------------%
% ----------------------------------------- PREDICADOS DE INICIALIZACAO -----------------------------------------------%
% ---------------------------------------------------------------------------------------------------------------------%


% 3.1.1. -> obtem_letras_palavras/2
%
% Argumentos:
% >Lst_pal = lista de palavras
% >Lst_let = lista ordenada cujos elementos sao listas com as letras
%
% Descricao:
% >Recebe uma lista de palavras e obtem uma lista ordenada cujos elementos sao listas com as letras de cada 
%  palavra de Lst_pals


obtem_letras_palavras(Lst_pal, Lst_let) :-

    % Obtem a lista que tem listas cujos elementos sao letras
    obtem_letras_palavras_aux(Lst_pal, Lst_letras_pal),

    % Ordena a lista obtida
    sort(Lst_letras_pal, Lst_let).

% ----------------------------------------

obtem_letras_palavras_aux([], []).
obtem_letras_palavras_aux([C_pal | R_pal], [Lst_letras_pal | Lst_let]) :- 

    % Lst_letras_pal vai ser a lista cujos elementos sao as letras da palavra
    atom_chars(C_pal, Lst_letras_pal),

    % Faz a chamada recursiva descartando o primeiro elemento da Lst_pal
    obtem_letras_palavras_aux(R_pal, Lst_let).


% 3.1.2. -> espaco_fila/2
%
% Argumentos:
% >Fila = lista que representa uma linha ou coluna de uma grelha
% >Esp = lista que representa um espaco
%
% Descricao:
% >Recebe uma linha/coluna e obtem uma lista que representa um espaco nessa linha/coluna


espaco_fila(Fila, Esp) :- 

    % Divide a fila em lado esquerdo, espaco e lado direito
    append([L1, Esp, L2], Fila),

    % Avalia o espaco e verifica se este e valido
    esp_valido(Esp),

    % Avalia o lado esquerdo e verifica se este e valido
    l1_valida(L1),

    % Avalia o lado direito e verifica se este e valido
    l2_valida(L2).

% ----------------------------------------

% Verifica se a posicao nao e um cardinal
eh_posicao_valida(Ele) :- Ele \== '#'.

% ----------------------------------------

% Verifica se o ultimo elemento e o elemento pretendido
ultimo_elemento([Cabeca | []], Elemento) :- Cabeca == Elemento.
ultimo_elemento([_ | Cauda], Elemento) :- \+ ord_empty(Cauda), ultimo_elemento(Cauda, Elemento).

% ----------------------------------------

% Verifica se o tamanho da lista e superior ou igual a 3 e se nao contem nenhum cardinal
esp_valido(Esp) :-
    length(Esp, Len), Len >= 3,
    maplist(eh_posicao_valida, Esp).

% ----------------------------------------

% Verifica se a lista e vazia ou se o seu ultimo elemento e um cardinal
l1_valida([]).
l1_valida(L1) :- ultimo_elemento(L1, '#').

% ----------------------------------------

% Verifica se a lista e vazia ou se o seu primeiro elemento e um cardinal
l2_valida([]).
l2_valida([Ele_l2 | _]) :- Ele_l2 == '#'.


% 3.1.3. -> espacos_fila/2
%
% Argumentos:
% >Fila = lista que representa uma linha ou coluna de uma grelha
% >Espacos = lista que contem todos os espacos livres de Fila
%
% Descricao:
% >Recebe uma linha/coluna e obtem uma lista que contem todos os espacos livres dessa linha/coluna


espacos_fila(Fila, Espacos) :- 
    
    % Coloca todos as respostas de espaco_fila numa lista
    bagof(Tds_esp, espaco_fila(Fila, Tds_esp), Espacos),

    % Impede que de mais do que uma resposta 
    !.

% Caso nao haja nenhum espaco, vai retornar uma lista vazia
espacos_fila(_, []).


% 3.1.4. -> espacos_puzzle/2
%
% Argumentos:
% >Grelha = lista que representa uma grelha
% >Espacos = lista que contem todos os espacos livres de Grelha
%
% Descricao:
% >Obtem uma lista que contem todos os espacos livres de Grelha, quer por linhas, quer por colunas


espacos_puzzle(Grelha, Espacos) :-

    % Obtem os espacos para as linhas
    espacos_puzzle_aux(Grelha, Espacos_1, []),

    % Transpoem a grelha
    mat_transposta(Grelha, Trans_grelha),

    % Obtem os espacos para as colunas
    espacos_puzzle_aux(Trans_grelha, Espacos_2, []),

    % Junta ambas as listas obtidas nos passos anteriores
    append(Espacos_1, Espacos_2, Espacos).

% ----------------------------------------    

espacos_puzzle_aux([], Res, Res).
espacos_puzzle_aux([C_grelha | R_grelha], Espacos, Acum) :-

    % Obtem os todos os espacos possiveis dessa linha/coluna
    espacos_fila(C_grelha, Res_espacos),

    % Acumula
    append(Acum, Res_espacos, Res_acum),

    % Volta a chamar o predicado para obter os espacos das restantes linhas/colunas
    espacos_puzzle_aux(R_grelha, Espacos, Res_acum).


% 3.1.5. -> espacos_com_posicoes_comuns/3
%
% Argumentos:
% >Espacos = lista de espacos
% >Esp = lista que representa um espaco
% >Esps_comuns = lista de espacos com posicoes em comum com Esp
%
% Descricao:
% >Recebe uma grelha e um espaco da grelha e obtem uma lista de espacos com posicoes em comum com as desse espaco


espacos_com_posicoes_comuns(Espacos, Esp, Esps_comuns) :- 
    espacos_com_posicoes_comuns_aux(Espacos, Esp, Esps_comuns, []).

% ----------------------------------------

espacos_com_posicoes_comuns_aux([], _, Acum, Acum).
espacos_com_posicoes_comuns_aux([C_espacos | R_espacos], Esp, Esps_comuns, Acum) :-

    % Verifica se existe alguma intersecao possivel entre um espaco da grelha e o espaco fornecido
    list_to_ord_set(C_espacos, C_espacos_set),
    list_to_ord_set(Esp, Esp_set),
    ord_intersect(C_espacos_set, Esp_set),

    % Verifica se o espaco corresponde ao espaco dado (se for, interrompe)
    \+ mesma_lista(C_espacos, Esp),

    % Impede o retrocesso caso ja se saiba que uma das variavies do espaco da grelha pertence ao espaco fornecido
    !,

    % Acumula o resultado caso haja uma intersecao
    append(Acum, [C_espacos], Res_acum),

    % Faz a chamada recursiva removendo o primeiro elemento
    espacos_com_posicoes_comuns_aux(R_espacos, Esp, Esps_comuns, Res_acum).

% ----------------------------------------

% Caso nao haja intersecao, executa este ramo e faz apenas a chamada recursiva sem acumular nenhum espaco da grelha
espacos_com_posicoes_comuns_aux([_ | R_espacos], Esp, Esps_comuns, Acum) :-
    espacos_com_posicoes_comuns_aux(R_espacos, Esp, Esps_comuns, Acum).

% ----------------------------------------

% Verifica se as listas sao estritamente iguais (serve para ver se sao dois espacos iguais)
mesma_lista([ ], [ ]).   
mesma_lista([Ele_lista1 | Cau_lista1], [Ele_lista2 | Cau_lista2]):-
    Ele_lista1 == Ele_lista2,
    mesma_lista(Cau_lista1, Cau_lista2).


% 3.1.6. -> palavra_possivel_esp/4
%
% Argumentos:
% >Pal = lista de letras de uma palavra
% >Esp = lista que representa um espaco
% >Espaco = lista de espacos
% >Letras = lista de listas de letras de palavras
%
% Descricao:
% >Retorna uma unificacao ou false caso a palavra (Pal) seja valida para aquele espaco (Esp)


palavra_possivel_esp(Pal, Esp, Espaco, Letras) :-

    % Verifica se ambas as palavras tem o mesmo comprimento e que tambem respeita as letras que ja la estam
    subsumes_term(Esp, Pal),

    % Obtem os espacos em comun com o espaco fornecido
    espacos_com_posicoes_comuns(Espaco, Esp, Esp_comuns), 

    % Unifica o espaco com a palavra (acaba tambem por unificar as posicoes dos espacos comuns)
    Esp = Pal, 

    % Verifica se a colocacao de Pal em Esp nao impossibilita o preenchimento de outros espacos com  
    % posicoes em comum com Esp
    maplist(verifica_palavras(Letras), Esp_comuns).

% ----------------------------------------

verifica_palavras(Letras, Esp_unif) :- 

    % Obtem todas as palavras unificaveis com aquele espaco
    include(subsumes_term(Esp_unif), Letras, Palavras_unificaveis),

    % Se a lista nao for vazia entao, ao unificar Pal em Esp, nao impede que outras palavras sejam unificadas
    \+ ord_empty(Palavras_unificaveis).
    

% 3.1.7. -> palavras_possiveis_esp/4
%
% Argumentos:
% >Letras = lista de listas de letras de palavras
% >Espacos = lista de espacos
% >Esp = lista que representa um espaco
% >Pals_possiveis = lista ordenada de palavras possiveis para o espaco Esp
%
% Descricao:
% >Retorna uma lista ordenada de palavras possiveis para o espaco fornecido


palavras_possiveis_esp(Letras, Espacos, Esp, Pals_possiveis) :-  

    % Obtem todas as palavras possiveis para aquele espaco
    findall(Letra, (member(Letra, Letras), palavra_possivel_esp(Letra, Esp, Espacos, Letras)), Pals_possiveis_desord),

    % Ordena a lista de palavras obtidas
    msort(Pals_possiveis_desord, Pals_possiveis).
    

% 3.1.8. -> palavras_possiveis/3
%
% Argumentos:
% >Letras = lista de lista de letras de palavras
% >Espaco = lista de espacos
% >Pals_possiveis = lista de palavras possiveis para cada espaco
%
% Descricao:
% >Retorna uma lista que contem as palavras possiveis para cada espaco da grelha


palavras_possiveis(Letras, Espacos, Pals_possiveis) :-

    % Chama uma funcao com um acumulador e com a lista de espacos repetidos para que esta seja percorrida
    palavras_possiveis_aux(Letras, Espacos, Espacos, Pals_possiveis, []), !.

% ----------------------------------------

palavras_possiveis_aux(_, _, [], Resultado, Resultado).
palavras_possiveis_aux(Letras, Espacos, [Ele_esp_rec | Cau_esp_rec], Pals_possiveis, Acum) :-

    % Obtem os as letras possiveis para o espaco
    palavras_possiveis_esp(Letras, Espacos, Ele_esp_rec, Palavras_possiveis),

    % Coloca o espaco e as palavras obtidas numa lista consoante as normas do enunciado
    append([Ele_esp_rec], [Palavras_possiveis], Res_append),

    % Coloca a lista anterior num acumulador para, no final, formar uma grelha com espacos e palavras
    append(Acum, [Res_append], Res_acum),

    % Faz a chamada recursiva da funcao de modo a percorrer todos os espacos e a acumular os resultados
    palavras_possiveis_aux(Letras, Espacos, Cau_esp_rec, Pals_possiveis, Res_acum).


% 3.1.9. -> letras_comuns/2
%
% Argumentos:
% >Lst_pals = lista de listas de letras
% >Letras_comuns = lista de pares (pos, letra) significando que todas as listas de Lst_Pals contem a letra em pos
%
% Descricao:
% >Retorna uma lista com as combinacoes de pos/letra comums nas palavras


% Chama uma funcao auxiliar com um acumulador e com uma variavel que controla as iteracoes
letras_comuns(Lst_pals, Letras_comuns) :- letras_comuns_aux(Lst_pals, 1, Letras_comuns, []), !.

% ----------------------------------------

letras_comuns_aux([Ele_lst_pals | Cau_lst_pals], Iterador, Letras_comuns, Acum) :-

    % Verifica se todas as letras ainda nao foram percorridas, se assim nao for, retorna o resultado pretendido
    length(Ele_lst_pals, Len_ele_lst_pals),
    Iterador =< Len_ele_lst_pals

    -> 
    (

    % Obtem a letra da primeira primeira palavra
    nth1(Iterador, Ele_lst_pals, Letra),
    
    % Obtem a letra das restantes palavras que se encontra no indice n
    obtem_restantes_letras(Cau_lst_pals, Iterador, Letras_indice_n, []),

    % Verifica se todos os elementos do indice em questao sao iguais
    maplist(subsumes_term(Letra), Letras_indice_n)

    ->

    % Acumula de acordo com o enunciado o resultado
    append(Acum, [(Iterador, Letra)], Res_acum),

    Iterador_1 is Iterador + 1,

    % Chama recursivamente mas com o iterador incrementado de modo a testar as outras letras
    letras_comuns_aux([Ele_lst_pals | Cau_lst_pals], Iterador_1, Letras_comuns, Res_acum)

    ;

    Iterador_1 is Iterador + 1,

    % Chama recursivamente mas com o iterador incrementado de modo a testar as outras letras
    letras_comuns_aux([Ele_lst_pals | Cau_lst_pals], Iterador_1, Letras_comuns, Acum) 

    )
    ;

    % Atribui o valor acumulado ao resultado pretendido
    Letras_comuns = Acum. 

% ----------------------------------------

obtem_restantes_letras([], _, Resultado, Resultado).
obtem_restantes_letras([Ele_lst_pals | Cau_lst_pals], Iterador, Letras_indice_n, Acum) :-

    % Obtem a letra pretendida
    nth1(Iterador, Ele_lst_pals, Letra),

    % Acumula a letra
    append([Letra], Acum, Res_acum),

    % Chama recursivamente retirando a palavra que ja foi percorrida
    obtem_restantes_letras(Cau_lst_pals, Iterador, Letras_indice_n, Res_acum).


% 3.1.10. -> atribui_comuns/1
%
% Argumentos:
% >Pals_possiveis = lista de palavras possiveis
%
% Descricao:
% >Recebe uma lista de palavras possiveis e atribui as palavras/letras que poder aos espacos da grelha


atribui_comuns([]).
atribui_comuns([ [Espaco | [Palavras] ] | Cau_pals_poss]) :-

    % Verifica se existe mais do que uma palavra possivel para o espaco, se assim for, obtem as letras comuns, se nao
    % atribui a palavra aquele espaco
    length(Palavras, Len_palavras), Len_palavras > 1

    ->
    
    % Obtem as letras em comun das palavras que podem ser atribuidas aquele espaco
    letras_comuns(Palavras, Letras_com),

    % Atribui as letras comuns as correspondentes posicoes do espaco
    atribui_letras_ao_espaco(Espaco, Letras_com),

    % Chama recursivamente sem o elemento que ja foi percorrido 
    atribui_comuns(Cau_pals_poss)

    ;

    % Como so existe uma palavra possivel, esta e unificada com o espaco
    flatten(Palavras, Flat_palavra),
    Espaco = Flat_palavra,

    % Chama recursivamente sem o elemento que ja foi percorrido 
    atribui_comuns(Cau_pals_poss), 
    
    % Impede que de mais do que uma resposta
    !.

% ----------------------------------------

atribui_letras_ao_espaco(_, []).
atribui_letras_ao_espaco(Espaco, [ (Index, Letra) | Cau_letras_com]) :-

    % Unifica a letra na posicao correspondente do espaco
    nth1(Index, Espaco, Letra),
    
    % Chama recursivamente removendo a combinacao que ja foi atribuida ao espaco
    atribui_letras_ao_espaco(Espaco, Cau_letras_com).


% 3.1.11. -> retira_impossiveis/2
%
% Argumentos:
% >Pals_possiveis = lista de palavras possiveis
% >Novas_pals_possiveis = corresponde a lista anterior mas sem as palavras impossiveis
%
% Descricao:
% >Remove as palavras imposssiveis de Pals_possiveis


retira_impossiveis(Pals_possiveis, Novas_pals_possiveis) :- 

    % Chama uma funcao auxiliar com um acumulador
    retira_impossiveis_aux(Pals_possiveis, Novas_pals_possiveis, []).

% ----------------------------------------

retira_impossiveis_aux([], Resultado, Resultado).
retira_impossiveis_aux([ [Espaco | [Palavras] ] | Cau_pals_poss], Novas_pals_possiveis, Acum) :- 


    % Obtem as palavras que podem ser colocadas naquele espaco
    include(subsumes_term(Espaco), Palavras, Palavras_unificaveis),
    
    % Acumula o nova combinacao de espaco/palavras
    append(Acum, [[Espaco | [Palavras_unificaveis]]], Res_acum),

    % Chama recursivamente sem a combinacao espaco/palavras ja percorrida
    retira_impossiveis_aux(Cau_pals_poss, Novas_pals_possiveis, Res_acum).


% 3.1.12. -> obtem_unicas/2
%
% Argumentos:
% >Pals_possiveis = lista de palavras possiveis
% >Unicas = lista de palavras unicas de Pals_possiveis
%
% Descricao:
% >Obtem a lista de palavras unicas (que ja estam atribuidas a um espaco) de Pals_possiveis


% Chama um predicado auxiliar com um acumulador
obtem_unicas(Pals_possiveis, Unicas) :- obtem_unicas_aux(Pals_possiveis, Unicas, []).

% ----------------------------------------

obtem_unicas_aux([], Resultado, Resultado).
obtem_unicas_aux([ [_ | [Palavras] ] | Cau_pals_poss], Unicas, Acum) :-

    % Verifica se a palavra e unica
    length(Palavras, Len_pal), Len_pal =:= 1
    
    ->

    % Acumula a palavra
    append(Acum, Palavras, Res_acum),

    % Chama recursivamente sem a combinacao espaco/palavras que ja foi percorrida
    obtem_unicas_aux(Cau_pals_poss, Unicas, Res_acum)

    ;

    % Chama recursivamente sem a combinacao espaco/palavras que ja foi percorrida
    obtem_unicas_aux(Cau_pals_poss, Unicas, Acum).


% 3.1.13. -> retira_unicas/2
%
% Argumentos:
% >Pals_possiveis = lista de palavras possiveis
% >Novas_Pals_Possiveis = lista de palavras unicas de Pals_possiveis
%
% Descricao:
% >Remove as palavras das combinacoes espacos/palavras que ja foram unificadas num outro espaco


retira_unicas(Pals_possiveis, Novas_pals_possiveis) :- 

    % Obtem as palavras unicas 
    obtem_unicas(Pals_possiveis, Unicas),
    
    % Chama uma funcao auxiliar com um acumulador e com uma lista de palavras unicas
    retira_unicas_aux(Pals_possiveis, Unicas, Novas_pals_possiveis, []).

% ----------------------------------------

retira_unicas_aux([], _, Resultado, Resultado).
retira_unicas_aux([ [Espaco | [Palavras] ] | Cau_pals_poss], Unicas, Novas_pals_possiveis, Acum) :-

    % Verifica se existem mais do que uma possibilidade de palavra para o espaco
    length(Palavras, Len_pal), Len_pal > 1

    ->

    % Obtem as palavras que devem poder ser unificadas naquele espaco
    findall(Palavra, (member(Palavra, Palavras), \+ member(Palavra, Unicas)), Palavras_unicas),
    
    % Acumula a nova combinacao de espaco/palavras (tem as palavras obtidas anteriormente)
    append(Acum, [ [ Espaco | [Palavras_unicas] ] ], Res_acum),

    % Chama recursivamente sem a combinacao que ja foi percorrida
    retira_unicas_aux(Cau_pals_poss, Unicas, Novas_pals_possiveis,  Res_acum)

    ;

    % Acumula a combinacao tal como ela esta
    append(Acum, [ [ Espaco | [Palavras] ] ], Res_acum),

    % Chama recursivamente sem a combinacao que ja foi percorrida
    retira_unicas_aux(Cau_pals_poss, Unicas, Novas_pals_possiveis, Res_acum).


% 3.1.14. -> simplifica/2
%
% Argumentos:
% >Pals_possiveis = lista de palavras possiveis
% >Novas_pals_possiveis = lista igual a Pals_possiveis mas com as variacoes causadas pelo uso do predicadp
%
% Descricao:
% >Recebe uma lista de palavras possiveis e atribui as palavras/letras que poder aos espacos da grelha


simplifica(Pals_possiveis, Novas_pals_possiveis) :- 

    % Simplifica as Pals_possiveis
    aplica_predicados(Pals_possiveis, Pals_alteradas),

    % Verifica se foram feitas alteracoes
    verifica_alteracoes(Pals_possiveis, Pals_alteradas, Novas_pals_possiveis).

% ----------------------------------------

verifica_alteracoes(Pals_antigas, Pals_novas, Resultado_final) :-

    % Verifica se nao foram feitas alteracoes aos elementos
    Pals_antigas == Pals_novas

    ->

    % Termina o predicado e retorna o resultado pretendido
    Resultado_final = Pals_novas

    ;

    % Repete o predicado ate nao alterar mais nada
    simplifica(Pals_novas, Resultado_final).

% ----------------------------------------

aplica_predicados(Pals_possiveis, Resultado) :-

    % Atribui as letras comuns (entre as palavras da combinacao espaco/palavras) a cada espaco
    atribui_comuns(Pals_possiveis),

    % Para cada espaco, remove as palavras que ja nao lhe podem ser atribuidas
    retira_impossiveis(Pals_possiveis, Pals_possiveis_retiradas),

    % Remove as palavras das combinacoes espacos/palavras que ja foram unificadas num outro espaco
    retira_unicas(Pals_possiveis_retiradas, Resultado).


% 3.1.15. -> inicializa/2
%
% Argumentos:
% >Puz = lista de listas que representa um puzzle (contem um conjunto de palavras e uma grelha)
% >Novas_pals_possiveis = resultado de inicializar o Puz
%
% Descricao:
% >Inicializa/simplifica o Puz de acordo com as normas do enunciado


inicializa([ Lst_pals | [Grelha] ], Novas_pals_possiveis) :-

    % Obtem uma lista de listas de palavras
    obtem_letras_palavras(Lst_pals, Lst_letras),

    % Obtem uma lista com todos os espacos do puzzle
    espacos_puzzle(Grelha, Espacos),

    % Obtem uma lista que representa as palavras possiveis para cada espaco
    palavras_possiveis(Lst_letras, Espacos, Pals_possiveis),

    % Simplifica o puzzle e torna-o mais facil de resolver
    simplifica(Pals_possiveis, Novas_pals_possiveis).


% ---------------------------------------------------------------------------------------------------------------------%
% ----------------------------- PREDICADOS DE RESOLUCAO DE LISTAS DE PALAVRAS POSSIVEIS -------------------------------%
% ---------------------------------------------------------------------------------------------------------------------%


% 3.2.1. -> escolhe_menos_alternativas/2
%
% Argumentos:
% >Pals_possiveis = lista de palavras possiveis
% >Escolha = lista que representa um elemento de Pals_Possiveis
%
% Descricao:
% >Retorna uma Escolha escolhido segundo o criterio do enunciado, porem se todos os espacos em Pals_Possiveis 
%  tiverem associadas listas de palavras unitarias, retorna falso


escolhe_menos_alternativas(Pals_possiveis, Escolha) :-

    % Obtem uma lista das combinacoes espaco/palavras que nao tem palavras unitarias
    include(filtra_tamanho, Pals_possiveis, Pals_possiveis_sem_unitarias),

    % Formata a lista de modo a que o primeiro elemento seja uma combinacao de espaco/palavra com o menor numero de 
    % palavras na lista de palavras
    reformata_lista(Pals_possiveis_sem_unitarias, Lst_ordenada),

    % Escolhe o primeiro elemento da lista porque vai ser o que tem menos palavras
    [ Escolha | _ ] = Lst_ordenada.

% ----------------------------------------

reformata_lista(Lst_pals, Lst_res) :-

    % Cria uma lista de pares em que cada Key (combinacao espaco/palavras) esta ligada ao tamanho da lista de palavras
    map_list_to_pairs(obtem_tamanho, Lst_pals, Lst_chaves_pares),

    % Vamos ordenar consoante o tamanho da lista de palavras (o mais pequeno fica no comeco)
    keysort(Lst_chaves_pares, Lst_chaves_ordenada),

    % Transforma a lista de pares anterior numa lista normal de espaco/palavras
    pairs_values(Lst_chaves_ordenada, Lst_res).

% ----------------------------------------

% Apenas retorna true se Palavras tiver um tamanho superior a 1, ou seja, nao e unitaria
filtra_tamanho([ _ | [Palavras] ]) :- length(Palavras, Len_pal), Len_pal > 1.

% ----------------------------------------

% Retorna o tamanho da lista de palavras da combinacao Espaco/Palavras
obtem_tamanho([ _ | [Palavras] ], Len_palavra) :- length(Palavras, Len_palavra).


% 3.2.2. -> experimenta_pal/3
%
% Argumentos:
% >Escolha = lista que representa um elemento de Pals_Possiveis
% >Pals_possiveis = lista de palavras possiveis
% >Novas_pals_possiveis = resultado de substituir, em Pals_Possiveis, o elemento Escolha por um novo
%
% Descricao:
% >Vai experimentar atribuir palavras aos espacos que estam na Escolha


experimenta_pal([ Espaco | [Palavras] ], Pals_possiveis, Novas_pals_possiveis) :-

    % Obtem uma das palavras da lista de palavras daquela combinacao e unifica com o espaco
    member(Palavra, Palavras), Espaco = Palavra,

    % Altera o puzzle de modo a que o espaco a ser testado fique corretamente escrito
    maplist(reformata_pals_possiveis([ Espaco | [Palavras] ]), Pals_possiveis, Novas_pals_possiveis).

% ----------------------------------------

reformata_pals_possiveis(Escolha, Ele_pals_poss, Resultado) :-

    % Verifica se a combinacao espaco/palavras e a que foi escolhida
    Escolha == Ele_pals_poss

    -> 

    % Escolhe a primeira letra da lista de palavras da e altera o espaco para que passe a estar no formato correto
    [ Palavra | _ ] = Escolha, Resultado = [Palavra, [Palavra]]

    ;

    % Como este nao corresponde ao espaco da escolha, vai permanecer igual
    Resultado = Ele_pals_poss.


% 3.2.3. -> resolve_aux/2
%
% Argumentos:
% >Pals_possiveis = lista de palavras possiveis
% >Novas_pals_possiveis = resultado de aplicar o algoritmo descrito no enunciado em Pals_possiveis
%
% Descricao:
% >Vai dar as varias solucoes do puzzle


resolve_aux(Pals_possiveis, Novas_pals_possiveis) :-

    % Vai escolher um espaco para aplicar o algoritmo, se ja estiver resolvido, retornar false 
    escolhe_menos_alternativas(Pals_possiveis, Escolha) 

    ->

    % Vamos agora experimentar a palavras ate encontrar uma solucao
    experimenta_pal(Escolha, Pals_possiveis, Res_experimentar_pals),

    % Simplifica o puzzle
    simplifica(Res_experimentar_pals, Res_simplificar_pals),

    % Volta a chamar este predicado ate que o puzzle esteja resolvido
    resolve_aux(Res_simplificar_pals, Novas_pals_possiveis)

    ;

    % Significa que ja terminou e entao unifica o a lista que tem com o resultado final
    Novas_pals_possiveis = Pals_possiveis.


% ---------------------------------------------------------------------------------------------------------------------%
% -------------------------------------- PREDICADOS DE RESOLUCAO DE PUZZLES -------------------------------------------%
% ---------------------------------------------------------------------------------------------------------------------%


% 3.3.1. -> resolve/1
%
% Argumentos:
% >Puz = Corresponde a uma lista que representa um puzzle ou seja, na primeira posicao esta uma lista de palavras e na 
%  segunda posicao esta uma grelha
%
% Descricao:
% >Vai resolver o enunciado

resolve(Puz) :-

    % Inicializa o puzzle (vai retornar uma lista de palavras possiveis para cada espaco)
    inicializa(Puz, Pals_possiveis),

    % Resolve o enunciado do problema
    resolve_aux(Pals_possiveis, _ ).

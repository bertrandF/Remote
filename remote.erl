-module(remote).
-export([start_lupus/0, start_caninus/1, do_lupus/0, do_caninus/2]).

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INFO: Comment lancer des processus sur des machines distantes et leur
%       envoyer des messages. 
%       L'échange de messages se fait entre process (ceux demares avec 
%       spawn()). Chaque process tourne au sein d'un noeud Erlang, lui 
%       meme heberge par une machine hote.
%       Dans la suite, lors du lancement du shell Erlang, le prompt affichera
%       le nom du noeud ainsi que celui de la machine (ex: lupus@www).
%       Pour envoyer un message a ce noeud on utilise la syntaxe '{pid, noeud}',
%       (ex: '{lupus, lupus@www} ! {finished}')
%               ^      ^     ^
%               |      |     +--- Nom de la machine (hostname)
%               |      +--- Nom du noeud Erlang (option '-sname' du shell)
%               +--- Nom du process (declare avec register())
%
% SECURITE: Afin de controler l'acces aux processus Erlang a travers un 
%           reseau, pour communiquer ensemble, deux noeud doivent avoir le
%           meme cookie Erlang. Celui ci est stoke par defaut dans le home
%           directory de l'utilisateur ('~/.erlang.cookie').
%
% HOW TO:
%   1-  Sur la premiere machine:
%       a-  Demarer un shell/node Erlang en donnant le NOM DU NOEUD ERLANG 
%           (ici on choisit 'lupus'): 'erl -sname lupus'
%       b-  Compiler le module: '(lupus@www)1> c(remote).'
%       c-  Lancer lupus: '(lupus@www)2> remote:start_lupus().'
%
%   2-  Sur la seconde machine:
%       a-  Demarer un shell/node Erlang en donnant le NOM DU NOEUD ERLANG 
%           (ici on choisit 'caninus'): 'erl -sname caninus'
%       b-  Compiler le module: '(caninus@www)1> c(remote).'
%       c-  Lancer caninus: '(caninus@www)2> remote:start_caninus(lupus@www).'
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

do_lupus() ->
    receive
        finished ->
            io:format("It's the weekend ! ~n"),
            done;
        {do, Caninus_PID} ->
            io:format("Doing my work ... OK ~n"),
            Caninus_PID ! done
    end,
    do_lupus().


do_caninus(0, Lupus_node) ->
    {lupus, Lupus_node} ! {finished};
do_caninus(N, Lupus_node) ->
    {lupus, Lupus_node} ! {do, self()},
    receive
        done ->
            io:format("Caninus finished working. Sending more work ... ~n")
    end,
    do_caninus(N-1, Lupus_node).


start_caninus(Lupus_node) ->
    register(caninus, spawn(remote, do_caninus, [3, Lupus_node])),
    ok.

start_lupus() ->
    register(lupus, spawn(remote, do_lupus, [])),
    ok.

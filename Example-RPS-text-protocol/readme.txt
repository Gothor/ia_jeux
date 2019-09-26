Confronter deux programmes implique d'établir un protocole texte permettant de dialoguer et un programme interface.
Rock-Paper-Scisors (alias RPS) est un jeu à deux joueurs en 1 tour.
Chaque joueur choisit simultanéement une valeur entre Rock Paper et Scisors. 
A l'issue de ce choix, soit l'un des deux joueurs gagne, soit les deux joueurs sont ex-aequo.

Nommons rps-tp ce protocole texte.
Proposons pour rps-tp, les commandes suivantes:
 quit
 name
 version
 showboard
 newgame
 genmove
 play ROCK | PAPER | SCISORS
 opp_play ROCK | PAPER | SCISORS
 endgame
 list_commands

En cas de bonne réception d'une commande, le programme-client répond "=\n"
En cas de mauvaise réception, le programme-client répond "= ?\n" 

Ci dessous un exemple de partie avec ce protocole texte :

///////////////////////////
$> ./RPS-Player
newgame
= 

genmove
= ROCK

play ROCK
= 

opp_play PAPER
= 

showboard
MY:ROCK OPP:PAPER
= 

endgame
= 

quit
= 

$>
///////////////////////////

Actions associées aux commandes du protocole texte :

 quit : quitter l'interpréteur en cours
 name : retourner le nom du programme-client
 version : retourner la version du programme-client
 showboard : retourner les coups joués par chaque joueur
 newgame : annoncer une nouvelle partie
 genmove : générer un coup
 play ROCK | PAPER | SCISORS : jouer un coup
 opp_play ROCK | PAPER | SCISORS : jouer le coup adverse
 endgame : annoncer la fin de partie
 list_commands : retourner la liste des commandes

//////////////////////////////

sh run_many_games.sh ./Rand-RPS-Player ./ROCK-RPS-Player data 10




# NOTES DE TRAVAIL

### 2026-03-03
* Désactivation du mot __2*__  dictonnaire rendu à 172 mots.
* Remis le mot __EVAL__ à son état original en désactivant le code modifiant la variable __UNEST__. 
* Modifié le mot __.OK__ pour désactiver le code testant l'état de __UNEST__ 
* Modifié le mot __.OK__ pour utiliser le mot __STATE__ pour déterminer si en mode INTERPRET ou COMPILE.
* Modifié le mot __WORDS__ pour afficher le nombre de mots dans le dictionnaire à la fin de la liste.
* commit __c1c16a646aec4eb87f454c733c017b4251a6e666__ effectué à 11:15:51
* Corrigé bogue dans __.OK__ qui ne s'affichait plus.
* Réécriture en assembleur de la routine __PARS__ pour sauver de l'espace.
* réécriture de __DIGIT__ en assembleur. 
* Réécritue de __HOLD__ en assembleur. 
* Modification de __FORGET__.
* Modification de __RSTVEC__
* Réécriture de __HEX__ et __DECIMAL__ en assembleur.
* Modifié  __EXTRACT__ pour utilisé __USLMOD__ au lieu de __UMMOD__. 

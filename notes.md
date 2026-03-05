# NOTES DE TRAVAIL

### 2026-03-04
* Renommé  __PAUSE__  en __WAIT__.
* Éliminer __TIMER__ et __TIMEOUT?__ et renommé __MSEC__ en __TIMER__.
* Éliminé la variable __CNTDWN__ et modifié __Timer4Handler__ en conséquence.
* Ajout du mot __TMR-RST__ pour remettre à zéro le compteur de millisecondes.
* Réécriture de __WAIT__.
* Réécriture de __OVER__. 
* Réécriture de __2DUP__. 
* Désactivation de __UM/MOD__. 
* Effectué un commit à 10:13:16
* Réécriture de __+!__. 
* Réécriture de __PAD__. 
* Réécriture de __@EXECUTE__. 
* Modifié __STRCQ__ pour sauté le __"__ à la fin de la chaîne en incrémentant __UINN__.
* Effectué un commit à 11:09:59.
* Créaton de la routine __utoa__ dans le fichier [bios.asm](bios.asm) pour remplacer plusieurs mot du FORTH.
* Sauver de l'espace en utilisant __utoa__ au lieu des mots __HOLD__, __&lt;#__, __#&gt;__, __#__, __EXTRACT__ et __SIGN__.
* Renommé __prt_cstr__  en __PRINT__ et déplacé dans [ForthCore.asm](ForthCore.asm).
* commit à 21:55:06.
* Débuté réécriture de NUMBER? en assembleur.
* commit à 22:47:06.

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

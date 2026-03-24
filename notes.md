# NOTES DE TRAVAIL

### 2026-03-23

* Retour au stm8l151k6.  Modifié [forth/w25q_prog.f](forth/w25q_prog.f ) pour utilisé PB0 au lieu de PA3 comme chip select du W25Q80DV.
* Ajout du démo [forth/play_wav.f](forth/play_wav.f).
* Corrigé bogue dans [ForthCore.asm](ForthCore.asm), la valeur __IRET_CODE__ était erronée.
* _PLAY_WAV fonctionne mais il faudrait ajoute un filtre passe bas pour éliminer le bruit de quantisation.
 

### 2026-03-22

* Travail sur [forth/w25q_prog.f](forth/w25q_prog.f ).
* Modifié __ABORT__ pour envoyer un retour à la ligne. 
* Testé avec succès [forth/w25q_prog.f](forth/w25q_prog.f ) en programmant le ficher [ren_3i_type_22k.hex](ren_3i_type_22k.hex) dans la W25Q80DV. durée de la programmation 26 minutes.
* Ajout de __W25Q_DUMP__ dans [forth/w25q_prog.f](forth/w25q_prog.f ). Testé avec succès.
* Corrigé bogue dans [forth/spi.f](forth/spi.f) __WRITE_BUFF__ et __READ_BUFF__ ne jetait pas __b__ à la sortie de la boucle FOR...NEXT.
* commit à 21:59 suivit d'un push.


### 2026-03-21 

* Adaptation de smallForth pour le stm8s103f3.
* Travail sur [forth/w25q_prog.f](forth/w25q_prog.f ). 
* Ajout de UM+  dans [forth/w25q_prog.f](forth/w25q_prog.f ).
* commit 21:40


### 2026-03-19 

* Augmenté la taille de **TIB_SIZE** à 128 octets. 
* Augmenté la taille **RX_QUEUE_SIZE** à 32 octets.
* commit 11:15 


### 2026-03-18

* Déboguage de [forth/spi.f](forth/spi.f). 
    * Les broches de sorties des périphériques doivent-être configurées en push-pull dans le registre PB_CR1, donc PB5 et PB6 devait l'être pour que le SPI fonctionne.
    * dans __WRITE_BUFF__ j'avais oublié d'envoyé la commande __2__ avant d'envoyer l'adresse. 
    * Mise à jour des commentaires dans plusieurs fichiers démo forth.
    * commit à 11:17 
    * Ajout de des mots __W25Q_RD_SR1__ et __W25Q_ERASE_SECTOR__ au démo [forth/spi.f](forth/spi.f).
    * Commit et push à 11:35 
    * Corrigé bogue dans __W25Q_ERASE_SECTOR__, testait le mauvait bit dans SR1. 
    * Modification de [bios.asm](bios.asm) pour activer les pullup sur toutes les entrées.
    * Commit 20:16 
    * Ajout de **W25Q_WAIT_EOP** et **W25Q_ERASE_CHIP** dans [forth/spi.f](forth/spi.f).
    * Ajout du fichier [forth/load_buffer.f](forth/load_buffer.f).
    * Commit 21:53
    * Modifié [forth/load_buffer.f](forth/load_buffer.f). 
    * commit 22:05 
    

### 2026-03-17 

* Ajout du fichier [forth/spi_registers.f](forth/spi_registers.f).
* Création du démo [forth/spi.f](forth/spi.f). 


### 2026-03-16

* Renommé le fichier [forth/dma.f](forth/dma.f) [forth/dma_registers.f](forth/dma_registers.f). 
* Après lecture de la documentation j'ai du mofifié le canal DMA utilisé par le DAC pour le canal 3.
* Modifié l'initialisation du TIMER4 dans [bios.asm](bios.asm), ramené la valeur de ARR à 124.
* Débogué [dma_dac.f](forth/dma_dac.f).
* commit à 15:28 suivit d'un push.
* Modifié [dma_dac.f](forth/dma_dac.f) pour faire passer la fréquence d'échantillonnage à 40Khz. Le démo produit maintenant une fréquence 1Khz.

### 2026-03-15

* Mise à jour note de license dans les fichiers source.
* Mise à jour du [readme.md](readme.md).
* Débuté un nouveau démo [dma_dac.f](forth/dma_dac.f), démontrant l'utilisation du DMA avec le convertisseur numérique/analogique.
* commit à 11:11 
* Continuer travail sur [dma_dac.f](forth/dma_dac.f). Le transfert DMA ne fonctionne pas.


### 2026-03-14 
* Ajout du programme [forth/dac.f](forth/dac.f).
* commit à 12:03 
* Corrigé bogue dans __NOISE__ de [forth/dac.f](forth/dac.f).       
* commit à 12:06 
* Corrigé bogue dans [bios.asm](bios.asm) dans l'initialisation du TIMER4 le registre ARR doit-être initialisé à **131** et non **125**.
* Corrigé bogue dans mot __FORGET__, __UPDATPTR__ n'était pas appellé.
* Incrémenté le numéro de révision à 2.
* commit à 20:30 
* Création du tag V1.1R2 
* Corrigé bogue dans NOISE du démo forth/dac.f
* commit à 20:36 suivit d'un push.


### 2026-03-13
* Ajout du programme [forth/char.f](forth/char.f).
* Modifié [forth/warble.f](forth/warble.f), remplacé __256 /MOD__  par un __8 RSHIFT__ plus rapide.
* Ajout du programme [forth/adc.f]. Démonstration de lecture d'un canal sur le convertisseur ADC1.
* commit à 16:46  et push.
* Reformaté le programme [forth/flags.f](forth/flags.f).
* commit à 16:56 
* Réactivé le mot __2/__ et __2*__ dans [ForthCore.asm](ForthCore.asm). 
* Modifié et débogué [forth/warble.f](forth/warble.f).
* commit à 21:00 
* Création du tag V1.1 poussé le tag vers github.


### 2026-03-12 
* Modifié le script [send.sh](send.sh), nécessitait un délais plus long.
* Création du programme [forth/blink.f](forth/blink.f).
* Création du programme [forth/exist.f](forth/exist.f)
* Création du programme [forth/warble.f](forth/warble.f)
* commit à 16:32 
* Moficiation de [forth/exist.f](forth/exist.f). 
* commit à 20:03 
* Modification de  [forth/warble.f](forth/warble.f)
* commit à 22:15 


### 2026-03-11
* Ajout des mots __DI__ et __EI__ qui avait été retirés du fichier [interrupts.asm](interrupts.asm).
* Suppression du mot __HLD__ qui n'était plus utile. 
* Travail sur le fichier [référence_smallForth.md]. 
* Corrigé erreur dans [ForthCore.asm](ForthCore.asm) où le mot "NEXT" apparaissait 2 fois. Le 2ième étant en fait le runtime __DONXT__.
* Travail sur le fichier [référence_smallForth.md]. 
* Merge de la branche test à la branche main à 15:03.

### 2026-03-10 
* Création de l'étiquette __DPUSHA:__ dans la routine __STR__. 
* Réécriture de __KEY__, __SNAME__ et __WORDS__ pour utiliser __DPUSHA__.
* commit à 10:52
* Ajout des mots __SETBIT__, __RSTBIT__ et __TOGLBIT__. 
* commit à 11:26
* Ajout du flags __COMPO__ aux mots __R&gt;__ et __R@__.
* commit 21:27 
* 21:28 Merge de la branche test à la branche main.
* Déplacé le mot __PICK__ du fichier [tools.asm](tools.asm) vers le fichier [ForthCore.asm](ForthCore.asm)
* Travail sur le fichier [référence_smallForth.md]. 
* commit à 22:15

### 2026-03-09 
* Remplacé __CALL XORW_Y___ par __CALLR XORW_Y__.
* Recodé __WAIT__ pour changer l'ordre des instructions.
* Désactivation du mot __TEMP__. 
* Modifié  __0&lt;__ pour sauver de l'espace. 
* commit à 12:09 
* Désactivé  __DIGIT?__
* Désactivé  __BL__ 
* Désactivé  __ACCEPT__ 
* Recodé     __QUERY__ en assembleur.
* Commit à 20:25 
* Réécriture de __SNAME__  pour réduire la taille.
* commit à 21:11 
 
### 2026-03-08 
*  sauvegarde des fichiers *.asm dans le dossier __save__. 
*  RESET de la brnache test à 3bd05065b7a25f2059e261860485b8ee48a04c41
*  Ajout de CHIPID dans le fichier [stm8l151k6.inc](inc/stm8l151k6.inc).
*  Modifié routine __reset__ dans [bios.asm](bios.asm) pour initialisé __SEEDY__ avec le LOT#. 
*  Commit 12:08 
*  Corrigé bogue dans __FIND__. 
*  Commit 15:32 
*  Corrigé bogue dans __PARS__.
*  Supprimé code fantôme dans [tools.asm](tools.asm).
*  Modifié __PARS__ pour que les espaces soient sautées seulement lorsque le séparateur est un espace.
*  Remplacé __CALL__ par __CALLR__ dans __PARSE__, __(__, __WORD__, __FIND__, __&gt;NAME__.
*  Remplacé un __JP__ par un __JRA__ dans __TOKEN__. 

### 2026-03-07
* Réécriture de __SAME?__ en assembleur pour réduire la taille.


### 2026-03-05
* merge de la branche test à la branche main 
* Réécriture du mot __FORGET__ pour sauver de l'espace. 
* Modifié __RAND__ pour remplacé les les macros **_stryz** et **_ldxz** .
* commit à 11:48:48
* Corrigé bogue dand __NUMBER?__. 
* Réécriture de DOSTR en assembleur. 
* Désactivé __$"__ qui n'était pas utilisé.
* commit à 21:28


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

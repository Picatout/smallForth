# smallForth V1.0  référence du vocabulaire.

## Conventions typographique

**a**&nbsp;&nbsp;  Adressse 16 bits 

**b**&nbsp;&nbsp;  Adresse 16 bits d'une chaîne de caractères

**c**&nbsp;&nbsp;  Caractère ASCII ou octet.

**f**&nbsp;&nbsp; Indicateur booléen 0 indique faux tout autre valeur est considérée comme vrai.

**i**&nbsp;&nbsp; Entier 16 bits signé {-32767...32767}, -32768 utilisé comme indicateur de débordement.

**id**&nbsp;&nbsp; Entier double (32 bits) signé

**n**&nbsp;&nbsp; Valeur 16 bits sans type défini.

**n+**&nbsp;&nbsp; Entier positif {0...32767}.

**u**&nbsp;&nbsp; Entier 16 bits non signé {0...65535}.

**ud**&nbsp;&nbsp; Entier 32 bits non signé.

**nx**&nbsp;&nbsp; Représente un nombre quelconque d'élément sur la pile.

**R:**&nbsp;&nbsp; Représente la pile des retours. 

**( nx1 -- nx2 )**&nbsp;&nbsp;  Commentaire indiquant  la liste des paramètres à gauche et des résultats à droite.

**T**&nbsp;&nbsp;  Indique la valeur booléenne **vrai**. 

**F**&nbsp;&nbsp;  Indique la valeur booléenne **faux**. 

<hr>
<a name="index"></a>

# Index 

Chaque module a une section séparée pour son vocubulaire. Cet index conduit à la section concernée. 

* [core](#core)&nbsp;&nbsp; module [ForthCore.asm](ForthCore.asm) 

* [flash](#flash)&nbsp;&nbsp; module [flash.asm](flash.asm) 

* [intr](#intr)&nbsp;&nbsp;  module [interrupts.asm](interrupts.asm) 

* [tools](#tools)&nbsp;&nbsp; module [tools.asm](tools.asm) 

* [bios](#bios)&nbsp;&nbsp; module [bios.asm](tools.asm) 

<hr>
<a id="core"></a>

## Vocabulaire principal du système

* __!__&nbsp;&nbsp;( n a -- ) Dépose la valeur **n** à l'adresse **a**

* __#TIB__&nbsp;&nbsp;( -- a ) Empile l'adresse de la variable système **UCTIB**. Cette variable contient le nombre de caractères qu'il y a dans le TIB *(Terminal Input Buffer)*.  

* __'__ &lt;nom&gt;&nbsp;&nbsp;( -- a ) Ce mot est suivit d'une chaîne de caractère qui doit représenter un mot du dictionnaire. Si ce mot est trouvé **a** est l'adresse d'éxécution de ce mot. Un échec résulte en un abandon avec message d'erreur.

* __'EVAL__&nbsp;&nbsp;( -- a ) Retourne l'adresse de la variable système **UINTER** qui contient l'adresse du code qui doit-être exécuté par **'EVAL**. 

* __(__&nbsp;&nbsp;( -- ) Ce mot introduit un commentaire délimité par **)**. Les commentaires sont simplement ignorés.

* __*__&nbsp;&nbsp;( i1 i2 -- i3 )  Multiplication signée. __i3=i1*i2__.

* __+__&nbsp;&nbsp;( i1 i2 -- i3 ) addition signée __i3=i1+i2__. 

* __+!__&nbsp;&nbsp;( i a -- ) Ajoute la valeur __i__ à l'entier situé à l'adresse __a__ et sauvegarde la nouvelle valeur.

* __,__&nbsp;&nbsp;( n -- ) Compile la valeur __n__ dans la mémoire FLASH et avance le pointer __UCP__ de 2 octets.

* __-__&nbsp;&nbsp;( i1 i2 -- i3 ) Soustraction signée. __i3=i1-i2__.

* __.__&nbsp;&nbsp;( i -- ) Imprime l'entier au sommet de la pile. __i__ est retiré de la pile.

* __."__ &lt;string"&gt;&nbsp;&nbsp;( -- ) Compile une chaîne litérale pour impression. Cette chaîne est terminée par le caractère **"**. Ce caractère est un délimiteur et ne fait pas partie de la chaîne compilée.

* __.OK__&nbsp;&nbsp;( -- ) Imprime le message ** ok** suivit d'un **CR**. 

* __/__&nbsp;&nbsp;( i1 i2 -- i3  ) Division entière sigée. **i3=i1/i2**. Le quotient est tronqué vers zéro.

* __/MOD__&nbsp;&nbsp;( i1 i2 -- r q ) **q** est le quotient et **r** le reste de la division entière __i1/i2__.  

* __0__&nbsp;&nbsp;( -- 0 ) Constante numérique **0**.  

* __0<__&nbsp;&nbsp;( i -- f ) Retourne vrai (-1) si __i&lt;0__ sinon retourne 0.

* __1+__&nbsp;&nbsp;( i1 -- i2 ) **i2=i1+1**. 

* __1-__&nbsp;&nbsp;( i1 -- i2 ) **i2-i1-1**.

* __2*__&nbsp;&nbsp;( i1 -- i2 ) __i2=2*i1__.

* __2+__&nbsp;&nbsp;( i1 -- i2 ) **i2=i1+2**. 

* __2-__&nbsp;&nbsp;( i1 -- i2 ) **i2=i1-2**.

* __2/__&nbsp;&nbsp;( i1 -- i2 ) **i2=i1/2**. 

* __2DROP__&nbsp;&nbsp;( n1 n2 -- ) Jette les 2 éléments au sommet de la pile. 

* __2DUP__&nbsp;&nbsp;( n1 n2 -- n1 n2 n1 n2 ) Duplique les 2 éléments au sommet de la pile. 

* __:__ &lt;nom&gt;&nbsp;&nbsp;( --) Débute la création d'une nouvelle définition dans le dictionnaire. **&lt;nom&gt;** est le nom de cette nouvelle définition. Passe en mode compilation. 

* __;__&nbsp;&nbsp;( -- ) Complète la définition d'un nouveau mot et repasse en mode interprétaion. 

* __<__&nbsp;&nbsp;( i1 i2 -- f ) Empile la valeur booléenne résultant de la compariason __i1&lt;i2__.

* __=__&nbsp;&nbsp;( i1 i2 -- f ) Empile la valeur booléenne résultant de la comparaison __i1=i2__.

* __>IN__&nbsp;&nbsp;( -- a ) Empile l'adrese de la variable système **UINN** qui est le pointeur de l'analyseur lexical. 

* __>NAME__&nbsp;&nbsp;( ca -- nfa|0 ) Retourne l'adrresse du champ nom __nfa__ à partir de l'adresse du champ code __ca__ d'une entrée du dictionnaire. __ca__ est le *code address* et __nfa__ est le *name field address*. Si le champ code est invalide retourne **0**. 

* __>R__&nbsp;&nbsp;( n -- R: n ) Envoie __n__ sur la pile des retours.

* __?DUP__&nbsp;&nbsp;( n -- n n | 0 ) Duplique **n** seulement si **&lt;&gt; 0**. 

* __KEY?__&nbsp;&nbsp;( -- f ) Vérifie s'il y a un caractère de disponible en provenance du terminal. Retourne un indicateur booléen.
  
* __?STACK__&nbsp;&nbsp;( -- ) Vérifie si la pile des arguments est en état sous-vidée *(underflow)*. Un abadon avec message d'erreur se produit dans ce cas.

* __?UNIQUE__&nbsp;&nbsp;( b -- b ) Vérifie si le nom pointé par __b__ existe déjà dans le dictionnaire.  Affiche un message d'avertissement si ce nom est déjà dans le dictionnaire. Ça signifie qu'on est en train de redéfinir un mot qui est déjà dans le dictionnaire.

* __@__&nbsp;&nbsp;( a -- n ) Empile l'entier qui est à l'adresse __a__.

* __@EXECUTE__&nbsp;&nbsp;( a -- ) __a__ est un pointeur vers l'adresse d'un code exécutable. Il s'agit d'un __@__ pour obtenir le __ca__ suivit d'un __EXECUTE__. 

* __ABORT__&nbsp;&nbsp;( nx -- ) Abandon avec vidage de la pile et du TIB. Est appellé par **ABORT"**.  

* __ABORT"__&nbsp;&nbsp;( f -- ) Si l'indicateur est vrai affiche le message litéral qui suit et appelle **ABORT**.

* __ABS__&nbsp;&nbsp;( i1 -- u ) __u__ est la valeur absolue de **i1**. 

* __AGAIN__&nbsp;&nbsp;( a -- ) Compile un saut arrière au début d'une boucle BEGIN..AGAIN. __a__ est la distination du saut et a été laissé sur la pile par __BEGIN__. 

* __ALLOT__&nbsp;&nbsp;( u -- ) Alloue __u__ octets dans l'espace RAM. Avance le pointeur **UVP** de __u__ octets. 

* __AND__&nbsp;&nbsp;( n1 n2 -- n3 ) Opération bit à bit ET.  

* __AUTORUN__ &lt;string&gt;&nbsp;&nbsp;( --  ) Enregistre dans la variable système persistante **EEP_RUN**  l'adresse d'exécution du programme qui doit-être exécuté au démarrage. Les 16 premiers octets de l'EEPROM sont réservés pour les variables système persistantes. 

* __BASE__&nbsp;&nbsp;( -- a ) Empile l'adresse de la variable système **UBASE** qui contient la base numérique utilisée pour la conversion des entiers en chaîne de caractères et vice-versa. 

* __BEGIN__&nbsp;&nbsp;( -- a ) Compile le début d'une boucle BEGIN..UNTIL|AGAIN|REPEAT. **a** indique l'adresse où doit se faire le saut arrière pour répéter la boucle. **a** est consommé par UNTIL|AGAIN|REPEAT. 

* __C!__&nbsp;&nbsp;( c a -- ) Dépose le caractère **c** à l'adresse **a**. 

* __C,__&nbsp;&nbsp;( c -- ) Compile le caractère qui est au sommet de la pile. 

* __C@__&nbsp;&nbsp;( a -- c ) Empile l'octet qui se trouve à l'adresse **a**.

* __CMOVE__&nbsp;&nbsp;( a1 a2 u -- ) Copie **u** octets de **a1** vers **a2**. __a1__ et __a2__ doivent indiqué un emplacement en mémoire RAM.

* __CONSTANT__ &lt;nom&gt; &nbsp;&nbsp;( n --) Compile une constante dans le dictionnaire. **n** est la valeur de la constante dont le nom est **&lt;nom&gt;**. 

* __CONTEXT__&nbsp;&nbsp;( -- a ) Empile l'adresse de la variable système **UCNTXT**. Cette variable contient l'adresse du point d'entré du dictionnaire.  

* __COUNT__&nbsp;&nbsp;( b -- b u ) Empile la longueur de la chaîne comptée **b** et incrémente **b**.   

* __CP__&nbsp;&nbsp;( -- a ) Empile l'adresse de la variable système **UCP** qui contient l'adresse du début de l'espace libre en mémoire flash. 

* __CP-HERE__&nbsp;&nbsp;( -- a ) Empile la valeur contenu dans la variable système **UCP**. Il s'agit de l'adresse où est rendu le pointeur de compilation dans la mémoire FLASH. Autrement l'adresse le début de la FLASH libre.

* __CR__&nbsp;&nbsp;( -- ) Envoie le caractère ASCII **CR** au terminal.

* __CREATE__ &lt;nom&gt;&nbsp;&nbsp;( -- ) Compile le nom d'un nouveau mot dans le dictionnaire. **&lt;nom&gt;** est le nom du nouveau mot. À l'exécution un mot définit par __CREATE__ empile l'adresse de son champ paramètre. 

* __DECIMAL__&nbsp;&nbsp;( -- ) Affecte la valeur **10** à la variable système **UBASE**. 

* __DEPTH__&nbsp;&nbsp;( -- u ) retourne le nombre d'éléments qu'il y a sur la pile.

* __DROP__&nbsp;&nbsp;( n -- ) Jette l'élément qui est au sommet de la pile. 

* __DUP__&nbsp;&nbsp;( n -- n n ) Empile une copie de l'élément au sommet de la pile.

* __ELSE__&nbsp;&nbsp;( a1 -- a2 ) Compile l'adresse du saut avant dans la fente **a1** laissée sur la pile par le **IF** qui indique où doit se faire le saut avant pour exécuter une condition **fausse**. Laisse **a2** sur la pile qui est l'adresse de la fente qui doit-être comblée par le **THEN** et qui permet un saut avant après le **THEN** lors que la condition **vrai** est exécutée.   

* __EMIT__&nbsp;&nbsp;( c -- ) Envoie vers le terminal le caractère **c**. 

* __EVAL__&nbsp;&nbsp;( -- ) Interprète le texte d'entrée. 

* __EXECUTE__&nbsp;&nbsp;( a -- ) Exécute le code à l'adresse *a*.  

* __FIND__&nbsp;&nbsp;( b cntxt -- ca nfa | b 0 ) Recherche le nom pointé par **b** dans le dictionnaire à partir du context **cntxt**. Si trouvé retourne **ca** l'adresse d'exécution et **nfa** l'adresse du champ nom. En cas d'échec retourne **b** et **0**.

* __FOR__&nbsp;&nbsp;(  -- a ) compile l'initialisation d'une boucle FOR..NEXT. La boucle se répète *u+1* fois. __a__ sera utilisé par __NEXT__ pour connaître l'endroit ou le saut arrière devra se faire. 

* __FORGET__ &lt;nom&gt;&nbsp;&nbsp;( -- ) Supprime du dictionnaire la définition **&lt;nom&gt;** ainsi que toutes celles qui ont étées créées après celle-ci. Ne supprime que les définitions de l'utilisateur. Les définitions du système sont protégées.  

* __FREE__&nbsp;&nbsp;(  -- ) Affiche la quantité de mémoire **RAM** et de mémoire **FLASH** encore disponible à l'utilisateur.   

* __HERE__&nbsp;&nbsp;( -- a ) Retourne la valeur de la variable système **UVP**.  

* __HEX__&nbsp;&nbsp;( -- ) Sélectionne la base numérique hexadécimal. Dépose la valeur **16** dans la variable système **UBASE**. 

* __I__&nbsp;&nbsp;( -- u ) Empile le compteur d'une boucle **FOR..NEXT** de premier niveau.

* __IF__&nbsp;&nbsp;(  -- a ) Compile un __?BRANCH__ c'est à dire un branchement conditionnel et laisse l'adresse indiquant la fente où doit-être compilée l'adresse destination du saut si le bloc suivant le __IF__ n'est pas excécuté. 

* __IMMEDIATE__&nbsp;&nbsp;( -- ) Active l'indicateur **IMMED** dans l'entête de dictionnaire du dernier mot qui a été compilé. Habituellement invoqué juste après le **;**. 

* __J__&nbsp;&nbsp;( -- u ) Empile le compteur d'une boucle **FOR..NEXT** de 2ième niveau. 

* __KEY__&nbsp;&nbsp;( -- c ) Attend la réception d'un caractère du  terminal. Empile le caractère reçu **c**.  

* __LAST__&nbsp;&nbsp;( -- a ) Empile l'adresse de la variable système **ULAST**. Cette variable contient l'adresse du champ nom (nfa) du dernier mot compilé.  

* __LITERAL__&nbsp;&nbsp;( n -- ) Compile **n** comme entier litéral. En **runtime** **DOLIT** est invoqué pour mettre sur la pile la valeur **n**.  

* __LSHIFT__&nbsp;&nbsp;( i1 n+ -- i2 ) Décalage vers la gauche de **i1** **n+** bits. Les bits à droites sont mis à zéro. __i2__ est le résultat de ce décalage.

* __MOD__&nbsp;&nbsp;( n1 n2 -- n ) Retourne le reste de la division entière __n1/n2__ arrondie vers zéro.

* __NAME>__&nbsp;&nbsp;( nfa -- ca ) Retourne l'adresse du __code__ correspondant à l'entrée du dictionnaire avec le *champ nom* __nfa__. Donne une valeur erronnée si __nfa__ n'est pas une entrée valide dans le dictionnaire.  

* __NAME?__&nbsp;&nbsp;( b -- ca nfa | b 0 ) Recherche le nom __b__ dans le dictionnaire. Si ce nom existe retourne l'adresse du code __ca__ et l'adresse du champ nom __nfa__. Si le nom n'est pas trouvé retourne __b__ et __0__. 

* __NEGATE__&nbsp;&nbsp;( i1 -- i2 ) Empile la négation arithmétique de __i1__. 

* __NEXT__&nbsp;&nbsp;( a -- ) Compile le runtime __DONXT__ complétant une boucle **FOR-NEXT**. En _runtime_ __DONXT__ décrément le compteur de boucle 
et fait un saut au début de la boucle tant que le compteur est __>=0__. 
__a__ est l'adresse du début de la boucle et est compilée comme saut arrière. 

* __NOT__&nbsp;&nbsp;( i1 -- i2 ) __i2__ est le complément unaire de __i1__. Autrement dit tous les bits de __i1__ sont inversés. 

* __NUMBER?__&nbsp;&nbsp;( b -- i T | b F ) Essaie de convertir la chaîne **b** en entier. Si la convertion réussie l'entier **i** et **T** sont retournés. Sinon **b** et **F** sont retournés.

* __OR__&nbsp;&nbsp;( n1 n2 -- n3 ) __n3__ est le résultat d'un OU bit à bit entre __n1__ et __n2__. 

* __OVER__&nbsp;&nbsp;( n1 n2 -- n1 n2 n1 ) Copie le second élémente de la pile au sommet. 

* __OVERT__&nbsp;&nbsp;( -- ) Copie l'adresse qui est dans **ULAST** dans **UCNTXT**. Cette variable indique le début du dictionnaire pour la recherche de mots. 

* __PAD__&nbsp;&nbsp;( -- a ) Empile l'adresse du tampon de travail **PAD**.  

* __PARSE__&nbsp;&nbsp;( c -- b u ) Analyseur lexical. parcourt le flux d'entrée à la recherche de la prochaîne unité lexicale. **c** est le caractère délimiteur. **b** est l'adresse de la chaîne trouvée et **u** sa longueur.  

* __PICK__&nbsp;&nbsp;( nx j -- nx nj ) Copie au sommet de la pile le jième élément de la pile. **j** est d'abord retiré de la pile ensuite les éléments sont compté à partir du sommet vers le fond de la pile. l'Élément au sommet est l'élément **0**.  Donc **0 PICK** est l'équivalent de **DUP** et **1 PICK** est l'équivalent de **OVER**. Le nombre d'éléments sur la pile doit-être __&ge;j+1__.

* __PRESET__&nbsp;&nbsp;( -- ) Vide la pile des arguments et le TIB avant d'invoquer **QUIT**.  

* __QUERY__&nbsp;&nbsp;( -- ) Lecture d'une ligne de texte du terminal dans le TIB. La lecture se termine à la réception d'un caractère **CR**. Le nombre de caractères dans le TIB est dans la variable système **UCTIB**. La variable **UINN** est remise à zéro pour débuter l'interprétation. __QUERY__ est appellé par l'interpréteur __QUIT__. 

* __QUIT__&nbsp;&nbsp;( -- ) Il s'agit de l'interpréteur de texte, c'est à dire l'interface entre l'utilisateur et le système. **QUIT** appel en boucle **QUERY** et **EVAL**. 

* __R>__&nbsp;&nbsp;( n -- R: -- n ) La valeur au sommet de la pile des arguments est transférée sur la pile des retours.

* __R@__&nbsp;&nbsp;( -- n ) La valeur au sommet de la pile des retours est copié sur la pile des arguments.  

* __RAND__&nbsp;&nbsp;( u1 -- u2 ) Retourne un entier pseudo aléatoire dans l'intervalle **0&le;u2&lt;u1**.  

* __REPEAT__&nbsp;&nbsp;( a1 a2 -- ) compile un saut arrière vers le début  d'un boucle de la forme **BEGIN-WHILE-REPEAT**. Le branchement s'effectue après le **BEGIN**. Consomme l'adresse de destination du saut arrière __a1__ . __a2__ est l'adresse d'une fente ou est compilé l'adressse du saut conditionnel du avant du __WHILE__. __a2__ est laissé sur la pile par le __WHILE__ pour indiquer au __REPEAT__ où il doit compiler l'adresse du saut conditionnel avant. 

* __RESET__&nbsp;&nbsp;( -- ) Réinitialise le système en effaçant tous les mots définis par l'utilisateur. 

* __ROT__&nbsp;&nbsp;( n1 n2 n3 -- n2 n3 n1 ) Rotation des 3 éléments supérieurs de la pile.

* __RP!__&nbsp;&nbsp;( u -- ) Initialise le pointeur de la pile des retours avec la valeur **u**.

* __RP@__&nbsp;&nbsp;( -- u ) Empile la valeur du pointeur de la pile des retours. 

* __RSHIFT__&nbsp;&nbsp;( n1 u -- n2 ) Décale **n1** de **u** bits vers la droite. Les bits à gauche sont remplacés par **0**. __n2__ est le résultat de ce décalage. 

* __RSTBIT__&nbsp;&nbsp;( c a --  ) Met à zéro le bit à la position __c__ {0...7} de l'octet qui est situé à l'adresse __a__. Surtout utile pour manipuler les bits des registres d'un périphérique.

* __SEED__&nbsp;&nbsp;( u -- ) Initialise le générateur pseudo-aléatoire avec la valeur **u**. __u__ doit-être différent de __0__.  

* __SETBIT__&nbsp;&nbsp;( c a --  ) Met à 1 le bit à la position __c__ {0...7} de l'octet qui est situé à l'adresse __a__. Surtout utile pour manipuler les bits des registres d'un périphérique.

* __SP!__&nbsp;&nbsp;( u --  ) Initialise le pointeur de la pile des arguments avec la valeur **u**.  

* __SP@__&nbsp;&nbsp;( -- u ) Empile la valeur du pointeur des arguments. 

* __SPACE__&nbsp;&nbsp;( -- ) Envoie un caractère ASCII *espace* au terminal.

* __SPACES__&nbsp;&nbsp;( n+ -- ) Envoie **n+** caractères ASCII *espace* au terminal. 

* __STR__&nbsp;&nbsp;( i -- b u ) Converti en chaîne de caractère l'entier **i**. **b** est la chaîne résultante et **u** la longueur de cette chaîne. 

* __SWAP__&nbsp;&nbsp;( n1 n2 -- n2 n1 ) Inverse l'ordre des 2 éléments au sommet de la pile. 

* __THEN__&nbsp;&nbsp;( a -- ) Compile l'adresse destination d'un saut avant du  **IF-ELSE-THEN. __a__ est laissé sur la pile par le __IF__ pour par le __ELSE__.
Il s'agit de l'adresse d'une fente ou la destination du saut doit-être compilée.

* __TIB__&nbsp;&nbsp;( -- a ) Empile l'adresse du *Transaction Input Buffer* qui est le tampon qui accumule les caractères lus par **QUERY**.  

* __TIMER__&nbsp;&nbsp;( -- u ) Retourne la valeur du compteur de millisecondes. Il s'agit d'un compteur qui est incrémenté chaque milliseconde par une interruption du TIMER4. 

* __TMR-RST__&nbsp;&nbsp;( -- u ) Remet à zéro le compteur de millisecondes.

* __TOGLBIT__&nbsp;&nbsp;( c a --  ) Inverse l'état du bit à la position __c__ {0...7} de l'octet qui est situé à l'adresse __a__. Surtout utile pour manipuler les bits des registres d'un périphérique.

* __TOKEN__  &lt;stream&gt;&nbsp;&nbsp;( -- b ) Extrait le prochain mot du TIB. __b__ est l'adresse de la chaîne comptée.  

* __TYPE__&nbsp;&nbsp;( b u -- ) Envoie *u* caractère au terminal à partir de l'adresse *b*. 

* __U.__&nbsp;&nbsp;( u -- ) Imprime l'entier non signé *u*.

* __U<__&nbsp;&nbsp;( u1 u2 -- f ) Comparaison de 2 entiers non signés. Retourne *vrai* si *u1&lt;u2*. Sinon retourne *faux*. 

* __UM*__&nbsp;&nbsp;( u1 u2 -- ud ) Multiplication de 2 entiers non signés et retourne le résultat comme entier non signé double.  

* __UNTIL__&nbsp;&nbsp;( a -- ) compile un saut conditionnel vers le début d'une boucle **BEGIN - UNTIL**. __a__ est l'adresse destination du saut et a été laissé sur la pile par __BEGIN__. En *runtime* le boucle roule aussi longtemps que la valeur au sommet de la pile est __0__.  

* __VARIABLE__  &lt;nom&gt;&nbsp;&nbsp;( --) Crée une nouvelle variable de nom **&lt;nom&gt;**. Cette variable est initialisée à zéro.  

* __VP__&nbsp;&nbsp;( -- a ) Empile l'adresse de la variable système **UVP**. Ce pointeur contient l'adresse début de la RAM libre.  

* __WAIT__&nbsp;&nbsp;( u -- ) Suspend l'exécution pour une durée de **u** millisecondes.  

* __WHILE__&nbsp;&nbsp;(  -- a ) Compile un saut conditionnel avant pour une boucle **BEGIN - WHILE - REPEAT**. __a__ est l'adresse de la fente où sera compilé l'adresse de destination du saut. __a__ est consommé par __REPEAT__. 
En *runtime* la bouche roule tant la valeur au sommet de la pile est *vrai*.

* __WITHIN__&nbsp;&nbsp;( u ul uh -- f ) Retourne **f** indiquant si **ul &le; u &lt;uh** 

* __WORD__&nbsp;&nbsp;( c -- b ) Extrait le prochain mot du **TIB** et le copie à la fin du dictionnaire. **c** est le caractère séparateur de mot et **b** est l'adresse où le mot a été copié. 

* __XOR__&nbsp;&nbsp;( n1 n2 -- n3 ) **n3** est le résultat d'un ou exclusif bit à bit entre **n1** et **n2**.  

* __[__&nbsp;&nbsp;( -- ) Initialise le vecteur EVAL en mode *interprétation*. 

* __[COMPILE]__&nbsp;&nbsp;( -- &lt;string&gt; ) Ce mot est utilisé à l'intérieur d'une définition pour compiler le mot suivant qui est un mot *immédiat* donc serait exécuté plutôt que compilé.

* __\\__&nbsp;&nbsp;( -- ) Introduit un commentaire qui se termine à la fin de la ligne.

* __]__&nbsp;&nbsp;( -- ) Initialise le vecteur EVAL en mode *compilation*. 

[Index](#index)
<hr>
<a id="flash"></a>

## Module [flash.asm](flash.asm) 

Ce module définit le vocabulaire nécessaire pour écrire dans la mémoire persistante FLASH et EEPROM. 

* __EEPROM__&nbsp;&nbsp;( -- a ) Empile l'adresse début de l'EEPROM. 

* __F!__&nbsp;&nbsp;( n a -- ) Écriture en mémoire persistante (FLASH|EEPROM) de la valeur *n*. *a* est l'adresse destination. 

* __FC!,__ ( c a -- ) Écriture en mémoire persistante (FLASH|EEPROM) de l'octet **c** à l'adresse **a**. 

* __FCPY__&nbsp;&nbsp;( a1 a2 u -- ) Copie une plage de mémoire RAM en mémoire FLASH ou EEPROM.  **a1** est l'adresse source en RAM. **a2** est l'adresse destination. **u** est le nombre d'octets à copier. 

* __FD!__&nbsp;&nbsp;( d a -- ) Écris en mémoire persistante l'entier double **d** à l'adresse **a**.

* __UPDAT-EEPTR__&nbsp;&nbsp;( -- ) Met à jour les variables système persistantes (en EEPROM) à partir des valeurs de celles en mémoire RAM. Il y a 3 variables sauvegardées: 

    1.  **UCNTXT**  qui contient le CONTEXT du dictionnaire.
    1.  **UVP**     qui contient l'adresse du début de la mémoire RAM libre.
    1.  **UCP**     qui contient l'adresse du début de la mémoire FLASH libre.

[index](#index)

<hr>
<a id="intr"></a>

## Module interruptions

 Le fichier [interrupts.asm](interrupts.asm) contient le vocabulaire permettant de créer et gérér des services d'interruptions.

* __DI__&nbsp;&nbsp;( -- ) Désactive les interruptions en exécutant l'instruction machine **SIM**. Ce mot ne peut être utilisé que dans une définition. Il est impératif de réactiver les interruptions dans la même définition. Si les interruptions sont désactivés il n'y a plus d'accès au terminal. 

* __EI__&nbsp;&nbsp;( -- ) Active les interruptions en exécutant l'instruction machine **RIM**.

* __I:__&nbsp;&nbsp;( n+ -- n+ ) Débute la compilation d'une routine d'interruption. Les routines d'interruptions n'ont pas de nom et ne sont donc pas inscrite dans le dictionnaire. **n+** est le numéro du vecteur d'interruption {0..29}. Il ne faut pas écraser les vecteurs utilisés par le TIMER4 et le USART qui communique avec le terminal sinon le système ne sera plus en état de marche.

* __I;__&nbsp;&nbsp;( n+ ca -- ) Termine la compilation d'une routine d'interruption. Le vecteur d'interruption **n+** est modifié avec l'adresse d'exécution __ca__ du gestionnaire d'interruption. 

* __I-RST__&nbsp;&nbsp;( n+ -- ) Réinitialise le vecteur d'interruption **n+** avec le gestionnaire par défaut qui est un interruption vide.

* __VEC-ADR__&nbsp;&nbsp;( n+ -- a ) retourne l'adresse d'exéction du  gestionnaire d'interruption du vecteur **n+**.

[index](#index)

<hr>
<a id="tools"></a>

## Module tools 

## Le fichier [tools.asm](tools.asm) contient le vocabulaire utile au débogage des programmes.

* __R.__&nbsp;&nbsp;( -- ) Imprime le contenu de la pile des retours. 

* __.S__&nbsp;&nbsp;( -- ) Imprime le contenu de la pile des paramètres.

* __DUMP__&nbsp;&nbsp;( a u --) Affiche le contenu de la mémoire en hexadécimal à partir de l'adresse __a__. 16 octets sont affichés par ligne. __u__ est le nombre d'octets à afficher. Ce nombre est arrondi vers le haut à un multiple de 16 octets.

* __SEE__&nbsp;&nbsp; &lt;string&gt;  décompile le mot du dictionnaire représenté par &lt;string&gt;.

* __WORDS__&nbsp;&nbsp; Affiche la liste des mots qui sont dans le dictionnaire et leur nombre à la fin de la liste.

[Index](#index)

<hr>
<a id="bios"></a>

## Module [bios.asm](bios.asm)

Ce module ne contient aucun mot inscrit dans le dictionnaire Forth. Il initialise le matériel et offre des fonctions de bas niveaux pour la minuterie **TIMER4** ainsi que  avec le **UART**  qui sert d'interface avec le terminal.

[Index](#index)


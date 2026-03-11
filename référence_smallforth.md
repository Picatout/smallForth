# smallForth V1.0  référence du vocabulaire.

## Conventions typographique

**a**  Adressse 16 bits 

**b**  Adresse 16 bits d'une chaîne de caractère

**c**  Caractère ASCII ou octet.

**f** Indicateur booléen 0 indique faux tout autre valeur est considérée comme vrai.

**i** Entier 16 bits signé {-32767...32767}, -32768 utilisé comme indicateur de débordement.

**id** Entier double (32 bits) signé

**n** Valeur 16 bits sans type défini.

**n+** Entier positif.

**u** Entier 16 bits non signé {0...65535}.

**ud** Entier 32 bits non signé.

**nx** Représente un nombre quelconque d'élément sur la pile.

**R:** Représente la pile des retours. 

**( nx1 -- nx2 )**  Commentaire indiquant  la liste des paramètres à gauche et des résultats à droite.

**T**  Indique la valeur booléenne **vrai**. 

**F**  Indique la valeur booléenne **faux**. 

<hr>
<a name="index"></a>

# Index 

Chaque module a une section séparé pour son vocubulaire. Cet index conduit à la section concernée. 

* [core](#core) module ForthCore.asm 

* [flash](#flash) module flash.asm 

* [tools](#tools) module tools.asm 

* [bios](#bios) module bios.asm 

<hr>
<a id="core"></a>

## Vocabulaire principal du système

* __!__&nbsp;&nbsp;( n a -- ) Dépose la valeur **n** à l'adresse **a**

* __#TIB__&nbsp;&nbsp;( -- a ) Empile l'adresse de la variable système **UCTIB**. Cette variable contient le nombre de caractères qu'il y a dans le TIB *(Terminal Input Buffer)*.  

* __$"__&nbsp;&nbsp;( -- ; &lt;string&gt; ) Compile la chaîne litérale **&lt;string&gt;**. 

* __'__&nbsp;&nbsp;( -- a  ; &lt;string&gt; ) Ce mot est suivit d'une chaîne de caractère qui doit représenter un mot du dictionnaire. Si ce mot est trouvé **a** est l'adresse d'éxécution de ce mot. Un échec résulte en un abandon avec message d'erreur.

* __'EVAL__&nbsp;&nbsp;( -- a ) Retourne l'adresse de la variable système **INTER** qui contient l'adresse du code qui doit-être exécuté par **EVAL**. 

* __(__&nbsp;&nbsp;( -- ) Ce mot introduit un commentaire délimité par **)**

* __*__&nbsp;&nbsp;( i1 i2 -- i3 )  Multiplication signée. i3=i1*i2.

* __+__&nbsp;&nbsp;( i1 i2 -- i3 ) i3 est la somme de i1 et i2. 

* __+!__&nbsp;&nbsp;( i a -- ) Ajoute la valeur i à l'entier situé à l'adresse a.

* __,__&nbsp;&nbsp;( n -- ) Compile la valeur n dans la mémoire FLASH et avance le pointer __UCP__ de 2. 

* __-__&nbsp;&nbsp;( i1 i2 -- i3 ) i3 est le résultat de la soustraction i1-i2. 

* __.__&nbsp;&nbsp;( i -- ) Imprime l'entier au sommet de la pile.

* __."__&nbsp;&nbsp;( -- ) Compile une chaîne litérale pour impression. Cette chaîne est terminée par le caractère **"**. 

* __.OK__&nbsp;&nbsp;( -- ) Imprime le messate ** ok** suivit d'un **CR**. 

* __/__&nbsp;&nbsp;( i1 i2 -- i3  ) i3 est le quotient entier arrondie à l'entier le plus petit résultant de i1/i2.

* __/MOD__&nbsp;&nbsp;( i1 i2 -- u i3 ) i3 est le quotient et u le reste de la division entière arrondie à l'entier le plus petit de i1/i2. 

* __0__&nbsp;&nbsp;( -- 0 ) Constante numérique **0**.  

* __0<__&nbsp;&nbsp;( i -- f ) Retourne vrai (-1) si i&lt;0 sinon retourne 0.

* __1__&nbsp;&nbsp;( -- ) Constante numérique **1**. 

* __1+__&nbsp;&nbsp;( i1 -- i2 ) Incrémente i1 pour donner i2. 

* __1-__&nbsp;&nbsp;( i1 -- i2 ) Décrémente i1 pour donner i2.

* __2!__&nbsp;&nbsp;( nd a -- ) Dépose un entier double à l'adresse a.  

* __2*__&nbsp;&nbsp;( i1 -- i2 ) Multiplie par i1 par 2.

* __2+__&nbsp;&nbsp;( i1 -- i2 ) Ajoute 2 à i1. 

* __2-__&nbsp;&nbsp;( i1 -- i2 ) Soustrait 2 à i1.

* __2/__&nbsp;&nbsp;( i2 -- i2 ) divise i2 par 2. 

* __2@__&nbsp;&nbsp;( a -- nd ) Empile l'entier double qui est à l'adresse a. 

* __2DROP__&nbsp;&nbsp;( n1 n2 -- ) Jette les 2 éléments au sommet de la pile. 

* __2DUP__&nbsp;&nbsp;( n1 n2 -- n1 n2 ) Duplique les 2 éléments au sommet de la pile. 

* __:__&nbsp;&nbsp;( -- ; &lt;string&gt; ) Débute la création d'une nouvelle définition dans le dictionnaire. **&lt;string&gt;** est le nom de cette nouvelle définition. Passe en mode compilation. 

* __;__&nbsp;&nbsp;( -- ) Complète la définition d'un nouveau mot et repasse en mode interprétaion. 

* __<__&nbsp;&nbsp;( i1 i2 -- f ) Empile la valeur booléenne i1&lt;i2.

* __<#__&nbsp;&nbsp;(  -- ) Débute la conversion d'un entier en chaîne de caractère.

* __=__&nbsp;&nbsp;( i1 i2 -- f ) Empile la valeur booléenne indiquant si i1=i2

* __>CHAR__&nbsp;&nbsp;( c -- c ) Filtre les caractères de contrôle ASCII pour les remplacer par un **_**.  

* __>IN__&nbsp;&nbsp;( -- a ) Empile l'adrese de la variable système **>IN** qui est le pointeur de l'analyseur lexical. 

* __>NAME__&nbsp;&nbsp;( a1 -- a2|0 ) Retourne l'adrresse du champ nom à partir de l'adresse du champ code d'une entrée du dictionnaire. a1 est le *code address* et a2 est le *name address*. 
Si le champ code est invalide retourne **0**. 

* __>R__&nbsp;&nbsp;( n -- R: n ) Envoie n sur la pile des retours.

* __?__&nbsp;&nbsp;( a -- ) Imprime l'entier à l'adresse a.

* __?DUP__&nbsp;&nbsp;( n -- n n | 0 ) Duplique n seulement si &lt;&gt; 0. 

* __?KEY__&nbsp;&nbsp;( -- c -1 | 0) Vérifie s'il y a un caractère de disponible en provenance du terminal. Si oui retourne le caractère **c** et **-1** sinon retourne **0**.  

* __?STACK__&nbsp;&nbsp;( -- ) Vérifie si la pile des arguments est en état sous-vidée *(underflow)*. Un abadon avec message d'erreur se produit dans ce cas.

* __?UNIQUE__&nbsp;&nbsp;( b -- b ) Vérifie si le nom pointé par __b__ existe déjà dans le dictionnaire.  Affiche un messag d'avertissement s'il ce nom est déjà dans le dictionnaire. Ça signifit qu'on est en train de redéfinir un mot qui est déjà dans le dictionnaire.

* __@__&nbsp;&nbsp;( a -- n ) Empile l'entier qui est à l'adresse __a__.

* __@EXECUTE__&nbsp;&nbsp;( a -- ) __a__ est un pointeur vers l'adresse d'un code exécutable. Cette adresse est empilée pour être exécutée immédiatement. 

* __ABORT__&nbsp;&nbsp;( nx -- ) Abandon avec vidage de la pile et du TIB. Est appellé par **ABORT"**.  

* __ABORT"__&nbsp;&nbsp;( f -- ) Si l'indicateur est vrai affiche le message litéral qui suit et appelle **ABORT**.

* __ABS__&nbsp;&nbsp;( i1 -- u ) Retourne la valeur absolue de i1. 

* __ACCEPT__&nbsp;&nbsp;( b u1 -- b u2 ) Effectue la lecture d'une ligne de texte dans le **TIB**. __b__ est l'adresse du **TIB** __u1__ est la longueur du **TIB** et __u2__ est le nombre de caractères reçus dans le **TIB**.  

* __AFT__&nbsp;&nbsp;( a1 -- a1 a2 ) Mot compilant Utilisé dans une boucle FOR..AFT..THEN..NEXT. Pendant la compilation compile un saut avant après le **THEN**.   

* __AGAIN__&nbsp;&nbsp;( -- ) Marque la fin d'une boucle BEGIN..AGAIN. 

* __AHEAD__&nbsp;&nbsp;( -- a ) Compile un saut avant inconditionnel. *a* est l'adresse de la fente où sera insérée l'adresse du saut ultérieurement lors du processus de compilation.

* __ALLOT__&nbsp;&nbsp;( u -- ) Alloue __u__ octets dans l'espace RAM. Avance le pointeur **VP** de __u__ octets. 

* __AND__&nbsp;&nbsp;( n1 n2 -- n3 ) Opération bit à bit ET.  

* __AUTORUN__&nbsp;&nbsp;( -- ; &lt;string&gt; ) Enregistre dans la variable système persistante **APP_RUN**  l'adresse d'exécution du programme qui doit-être exécuté au démarrage. Par défaut il s'agit du *ca* du mot **hi**.  

* __BASE__&nbsp;&nbsp;( -- ) Variable système qui contient la base numérique utilisée pour la conversion des entiers en chaîne de caractères. 

* __BEGIN__&nbsp;&nbsp;( -- a ) Compile le début d'une boucle BEGIN..UNTIL|AGAIN. *a* indique l'adresse où doit se faire le saut arrière pour répéter la boucle. 

* __BL__&nbsp;&nbsp;( -- c ) Empile le caractère ASCII *space* i.e. 32.  

* __BRANCH__&nbsp;&nbsp;( -- ) Compile un saut inconditionnel avec une adresse litérale.
En *runtime* ce saut est toujours effectué.

* __BYE__&nbsp;&nbsp;( -- ) Exécute l'instruction machine **HALT** pour mettre le MCU en mode suspendu. Dans ce mode l'oscillateur et arrêter et le MCU dépense un minimum d'énergie. Seul un *reset* ou une interruption externe peut réactivé le MCU. Si le MCU est réanimé par une interruption après l'exécution de celle-ci l'exécution se poursuit après l'instruction **HALT**. 

* __C!__&nbsp;&nbsp;( c a -- ) Dépose le caractère *c* à l'adresse *a*. Sur la pile *c* occupe 2 octets mais en mémoire il n'occupe qu'un octete. 

* __C,__&nbsp;&nbsp;( c -- ) Compile le caractère qui est au sommet de la pile. 

* __C@__&nbsp;&nbsp;( a -- c ) Empile l'octet qui se trouve à l'adresse *a*.

* __CALL,__&nbsp;&nbsp;( a -- ) Compile un appel de sous-routine dans la liste d'une définition.  *a* est l'adresse de la sous-routine. 

* __CMOVE__&nbsp;&nbsp;( a1 a2 u -- ) Copie *u* octets de *a1* vers *a2*.

* __COLD__&nbsp;&nbsp;( -- ) Réinitialisation du système. Toute la mémoire RAM est remise à **0** et les pointeurs de piles sont réinitialisés ainsi que les variables système.

* __COMPILE__&nbsp;&nbsp;( -- ) Compile un appel de sous-routine avec adresse litérale.

* __CONSTANT__&nbsp;&nbsp;( n -- ; &lt;string&gt; ) Compile une constante dans le dictionnaire. *n* est la valeur de la constante dont le nom est **&lt;string&gt;**. 

* __CONTEXT__&nbsp;&nbsp;( -- a ) Empile l'adresse de la variable système CNTXT. Cette variable contient l'adresse du point d'entré du dictionnaire.  

* __COUNT__&nbsp;&nbsp;( b -- b u ) Empile la longueur de la chaîne comptée *b* et incrémente *b*.   

* __CP__&nbsp;&nbsp;( -- a ) Empile l'adresse de la variable système **CP** qui contient l'adresse du début de l'espace libre en mémoire flash. 

* __CR__&nbsp;&nbsp;( -- ) Envoie le caractère ASCII **CR** au terminal.

* __CREATE__&nbsp;&nbsp;( -- ; &lt;string&gt; ) Compile le nom d'une nouvelle variable dans le dictionnaire. **&lt;string&gt;** est le nom de la nouvelle variable. Les variables sont initialisées à **0**.  

* __DCONST__&nbsp;&nbsp;( d -- ; &lt;string&gt;) Création d'une constante de type entier double.

* __DECIMAL__&nbsp;&nbsp;( -- ) Affecte la valeur **10** à la variable système **BASE**. 

* __DEPTH__&nbsp;&nbsp;( -- u ) retourne le nombre d'élément qu'il y a sur la pile.

* __DI__&nbsp;&nbsp;( -- ) Désactive les interruptions en exécutant l'instruction machine **SIM**. 

* __DIGIT__&nbsp;&nbsp;( u -- c ) Convertie le chiffre *u* en caractère ASCII.

* __DIGIT?__&nbsp;&nbsp;( c base -- u f ) Converti le caractère *c* en chiffre correspondant dans la *base*. L'indicateur *f* indique si *c* est bien dans l'intervalle {0..base-1}.   

* __DNEGATE__&nbsp;&nbsp;( d1 -- d2 ) Négation arithmétique de l'entier double *d1*.

* __DROP__&nbsp;&nbsp;( n -- ) Jette l'élément qui est au sommet de la pile. 

* __DUMP__&nbsp;&nbsp;( a u -- ) Affiche en hexadécimal le contenu de la mémoire débutant à l'adresse *a*. *u* octets arrondie au multiple de 16 supérieur sont affichés. Chaque ligne affiche 16 octets suivit de leur représentation ASCII.  

* __DUP__&nbsp;&nbsp;( n -- n n ) Empile une copie de l'élément au sommet de la pile.

* __EI__&nbsp;&nbsp;( -- ) Active les interruptions en exécutant l'instruction machine **RIM**.

* __ELSE__&nbsp;&nbsp;( a1 -- a2 ) Compile l'adresse du saut avant dans la fente *a1* laissée sur la pile par le **IF** qui indique où doit se faire le saut avant pour exécuter une condition *fausse*. Laisse *a2* sur la pile qui est l'adresse de la fente qui doit-être comblée par le **THEN** et qui permet un saut avant après le **THEN** lors que la condition *vrai* est exécutée.   

* __EMIT__&nbsp;&nbsp;( c -- ) Envoie vers le terminal le caractère *c*. 

* __ERASE__&nbsp;&nbsp;( b u -- ) Met à zéro *u* octets à partir de l'adresse *b*.

* __EVAL__&nbsp;&nbsp;( -- ) Interprète le texte d'entrée. 

* __EXECUTE__&nbsp;&nbsp;( a -- ) Exécute le code à l'adresse *a*.  

* __EXTRACT__&nbsp;&nbsp;(  n1 base -- n2 c  ) Extrait le chiffre le moins significatif de *n* et le converti en caractère ASCII *c*. *n2=n1/base*.   

* __FC-XOFF__&nbsp;&nbsp;( -- ) Envoie du caractère ASCII XOFF (19) au terminal. Il s'agit du caractère de contrôle de flux logiciel selon le protocole XON/XOFF. Lorsque le terminal reçoit ce caractère il doit cesser de transmettre jusqu'à ce qu'il reçoive un caractère XON. 

* __FC-XON__&nbsp;&nbsp;( -- ) Envoie du caractère ASCII XON (17) au terminal. Il s'agit du caractère de contrôle de flux logiciel selon le protocole XON/XOFF. Indique au terminal qu'il peut reprendre la transmission.

* __FILL__&nbsp;&nbsp;( b u c -- ) Remplie *u* octets de la mémoire RAM à partir de l'adresse *b* avec le caractère *c*.  

* __FIND__&nbsp;&nbsp;( a va -- ca na | a 0 ) Recherche le nom pointé par *a* dans le dictionnaire à partir de l'entrée indiquée par *va*. Si trouvé retourne *ca* l'adresse d'exécution. *na* l'adresse du champ nom. En cas d'échec retourne *a* et *0*.

* __FOR__&nbsp;&nbsp;( n+ -- ) Initialise une boucle FOR..NEXT. *n+* est un entier positif. La boucle se répète *n+1* fois. 

* __FORGET__&nbsp;&nbsp;( -- ; &lt;string&gt; ) Supprime du dictionnaire la définition **&lt;string&gt;** ainsi que toutes celles qui ont étées créées après celle-ci. Ne supprime que les définitions en mémoire FLASH. Pour les définitions en mémoire RAM il faut faire un **REBOOT**. 

* __FREEVAR__&nbsp;&nbsp;( na -- ) *na* étant l'adresse du champ nom d'une variable **FEEVAR** réinitialise le pointeur **VP** à cette adresse. Toute allocation de mémoire RAM qui suit cette adresse est perdu.  

* __HERE__&nbsp;&nbsp;( -- a ) Retourne la valeur de la variable système **VP**.  

* __HEX__&nbsp;&nbsp;( -- ) Sélectionne la base numérique hexadécimal. Dépose la valeur **16** dans la variable système **BASE**. 

* __HLD__&nbsp;&nbsp;( -- a ) Empile l'adresse de la variable système **UHLD** 

* __HOLD__&nbsp;&nbsp;( c -- ) Insère le caractère *c* dans la chaîne de sortie. HOLD est utilisé dans la conversion des entiere en chaîne.  

* __I__&nbsp;&nbsp;( -- n+ ) Empile le compteur d'une boucle **FOR..NEXT**.

* __I:__&nbsp;&nbsp;( -- ) Débute la compilation d'une routine d'interruption. Les routines d'interruptions n'ont pas de nom et ne sont pas inscrite dans le dictionnaire. 

* __I;__&nbsp;&nbsp;( -- ad ) Termine la compilation d'une routine d'interruption. *ad* est l'adresse de la routine d'interruption tel qu'elle doit-être inscrite dans le vecteur d'interruption. 

* __IF__&nbsp;&nbsp;( f -- ) Vérifie la valeur de l'indicateur booléen *f* et exécute le code qui suis le **IF** si cette indicateur est *vrai* sinon saute après le **ELSE** ou le **THEN**. 

* __IMMEDIATE__&nbsp;&nbsp;( -- ) Active l'indicateur **IMMED** dans l'entête de dictionnaire du dernier mot qui a été compilé. Habituellement invoqué juste après le **;**. 

* __INIT-OFS__&nbsp;&nbsp;( -- ) Initialise la variable système **OFFSET** au début d'une nouvelle compilation. L'offset est la distance entre les valeurs des variables **CP** et **VP**
Lorsque la variable système **TFLASH**  est à zéro **OFFSET** est initialisé à zéro. **OFFSET** est utilisé par le compilateur pour déterminer les adresses absolues à utiliser dans les instructions de saut **BRANCH** et **?BRANCH**. 

* __KEY__&nbsp;&nbsp;( -- c ) Attend la réception d'un caractère du  terminal. Empile le caractère *c*.  

* __KTAP__&nbsp;&nbsp;( c -- ) Utilisé par **ACCEPT** pour Traiter les caractères de contrôles reçu du terminal. Les les caractères ASCII **CR** et **BS** sont traités les autres sont remplacés par un **BLANK**.  

* __LAST__&nbsp;&nbsp;( -- a ) Empile l'adresse de la variable système **LAST**. 

* __LITERAL__&nbsp;&nbsp;( n -- ) Compile *n* comme entier litéral. En *runtime* **DOLIT** est invoqué pour remettre sur la pile la valeur *n*.  

* __LSHIFT__&nbsp;&nbsp;( i1 n+ -- ) Décalager vers la gauche de *i1* *n+* bits. Les bits à droites sont mis à zéro.

* __M*__&nbsp;&nbsp;( n1 n2 -- d ) Multiplication _n1*n2_ conservé en entier double *d*.  

* __M/MOD__&nbsp;&nbsp;( d n -- r q ) Division de l'entier double *d* par l'entier simple *n*. Empile le reste et le quotient. Le quotient est arrondie à l'entier le plus petit. 

* __MAX__&nbsp;&nbsp;( n1 n2 -- n ) Empile le plus grand des 2 entiers. 

* __MIN__&nbsp;&nbsp;( n1 n2 -- n ) Empile le plus petit des 2 entiers. 

* __MOD__&nbsp;&nbsp;( n1 n2 -- n ) Retourne le reste de la division entière arrondie au plus petit entier. *n* est toujours __&ge;0__.

* __MSEC__&nbsp;&nbsp;( -- u ) Retourne la valeur du compteur de millisecondes. Il s'agit d'un compteur qui est incrémenté chaque milliseconde par une interruption du TIMER4. 

* __NAME>__&nbsp;&nbsp;( na -- ca ) Retourne l'adresse du __code__ correspondant à l'entrée du dictionnaire avec le *champ nom* __ca__. Donne une valeur erronnée si __na__ n'est pas une entrée valide dans le dictionnaire.  

* __NAME?__&nbsp;&nbsp;( b -- ca na | b 0 ) Recherche le nom __b__ dans le dictionnaire. Si ce nom existe retourne l'adresse du code __ca__ et l'adresse du champ nom __na__. Si le nom n'est pas trouvé retourne __b__ et __0__. 

* __NEGATE__&nbsp;&nbsp;( i1 -- i2 ) Empile la négation arithmétique de __i1__. 

* __NEXT__&nbsp;&nbsp;( a -- ) Mot immédiat qui compile la fin d'une boucle **FOR-NEXT**.
__a__ est l'adresse du début de la boucle et est compilée comme saut arrière. 

* __NOT__&nbsp;&nbsp;( i1 -- i2 ) __i2__ est le complément unaire de __i1__. Autrement dit tous les bits de __i1__ sont inversés. 

* __NUF?__ ( -- f ) Vérifie si un caractère a été reçu du terminal. Si aucun caractère reçu retourne **F**. Si un caractère a été reçu jette ce caractère et appel **KEY** pour attendre le prochain caractère. Si le prochain caractère reçu est **CR** retourne **T** sinon retourn **0**. Est utilisé pour faire une pause dans un défilement d'écran.

* __NUMBER?__&nbsp;&nbsp;( b -- i T | b F ) Essaie de convertir la chaîne *b* en entier. Si la convertion réussie l'entier **i** et **T** sont retournés. Sinon **b** et **F** sont retournés.

* __OFFSET__&nbsp;&nbsp;( -- a ) Variable système indiquant la distance enter **CP** et **VP**. Utilisé pour calculer les adresses de saut lors de la compilation. 

* __OR__&nbsp;&nbsp;( n1 n2 -- n3 ) __n3__ est le résultat d'un OU bit à bit entre __n1__ et __n2__. 

* __OVER__&nbsp;&nbsp;( n1 n2 -- n1 n2 n1 ) Copie le second élémente de la pile au sommet. 

* __OVERT__&nbsp;&nbsp;( -- ) Ajoute le dernier mot compilé au début de la liste chaîné du dictionnaire. 

* __PAD__&nbsp;&nbsp;( -- a ) Empile l'adresse du tampon de travail **PAD**.  

* __PARSE__&nbsp;&nbsp;( c -- b u ; <string> ) Analyseur lexical. parcourt le flux d'entrée à la recherche de la prochaîne unité lexicale. *c* est le caractère délimiteur. *b* est l'adresse de la chaîne trouvée et *u* sa longueur.  

* __PICK__&nbsp;&nbsp;( nx j -- nx nj ) Copie au sommet de la pile le jième élément de la pile. *j* est d'abord retiré de la pile ensuit les éléments sont compté à partir du sommet vers le fond de la pile. l'Élément au sommet est l'élément *0*.  Donc **0 PICK** est l'équivalent de **DUP** et **1 PICK** est l'équivalent de **OVER**. Le nombre d'éléments sur la pile doit-être &ge;j+1.

* __PRESET__&nbsp;&nbsp;( -- ) Vide la pile des arguments et le TIB avant d'invoquer **QUIT**.  

* __QUERY__&nbsp;&nbsp;( -- ) Lecture d'une ligne de texte du terminal dans le TIB. La lecture se termine à la réception d'un caractère **CR**. Le nombre de caractères dans le TIB est dans la variable systèmE **#TIB**. 

* __QUIT__&nbsp;&nbsp;( -- ) Il s'agit de l'interpréteur de texte, c'est à dire l'interface entre l'utilisateur et le système. **QUIT** appel en boucle **QUEYR** et **EVAL**. 

* __R>__&nbsp;&nbsp;( n -- R: -- n ) La valeur au sommet de la pile des arguments est transférée sur la pile des retours.

* __R@__&nbsp;&nbsp;( -- n ) La valeur au sommet de la pile des retours est copié sur la pile des arguments.  

* __RAND__&nbsp;&nbsp;( u1 -- u2 ) Retourne un entier pseudo aléatoire dans l'intervalle **0&le;u2&lt;u1**.  

* __REPEAT__&nbsp;&nbsp;( -- ) Termine un boucle de la forme **BEGIN-WHILE-REPEAT**. Le branchement s'effectue après le **BEGIN**.

* __ROT__&nbsp;&nbsp;( n1 n2 n3 -- n2 n3 n1 ) Rotation des 2 éléments supérieurs de la pile.

* __RP!__&nbsp;&nbsp;( n -- ) Initialise le pointeur de la pile des retours avec la valeur **n**.

* __RP@__&nbsp;&nbsp;( -- n ) Empile la valeur du pointeur de la pile des retours. 

* __RSHIFT__&nbsp;&nbsp;( n1 u -- n2 ) Décale *n1* de *u* bits vers la droite. Les bits à gauche sont remplacés par **0**. Même effet que l'opérateur **C** **&gt;&gt;**.  

* __SEED__&nbsp;&nbsp;( u -- ) Initialise le générateur pseudo-aléatoire.  

* __SP!__&nbsp;&nbsp;( u --  ) Initialise le pointeur de la pile des arguments.  

* __SP@__&nbsp;&nbsp;( -- u ) Empile la valeur du pointeur des arguments. 

* __SPACE__&nbsp;&nbsp;( -- ) Envoie un caractère ASCII *espace* au terminal.

* __SPACES__&nbsp;&nbsp;( n+ -- ) Envoie **n+** caractères ASCII *espace* au terminal. 

* __STR__&nbsp;&nbsp;( i -- b u ) Converti en chaîne de caractère l'entier **i**. **b** est la chaîne résultatnte et **u** la longueur de cette chaîne. 

* __SWAP__&nbsp;&nbsp;( n1 n2 -- n2 n1 ) Inverse l'ordre des 2 éléments au sommet de la pile. 

* __THEN__&nbsp;&nbsp;( -- ) Termine une boucle **IF-ELSE-THEN. 

* __TIB__&nbsp;&nbsp;( -- a ) Empile l'adresse du *Transaction Input Buffer* qui est le tampon qui accumule les caractes lus par **ACCEPT**.  

* __TIMEOUT?__&nbsp;&nbsp;( -- f ) Vérifie l'état du compteur à rebour **TMER** et retourne *vrai* s'il est à zéro sinon retourne *faux*.

* __TIMER__&nbsp;&nbsp;( u -- ) Initialise le compteur à rebour. Ce compteur est décrémenter à chaque milliseconde jusqu'à ce qu'il atteigne zéro. 

* __TOKEN__&nbsp;&nbsp;( -- a ; &lt;string&gt;) Extrait le prochain mot du TIB. 

* __TYPE__&nbsp;&nbsp;( b u -- ) Envoie *u* caractère au terminal à partir de l'adresse *b*. 

* __U.__&nbsp;&nbsp;( u -- ) Imprime l'entier non signé *u*.

* __U.R__&nbsp;&nbsp;( u n+ -- ) Imprime l'entier non signé *u* sur *n+* colonnes aligné à droite avec remplissage par *espace*.  

* __U<__&nbsp;&nbsp;( u1 u2 -- f ) Comparaison de 2 entiers non signés. Retourne *vrai* si *u1&lt;u2*. Sinon retourne *faux*. 

* __UM*__&nbsp;&nbsp;( u1 u2 -- ud ) Multiplication de 2 entiers non signés et retourne le résultat comme entier non signé double.  

* __UM+__&nbsp;&nbsp;( u1 u1 -- ud ) Additionne 2 entiers non signés et retourne la somme comme entier non signé double.  

* __UM/MOD__&nbsp;&nbsp;( ud u -- ur uq ) Division non signé de l'entier double *ud* par l'entier simple non signé *u*. Retourne le reste *ur* et le quotient *uq*. 

* __UNTIL__&nbsp;&nbsp;( f -- ) Termine une boucle **BEGIN - UNTIL**. La boucle se termine quand **f** est *vrai*.  

* __VARIABLE__&nbsp;&nbsp;( -- &lt;string&gt;) Crée une nouvelle variable de nom **&lt;string&gt;**. Cette variable est initialisée à zéro.  

* __VP__&nbsp;&nbsp;( -- a ) Empile l'adresse de la variable système **VP**.  

* __WAIT__&nbsp;&nbsp;( u -- ) Suspend l'exécution pour une durée de *u* millisecondes.  

* __WHILE__&nbsp;&nbsp;( f -- ) Condition de contrôle d'une boucle **BEGIN - WHILE - REPEAT**. la boucle se poursuit tant que **f** est *vrai*.  

* __WITHIN__&nbsp;&nbsp;( u ul uh -- f ) Retourne **f** indiquant si **ul &le; u &lt;uh** 

* __WORD__&nbsp;&nbsp;( c -- a ) Extrait le prochain mot du **TIB** et le copie à la fin du dictionnaire. **c** est le caractère séparateur de mot et **a** est l'adresse où le mot a été copié. 

* __WORDS__&nbsp;&nbsp;( -- ) Imprime la liste de tous les mots du dictionnaire. 
* __XOR__&nbsp;&nbsp;( n1 n2 -- n3 ) **n3** est le résultat d'un ou exclusif bit à bit entre **n1** et **n2**.  

* __[__&nbsp;&nbsp;( -- ) Initialise le vecteur EVAL en mode *interprétation*. 

* __[COMPILE]__&nbsp;&nbsp;( -- &lt;string&gt; ) Ce mot est utilisé à l'intérieur d'une définition pour compiler le mot suivant qui est un mot *immédiat* donc serait exécuté plutôt que compilé.

* __[N]?__&nbsp;&nbsp;( n+ - n T | a F ) Affiche **[n+]?** puis attend la saisie d'un entier.
Si un entier a été entré au terminal retourne l'entier et **T** sinon retounre l'adresse du token **a** et **F**. Ce mot est utilisé par **CTFILL** et **WTFILL**. 

* __\__&nbsp;&nbsp;( -- ) Introduit un commentaire qui se termine à la fin de la ligne.

* __]__&nbsp;&nbsp;( -- ) Initialise le vecteur EVAL en mode *compilation*. 

* __^H__&nbsp;&nbsp;( -- ) Envoie le caractère ASCII DEL (8) au terminal. 

* __dm+__&nbsp;&nbsp;( a u -- a+u ) Affiche l'adresse **a** suivit de **u** octets de mémoire à partir de **a**. Retourne l'adresse incrémenté. Invoqué par **DUMP**.  

* __hi__&nbsp;&nbsp;( -- ) Application par défaut appellée par **COLD** et qui imprime le message *stm8eForth v3.0*. 

* __parse__&nbsp;&nbsp;( b1 u1 c -- b2 u2 delta ; <string> ) **c** étant le séparateur de mots saute par dessus les **c** jusqu'au premier caractère différent de **c** ensuite avance jusqu'au premier caractère **c**. **b2** est le début du mot, **u2** sa longueur et **delta** est la distance **b2-b1**.   

[Index](#index)
<hr>
<a id="flash"></a>

## Module [flash.asm](flash.asm) 

Ce module définit le vocabulaire nécessaire pour écrire dans la mémoire persistante FLASH,EEPROM et OPTION. Il y a aussi des mots pour modifier les vecteurs d'interruptions.

* __BUF&gt;ROW__&nbsp;&nbsp;( ud -- ) Écris le contenu du tampon **ROWBUFF** dans la mémoire flash en utilisant l'opération d'écriture par bloc du MCU.   

* __CHKIVEC__&nbsp;&nbsp;( a -- ) Toutes les adresses de destination des vecteurs d'interruptions sont comparés à *a*. Tous les vecteurs qui pointent vers une adresse &lt;=*a* sont réinitialisés à la valeur par défaut. Ce mot est invoqué par **PRISTINE**. 

* __EE!__&nbsp;&nbsp;( n ud -- ) Écriture en mémoire persistante (FLASH|EEPROM) de la valeur *n*. *ud* et un entier double non signé représentant l'adresse destination. 

* __EE,__ ( n -- ) Compile en mémoire FLASH l'entier *n*. 

* __EEC!__&nbsp;&nbsp;( c ud -- ) Écris en mémoire persistante le caractère *c*. *ud* est l'adresse destination sous-forme d'entier double non signé.

* __EEC,__&nbsp;&nbsp;( c -- )  Compile en mémoire FLASH le caractère *c*.  

* __EE-CREAD__&nbsp;&nbsp;( -- c) Empile le caractère à l'adresse pointé par **FPTR** et incrément le pointeur.

* __EE-READ__&nbsp;&nbsp;( -- n ) Empile l'entier pointé par **FPTR** et incrément le pointeur de 2.

* __EEP-CP__&nbsp;&nbsp;( -- ud ) Empile l'adresse de la variable système persistante **APP_CP**
. *ud* est un entier double non signé. 

* __EEP-LAST__&nbsp;&nbsp;( -- ud ) Empile l'adresse de la variable système persistante **APP_LAST**.

* __EEP-RUN__&nbsp;&nbsp;( -- ud ) Empile l'adresse de la variable système persistante **APP_RUN**. 

* __EEP-VP__&nbsp;&nbsp;( -- ud ) Empile l'adresse de la variable système persitante **APP_VP** 

* __EEPROM__&nbsp;&nbsp;( -- ud ) Empile l'adresse de base de l'EEPROM. 

* __FAR@__&nbsp;&nbsp;( ad -- n ) Empile l'entier qui se trouve à l'adresse étendue *ad*. Utile pour lire la mémoire flash au delà de 65535. Sur la version **NUCLEO** seulement.

* __FADDR__&nbsp;&nbsp;( a -- ad ) Convertie l'adresse 16 bits *a* en adresse 32 bits *ad*. Sur la version **NUCLEO** seulement.

* __FARC@__&nbsp;&nbsp;( ad -- ) Empile l'octet qui se trouve à l'adresse étendue *ad*. Utile pour lire  à mémoire flash au delà de 65535. Sur la version **NUCLEO** seulement.

* __FMOVE__&nbsp;&nbsp;( -- a ) Déplace le dernier mot compilé de la mémoire RAM vers la mémoire FLASH. Retourne le pointeur de code mis à jour __a__.  

* __FP!__&nbsp;&nbsp;( ad -- ) Initialize la variable système **FPTR** avec la valeur __ad__. Le far pointer est utilisé pour les opérations d'écriture en mémoire persistante.  

* __IFMOVE__&nbsp;&nbsp;( -- a ) Transfert routine d'interruption qui vient d'être compilée vers la mémoire flash. __a__ est la valeur mise à jour du pointeur de code __CP__. 

* __INC-FPTR__&nbsp;&nbsp;( -- ) Incrémente la variable système **FPTR**.  

* __LOCK__&nbsp;&nbsp;( -- ) Verrouille l'écrire dans la mémoire persistante (FLASH et EEPROM).

* __PRISTINE__&nbsp;&nbsp;( -- ) Nettoie le système de toutes les modifications effectuées par l'utilisateur. Le système Forth se retrouve alors dans son état initial avant toute intervention de l'utilisateur. 

* __PTR+__&nbsp;&nbsp;( u -- ) Incrémente **FPTR** d'une valeur arbitraire __u__.

* __RAM&gt;EE__&nbsp;&nbsp;( ud a u1 -- u2 ) Écris dans la mémoire persistance __u1__ octets de la mérmoire RAM à partir de l'adresse __a__ vers l'adresse __ud__. Cependant l'écriture est limitée aux limites du bloc 128 octets qui contient l'adresse __ud__. Si __ud+u1__  dépasse la limite l'écriture s'arrête à la fin du bloc. Retourne __u2__ le nombre d'octets réellement écris. 

* __RFREE__&nbsp;&nbsp;( a -- u ) __u__ est le nombre d'octets libres dans le bloc qui contient l'adresse __a__. En fait u=128-a%128. 128 étant la longueur d'un bloc FLASH pour les MCU **STM8S105C6** et **STM8S208RB.**  

* __ROW-ERASE__&nbsp;&nbsp;( ud -- ) Efface le bloc de mémoire persistante contentant l'adresse **ud**.  

* __ROW&gt;BUF__&nbsp;&nbsp;( ud -- ) Copie le bloc de mémoire persistante contenant l'adresse **ud** vers le tampon système **TBUF**. 

* __RST-IVEC__&nbsp;&nbsp;( u -- ) Réinitialise le vecteur d'interruption #**u** à sa valeur par défaut. 

* __SET-IVEC__&nbsp;&nbsp;( ud u -- )  Initialise le vecteur d'interruption __u__ avec l'adresse **ud** qui et l'adresse d'une routine de service d'interruption. 

* __SET-OPT__&nbsp;&nbsp;( c u -- ) Écris le caractère __c__ dans le registre d'OPTION __u__.  

* __UNLKEE__&nbsp;&nbsp;( -- ) Déverouille pour l'écriture la mémoire EEPROM.  

* __UNLKFL__&nbsp;&nbsp;( -- ) Déverouille pour l'écriture la mémoire FLASH.

* __UNLOCK__&nbsp;&nbsp;(  -- ) Selon l'adresse contenue dans la variable système **FPTR** déverrouille la mémoire FLASH ou EEPROM.  

* __UPDAT-CP__&nbsp;&nbsp;( -- ) Met à jour la variable système persistante **EEP-CP** à partir de la variable **CP**.  

* __UPDAT-LAST__&nbsp;&nbsp;( -- ) Met à jour la variable système persistante **EEP-LAST** à partir de la variable **LAST**. 

* __UPDAT-PTR__&nbsp;&nbsp;( -- ) Met à jour les différentes variables système persistantes à partir des valeurs de leur correspondantes non persistantes.

* __UPDAT-RUN__&nbsp;&nbsp;( a -- ) Met à jour la variable système persistante **EEP-RUN**. **a** est la nouvelle adresse du programme à exécuter au démarrage.

* __UPDAT-VP__&nbsp;&nbsp;( -- ) Met à jour la variable système persistante **EEP-VP** à partir de la valeur de **VP**. 

* __WR-BYTE__&nbsp;&nbsp;( c -- ) Écris un octet dans la mémoire persistante à l'adresse indiquée par la variable système **FPTR**.  Incrémente **FPTR**.

* __WR-ROW__&nbsp;&nbsp;( a ud -- ) Écriture d'un bloc de 128 octets dans la mémoire persistante. **a** est l'adresse RAM qui contient les données à écrires et **ud** l'adresse destination. Si __ud__ n'est pas alignée sur un bloc de 128 octets il le sera en mettant les 7 bits les moins significatifs à zéro. Dans la version __DISCOVERY__ __ud__ est remplacé par une adresse de type *entier simple non signé*.

* __WR-WORD__&nbsp;&nbsp;( n -- ) Écris un entier 16 bits dans la mémoire persitante à l'adresse pointée par **FPTR**. Incrémente **FPTR**. 

[index](#index)

<hr>

<a id="tools"></a>

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


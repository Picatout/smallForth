# SmallForth 

J'ai repris le projet stm8_eforth [stm8_eforth](https://github.com/Picatout/stm8_eForth) pour en réduire la taille. Le projet original avait été développé pour les MCU STM8207/8  qui possède une mémoire étendue au delà des 64KO. La taille du binaire était de plus de 13KO. J'ai réduit la taille du binaire à moins de 6KO ce qui permet d'utilisé __smallForth__ sur les MCU qui possèdent de 8KO à 32Ko de mémoire FLASH. 

## Modifications

* Le support pour la mémoire au delà de 64KO  a été éliminé. 
* Le support pour la création d'un vocabulaire en mémoire RAM a été éliminé. Toutes les définitions sont compilées directement en mémoire FLASH.
* Le support pour les entiers double (32 bits) a été illiminé. 
* Certains mots ont été éliminés. Alors que d'autres ont étés simplement retirés du dictionnaire puisqu'ils ne sont utilent que pour le compilateur.
* Le vocabulaire original compenrait environ 250 mots dans le dictionnaire, __smallForth__ ne contient que 160 mots dans le dictionnaire.
* Ajouté 3 mots utiles pour la manipulation des périphériques: __SETBIT__, __RSTBIT__ et __TOGLBIT__. 

## Chargement d'un fichier forth 

Un utilitaire est fourni pour programmer un fichier source forth dans le MCU. Cet utilitaire est appellé [SendFile](tools/SendFile).  
```
Command line tool to program forth file to stm8 MCU
USAGE: SendFile -s device [-d msec] file_name [file2 ... fileN]
  -s device indique le port sériel utilisé.
  -d msec  délais en millisecondes entre chaque ligne envoyée.
   file_name   nom du fichier à programmer.
La configuration du port sériel est de 8 bits, 1 stop, pas de parité, 115200 BAUD. 
```
Il s'agit d'un projet séparé disponible ici [sendFile](https://github.com/Picatout/sendFile). J'ai créer ce projet à la même époque que [stm8_eForth](https://github.com/Picatout/stm8_eForth), dont ce projet est dérivé.

Pour simplifier encore plus les choses il y a le script [send.sh](send.sh).
```
#! /bin/bash 
./tools/SendFile -d 200 -s/dev/ttyS0 $1
```
Présentement avec **smallForth** j'ai du augmenter le délais à 200 à cause de la lenteur d'écriture dans la mémoire **FLASH**. Dans le fichier source forth il vaux mieux éviter les lignes de texte trop longue car alors le délais de programmation pourrait dépasser 200 msec par ligne.





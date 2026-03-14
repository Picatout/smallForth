# SmallForth 

J'ai repris le projet stm8_eforth [stm8_eforth](https://github.com/Picatout/stm8_eForth) pour en réduire la taille. Le projet original avait été développé pour les MCU STM8207/8  qui possède une mémoire étendue au delà des 64KO. La taille du binaire était de plus de 13KO. J'ai réduit la taille du binaire à moins de 6KO ce qui permet d'utilisé __smallForth__ sur les MCU qui possèdent de 8KO à 32Ko de mémoire FLASH. 

## Modifications

* Le support pour la mémoire au delà de 64KO  a été éliminé. 
* Le support pour la création d'un vocabulaire en mémoire RAM a été éliminé. Toutes les définitions sont compilées directement en mémoire FLASH.
* Le support pour les entiers double (32 bits) a été illiminé. 
* Certains mots ont été éliminés. Alors que d'autres ont étés simplement retirés du dictionnaire puisqu'ils ne sont utilent que pour le compilateur.
* Le vocabulaire original compenrait environ 250 mots dans le dictionnaire, __smallForth__ ne contient que 160 mots dans le dictionnaire.
* Ajouté 3 mots utiles pour la manipulation des périphériques: __SETBIT__, __RSTBIT__ et __TOGLBIT__. 


\ ****************************************************
\ Démonstration de l'utilisation du périphérique SPI  
\ Lecture et écriture dans une mémoire FLASH W25Q80DV 
\ ****************************************************

\ NOTE: forth/exist.f  doit-être chargé avant ce fichier 

DECIMAL 
FORGET BUFFER 

\ registre 1 d'activation périphérique 
$50C3 CONST CLK_PCKENR1
4 CONST CLK_PCKENR1_SPI1 \ SPI bit gating bit 


\ sortie chip select sur PB0 
\ pin 13 du stm8l151k6 
$5005 CONST PB_ODR 
$5007 CONST PB_DDR 
$5008 CONST PB_CR1 
0 CONST PB0 \ W25Q80DV select   

\ regitres du SPI 
$5200 CONST SPI1_CR1 \ SPI1 control register 
$5201 CONST SPI1_CR2 
$5203 CONST SPI1_SR \ SPI1 status register
$5204 CONST SPI1_DR \ SPI1 data register

\ création d'un tampon de
\ n entiers dans la mémoire RAM  
: BUFFER ( <name> n --  )
    VAR 
    1- 2* ALLOT 
;

128 BUFFER WR_BUFF  \ tampon d'écriture 
128 BUFFER RD_BUFF  \ tampon de lecture  

\ configuration du 
\ périphérique SPI 
\ CLK=8Mhz
: SPI_CFG ( -- )
\ PB0 configuré en sortie push pull 
\ pour contrôler la broche sélect du W25Q80DV
    0 PB_ODR SETBIT \ ~CS  W25Q80DV désactivé quand à 1   
    0 PB_CR1 SETBIT \ PB0 configuration push pull 
    0 PB_DDR SETBIT  \ PB0 mode sortie 
    5 PB_CR1 SETBIT   \ SPI SCLK en pushpull 
    6 PB_CR1 SETBIT   \ SPI MOSI en pushpull 
    7 PB_CR1 SETBIT  \ SPI MISO pullup activé 
\ utilisation du SPI à sa fréquence maximale de 8Mhz   
    CLK_PCKENR1_SPI1 CLK_PCKENR1 SETBIT \ activation du signal clock SPI  
    3 SPI1_CR2 C!  \ NSS contrôlé par logiciel, mode maître   
    $44 SPI1_CR1 C! \ activation du périphérique en maître      
; 

\ désactivation du SPI 
: SPI_OFF ( -- )
    6 SPI1_CR1 RSTBIT 
    CLK_PCKENR1_SPI1 CLK_PCKENR1 RSTBIT
    0 PB_DDR RSTBIT \ mode entrée, avec pullup 
; 

\ attend que la transaction 
\ SPI soit complétée
: SPI_WAIT ( -- )
    BEGIN 
        SPI1_CR1 C@ 
        $80 AND \ test BSY bit  
        0= 
    UNTIL \ boucle jusqu'à ce que  BSY=0
; 

\ Pour éviter d'écraser 
\ le contenu de  SPI1_DR  
: WAIT_TXE ( -- )
    BEGIN 
        SPI1_SR C@ 
        2 AND 
    UNTIL \ loop until TXE=1 
; 

\ Envoie d'un octet via SPI  
\ SPI déjà sélectionné 
: SPI_WR_BYTE ( c -- ) 
    WAIT_TXE  
    SPI1_DR C! 
    SPI_WAIT  
    SPI1_DR C@ DROP \ jette l'octet reçu    
; 

\ réception d'un octet du SPI 
\ SPI déjà sélectionné  
\ et l'adresse a déjà été envoyée. 
: SPI_RD_BYTE ( -- c )
    WAIT_TXE  
    0 SPI1_DR C! 
    BEGIN 
        SPI1_SR C@ 
        1 AND  \ test RXNE bit 
    UNTIL \ boucle jusqu'à ce que RXNE=1 
    SPI1_DR C@ \ -- c 
;

\ sélectionne le W25Q
: W25Q_SELECT ( -- )
    PB0 PB_ODR RSTBIT 
; 

\ désélectionne le W25Q
: W25Q_DESELECT ( -- )
    SPI_WAIT \ évter la corruption 
    PB0 PB_ODR SETBIT \ désélection du W25Q 
; 

\ Envoie de la commande WRITE ENABLE 
\ to W25Q80DV
: W25Q_WR_EN ( -- )
    W25Q_SELECT 
    6 SPI_WR_BYTE
    W25Q_DESELECT \ must deselect after this command 
; 

\ envoie de l'adresse W25Q80DV
\ W25Q80DV déjà sélectionné  
: W25Q_ADDR ( ud -- )
    SPI_WR_BYTE \ adresse bits 16..23  
    DUP 
    8 RSHIFT 
    SPI_WR_BYTE \ adresse bits 8..15
    SPI_WR_BYTE \ adresse bits 0..7
; 

\ envoie le tampon vers le SPI 
\ b -> adresse du tampon  
\ ud  -> adresse destination dans W25Q80  
\ u  -> nombre d'octets à envoyer 
: WRITE_BUFF ( b ud u -- )
    >R 
    W25Q_WR_EN \ authorique l'écriture dans W25Q
    W25Q_SELECT
    2 SPI_WR_BYTE \ commande de programmation
    W25Q_ADDR  
    R> 1- 
    FOR 
        DUP C@ 
        SPI_WR_BYTE
        1+
    NEXT
    W25Q_DESELECT 
; 

\ Lecture  du W25Q80DV dans un tampon   
\ b -> adresse du tampon en RAM 
\ d  -> adresse dans le W25Q80DV 
\ u  -> nombre d'octets à lire 
: READ_BUFF ( b ud u -- )
    >R 
    W25Q_SELECT 
    3   SPI_WR_BYTE \ envoie de la commenade lecture du W25Q80DV  
    W25Q_ADDR
    R>
    1-
    FOR 
        SPI_RD_BYTE 
        OVER C! 
        1+
    NEXT
    W25Q_DESELECT  
;

\ remplie le tampon 
\ de transmission 
: FILL_BUFF ( -- )
    WR_BUFF 
    255 FOR 
        I OVER C! 
        1+ 
    NEXT 
; 

: TEST ( -- )
    FILL_BUFF \ remplie de tampon de transmission 
    CR ." ecriture vers W25Q80DV" 
    WR_BUFF 255 DUMP \ affiche le contenu 
    SPI_CFG 
    WR_BUFF 0 0 256 
    WRITE_BUFF
    CR ." lecture du contenu de W25Q80DV"  
    RD_BUFF 0 0 256 
    READ_BUFF
    RD_BUFF 255 DUMP \ affiche le contenu
    SPI_OFF    
; 


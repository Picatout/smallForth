\ ********************************
\ joue un fichier WAV enregistré
\ dans une mémoire FLASH externe.
\  
\ Ce démo utilise 4 périphériques 
\ DAC fait la convertion
\ DMA canal 3 transferer les
\ octets lue de W25Q80DV vers le DAC 
\ TIMER4 cadence le transfert À 22Khz 
\ SPI pour interfacé la mémoire W25Q80DV 
\ ********************************

\ ****************************
\  DÉPENDANCES
\
\    forth/exist.f 
\    forth/w25q_prog.f 
\ ****************************


DECIMAL 
FORGET SET_TICKER 

\ peripheral clock gating 
$50C3 CONST CLK_PCKENR1 \ peripheral clock gating register 1 
$50C4 CONST CLK_PCKENR2 \ peripheral clock gating register 2
7 CONST CLK_PCKENR1_DAC \ DAC clock gating bit 
5 CONST CLK_PCKENR2_COMP \ COMP clock gating bit 
4 CONST CLK_PCKENR2_DMA1 \ DMA clock gating bit 

\ routing register 
$543B CONST RI_IOSR3 \ I/O switch register 3 
$5438 CONST RI_IOCMR3 \ I/O control mode register 3
4   CONST RI_IOSR3_CH15E  \ bit to connect DAC to PB4 

\ digital to analog converter registers 
$5380 CONST DAC_CR1
$5381 CONST DAC_CR2 
$5384 CONST DAC_SWTRIGR 
$5385 CONST DAC_SR 
$5388 CONST DAC_RDHRH 
$5389 CONST DAC_RDHRL 
$538C CONST DAC_LDHRH 
$538D CONST DAC_LDHRL 
$5390 CONST DAC_DHR8 
$53AC CONST DAC_DORH 
$53AD CONST DAC_DORL 

\ TIMER registers 
$52E0 CONST TIM4_CR1 \ control register 1
$52E1 CONST TIM4_CR2 \ control register 2 
$52E8 CONST TIM4_PSCR \ prescale register 
$52E9 CONST TIM4_ARR \ auto reload register 
$52E3 CONST TIM4_DER \ DMA request enable 
$52E4 CONST TIM4_IER \ interrupt enable 
$52E5 CONST TIM4_SR \ status register 


0 CONST TIM4_IER_UIE \ update interrupt enable 
0 CONST TIM4_CR1_CEN \ counter enable

\ DMA global registers 
$5070 CONST DMA_GCSR
\ DMA channel 3 registers 
$5093 CONST DMA_C3CR
$5094 CONST DMA_C3SPR
$5095 CONST DMA_C3NDTR
$5096 CONST DMA_C3PARH
$5097 CONST DMA_C3PARL
$5099 CONST DMA_C3M0ARH
$509A CONST DMA_C3M0ARL


\ config TIMER 4 
\ as system 
\ msec ticker 
: SET_TICKER 
    7 TIM4_PSCR C!  \ 16Mhz/128  
    124 TIM4_ARR C!  \ 125Khz/1Khz-1 
    5 TIM4_CR1 C! 
    TIM4_IER_UIE TIM4_IER SETBIT 
;   

\ set TIMER4 to use 
\ as DAC trigger
\ fréquence d'échantillonnage ~ 22050 
\ no interrupt   
: SET_TRIGGER ( -- ) 
    TIM4_IER_UIE TIM4_IER RSTBIT 
    2 TIM4_PSCR C!  \ 16Mhz/4  
    180 TIM4_ARR C!  \ 4Mhz/22050-1     
    $20 TIM4_CR2 C! \ UEV  -> TRGO 
    5 TIM4_CR1 C!   \ URS and EN bits  
;

\ configure DAC 
\ output on PB4 
: DAC_CFG ( -- )
    SET_TRIGGER \ TIMER4 used as sampling trigger 
    CLK_PCKENR1_DAC CLK_PCKENR1 SETBIT \ DAC clock enable 
    CLK_PCKENR2_COMP CLK_PCKENR2 SETBIT \ COMP clock enable 
    RI_IOSR3_CH15E RI_IOCMR3 SETBIT \ i/o controlled by RI_IOSR3 
    RI_IOSR3_CH15E RI_IOSR3 SETBIT \ route DAC on PB4
    4 DAC_CR2 SETBIT \ enable DMA 
    2 DAC_CR1 SETBIT \ triggered by TIMER4 
    0 DAC_CR1 SETBIT \ enable DAC  
; 

\ turn off DAC 
: DAC_OFF ( -- )
    0 DAC_CR1 RSTBIT 
    CLK_PCKENR1_DAC CLK_PCKENR1 RSTBIT
    CLK_PCKENR2_COMP CLK_PCKENR2 RSTBIT 
    SET_TICKER \ restore TIMER4 to its system function 
; 

\ configure DMA channel 0 
\ for transfert from PROG_BUFF 
\ to DAC_RDHR register 
\ TIMER4 control transfert pace 
\ b is PROG_BUFF address 
: DMA_CFG ( b -- )
    CLK_PCKENR2_DMA1 CLK_PCKENR2 SETBIT \ enable DMA clock gating 
\ set memory address in DMA_C0M0AR 
    DUP 
    8 RSHIFT 
    DMA_C3M0ARH C!
    DMA_C3M0ARL C!
\ set peripheral address in DMA_C3PAR
    DAC_DHR8 DUP 
    8 RSHIFT 
    DMA_C3PARH C! 
    DMA_C3PARL C!
    254 DMA_C3NDTR C! \ samples transfert count 
    $30 DMA_C3SPR C! \ highest priority, 8 bits transfert 
\ memory incr, circular mode, memory to peripheral, enable channel
    $3F DMA_C3CR C!  \ set HTIF flag 
; 

\ enable DMA 
: DMA_ON 
   0 DMA_GCSR SETBIT 
; 

: DMA_OFF 
   0 DMA_GCSR RSTBIT 
; 

VAR FLAGS 
0 CONST FLAG_HALF  \ which half of buffer to fill 
1 CONST FLAG_LOAD  \ time to reload buffer 

\ get flag state 
: FLAG_TEST ( bit a -- f )
    @ 
    1 ROT LSHIFT  
    AND 
;

\ inverse flag state 
: FLAG_TOGL ( bit a -- )
    >R 
    1 SWAP LSHIFT
    R@ @ XOR
    R> ! 
;

\ set flag 
: FLAG_SET ( bit a -- )
    >R 
    1 SWAP LSHIFT 
    R@ @ OR 
    R> !
; 

\ reset flag 
: FLAG_RESET ( bit a -- )
    >R 
    1 SWAP LSHIFT 
    NOT R@ @ AND 
    R> !
; 


\ DMA channel 3 interrupt handler 
3 I:
    FLAG_LOAD FLAGS FLAG_SET 
    2 DMA_C3SPR RSTBIT 
    1 DMA_C3SPR RSTBIT
I;  


: DOUBLE ( <name> ) 
    VAR 
    2 ALLOT 
;

\ store a double 
: 2! ( d a -- )
    DUP >R 
    ! 
    R> 2+ ! 
;

\ fetch a double 
: 2@ ( a -- d )
    DUP 2+ @ 
    SWAP @ 
;


DOUBLE W25Q_OFFSET \ where in file 
DOUBLE WAV_SIZE  \ WAV data size 


\ write WAV data in PROG_BUFF.
\ load a page size from 
\ W25Q80DV
\ while DMA is transferring 
\ data from one half to DAC 
\ the other half is filled 
\ with next data page 
\ nombre d'octets à lire   
: FILL_BUFFER ( n -- ) 
    >R 
    PROG_BUFF
    FLAG_HALF FLAGS FLAG_TEST 
    IF 127 + THEN \ fill upper half 
    W25Q_OFFSET 2@ \ W25Q address 
    R> READ_BUFF   \ read n bytes 
    W25Q_OFFSET 2@  \ update to 
    SWAP 127 UM+  ROT + \ next segment  
    W25Q_OFFSET 2!   
    FLAG_HALF FLAGS FLAG_TOGL \ toggle flag 
    WAV_SIZE 2@ 127 UM- 
    DUP 0< IF 2DROP 0 0 THEN 
    WAV_SIZE 2! 
    FLAG_LOAD FLAGS FLAG_RESET 
;

\ read little indian integer 
: LI@ ( a -- n )
    DUP 1+ C@ 
    8 LSHIFT 
    SWAP C@ + 
; 

: 2LI@ ( a -- d )
    DUP LI@ SWAP 2+ LI@ 
;

\ imprime l'entier u1
\ à largeur de champ u2
\ sans espace avant ou après 
\ BASE doit-être 16 
: H.R ( u1 u2 -- )
    SWAP STR \ u2 b us 
    >R  \ u2 b 
    BEGIN 
       OVER R@ > WHILE \ tant que u2 > us 
       $30 EMIT 
       SWAP 1- SWAP  \ u2 - 1    
    REPEAT 
    R> TYPE
    DROP
; 

\ imprime entier double 
\ en hexadecimal 
\ sous la forme 
\ $xxxx xxxx
\ BASE doit-être 16  
: 2H.R ( d  -- )
    $24 EMIT 
    4 H.R
    SPACE  
    4 H.R
    SPACE  
;

\ print file name 
\ file size 
\ data size 
: FILE_INFO 
    BASE @ >R 
    16 BASE ! 
    CR
    W25Q_OFFSET 2@ 
    2H.R   
    PROG_BUFF 12 TYPE 
    ."  FILE SIZE: "
    PROG_BUFF $C + 
    2LI@ 2H.R 
    ."  DATA SIZE: " 
    PROG_BUFF $38 +
    2LI@  2H.R  
    R> BASE ! 
; 

\ list file saved on 
\ W25Q80DV 
: LIST 
    SPI_CFG 
    0 0 2DUP W25Q_OFFSET 2! 
    BEGIN 
        PROG_BUFF 
        W25Q_OFFSET 2@
        60 READ_BUFF
        PROG_BUFF C@ 
        32 127 WITHIN 
        WHILE
          FILE_INFO 
          PROG_BUFF 12 + 
          2LI@  
          W25Q_SECT_ALGN 
          W25Q_OFFSET 2@ D+
          W25Q_OFFSET 2! 
    REPEAT
    SPI_OFF 
;

\ play WAV file from 
\ W25Q80DV 
\ data rate 22050 hertz 
\ channel 1 
\ bits per sample 8 
\ data offset at 60
\ ud address of wav file in W25Q  
: PLAY_WAV ( ud -- )
\ initialize peripherals 
    SWAP 60 UM+ ROT + 
    W25Q_OFFSET 2! 
    SPI_CFG 
    DAC_CFG 
    PROG_BUFF DMA_CFG 
    0 FLAGS !
\ get data size, 32 bits integer 
    PROG_BUFF 0 0 60 READ_BUFF 
    PROG_BUFF 56 + DUP \ little indian double 
    2LI@    
    WAV_SIZE 2!
\ fill first half of buffer 
    254 FILL_BUFFER
    DMA_ON
    BEGIN 
        BEGIN 
            FLAG_LOAD FLAGS FLAG_TEST 
        UNTIL 
        127 FILL_BUFFER
    WAV_SIZE 2@ OR 
    WHILE REPEAT
    DMA_OFF 
    SPI_OFF
    DAC_OFF 
    SET_TICKER  
;         

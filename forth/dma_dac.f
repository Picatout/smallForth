\ NOTE: forth/exist.f doit-être programmé dans le MCU avant celui-ci 
\ 
\ *********************************
\ DEMO: 
\ Démonstration de l'utilisation 
\ du DMA avec le DAC 
\ pour générer une onde triangulaire 
\ de 500 Hertz. 
\ la sortie est sur PB4 pint 17 du 
\ stm8l151k6.
\ Le tampon l'onde triangulaire 
\ comprend 40 échantillons 
\ *********************************

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
    125 TIM4_ARR C!  \ 125 
    5 TIM4_CR1 C! 
    TIM4_IER_UIE TIM4_IER SETBIT 
;   

\ set TIMER4 to use 
\ as DAC trigger
\ 50µSec sample rate 
\ no interrupt   
: SET_TRIGGER ( -- ) 
    TIM4_IER_UIE TIM4_IER RSTBIT 
    2 TIM4_PSCR C!  \ 16Mhz/4  
    199 TIM4_ARR C!  \ 4Mhz/20Khz   
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
\ for transfert from DMA_BUFFER 
\ to DAC_RDHR register 
\ TIMER4 control transfert pace 
\ b is DMA_BUFFER address 
: DMA_CFG ( b -- )
    CLK_PCKENR2_DMA1 CLK_PCKENR2 SETBIT \ enable DMA clock gating 
\ set memory address in DMA_C0M0AR 
    DUP 
    8 RSHIFT 
    DMA_C3M0ARH C!
    DMA_C3M0ARL C!
\ set peripheral address in DMA_C0PAR
    DAC_RDHRH DUP 
    8 RSHIFT 
    DMA_C3PARH C! 
    DMA_C3PARL C!
    40 DMA_C3NDTR C! \ samples transfert count 
    $38 DMA_C3SPR C! \ highest priority, 16 bits transfert 
\ memory incr, circular mode, memory to peripheral, enable channel
    $39 DMA_C3CR C!  
; 


\ create a buffer of n integers in RAM 
: BUFFER ( <name> n --  )
    VAR 
    1- 2* ALLOT 
;

\ set DAC data in DMA_BUFFER.
\ ~ 1Khz triangle wave 
\ a -> buffer address  
: FILL_BUFFER ( a -- ) 
    200 0 ROT  
    19 FOR
        >R 
        DUP 
        R@ ! 
        OVER +
        R> 2+ 
    NEXT 
    19 FOR 
        >R 
        OVER -
        DUP 
        R@ ! 
        R> 2+
    NEXT 
    DROP 2DROP        
;

40 BUFFER DMA_BUFFER

\ DAC triangle wave channel output 
: TRIANGLE ( -- )
    DMA_BUFFER FILL_BUFFER  \  a -- 
    DMA_BUFFER DMA_CFG 
    DAC_CFG
    1 DMA_GCSR C! \ start transfert  
    BEGIN 
        KEY? 
    UNTIL 
    KEY DROP
    DAC_OFF  
; 


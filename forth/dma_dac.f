\ NOTE: must load exist.f before this one 
\ 
\ DEMO: 
\ Using DMA with 
\ digital to analog converter
\ output on PB4 STM8L151K6 pin 17


\ peripheral clock gating 
$50C3 CONST CLK_PCKENR1 \ peripheral clock gating register 1 
$50C4 CONST CLK_PCKENR2 \ peripheral clock gating register 2
7 CONST CLK_PCKENR1_DAC \ DAC clock gating bit 
5 CONST CLK_PCKENR2_COMP \ COMP clock gating bit 

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
$52E4 CONST TIM4_IER \ interrupt enable 
$52E5 CONST TIM4_SR \ status register 

0 CONST TIM4_IER_UIE \ update interrupt enable 
0 CONST TIM4_CR1_CEN \ counter enable

\ DMA registers 
$5070 CONST DMA_GCSR
$5071 CONST DMA_GIR1
$5075 CONST DMA_C0CR
$5076 CONST DMA_C0SPR
$5077 CONST DMA_C0NDTR
$5078 CONST DMA_C0PARH
$5079 CONST DMA_C0PARL
$507B CONST DMA_C0M0ARH
$507C CONST DMA_C0M0ARL
$507F CONST DMA_C1CR
$5080 CONST DMA_C1SPR
$5081 CONST DMA_C1NDTR
$5082 CONST DMA_C1PARH
$5083 CONST DMA_C1PARL
$5085 CONST DMA_C1M0ARH
$5086 CONST DMA_C1M0ARL
$5089 CONST DMA_C2CR 
$508A CONST DMA_C2SPR
$508B CONST DMA_C2NDTR
$508C CONST DMA_C2PARH
$508D CONST DMA_C2PARL
$508F CONST DMA_C2M0ARH
$5090 CONST DMA_C2M0ARL
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
    131 TIM4_ARR C!  \ 256-125 
    5 TIM4_CR1 C! 
    TIM4_IER_UIE TIM4_IER SETBIT 
;   

\ set TIMER4 to use 
\ as DAC trigger
\ 50µSec sampling rate 
\ no interrupt   
: SET_TRIGGER ( -- ) 
    TIM4_IER_UIE TIM4_IER RSTBIT 
    2 TIM4_PSCR C!  \ 16Mhz/4  
    56 TIM4_ARR C!  \ 256-200  
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
    0 DAC_CR1 SETBIT \ enable DAC  
; 

\ turn off DAC 
: DAC_OFF ( -- )
    0 DAC_CR1 RSTBIT 
    CLK_PCKENR1_DAC CLK_PCKENR1 RSTBIT
    CLK_PCKENR2_COMP CLK_PCKENR2 RSTBIT 
    SET_TICKER \ restore TIMER4 to its system function 
; 

\ DAC noise channel output 
: NOISE ( -- )
    DAC_CFG 
    0 DAC_CR1 RSTBIT \ disable DAC  
    10 DAC_CR2 C! \ 32 samples per cycle 
    $45 DAC_CR1 C! \ NOISE, TEN and EN bits  
    BEGIN 
        KEY? 
    UNTIL 
    KEY DROP
    DAC_OFF  
; 


\ DAC triangle wave channel output 
: TRIANGLE ( -- )
    DAC_CFG 
    0 DAC_CR1 RSTBIT \ disable DAC  
    10 DAC_CR2 C! \ 32 samples per cycle 
    $85 DAC_CR1 C! \ TRIANGLE, TEN and EN bits  
    BEGIN 
        KEY? 
    UNTIL 
    KEY DROP
    DAC_OFF  
; 


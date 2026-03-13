\ USE: exist.f 

\ analog to digital converter demo.
\ read the stm8l151k6 internal
\ temperature sensor and print value.

\ peripherals clock gating register 2 
$50C4 CONST CLK_PCKENR2 
0 CONST CLK_PCKENR2_ADC1 \ ADC1 clock gating bit 

\ ADC1 registers 
$5340 CONST ADC1_CR1 \ control register 1 
$5343 CONST ADC1_SR \ status register 
$5344 CONST ADC1_DRH \ data register high byte 
$5345 CONST ADC1_DRL \ data register low byte 
$534A CONST ADC1_SQR1 \ 24-27 channel select 
$534B CONST ADC1_SQR2 \ 16-23 channel select 
$534C CONST ADC1_SQR3 \ 8-15 channel select 
$534D CONST ADC1_SQR4 \ 0-7 channel select 
17  CONST ADC1_CH_17 \ on pin 14  
0   CONST ADC1_CR1_ADON \ enable converter 
1   CONST ADC1_CR1_START \ start convertion 
0   CONST ADC1_SR_EOC \ end of convertion 
7   CONST ADC1_SQR1_DMAOFF \ disable DMA 

\ read ADC1 channel n 
\ u range {0...4095} 
:? READ_ADC ( n+ -- u )
    DUP 
    23 > IF 
        24 - ADC1_SQR1 SETBIT 
    ELSE 
        DUP 15  > IF 
            16 - ADC1_SQR2 SETBIT 
        ELSE 
            DUP 7 > IF  
                8 - ADC1_SQR3 SETBIT 
            ELSE
                ADC1_SQR4 SETBIT 
            THEN 
        THEN 
    THEN  
    ADC1_SQR1_DMAOFF ADC1_SQR1 SETBIT \ disable DMA  
    ADC1_CR1_START ADC1_CR1 SETBIT \ start conversion 
    BEGIN \ wait conversion done 
        ADC1_SR C@   
        1 ADC1_SR_EOC LSHIFT  
        AND
    UNTIL \ loop until EOC bit set 
\ value= ADC1_DRH*256+ADC1_DRL 
    ADC1_DRH C@ 
    8 LSHIFT  \ DRH*256
    ADC1_DRL C@
    +
\ reset all channel  
    0 ADC1_SQR1 C! 
    0 ADC1_SQR2 C! 
    0 ADC1_SQR3 C! 
    0 ADC1_SQR4 C! 
; 

\ display internal temparure sensor 
\ reading 
:? TEMP ( -- )
    CLK_PCKENR2_ADC1 CLK_PCKENR2 SETBIT \ enable ADC1 clock gate
    ADC1_CR1_ADON ADC1_CR1 SETBIT \ enable ADC 
    BEGIN \ display temp sensor value loop 
        ADC1_CH_17 READ_ADC
        . CR \ display value 
        1000 WAIT  \ pause 1 second 
        KEY? \ any key? 
    UNTIL \ loop until key pressed 
    KEY DROP \ drop key pressed 
; 


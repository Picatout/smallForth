\ Digital to analog converter demo 
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


\ configure DAC 
\ output on PB4 
: DAC_CFG ( -- )
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
; 

\ DAC noise channel output 
: NOISE ( -- )
    DAC_CFG 
    BEGIN 
        4096 RAND 
        DUP 
        8 RSHIFT 
        DAC_RDHRH C! 
        DAC_RDHRL C!
        KEY? 
    UNTIL 
    2DROP 
    KEY DROP
    DAC_OFF  
; 


\ DAC triangle wave channel output 
: TRIANGLE ( -- )
    DAC_CFG 
    256 0
    BEGIN 
        OVER  
        + DUP
        0 4096 WITHIN IF 
            DUP DUP  
            8 RSHIFT 
            DAC_RDHRH C! 
            DAC_RDHRL C!
        ELSE 
            SWAP 
            NEGATE 
            SWAP 
            OVER + 
        THEN 
        KEY? 
    UNTIL 
    2DROP 
    KEY DROP
    DAC_OFF  
; 


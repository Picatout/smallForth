\ USE: exist.f 

\ use TIMER2 channel 1 to generate a warble sound 

\ clock gating register 
$50C3 CONST CLK_PCKENR1 \ clock gating register 1 
0  CONST CLK_PCKENR1_TIM2 \ timer 2 gating bit 

\ TIMER2 registers 

$5250 CONST TIM2_CR1  \ control register 1 
$5259 CONST TIM2_CCMR1 \ capture|compare mode register 
$525B CONST TIM2_CCER1 \ Capture/compare enable register 1
$525F CONST TIM2_ARRH  \ auto reload register high value 
$5260 CONST TIM2_ARRL \ auto reload register low value 
$5258 CONST TIM2_EGR \ event generator 
$5265 CONST TIM2_BKR \ break register 
7 CONST TIM2_BKR_MOE  \ master output enable 

: PWM-CFG ( -- )
    CLK_PCKENR1_TIM2 CLK_PCKENR1 SETBIT \ enable TIMER2 
    $68 TIM2_CCMR1 C! \ OC1M = mode 6 , OC1PE enabled  
    0 TIM2_CR1 SETBIT \  enable timer counter
    TIM2_BKR_MOE TIM2_BKR SETBIT \ enable master output  
    0 TIM2_CCER1 SETBIT \ CC1E,  enable ch1 output  
;

\ alternate tones generation 
\ u1=freq1, u2=freq2, u3=delay
: WARBLE ( u1 u2 u3 -- )
    PWM-CFG 
    >R \ put delay on R: 
BEGIN 
    DUP \ u1 u2 u2 
    256 /MOD \ u1 u2 r q 
    TIM2_ARRH C! \ u1 u2 r 
    TIM2_ARRL C! \ u1 u2 
    R@ WAIT \ u3 delay 
    OVER \ u1 u2 u1 
    256 /MOD \ u1 u2 r q 
    TIM2_ARRH C! \ u1 u2 r 
    TIM2_ARRL C! \ u1 u2 
    R@ WAIT \ u3 delay 
    KEY? \ u1 u2 flag 
UNTIL 
0   TIM2_CR1 RSTBIT   \ disable counter 
0   TIM2_CCER1 RSTBIT  \ disable OC1 
TIM2_BKR_MOE TIM2_BKR RSTBIT \ disable master output
R> KEY 2DROP 2DROP \ flush both stacks 
; 



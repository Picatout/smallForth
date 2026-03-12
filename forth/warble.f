\ USE: exist.f 

\ use TIMER2 channel 1 to generate a warble sound 

\ clock gating register 
$50C3 CONST CLK_PCKENR1 \ clock gating register 1 
0  CONST CLK_PCKENR1_TIM2 \ timer 2 gating bit 

\ PORT B registers 
$5005 CONST PB_ODR \ PB ODR register address 
$5006 CONST PB_IDR \ PB IDR register address 
$5007 CONST PB_DDR \ PB DDR register address 
$5008 CONST PB_CR1 \ PB CR1 register address 
$5009 CONST PB_CR2 \ PB CR2 register address 
\ output is on PB0 
0 CONST SPEAKER  \ autio output bit 

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
    SPEAKER PB_DDR SETBIT \ speaker pin as output 
    SPEAKER PB_CR1 SETBIT \ push pull 
    CLK_PCKENR1_TIM2 CLK_PCKENR1 SETBIT \ enable TIMER2 
    $68 TIM2_CCMR1 C! \ OC1M = mode 6 , OC1PE enabled  
    0 TIM2_CR1 SETBIT \  enable timer counter
;

\ alternate tones generation 
\ u1=freq1, u2=freq2, u3=delay
: WARBLE ( u1 u2 u3 -- )
    PWM-CFG 
    TIM2_BKR_MOE TIM2_BKR SETBIT 
    0 TIM2_CCER1 SETBIT \ CC1E,  enable ch1 output  
    >R \ put delay on R: 
BEGIN 
    DUP \ u1 u2 u2 
    256 /MOD \ u1 u2 r q 
    TIM2_ARRH C! \ u1 u2 r 
    TIM2_ARRL C! \ u1 u2 
\    0 TIM2_EGR SETBIT \ set bit UG 
    R@ WAIT \ u3 delay 
    OVER \ u1 u2 u1 
    256 /MOD \ u1 u2 r q 
    TIM2_ARRH C! \ u1 u2 r 
    TIM2_ARRL C! \ u1 u2 
\    0 TIM2_EGR SETBIT \ set bit UG 
    R@ WAIT \ u3 delay 
    KEY? \ u1 u2 flag 
UNTIL 
0   TIM2_CR1 RSTBIT   \ disable counter 
0   TIM2_CCER1 RSTBIT  \ disable OC1 
TIM2_BKR_MOE TIM2_BKR RSTBIT \ disable master output
R> KEY 2DROP 2DROP \ flush both stacks 
; 



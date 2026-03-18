\ *************************************************
\ use TIMER2 channel 1 to generate a warble sound 
\ output is on PB0 pin 12 on STM8L151K6 
\ *************************************************

\ NOTE: Must load exist.f before this one. 


DECIMAL 
FORGET PWM-CFG 

\ clock gating register 
$50C3 CONST CLK_PCKENR1 \ clock gating register 1 
0  CONST CLK_PCKENR1_TIM2 \ timer 2 gating bit 

\ needed to set PB0 in push-pull mode 
$5008 CONST PB_CR1 
0   CONST PB0 

\ TIMER2 registers 

$5250 CONST TIM2_CR1  \ control register 1 
$5259 CONST TIM2_CCMR1 \ capture|compare mode register 
$525B CONST TIM2_CCER1 \ Capture/compare enable register 1
$525F CONST TIM2_ARRH  \ auto reload register high value 
$5260 CONST TIM2_ARRL \ auto reload register low value 
$5261 CONST TIM2_CCR1H \ capture|compare register 1 high byte 
$5262 CONST TIM2_CCR1L \ capture|compare register 1 low byte 
$5258 CONST TIM2_EGR \ event generator 
$5265 CONST TIM2_BKR \ break register 
7 CONST TIM2_BKR_MOE  \ master output enable 

: PWM-CFG ( -- )
    PB0 PB_CR1 SETBIT \ PB0  push pull 
    CLK_PCKENR1_TIM2 CLK_PCKENR1 SETBIT \ enable TIMER2 
    $68 TIM2_CCMR1 C! \ OC1M = mode 6 , OC1PE enabled  
    0 TIM2_CR1 SETBIT \  enable timer counter
    TIM2_BKR_MOE TIM2_BKR SETBIT \ enable master output  
    0 TIM2_CCER1 SETBIT \ CC1E,  enable ch1 output  
;

\ set TIM2_ARR and CCR1 
: SET_PERIOD ( u -- )
    DUP DUP \ u u u 
\ set TIM2_ARR     
    8 RSHIFT \ u u hi 
    TIM2_ARRH C!  
    TIM2_ARRL C!  
\ set TIM2_CCR1   
    2/  \ u/2 
    DUP \ u/2 u/2 
    8 RSHIFT  \ u/2 hi  
    TIM2_CCR1H C! \ CCR1H = hi 
    TIM2_CCR1L C! \ CCR1H = lo 
;

\ alternate tones generation 
\ u1=16Mhz/freq1, u2=16Mhz/freq2
\ u3=delay in msec between freq. swith 
: WARBLE ( u1 u2 u3 -- )
    PWM-CFG 
    >R \ put delay on R: 
BEGIN 
    DUP \ u1 u2 u2
    SET_PERIOD 
    R@ WAIT \ u3 delay 
    OVER \ u1 u2 u1
    SET_PERIOD 
     R@ WAIT \ u3 delay 
    KEY? \ u1 u2 flag 
UNTIL 
0   TIM2_CR1 RSTBIT   \ disable counter 
0   TIM2_CCER1 RSTBIT  \ disable OC1 
TIM2_BKR_MOE TIM2_BKR RSTBIT \ disable master output
R> KEY 2DROP 2DROP \ flush both stacks 
; 



\ NOTE: Must load exist.f before this one  

\ BLINK LED CONNECTED ON PB3 
$5005 CONST PB_ODR \ PB ODR register address 
$5006 CONST PB_IDR \ PB IDR register address 
$5007 CONST PB_DDR \ PB DDR register address 
$5008 CONST PB_CR1 \ PB CR1 register address 
$5009 CONST PB_CR2 \ PB CR2 register address 
3 CONSTANT LED \ LED bit 

\ usage:  u BLINK 
\ any key to stop 
: BLINK  ( u -- ) 
LED PB_CR1 SETBIT \ push pull output 
LED PB_DDR SETBIT \ set pin as output 
BEGIN \ begin blinking loop 
    LED PB_ODR TOGLBIT \ toggle LED bit 
    DUP WAIT \ suspend execution u msec 
    KEY? \ key pressed? 
UNTIL \ loop until a key is pressed 
LED PB_ODR RSTBIT \ turn off LED 
KEY  \ remove key from queue 
2DROP ; \ drop key and delay 


   

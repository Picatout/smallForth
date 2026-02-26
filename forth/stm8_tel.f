;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; STM8_TEL 
;; Tiny Embedded Language 
;; created in smallForth 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

: BAD ABORT" BAD SYNTAX" ; 

: NUMBER TOKEN NUMBER? ~IF BAD THEN ;

: CONST NUMBER CONSTANT ; 

: VAR VARIABLE ;

: := EVAL SWAP ! ; 

\ arithmetic 

: + NUMBER NUMBER + ;

: - NUMBER NUMBER - ;

: * NUMBER NUMBER * ;

: / NUMBER NUMBER / ;

: % NUMBER NUMBER MOD ;

: REPEAT NUMBER 1- [COMPILE] FOR ; COMPILE-ONLY IMMEDIATE

: {  BEGIN ; COMPILE-ONLY IMMEDIATE 

: }  REPEAT ; COMPILE-ONLY IMMEDIATE 


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; STM8_TEL 
;; Tiny Embedded Language 
;; created in tinyForth 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

: BAD ABORT" BAD SYNTAX" ; 

: NUMBER TOKEN NUMBER? ~IF BAD THEN ;

: CONST CREATE NUMBER CP-HERE 2- F! DOES @ ; 

: VAR CREATE 0 HERE 2 ALLOT ! DOES> ;

\ arithmetic 

: + NUMBER NUMBER + ;

: - NUMBER NUMBER - ;

: * NUMBER NUMBER * ;

: / NUMBER NUMBER / ;

: % NUMBER NUMBER MOD ;

: REPEAT NUMBER 1- [COMPILE] FOR ; COMPILE-ONLY IMMEDIATE

: {  BEGIN ; COMPILE-ONLY IMMEDIATE 

: }  REPEAT ; COMPILE-ONLY IMMEDIATE 


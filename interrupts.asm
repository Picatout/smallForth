;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  interrupt routines 
;  words 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;
; Enable interrupts 
; EI ( -- )
;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER EI,2,"EI"
        rim 
        ret 
;;;;;;;;;;;;;;;;;;;;;;;;;;
; Disable interrupts
; DI ( -- )
;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER DI,2,"DI"
        sim 
        ret 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       I:  ( -- ca )
; Start interrupt service 
; routine definition
; those definition have 
; no name.
; return interrput code address 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER ICOLON,2,"I:"
        LDW     Y,UCP 
        SUBW    X,#CELLL 
        LDW     (X),Y  ; ca of interrupt 
        JP      RBRAC  

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       I; ( ca -- int-vec )
;  Terminate an ISR definition 
;  return interrupt vector as double 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
       _HEADER ISEMI,2+IMEDD+COMPO,^/"I;"/
        _DOLIT  IRET_CODE  
        CALL    CCOMMA
        CALL    CPP
        CALL    AT 
        CALL    EEPCP
        CALL    FSTOR
        SUBW    X,#CELLL  
        LDW     Y,#IRET_CODE<<8 
        ldw     (X),Y
        JP      LBRAC 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  ADR-VEC ( n -- adr )
;  return address of interrupt 
;  vector 'n' 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER ADRVEC,7,"ADR-VEC"
        LDW     Y,X
        LDW     Y,(Y)
        CPW     Y,#29  
        JRUGT   4$
        LD      A,#4 
        MUL     Y,A  
        ADDW    Y,#FLASH_BASE
        LDW     (X),Y 
        RET 
4$:      
       CALL     ABORQ
       .byte    10
       .ascii " bad vector"


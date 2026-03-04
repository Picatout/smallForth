;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  interrupt routines 
;  words 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       I:  ( n --  )
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
;       I; ( vector ca --  )
;  Terminate an ISR definition 
;  write interrupt vector  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
       _HEADER ISEMI,2+IMEDD+COMPO,^/"I;"/
        _DOLIT  IRET_CODE  
        CALL    CCOMMA
        CALL    CPP
        CALL    AT 
        CALL    EEPCP
        CALL    FSTOR
        CALL    SWAPP  ; CA VECTOR 
        CALL    VECADR 
        CALL    CELLP  
        CALL    FSTOR 
        JP      LBRAC 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; I-RST  ( n -- )
;; reset inteerupt vector to defalut 
;; value 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER IRESET,5,"I-RST" 
        CALL VECADR
        CALL CELLP 
        LDW   Y,#NotHandledInterrupt
        CALL  DPUSH
        CALL  SWAPP 
        JP    FSTOR

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  VEC-ADR ( n -- adr )
;  return address of interrupt 
;  vector 'n' 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER VECADR,7,"VEC-ADR"
        LDW     Y,X
        LDW     Y,(Y)
        CPW     Y,#29  
        JRUGT   4$
        LD      A,#4 
        MUL     Y,A  
        ADDW    Y,#VECTOR_INT0 
        LDW     (X),Y 
        RET 
4$:      
       CALL     ABORQ
       .byte    10
       .ascii " bad vector"

;------------------------------
; RST-VEC ( xt -- )
; all interrupt vector with 
; an address >= xt are resetted 
; to default
;------------------------------
VECTOR_SIZE=4 
RSTVEC:
	CALL DUPP 
        _DOLIT app_space
        CALL ULESS 
        CALL TBRAN 
        .WORD 6$ 
        CALL TOR       ; R: xt 
	_DOLIT VECTOR_INT0   
1$: ; S: va  R: xt 
	CALL DUPP  ; va va 
	CALL CELLP 
	CALL AT    ; va ia 
	CALL RAT   ; va ia xt 
	CALL ULESS 
	CALL TBRAN 
	.WORD 2$   ; keep this one 
; reset this vector -- va 
	_DOLIT NotHandledInterrupt
	CALL OVER   ; va a va 
	CALL CELLP 
	CALL FSTOR 
2$:  ; -- va  R: xt  
	_DOLIT VECTOR_SIZE  
	CALL  PLUS  ; va + 4 
	CALL DUPP   ; va va 
	_DOLIT 0x8080 ; va va 0x8080 
	CALL ULESS   
	CALL TBRAN 
	.WORD 1$ 
	CALL RFROM    ; va xt  
	_DDROP        
	RET 
6$: ; system interrupts protected 
        call ABORQ
        .byte 10
        .ascii " Protected"

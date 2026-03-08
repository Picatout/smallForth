;;;;;;;;;;;;;;;;;;;;;;
;; tools vocabulary ;;
;;;;;;;;;;;;;;;;;;;;;;

.IF 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       U.R     ( u +n -- )
;       Display an unsigned integer
;       in n column, right justified.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER UDOTR,3,"U.R"
        CALL     TOR
        CALL     BDIGS
        CALL     DIGS
        CALL     EDIGS
        CALL     RFROM
        CALL     OVER
        CALL     SUBB
        CALL     SPACS
        JP       TYPES
.ENDIF 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       _TYPE   ( b u -- )
;       Display a string. Filter
;       non-printing characters.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;        _HEADER UTYPE,5,"_TYPE"
UTYPE: 
        LDW     Y,X 
        LDW     Y,(2,Y)
1$:
        LD      A,(1,X)
        JREQ    9$ 
        LD      A,(Y)
        CP      A,#SPC 
        JRMI    2$ 
        CP      A,#127 
        JRMI    3$
2$:     LD      A,#SPC 
3$:     CALL    putc 
        INCW    Y 
        DEC     (1,X)
        JRA     1$ 
9$:     JP      DDROP 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       dm+     ( a u -- a )
;       Dump u bytes from ,
;       leaving a+u on  stack.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;        _HEADER DUMPP,3,"DM+"
DUMPP: 
        CALL     OVER
;        CALL     DOLIT
;        .word      4
        CALL     PRT_HEX_WORD ;UDOTR   ;display address
        CALL     SPACE
        CALL     TOR     ;start count down loop
        JRA     PDUM2   ;skip first pass
PDUM1:  CALL     DUPP
        CALL     CAT
        CALL     SPACE
        LD       A,(1,X)
        CALL     PRT_HEX_BYTE 
        ADDW     X,#CELLL        
        CALL     ONEP    ;increment address
PDUM2:  CALL     DONXT
        .word    PDUM1   ;loop till done
        RET

;---------------------------
; print WORD in hexadecimal 
; 4 characters wide 
; input:
;---------------------------
PRT_HEX_WORD: ; ( w -- )
        LDW Y,X 
        LDW Y,(Y)
        _DROP 
        LD A,YH 
        CALLR PRT_HEX_BYTE 
        LD A,YL 

;----------------------------
; print byte in hexadecimal  
; 2 characters wide
; input:
;    A   byte to print 
;----------------------------
PRT_HEX_BYTE:
        PUSH    A 
        SWAP    A 
        CALL    PRT_DIGIT 
        POP     A
PRT_DIGIT:
        AND      A,#0XF 
        ADD      A,#'0
        CP       A,#'9+1
        JRMI     1$ 
        ADD      A,#7 
1$:     CALL     putc 
        RET 


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       DUMP    ( a u -- )
;       Dump u bytes from a,
;       in a formatted manner.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER DUMP,4,"DUMP"
        CALL     BASE
        CALL     AT
        CALL     TOR
        CALL     HEX     ;save radix, set hex
        CALL     DOLIT
        .word      16
        CALL     SLASH   ;change count to lines
        CALL     TOR     ;start count down loop
DUMP1:  CALL     CR
        CALL     DOLIT
        .word      16
        CALL     DDUP
        CALL     DUMPP   ;display numeric
        CALL     ROT
        CALL     ROT
        CALL     SPACE
        CALL     SPACE
        CALL     UTYPE   ;display printable characters
        CALL     DONXT
        .word      DUMP1   ;loop till done
DUMP3:  _DROP
        CALL     RFROM
        CALL     BASE
        JP     STORE   ;restore radix

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       PICK    ( ... +n -- ... w )
;       Copy  nth stack item to tos.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER PICK,4,"PICK"
        LDW Y,X   ;D = n1
        LDW Y,(Y)
; modified for standard compliance          
; 0 PICK must be equivalent to DUP 
        INCW Y 
        SLAW Y
        PUSHW X 
        ADDW Y,(1,SP)
        LDW Y,(Y)
        LDW (X),Y
        ADDW  SP,#2 
        RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       .S      ( ... -- ... )
;        Display  contents of stack.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER DOTS,2,".S"
        CALL     CR
        CALL     DEPTH   ;stack depth
        CALL     TOR     ;start count down loop
        JRA     DOTS2   ;skip first pass
DOTS1:  CALL     RAT
	CALL     PICK
        CALL     DOT     ;index stack, display contents
DOTS2:  CALL     DONXT
        .word      DOTS1   ;loop till done
        CALL     DOTQP
        .byte      5
        .ascii     " <sp "
        RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       WORDS   ( -- )
;       Display names in vocabulary.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER WORDS,5,"WORDS"
NA=1 ; name field
LLEN=3 ; line length
SLEN=4 ; string length 
WC=5
VSIZE=5   
        SUB     SP,#VSIZE
        CLR     (WC,SP)
        LDW     Y,UCNTXT 
0$: 
        CLR     (LLEN,SP)  
        CALL    CR  
1$:     LDW     (NA,SP),Y 
        LD      A,(Y)
        AND     A,#0X1F
        LD      (SLEN,SP),A 
        INC     A 
        ADD     A,(LLEN,SP) 
        CP      A,#78 
        JRPL    0$
        LD      (LLEN,SP),A   
        INCW    Y  
        LD      A,(SLEN,SP)
        CALL    PRINT
        LD      A,#SPC 
        CALL    putc  
        INC     (WC,SP)
        LDW     Y,(NA,SP)
        SUBW    Y,#2
        LDW     Y,(Y)
        JRNE     1$
;display words count 
        CALL    CR
        LD      A,(WC,SP)
        CLRW    Y
        LD      YL,A  
        CALL    DPUSH 
        CALL    DOT 
        ADDW     SP,#VSIZE 
        RET  

;------------------------
; .ID 
; print name in 
; dictionary name field 
;------------------------
DOTID: ; ( adr -- )
        CALL COUNT 
        _DOLIT 0X1F 
        CALL ANDD  
        CALL TYPES 
        RET 

;------------------------
; print code address 
;------------------------
PRT_ADR: ; ( adr -- adr )
        CALL DUPP 
;        CALL HDOT 
        CALL PRT_HEX_WORD  
        _DOLIT 2 
        CALL SPACS
        RET 

        _DOLIT 2 
        CALL SPACS 
        CALL DOTQP
        .BYTE 3 
        .ASCII "JP " 

;-------------------------------
; print CALL or JP target 
; name or address 
;-------------------------------
PRT_TARGET: 
        CALL DUPP     ; -- xt xt 
        CALL ONEP     ; -- xt xt+1 
        CALL AT       ; -- xt target   
        CALL TNAME    ; -- xt nf | 0 
        CALL QDUP
        CALL QBRAN 
        .WORD NO_NAME 
        CALL DOTID    ; -- xt 
        _DOLIT 3     ;  -- xt 3  
        CALL PLUS    ; -- xt+3     
        RET 
NO_NAME:
        CALL ONEP      ; -- xt+1 
        CALL DUPP      ; -- a a 
        CALL AT        ; -- a trgt 
        CALL PRT_HEX_WORD      ; -- a 
        CALL CELLP     ; -- xt+2 
        RET         

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; SEE word 
;; decompile dictionary WORD 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER SEE,3,"SEE"
        CALL CR 
        CALL TICK  ; -- xt 
        CALL DUPP  ; -- xt xt  
        CALL TNAME ; -- xt nf 
        CALL DUPP  ; -- xt nf nf
        CALL CELLM ; -- xt nf lnk 
        CALL PRT_HEX_WORD  
        _DOLIT 2 
        CALL SPACS 
        CALL DOTID ; -- xt 
SEE1: ; -- xt 
        CALL CR
        CALL PRT_ADR    
        CALL DUPP   ; -- xt xt 
        CALL CAT    ; -- xt c 
        _DOLIT 0XCD 
        CALL EQUAL 
        CALL QBRAN 
        .WORD NOT_CALL 
        CALL DOTQP
        .BYTE 5 
        .ASCII "CALL " 
        CALL PRT_TARGET 
        JRA SEE1         
NOT_CALL:
        CALL DUPP 
        CALL CAT
        _DOLIT JPIMM 
        CALL EQUAL 
        CALL QBRAN 
        .WORD NOT_JUMP 
        CALL DOTQP
        .BYTE 3 
        .ASCII "JP " 
        CALL PRT_TARGET 
        JRA SEE1 
NOT_JUMP:  
        CALL DUPP
        CALL CAT 
        _DOLIT RET_CODE 
        CALL EQUAL 
        CALL QBRAN 
        .WORD SEE9 
        _DROP 
        CALL DOTQP 
        .BYTE 3 
        .ASCII "RET"
        RET 
SEE9:   
        CALL DOTQP 
        .BYTE 6 
        .ASCII ".BYTE "
        CALL DUPP 
        CALL CAT 
        LD A,(1,X)
        _DROP 
        CALL PRT_HEX_BYTE 
        CALL ONEP 
        JP SEE1  

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; R.  ( -- )
;; print return stack 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER RDOT,2,"R."
        CALL CR
        CALL RPAT
        CALL CELLP
        _DOLIT RAM_END   
1$:
        CALL DDUP 
        CALL EQUAL     
        CALL TBRAN 
        .WORD 9$ 
        CALL DUPP
        CALL ONEM

        CALL AT 
        CALL PRT_HEX_WORD 
        CALL SPACE 
        CALL CELLM   
        JRA 1$
9$:     CALL DOTQP
        .BYTE 4
        .ASCII " <R "
        _DROP 
        CALL PRT_HEX_WORD 
        CALL CR 
        RET 

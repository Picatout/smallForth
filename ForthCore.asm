;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Copyright Jacques Deschênes 2019,2020,2021,2026 
;; This file is part of stm8_tinyForth  
;;
;;     stm8_tinyForth is free software: you can redistribute it and/or modify
;;     it under the terms of the GNU General Public License as published by
;;     the Free Software Foundation, either version 3 of the License, or
;;     (at your option) any later version.
;;
;;     stm8_tinyForth is distributed in the hope that it will be useful,
;;     but WITHOUT ANY WARRANTY;; without even the implied warranty of
;;     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;     GNU General Public License for more details.
;;
;;     You should have received a copy of the GNU General Public License
;;     along with stm8_tinyForth.  If not, see <http:;;www.gnu.org/licenses/>.
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;-------------------------------------------------------------
;  Strip down version of stm8_eForth wich take origin from
;  eForth for STM8S C. H. Ting source file and  
;  adpated to assemble using sdasstm8
;  implemented on stm8l151k6
;  picatout 2026/01/17
; 
;  NOTES: 
;  New definition is compiled in RAM then copied to FLASH 
;  memory if there is not compilation error.
;--------------------------------------------------------------
	.module SMALLFORTH
         .optsdcc -mstm8
        .include "inc/config.inc"

;===============================================================
;  Adaption to NUCLEO-8S208RB by Picatout
;  Date: 2020-06-07 
;       Suite aux nombreux changement remplacé le numéro de version pour 3.0
;  Date: 2019-10-26
;================================================================
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   Original comment from C. H. Ting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       STM8EF, Version 2.1, 13 July
;               Implemented on STM8S-Discovery Board.
;               Assembled by ST VisualDevelop STVD 
;               Bootup on internal 2 MHz clock
;               Switch to external 16 MHz crystal clock
;
; FORTH Virtual Machine:
; Subroutine threaded model
; SP Return stack pointer
; X Data stack pointer
; A,Y Scratch pad registers
;
; Memory Map:
; 0x0 RAM memory, system variables
; 0x80 Start of user defined words, linked to ROM dictionary
; 0x780 Data stack, growing downward
; 0x790 Terminal input buffer TIB
; 0x7FF Return stack, growing downward
; 0x8000 Interrupt vector table
; 0x8080 FORTH startup code
; 0x80E7 Start of FORTH dictionary in ROM
; 0x9584 End of FORTH dictionary
;
;       2020-04-26 Addapted for NUCLEO-8S208RB by Picatout 
;                  use UART1 instead of UART2 for communication with user.
;                  UART1 is available as ttyACM* device via USB connection.
;                  Use TIMER4 for millisecond interrupt to support MS counter 
;                  and MSEC word that return MS value.
;
;       EF12, Version 2.1, 18apr00cht
;               move to 8000H replacing WHYP.
;               copy interrupt vectors from WHYPFLSH.S19
;               to EF12.S19 before flashing
;               add TICKS1 and DELAY1 for motor stepping
;
;       EF12, 02/18/00, C. H. TingCOLD1,
;       Adapt 86eForth v2.02 to 68HC12.
;               Use WHYP to seed EF12.ASM
;               Use AS12 native 68HC12 assembler:
;               as12 ef12.asm >ef12.lst
;       EF12A, add ADC code, 02mar00cht
;       EF12B, 01mar00cht
;               stack to 0x78, return stack to 0xf8.
;               add all port definitions
;               add PWM registers
;               add SPI registers and code
;       EF12C, 12mar00cht
;               add MAX5250 D/A converter
;       EF12D, 15mar00cht
;               add all the Lexel interface words
;       EF12E, 18apr00cht, save for reference
;
;       Copyright (c) 2000
;       Dr. C. H. Ting
;       156 14th Avenue
;       San Mateo, CA 94402
;       (650) 571-7639
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

      
;*********************************************************
;	Assembler constants
;*********************************************************

;; Memory allocation
UPP     =     RAMBASE+6          ; systeme variables base address 
SPP     =     RAMBASE+DATSTK     ; data stack bottom 
RPP     =     RAMBASE+STACK      ;  return stack bottom
TIBB    =     RAMBASE+TIBBASE    ; transaction input buffer
VAR_BASE =    RAMBASE+128        ; user variables start here .

; user variables constants 
UBASE = UPP       ; numeric base 
UTMP = UBASE+2    ; temporary storage
UINN = UTMP+2     ; >IN tib pointer 
UCTIB = UINN+2    ; tib count 
UTIB = UCTIB+2    ; tib address 
UINTER = UTIB+2   ; interpreter vector 
UHLD = UINTER+2   ; hold 
UCNTXT = UHLD+2   ; context, dictionary first link 
UVP = UCNTXT+2    ; variable pointer in RAM 
UCP = UVP+2       ; code pointer in FLASH 
ULAST = UCP+2     ; last dictionary pointer 
USTATE = ULAST+2  ; compile or interpret state flag 
UNEST = USTATE+2  ; EVAL nesting level 

;******  System Variables  ******
;XTEMP = UNEST + 2 ; temporary storage  
YTEMP = UNEST+2  ; temporary storage 
SP0  = YTEMP+2	 ;initial data stack pointer
RP0  =  SP0+2	 ;initial return stack pointer
MS   =   RP0+2   ; millisecond counter 
SEEDY = MS+2 ; PRNG seed 
RX_QUEUE = SEEDY+2 ; UART receive circular queue. 
RX_HEAD = RX_QUEUE+RX_QUEUE_SIZE ;  
RX_TAIL = RX_HEAD+1 

; system variables saved in EEPROM when updated   
EEP_CNTXT= EEPROM_BASE  ; value of UCNTXT  
EEP_VP = EEP_CNTXT+2      ; value of UVP  
EEP_CP = EEP_VP+2     ; value UCP  
EEP_RUN = EEP_CP+2   ; application autorun Code Addr  


;***********************************************
;; Version control
;***********************************************
VER     =  1         ;major release version
MINOR   =  0         ;minor revision

;; Constants

TRUEE   =     0xFFFF      ;true flag

COMPO   =     0x40     ;lexicon compile only bit
IMEDD   =     0x80     ;lexicon immediate bit
MASKK   =     0x1F7F  ;lexicon bit mask

CELLL   =     2       ;size of a cell
DBL_SIZE =    2*CELLL ; size of double integer 
BASEE   =     10      ;default radix
BKSPP   =     8       ;back space
LF      =     10      ;line feed
CRR     =     13      ;carriage return
CTRL_C  =     3       ; stop porgram hotkey 
CTRL_X  =     24      ; reboot hotkey 
ERR     =     27      ;error escape
SPC     =     32      ; space 
TIC     =     39      ;tick
CALLL   =     0xCD     ;CALL opcode
IRET_CODE =   0x82    ; IRET opcode 
ADDWX   =     0x1C    ; opcode for ADDW X,#word  
JPIMM   =     0xCC    ; JP addr opcode 
RET_CODE =    0x81    ; exit subroutine 


; COLD initialize these variables.
UZERO:
        .word      BASEE   ;UBASE
        .word      0       ;UTMP 
        .word      0       ;UINN
        .word      0       ;UCTIB
        .word      TIBB    ;UTIB
        .word      INTER   ;UINTER 
        .word      0       ;UHLD
        .word      LASTN   ;UCNTXT pointer
        .word      VAR_BASE ;UVP variables free space pointer 
        .word      app_space ;UCP FLASH free space pointer 
        .word      LASTN   ;ULAST
        .word      0       ;USTATE 
        .word      0       ;UNEST  
UEND:   .word      0

        LINK = 0  ; used by _HEADER macro 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; AUTORUN <name> 
; sélectionne l'application 
; qui démarre automatique lors 
; d'un COLD start 
; AUTORUN app_name 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER AUTORUN,7,"AUTORUN"
        CALL    TICK  
        JP      UPDATRUN 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; FORGET  <name>
;; Reset dictionary pointer before 
;; forgotten word. RAM space and 
;; interrupt vector defined after 
;; must be resetted also.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER FORGET,6,"FORGET"
        CALL  TICK  
        CALL    DUPP 
        CALL    RSTVEC 
        CALL    TNAME  ; na 
; reset UCP, CNTXT and LAST to word before this one 
        CALL DUPP  ; na na 
        CALL CELLM ; na link  
        CALL DUPP  ; na link link   
        CALL CPP   ; na link link cp 
        CALL STORE ; na link   now UCP point to first deleted word link 
        CALL AT    ; na prev_na
        CALL DUPP  ; na prev_na prev_na   
        CALL CNTXT ; na prev_na prev_na cntxt  
        CALL STORE ; na prev_na 
        CALL LAST  ; na prev_na last 
        CALL STORE ; na 
; follow LINK chain from 'na' back to app_space 
; if code at ca is CALL DOVAR  
; reset HERE to pfa value 
FORGET1: 
        CALL DUPP  ; na na 
        _DOLIT app_space  
        CALL UGREAT  ; na > app_space?
        CALL QBRAN 
        .WORD FORGET4  ; no then done 
        CALL DUPP   ; na na 
        CALL NAMET  ; na ca  
        CALL ONEP   ; skip over CALL  
        CALL DUPP   
        CALL AT     ; get routine address 
        _DOLIT DOVAR
        CALL EQUAL    ; adr = DOVAR ?
        CALL QBRAN     
        .WORD FORGET2  ; not a VARIABLE  
;reset HERE 
        CALL CELLP 
        CALL AT 
        CALL VPP 
        CALL STORE
        JRA  FORGET3 
FORGET2:
        _DROP 
FORGET3:         
        CALL CELLM  ; link field  
        CALL AT     ; previous word  na  
        CALL DUPP 
        CALL TBRAN 
        .WORD FORGET1 
FORGET4:
        _DROP ; na  
        CALL UPDATPTR 
        call ZERO  
        CALL UPDATRUN  
        RET         


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;    SEED ( n -- )
; Initialize PRNG seed with n 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER SEED,4,"SEED"
        LDW     Y,X 
        _DROP 
        LDW     Y,(Y)
        LDW     SEEDY,Y 
        RET 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;    RAND ( u1 -- u2 )
; Pseudo random number betwen 0 and u1-1
;  XOR16 algorithm 
;  SY ^= SY<<7 
;  SY ^= SY>>9
;  SY ^= SY<<8 
;  u2 = SY%u1 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER RANDOM,4,"RAND"
        _ldyz  SEEDY 
        LD   A,#7 
1$:
        SLLW  Y 
        DEC A 
        JRNE 1$
        CALL  XORW_Y
        _stryz SEEDY 
        LD A,#9 
2$:     SRLW Y 
        DEC A 
        JRNE 2$ 
        CALL XORW_Y
        _stryz SEEDY 
        LD A,#8 
3$:     SLLW Y 
        DEC A 
        JRNE 3$ 
        CALL XORW_Y 
        _stryz SEEDY 
        LDW Y,X 
        LDW Y,(Y)
        PUSHW X 
        _ldxz SEEDY 
        DIVW X,Y 
        POPW X 
        LDW (X),Y 
        RET  

;----------------------------
;  XOR Y WITH SEEDY 
;----------------------------
XORW_Y: 
        LD A,YL 
        XOR A,SEEDY+1 
        LD YL,A 
        LD A,YH 
        XOR A,SEEDY 
        LD  YH,A 
        RET 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; TIMER ( -- u )
;; get millisecond counter 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER TIMER,5,"TIMER"
        ldw y,MS 
DPUSH: ; push Y on parameter stack 
        subw x,#CELLL 
        ldw (x),y 
        ret 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  TMR-RST ( -- )
;; Reset to 0 MS variable 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER TMR_RST,7,"TMR-RST"
        SIM
        CLR     MS+1
        CLR     MS 
        RIM 
        RET 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  WAIT ( u -- )
; suspend execution for u msec 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER WAIT,4,"WAIT"
        LDW     Y,X 
        LDW     Y,(Y)
        _DROP  
        CALL    TMR_RST 
1$:     WFI 
        CPW     Y,MS   
        JRPL    1$  
        RET 

;;;;;;;;;;;;;;;;;;;;;
; reboot MCU 
; REBOOT ( -- )
;;;;;;;;;;;;;;;;;;;;;
;        _HEADER reboot,6,"REBOOT"
reboot:
        clr FLASH_IAPSR 
        _swreset

;;;;;;;;;;;;;;;
;; The kernel
;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       doLIT   ( -- w )
;       Push an inline literal.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DOLIT:
	SUBW X,#CELLL
        ldw y,(1,sp)
        ldw y,(y)
        ldw (x),y
        popw y 
        jp (2,y)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       NEXT    ( -- )
;       Code for  single index loop.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER DONXT,COMPO+4,"NEXT"
	LDW Y,(3,SP)
	DECW Y
	JRPL NEX1 ; jump if N=0
	POPW Y
        addw sp,#2
        JP (2,Y)
NEX1:
        LDW (3,SP),Y
        POPW Y
	LDW Y,(Y)
	JP (Y)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       ?branch ( f -- )
;       Branch if flag is zero.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       _HEADER QBRAN,COMPO+7,"?BRANCH"        
QBRAN:	
        LDW Y,X
	_DROP 
	LDW Y,(Y)
        JREQ     BRAN
	POPW Y
	JP (2,Y)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  TBRANCH ( f -- )
;  branch if f==TRUE 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;        _HEADER TBRAN,COMPO+7,"TBRANCH"
TBRAN: 
        LDW Y,X 
        _DROP  
        LDW Y,(Y)
        JRNE BRAN 
        POPW Y 
        JP (2,Y)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       BRANCH  ( -- )
;       Branch to an inline address.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       _HEADER BRAN,COMPO+6,"BRANCH"
BRAN:
        POPW Y
	LDW Y,(Y)
        JP  (Y)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       EXECUTE ( ca -- )
;       Execute  word at ca.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER EXECU,7,"EXECUTE"
        LDW Y,X
	_DROP 
	LDW  Y,(Y)
        JP   (Y)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       !       ( w a -- )
;       Pop  data stack to memory.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER STORE,1,"!"
        LDW Y,X
        LDW Y,(Y)    ;Y=a
        PUSHW X
        LDW X,(2,X) ; x=w 
        LDW (Y),X 
        POPW X  
        _DDROP 
        RET     

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       @       ( a -- w )
;       Push memory location to stack.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER AT,1,"@"
        LDW Y,X     ;Y = a
        LDW Y,(Y)   ; address 
        LDW Y,(Y)   ; value 
        LDW (X),Y ;w = @Y
        RET     

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       C!      ( c b -- )
;       Pop  data stack to byte memory.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER CSTOR,2,"C!"
        LDW Y,X
	LDW Y,(Y)    ;Y=b
        LD A,(3,X)    ;D = c
        LD  (Y),A     ;store c at b
	ADDW X,#4 ; DDROP 
        RET     

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       C@      ( b -- c )
;       Push byte in memory to  stack.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER CAT,2,"C@"
        LDW Y,X     ;Y=b
        LDW Y,(Y)
        LD A,(Y)
        LD (1,X),A
        CLR (X)
        RET     

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       RP@     ( -- a )
;       Push current RP to data stack.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER RPAT,3,"RP@"
        LDW Y,SP    ;save return addr
        JP      DPUSH 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       RP!     ( a -- )
;       Set  return stack pointer.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER RPSTO,COMPO+3,"RP!"
        POPW Y
        LDW YTEMP,Y
        LDW Y,X
        LDW Y,(Y)
        LDW SP,Y
        _DROP 
        JP [YTEMP]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       R>      ( -- w )
;       Pop return stack to data stack.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER RFROM,2,"R>"
        SUBW X,#CELLL 
        LDW Y,(3,SP)
        LDW (X),Y 
        POPW Y 
        ADDW SP,#2 
        JP (Y)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       R@      ( -- w )
;       Copy top of return stack to stack.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER RAT,2,"R@"
        ldw y,(3,sp)
        JP      DPUSH 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       >R      ( w -- )
;       Push data stack to return stack.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER TOR,COMPO+2,">R"
        LDW Y,(1,SP)
        PUSHW Y 
        LDW Y,X 
        LDW Y,(Y)
        LDW (3,SP),Y 
        _DROP 
        RET  

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       SP@     ( -- a )
;       Push current stack pointer.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER SPAT,3,"SP@"
	LDW Y,X
        JP      DPUSH 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       SP!     ( a -- )
;       Set  data stack pointer.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER SPSTO,3,"SP!"
        LDW     X,(X)     ;X = a
        RET     

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       DROP    ( w -- )
;       Discard top stack item.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER DROP,4,"DROP"
        INCW X 
        INCW X      
        RET     

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       DUP     ( w -- w w )
;       Duplicate  top stack item.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER DUPP,3,"DUP"
	LDW Y,X
	LDW Y,(Y)
        JP      DPUSH 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       SWAP    ( w1 w2 -- w2 w1 )
;       Exchange top two stack items.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER SWAPP,4,"SWAP"
        LDW Y,X
        LDW Y,(Y)
        PUSHW Y  
        LDW Y,X
        LDW Y,(2,Y)
        LDW (X),Y
        POPW Y 
        LDW (2,X),Y
        RET     

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       OVER    ( w1 w2 -- w1 w2 w1 )
;       Copy second stack item to top.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER OVER,4,"OVER"
        LDW Y,X 
        LDW Y,(2,Y)
        JP  DPUSH 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       AND     ( w w -- w )
;       Bitwise AND.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER ANDD,3,"AND"
        LD  A,(X)    ;D=w
        AND A,(2,X)
        LD (2,X),A
        LD A,(1,X)
        AND A,(3,X)
        LD (3,X),A
        _DROP 
        RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       OR      ( w w -- w )
;       Bitwise inclusive OR.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER ORR,2,"OR"
        LD A,(X)    ;D=w
        OR A,(2,X)
        LD (2,X),A
        LD A,(1,X)
        OR A,(3,X)
        LD (3,X),A
        _DROP 
        RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       XOR     ( w w -- w )
;       Bitwise exclusive OR.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER XORR,3,"XOR"
        LD A,(X)    ;D=w
        XOR A,(2,X)
        LD (2,X),A
        LD A,(1,X)
        XOR A,(3,X)
        LD (3,X),A
        _DROP 
        RET

;; System and user variables

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       BASE    ( -- a )
;       Radix base for numeric I/O.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER BASE,4,"BASE"
	LDW Y,#UBASE 
	JP  DPUSH 

.IF 1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       TMP     ( -- a )
;       A temporary storage.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER TEMP,3,"TMP"
	LDW Y,#UTMP
        JP  DPUSH 
.ENDIF 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       >IN     ( -- a )
;        Hold parsing pointer.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER INN,3,">IN"
	LDW Y,#UINN 
        JP      DPUSH

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       #TIB    ( -- a )
;       Count in terminal input 
;       buffer.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER NTIB,4,"#TIB"
	LDW Y,#UCTIB 
        JP      DPUSH 

; systeme variable 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       'EVAL   ( -- a )
;       Execution vector of EVAL.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER TEVAL,5,"'EVAL"
	LDW Y,#UINTER 
        JP      DPUSH 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       HLD     ( -- a )
;       Hold a pointer of output
;        string.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER HLD,3,"HLD"
	LDW Y,#UHLD 
        JP      DPUSH 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       CONTEXT ( -- a )
;       Start vocabulary search.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER CNTXT,7,"CONTEXT"
	LDW Y,#UCNTXT
        JP      DPUSH 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       VP      ( -- a )
;       Point to top of variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER VPP,2,"VP"
	LDW Y,#UVP 
        JP      DPUSH 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       CP    ( -- a )
;       Pointer to top of FLASH 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER CPP,2,"CP"
        ldw y,#UCP 
        JP      DPUSH 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       LAST    ( -- a )
;       Point to last name in 
;       dictionary.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER LAST,4,"LAST"
	LDW Y,#ULAST 
        JP      DPUSH 

;; Common functions

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       ?DUP    ( w -- w w | 0 )
;       Dup tos if its is not zero.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER QDUP,4,"?DUP"
        LDW Y,X
	LDW Y,(Y)
        JREQ     QDUP1
        JP      DPUSH 
QDUP1:  RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       ROT     ( w1 w2 w3 -- w2 w3 w1 )
;       Rot 3rd item to top.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER ROT,3,"ROT"
        ldw y,x 
        ldw y,(y)
        pushw y 
        ldw y,x 
        ldw y,(4,y)
        ldw (x),y 
        ldw y,x 
        ldw y,(2,y)
        ldw (4,x),y 
        popw y 
        ldw (2,x),y
        ret 

.IF 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;    <ROT ( n1 n2 n3 -- n3 n1 n2 )
;    rotate left 3 top elements 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    _HEADER NROT,4,"<ROT"
    LDW Y,X 
    LDW Y,(Y)
    PUSHW Y ; n3 >R 
    LDW Y,X 
    LDW Y,(2,Y) ; Y = n2 
    LDW (X),Y   ; TOS = n2 
    LDW Y,X    
    LDW Y,(4,Y) ; Y = n1 
    LDW (2,X),Y ;   = n1 
    POPW Y  ; R> Y 
    LDW (4,X),Y ; = n3 
    RET 
.ENDIF 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       2DROP   ( w w -- )
;       Drop 2 cells 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER DDROP,5,"2DROP"
        ADDW X,#2*CELLL 
        RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       2DUP    ( w1 w2 -- w1 w2 w1 w2 )
;       Duplicate top two cells.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER DDUP,4,"2DUP"
        LDW     Y,X 
        LDW     Y,(2,Y)
        CALL    DPUSH 
        LDW     Y,X 
        LDW     Y,(2,Y)
        JP      DPUSH 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       +       ( n1 n2 -- sum )
;       Add top two items.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER PLUS,1,"+"
        LDW Y,X
        LDW Y,(Y)
        PUSHW Y      ; R: n2 
        _DROP        ; -- n1 
        LDW Y,X
        LDW Y,(Y)
        ADDW Y,(1,SP)  ; n1+n2  
        ADDW SP,#CELLL ; R: -- 
        LDW  (X),Y     ; -- sum 
        RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       NOT     ( w -- w )
;       One's complement.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER INVER,3,"NOT"
        LDW Y,X
        LDW Y,(Y)
        CPLW Y
        LDW (X),Y
        RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       NEGATE  ( n -- -n )
;       Two's complement
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER NEGAT,6,"NEGATE"
        LDW Y,X
        LDW Y,(Y)
        NEGW Y
        LDW (X),Y
        RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       -       ( n1 n2 -- n1-n2 )
;       Subtraction.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER SUBB,1,"-"
        LDW Y,X
        LDW Y,(Y) ; n2 
        PUSHW Y   ; R: -- n2 
        _DROP     ; -- n1 
        LDW Y,X
        LDW Y,(Y) ; n1 
        SUBW Y,(1,SP) ; n1-n2 
        LDW (X),Y     ; -- diff 
        ADDW SP,#CELLL ; R: -- 
        RET

.IF 1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       ABS     ( n -- n )
;       Return  absolute value of n.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER ABSS,3,"ABS"
        LDW Y,X
	LDW Y,(Y)
        JRPL     AB1     ;negate:
        NEGW     Y     ;else negate hi byte
        LDW (X),Y
AB1:    RET
.ENDIF 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       0<      ( n -- t )
;       Return true if n is negative.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER ZLESS,2,"0<"
        LD A,#0xFF
        LDW Y,X
        LDW Y,(Y)
        JRMI     ZL1
        CLR A   ;false
ZL1:    LD     (X),A
        LD (1,X),A
	RET     

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       0= ( n -- f )
;   n==0?
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER ZEQUAL,2,"0="
        LD A,#0XFF 
        LDW Y,X 
        LDW Y,(Y)
        JREQ ZEQU1 
        CPL  A  
ZEQU1:  
        LD (X),A 
        LD (1,X),A         
        RET 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       =       ( w w -- t )
;       Return true if top two are equal.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER EQUAL,1,"="
        LD A,#0xFF  ;true
        LDW Y,X    
        LDW Y,(Y)   ; n2 
        _DROP 
        CPW Y,(X)   ; n1==n2
        JREQ EQ1 
        CLR A 
EQ1:    LD (X),A
        LD (1,X),A
	RET     

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       U<      ( u1 u2 -- f )
;       Unsigned compare of top two items.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER ULESS,2,"U<"
        LD A,#0xFF  ;true
        LDW Y,X    
        LDW Y,(2,Y) ; u1 
        CPW Y,(X)   ; cpw u1  u2 
        JRULT     ULES1
        CLR A
ULES1:  _DROP 
        LD (X),A
        LD (1,X),A
	RET     


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       <       ( n1 n2 -- t )
;       Signed compare of top two items.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER LESS,1,"<"
        LD A,#0xFF  ;true
        LDW Y,X    
        LDW Y,(2,Y)  ; n1 
        CPW Y,(X)  ; n1 < n2 ? 
        JRSLT     LT1
        CLR A
LT1:    _DROP 
        LD (X),A
        LD (1,X),A
	RET     

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   U> ( u1 u2 -- f )
;   f = true if u1>u2 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER UGREAT,2,"U>"
        LD A,#255  
        LDW Y,X 
        LDW Y,(2,Y)  ; u1 
        CPW Y,(X)  ; u1 > u2 
        JRUGT UGREAT1 
        CLR A   
UGREAT1:
        _DROP 
        LD (X),A 
        LD (1,X),A 
        RET 

.IF 1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       >   (n1 n2 -- f )
;  signed compare n1 n2 
;  true if n1 > n2 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER GREAT,1,">"
        LD A,#0xFF ;
        LDW Y,X 
        LDW Y,(2,Y)  ; n1 
        CPW Y,(X) ; n1 > n2 ?  
        JRSGT GREAT1 
        CLR  A
GREAT1:
        _DROP 
        LD (X),A 
        LD (1,X),A 
        RET 
.ENDIF 

.IF 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       MAX     ( n n -- n )
;       Return greater of two top items.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER MAX,3,"MAX"
        LDW Y,X    
        LDW Y,(Y) ; n2 
        CPW Y,(2,X)   
        JRSLT  MAX1
        LDW (2,X),Y
MAX1:   _DROP 
	RET     

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       MIN     ( n n -- n )
;       Return smaller of top two items.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER MIN,3,"MIN"
        LDW Y,X    
        LDW Y,(Y)  ; n2 
        CPW Y,(2,X) 
        JRSGT MIN1
        LDW (2,X),Y
MIN1:	_DROP 
	RET     
.ENDIF 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       WITHIN  ( u ul uh -- t )
;       Return true if u is within
;       range of ul and uh. ( ul <= u < uh )
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER WITHI,6,"WITHIN"
        CALL     OVER
        CALL     SUBB
        CALL     TOR
        CALL     SUBB
        CALL     RFROM
        JP       ULESS

;; Divide

.IF 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       UM/MOD  ( udl udh un -- ur uq )
;       Unsigned divide of a double by a
;       single. Return mod and quotient.
; 2021-02-22
; changed algorithm for Jeeek one 
; ref: https://github.com/TG9541/stm8ef/pull/406        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER UMMOD,6,"UM/MOD"
        LDW     Y,X             ; stack pointer to Y
        LDW     X,(X)           ; un
        LDW     YTEMP,X         ; save un
        LDW     X,Y
        INCW    X               ; drop un
        INCW    X
        PUSHW   X               ; save stack pointer
        LDW     X,(X)           ; X=udh
        JRNE    MMSM0
        LDW    X,(1,SP)
        LDW    X,(2,X)          ; udl 
        LDW     Y,YTEMP         ;divisor 
        DIVW    X,Y             ; udl/un 
        EXGW    X,Y 
        JRA     MMSMb 
MMSM0:    
        LDW     Y,(4,Y)         ; Y=udl (offset before drop)
        CPW     X,YTEMP
        JRULT   MMSM1           ; X is still on the R-stack
        POPW    X               ; restore stack pointer
        CLRW    Y
        LDW     (2,X),Y         ; remainder 0
        DECW    Y
        LDW     (X),Y           ; quotient max. 16 bit value
        RET
MMSM1:
        LD      A,#16           ; loop count
        SLLW    Y               ; udl shift udl into udh
MMSM3:
        RLCW    X               ; rotate udl bit into uhdh (= remainder)
        JRC     MMSMa           ; if carry out of rotate
        CPW     X,YTEMP         ; compare udh to un
        JRULT   MMSM4           ; can't subtract
MMSMa:
        SUBW    X,YTEMP         ; can subtract
        RCF
MMSM4:
        CCF                     ; quotient bit
        RLCW    Y               ; rotate into quotient, rotate out udl
        DEC     A               ; repeat
        JRNE    MMSM3           ; if A == 0
MMSMb:
        LDW     YTEMP,X         ; done, save remainder
        POPW    X               ; restore stack pointer
        LDW     (X),Y           ; save quotient
        LDW     Y,YTEMP         ; remainder onto stack
        LDW     (2,X),Y
        RET
.ENDIF 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   U/MOD ( u1 u2 -- ur uq )
;   unsigned divide u1/u2 
;   return remainder and quotient 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER USLMOD,5,"U/MOD"
        LDW Y,X 
        LDW Y,(Y)  ; dividend 
        PUSHW X    ; DP >R 
        LDW X,(2,X) ; divisor 
        DIVW X,Y 
        PUSHW X     ; quotient 
        LDW X,(3,SP) ; DP 
        LDW (2,X),Y ; remainder 
        LDW Y,(1,SP) ; quotient 
        LDW (X),Y 
        ADDW SP,#2*CELLL ; drop quotient and DP from rstack 
        RET 

.IF 0 ;******************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
;       M/MOD   ( d n -- r q )
;       Signed floored divide of double by
;       single. Return mod and quotient.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER MSMOD,5,"M/MOD"
        CALL	DUPP
        CALL	ZLESS
        CALL	DUPP
        CALL	TOR
        CALL	QBRAN
        .word	MMOD1
        CALL	NEGAT
        CALL	TOR
        CALL	DNEGA
        CALL	RFROM
MMOD1:	CALL	TOR
        CALL	DUPP
        CALL	ZLESS
        CALL	QBRAN
        .word	MMOD2
        CALL	RAT
        CALL	PLUS
MMOD2:	CALL	RFROM
        CALL	UMMOD
        CALL	RFROM
        CALL	QBRAN
        .word	MMOD3
        CALL	SWAPP
        CALL	NEGAT
        JP	SWAPP
MMOD3:	RET
.ENDIF ;********************

.IF 1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       /MOD    ( n1 n2 -- r q )
; Signed divide n1/n2. 
; Return mod and quotient.
; quotient rounded toward zero 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER SLMOD,4,"/MOD"
        LD A,(X)
        PUSH A   ; n2 sign 
        LD A,(2,X)
        PUSH A    ; n1 sign 
        CALL ABSS 
        CALL TOR  ; R: n2sign n1sign abs(n2)
        CALL ABSS 
        CALL RAT   ; -- abs(n1) abs(n2)
        CALL USLMOD ; -- ur uq 
        LD A,(3,SP) ; n1sign 
        OR A,(4,SP) ; n1sing or n2sign 
        JRPL SLMOD8 ; both positive nothing to change 
        LD A,(3,SP)  ; dividend sign 
        XOR A,(4,SP) ; divisor  sign 
        JRPL SLMOD1  ; both same sign  
; dividend and divisor are opposite sign          
        CALL NEGAT ; negative quotient
        CALL OVER 
        CALL ZEQUAL 
        _TBRAN SLMOD8 
        ; remainder sign of dividend 
        LD A,(3,SP)
        JRPL SLMOD8 
        JRA  SLMOD2 
SLMOD1: ; n1 n2 same sign then q positive and r sign of divisor  
        LD A,(4,SP) ; divisor sign 
        JRPL SLMOD8 
SLMOD2: CALL TOR 
        CALL NEGAT ; if divisor negative negate remainder 
        CALL RFROM 
SLMOD8: 
        ADDW SP,#4 
        RET 
.ENDIF 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       MOD     ( n1 n2 -- r )
;       Signed divide. Return mod only.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER MODD,3,"MOD"
	CALL	SLMOD
	JP	DROP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       /       ( n n -- q )
;       Signed divide. Return quotient only.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER SLASH,1,"/"
        CALL	SLMOD
        CALL	SWAPP
        JP	DROP

;; Multiply

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       UM*     ( u1 u2 -- ud )
;       Unsigned multiply. Return 
;       double product.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER UMSTA,3,"UM*"
; stack have 4 bytes u1=a:b u2=c:d
        ;; bytes offset on data stack 
        u1hi=2 
        u1lo=3 
        u2hi=0 
        u2lo=1 
        ;;;;;; local variables ;;;;;;;;;
        ;; product bytes offset on return stack 
        UD1=1  ; ud bits 31..24
        UD2=2  ; ud bits 23..16
        UD3=3  ; ud bits 15..8 
        UD4=4  ; ud bits 7..0 
        ;; local variable for product set to zero   
        clrw y 
        pushw y  ; bits 15..0
        pushw y  ; bits 31..16 
        ld a,(u1lo,x) ;  
        ld yl,a 
        ld a,(u2lo,x)   ; 
        mul y,a    ; u1lo*u2lo  
        ldw (UD3,sp),y ; lowest weight product 
        ld a,(u1lo,x)
        ld yl,a 
        ld a,(u2hi,x)
        mul y,a  ; u1lo*u2hi 
        ;;; do the partial sum 
        addw y,(UD2,sp)
        clr a 
        rlc a
        ld (UD1,sp),a 
        ldw (UD2,sp),y 
        ld a,(u1hi,x)
        ld yl,a 
        ld a,(u2lo,x)
        mul y,a   ; u1hi*u2lo  
        ;; do partial sum 
        addw y,(UD2,sp)
        clr a 
        adc a,(UD1,sp)
        ld (UD1,sp),a  
        ldw (UD2,sp),y 
        ld a,(u1hi,x)
        ld yl,a 
        ld a,(u2hi,x)
        mul y,a  ;  u1hi*u2hi highest weight product 
        ;;; do partial sum 
        addw y,(UD1,sp)
        ldw (x),y  ; udh 
        ldw y,(UD3,sp)
        ldw (2,x),y  ; udl  
        addw sp,#4 ; drop local variableS 
        ret  

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       *       ( n n -- n )
;       Signed multiply. Return 
;       single product.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER STAR,1,"*"
	CALL	UMSTA
        _DROP 
        RET 

.IF 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       M*      ( n n -- d )
;       Signed multiply. Return 
;       double product.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER MSTAR,2,"M*"
        CALL	DDUP
        CALL	XORR
        CALL	ZLESS
        CALL	TOR
        CALL	ABSS
        CALL	SWAPP
        CALL	ABSS
        CALL	UMSTA
        CALL	RFROM
        CALL	QBRAN
        .word	MSTA1
        JP	DNEGA
MSTA1:	RET
.ENDIF 

.IF 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       */MOD   ( n1 n2 n3 -- r q )
;       Multiply n1 and n2, then divide
;       by n3. Return mod and quotient.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER SSMOD,5,"*/MOD"
        CALL     TOR
        CALL     MSTAR
        CALL     RFROM
        JP       MSMOD

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       */      ( n1 n2 n3 -- q )
; Multiply n1 by n2
; keep product as double 
; then divide by n3.
; Return quotient only.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER STASL,2,"*/"
        CALL	SSMOD
        CALL	SWAPP
        JP	DROP
.ENDIF 


;; Miscellaneous

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       2+   ( a -- a )
;       Add cell size in byte to address.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER CELLP,2,"2+"
        LDW Y,X
	LDW Y,(Y)
        ADDW Y,#CELLL 
        LDW (X),Y
        RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       2-   ( a -- a )
;       Subtract 2 from address.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER CELLM,2,"2-"
        LDW Y,X
	LDW Y,(Y)
        SUBW Y,#CELLL
        LDW (X),Y
        RET

.IF 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       2*   ( n -- n )
;       Multiply tos by 2.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER CELLS,2,"2*"
TWOSTAR:        
        LDW Y,X
	LDW Y,(Y)
        SLAW Y
        LDW (X),Y
        RET
.ENDIF 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       1+      ( a -- a )
;       Add cell size in byte 
;       to address.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER ONEP,2,"1+"
        LDW Y,X
	LDW Y,(Y)
        INCW Y
        LDW (X),Y
        RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       1-      ( a -- a )
;       Subtract 2 from address.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER ONEM,2,"1-"
        LDW Y,X
	LDW Y,(Y)
        DECW Y
        LDW (X),Y
        RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  shift left n times 
; LSHIFT ( n1 n2 -- n1<<n2 )
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER LSHIFT,6,"LSHIFT"
        ld a,(1,x)
        addw x,#CELLL 
        ldw y,x 
        ldw y,(y)
LSHIFT1:
        tnz a 
        jreq LSHIFT4 
        sllw y 
        dec a 
        jra LSHIFT1 
LSHIFT4:
        ldw (x),y 
        ret 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; shift right n times                 
; RSHIFT (n1 n2 -- n1>>n2 )
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER RSHIFT,6,"RSHIFT"
        ld a,(1,x)
        addw x,#CELLL 
        ldw y,x 
        ldw y,(y)
RSHIFT1:
        tnz a 
        jreq RSHIFT4 
        srlw y 
        dec a 
        jra RSHIFT1 
RSHIFT4:
        ldw (x),y 
        ret 

.IF 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       2/      ( n -- n )
;       divide  tos by 2.
;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER TWOSL,2,"2/"
        LDW Y,X
	LDW Y,(Y)
        SRAW Y
        LDW (X),Y
        RET
.ENDIF 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       BL      ( -- 32 )
;       Return 32,  blank character.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER BLANK,2,"BL"
	LDW Y,#32
        JP      DPUSH 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         0     ( -- 0)
;         Return 0.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER ZERO,1,"0"
        CLRW    Y 
        JP      DPUSH 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       DEPTH   ( -- n )
;       Return  depth of  data stack.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER DEPTH,5,"DEPTH"
        LDW Y,SP0    ;save data stack ptr
	PUSHW  X 
        SUBW Y,(1,SP)     ;#bytes = SP0 - X
        SRAW Y    ;Y = #stack items
        ADDW    SP,#2 
        JP      DPUSH 

;; Memory access

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       +!      ( n a -- )
;       Add n to  contents at 
;       address a.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER PSTOR,2,"+!"
        PUSHW X   ; R: DP 
        LDW Y,X 
        LDW X,(X) ; a 
        LDW Y,(2,Y)  ; n 
        PUSHW Y      ; R: DP n 
        LDW Y,X 
        LDW Y,(Y)
        ADDW Y,(1,SP) ; *a + n 
        LDW (X),Y 
        LDW X,(3,SP) ; DP
        ADDW X,#2*CELLL  ; ( n a -- )  
        ADDW SP,#2*CELLL ; R: DP n -- 
        RET 
                
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       COUNT   ( b -- b+ n )
;       Return count byte of a string
;       and add 1 to byte address.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER COUNT,5,"COUNT"
        ldw y,x 
        ldw y,(y) ; address 
        ld a,(y)  ; count 
        incw y 
        ldw (x),y 
        clrw  y 
        ld yl,a
        jp      DPUSH  

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       HERE    ( -- a )
;       Return  top of  variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER HERE,4,"HERE"
      	LDW     Y,UVP 
        JP      DPUSH 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; CP-HERE ( -- a)
; return code space top address 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER CPHERE,7,"CP-HERE"
        LDW     Y,UCP 
        JP      DPUSH 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       PAD     ( -- a )
;       Return address of text buffer
;       above  code dictionary.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER PAD,3,"PAD"
        CALL     HERE
        _DOLIT   80
        JP     PLUS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       TIB     ( -- a )
;       Return address of 
;       terminal input buffer.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER TIB,3,"TIB"
        LDW     Y,UTIB 
        JP      DPUSH 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       @EXECUTE        ( a -- )
;       Execute vector stored in 
;       address a.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER ATEXE,8,"@EXECUTE"
        CALL     AT
        CALL     QDUP    ;?address or zero
        CALL     QBRAN
        .word      EXE1
        CALL     EXECU   ;execute if non-zero
EXE1:   RET     ;do nothing if zero

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       CMOVE   ( b1 b2 u -- )
;       Copy u bytes from b1 to b2.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER CMOVE,5,"CMOVE"
        ;;;;  local variables ;;;;;;;
        DP = 5
        YTMP = 3 
        CNT  = 1 
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        PUSHW X  ; R: DP  
        SUB SP,#2 ; R: DP YTMP 
        LDW Y,X 
        LDW Y,(Y) ; CNT 
        PUSHW Y  ; R: DP YTMP CNT
        LDW Y,X 
        LDW Y,(2,Y) ; b2, dest 
        LDW X,(4,X) ; b1, src 
        LDW (YTMP,SP),Y 
        CPW X,(YTMP,SP) 
        JRUGT CMOV2  ; src>dest 
; src<dest copy from top to bottom
        ADDW X,(CNT,SP)
        ADDW Y,(CNT,SP)
CMOV1:  
        LDW (YTMP,SP),Y 
        LDW Y,(CNT,SP)
        JREQ CMOV3 
        DECW Y 
        LDW (CNT,SP),Y 
        LDW Y,(YTMP,SP)
        DECW X
        LD A,(X)
        DECW Y 
        LD (Y),A 
        JRA CMOV1
; src>dest copy from bottom to top   
CMOV2: 
        LDW (YTMP,SP),Y 
        LDW Y,(CNT,SP)
        JREQ CMOV3
        DECW Y 
        LDW (CNT,SP),Y 
        LDW Y,(YTMP,SP)
        LD A,(X)
        INCW X 
        LD (Y),A 
        INCW Y 
        JRA CMOV2 
CMOV3:
        LDW X,(DP,SP)
        ADDW X,#3*CELLL 
        ADDW SP,#3*CELLL 
        RET 
        
.IF 0 ;**************************

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       FILL    ( b u c -- )
;       Fill u bytes of character c
;       to area beginning at b.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER FILL,4,"FILL"
        LD A,(1,X)
        LDW Y,X 
        ADDW X,#3*CELLL 
        PUSHW X ; R: DP 
        LDW X,Y 
        LDW X,(4,X) ; b
        LDW Y,(2,Y) ; u
FILL0:
        JREQ FILL1
        LD (X),A 
        INCW X 
        DECW Y 
        JRA FILL0         
FILL1: POPW X 
        RET         

.ENDIF ;*************************

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       PACK0   ( b u a -- a )
;       Build a counted string with
;       u characters from b. Null fill.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;        _HEADER PACKS,5,"PACK0"
PACKS:
        CALL     DUPP
        CALL     TOR     ;strings only on cell boundary
        CALL     DDUP
        CALL     CSTOR
        CALL     ONEP ;save count
        CALL     SWAPP
        CALL     CMOVE 
        CALL     RFROM
        RET

;; Numeric output, single precision

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       DIGIT   ( u -- c )
;       Convert digit u to a character.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER DIGIT,5,"DIGIT"
        LD      A,(1,X)
        CP      A,#10 
        JRMI    1$ 
        ADD     A,#7
1$:     ADD     A,#'0 
        LD      (1,X),A 
        RET         


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       EXTRACT ( n base -- n c )
;       Extract least significant 
;       digit from n.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER EXTRC,7,"EXTRACT"
        CALL     USLMOD
        CALL     SWAPP
        JP       DIGIT

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       <#      ( -- )
;       Initiate  numeric 
;       output process.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER BDIGS,2,"#<"
        CALL     PAD
        CALL     HLD
        JP     STORE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       HOLD    ( c -- )
;       Insert a character 
;       into output string.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER HOLD,4,"HOLD"
        LDW     Y,UHLD 
        DECW    Y 
        LDW     UHLD,Y 
        LD      A,(1,X)
        LD      (Y),A 
        _DROP 
        RET 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       #       ( u -- u )
;       Extract one digit from u and
;       append digit to output string.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER DIG,1,"#"
        CALL     BASE
        CALL     AT
        CALL     EXTRC
        JP     HOLD

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       #S      ( u -- 0 )
;       Convert u until all digits
;       are added to output string.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER DIGS,2,"#S"
DIGS1:  CALL     DIG
        CALL     DUPP
        CALL     QBRAN
        .word      DIGS2
        JRA     DIGS1
DIGS2:  RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       SIGN    ( n -- )
;       Add a minus sign to
;       numeric output string.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER SIGN,4,"SIGN"
        CALL     ZLESS
        CALL     QBRAN
        .word      SIGN1
        CALL     DOLIT
        .word      45	;"-"
        JP     HOLD
SIGN1:  RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       #>      ( w -- b u )
;       Prepare output string.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER EDIGS,2,"#>"
        _DROP
        CALL     HLD
        CALL     AT
        CALL     PAD
        CALL     OVER
        JP     SUBB

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       STR     ( w -- b u )
;       Convert a signed integer
;       to a numeric string.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER STR,3,"STR"
        CALL     DUPP
        CALL     TOR
        CALL     ABSS
        CALL     BDIGS
        CALL     DIGS
        CALL     RFROM
        CALL     SIGN
        JP     EDIGS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       HEX     ( -- )
;       Use radix 16 as base for
;       numeric conversions.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER HEX,3,"HEX"
        MOV     UBASE+1,#16
        RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       DECIMAL ( -- )
;       Use radix 10 as base
;       for numeric conversions.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER DECIM,7,"DECIMAL"
        MOV     UBASE+1,#10 
        RET

;; Numeric input, single precision

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       DIGIT?  ( c base -- u t )
;       Convert a character to its numeric
;       value. A flag indicates success.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER DIGTQ,6,"DIGIT?"
        CALL     TOR
        CALL     DOLIT
        .word    '0'
        CALL     SUBB
        CALL     DOLIT
        .word      9
        CALL     OVER
        CALL     LESS
        CALL     QBRAN
        .word      DGTQ1
        CALL     DOLIT
        .word      7
        CALL     SUBB
        CALL     DUPP
        CALL     DOLIT
        .word      10
        CALL     LESS
        CALL     ORR
DGTQ1:  CALL     DUPP
        CALL     RFROM
        JP     ULESS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  NUMBER? ( a -- n T | a F )
;  Convert a number string to
;  integer. Push a flag on tos.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER NUMBQ,7,"NUMBER?"
        CALL     BASE
        CALL     AT
        CALL     TOR
        CALL     ZERO
        CALL     OVER
        CALL     COUNT
        CALL     OVER
        CALL     CAT
        CALL     DOLIT
        .WORD    '$'
        CALL     EQUAL
        CALL     QBRAN
        .WORD    NUMQ1
        CALL     HEX   ; hexadecimal string 
        CALL     SWAPP
        CALL     ONEP
        CALL     SWAPP
        CALL     ONEM
NUMQ1:  CALL     OVER
        CALL     CAT
        CALL     DOLIT
        .WORD    '-'
        CALL     EQUAL
        CALL     TOR
        CALL     SWAPP
        CALL     RAT
        CALL     SUBB
        CALL     SWAPP
        CALL     RAT
        CALL     PLUS
        CALL     QDUP
        CALL     QBRAN
        .WORD    NUMQ6
        CALL     ONEM
        CALL     TOR
NUMQ2:  ; digit loop 
        CALL     DUPP
        CALL     TOR
        CALL     CAT
        CALL     BASE
        CALL     AT
        CALL     DIGTQ
        CALL     QBRAN
        .WORD    NUMQ4
        CALL     SWAPP
        CALL     BASE
        CALL     AT
        CALL     STAR
        CALL     PLUS
        CALL     RFROM
        CALL     ONEP
        CALL     DONXT
        .WORD    NUMQ2
        CALL     RAT
        CALL     SWAPP
        _DROP
        CALL     QBRAN
        .WORD    NUMQ3
        CALL     NEGAT ; negative number 
NUMQ3:  CALL     SWAPP
        JRA      NUMQ5
NUMQ4:  
.if 1 ; optimize 
        ADDW SP,#2*CELLL ; drop 2 elements from R:
        ADDW X,#2*CELLL  ; drop 2 elements from S: 
.else
        CALL     RFROM
        CALL     RFROM
        CALL     DDROP
        CALL     DDROP
.endif 
        CALL     ZERO 
NUMQ5:  CALL     DUPP
NUMQ6:  
.if 1 ; optimize
        addw sp,#CELLL  ; drop 1 element from R: 
        addw x,#CELLL   ; drop 1 element from S: 
.else 
        CALL     RFROM
        CALL     DDROP
.endif 
        CALL     RFROM
        CALL     BASE
        JP       STORE

;;;;;;;;;;;;;;;;;;;;;;
; forth terminal 
; interface 
;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       KEY?      ( -- T | F )
; return a flag .
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER KEYQ,4,"KEY?"
        clrw y 
        call qchar 
        jreq 1$
        cplw y 
1$:     JP      DPUSH     


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       KEY     ( -- c )
;       Wait for and return an
;       input character.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER KEY,3,"KEY"
        call getc 
        clrw y
        ld yl ,a         
        JP      DPUSH 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       EMIT    ( c -- )
;       Send character c to  output device.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER EMIT,4,"EMIT"
        LD     A,(1,X)
	ADDW	X,#CELLL
        JP      putc  

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       SPACE   ( -- )
;       Send  blank character to
;       output device.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER SPACE,5,"SPACE"
        LD      A,#SPC 
        JP      putc 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       SPACES  ( +n -- )
;       Send n spaces to output device.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER SPACS,6,"SPACES"
        CLR     (X) ; maximum spaces 255 
        CALL     TOR
        JRA      CHAR2
CHAR1:  CALL     SPACE
CHAR2:  CALL     DONXT
        .word    CHAR1
        RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       TYPE    ( b u -- )
;       Output u characters from b.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER TYPES,4,"TYPE"
        LD      A,(1,X)
        LDW     Y,X 
        LDW     Y,(2,Y)
        CALL    prt_cstr
        JP      DDROP 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       CR      ( -- )
;       Output a carriage return
;       and a line feed.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER CR,2,"CR"
        LD      A,#CRR
        CALL    putc 
        LD      A,#LF 
        JP      putc 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       do$     ( -- a )
;       Return  address of a compiled
;       string.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       _HEADER DOSTR,COMPO+3,"DO$"
DOSTR:
        CALL     RFROM
        CALL     RAT
        CALL     RFROM
        CALL     COUNT
        CALL     PLUS
        CALL     TOR
        CALL     SWAPP
        CALL     TOR
        RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       $"|     ( -- a )
;       Run time routine compiled by $".
;       Return address of a compiled string.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       _HEADER STRQP,COMPO+3,"$\"|"
STRQP:
        CALL     DOSTR
        RET 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       ."|     ( -- )
;       Run time routine of ." .
;       Output a compiled string.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       _HEADER DOTQP,COMPO+3,".\"|"
DOTQP:
        CALL     DOSTR
        CALL     COUNT
        JP       TYPES

.IF 0 ;*************************

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       .R      ( n +n -- )
;       Display an integer in a field
;       of n columns, right justified.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER DOTR,2,".R"
        CALL     TOR
        CALL     STR
        CALL     RFROM
        CALL     OVER
        CALL     SUBB
        CALL     SPACS
        JP     TYPES

.ENDIF ;**********************

.IF 1 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       U.      ( u -- )
;       Display an unsigned integer
;       in free format.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER UDOT,2,"U."
        CALL     BDIGS
        CALL     DIGS
        CALL     EDIGS
        CALL     SPACE
        JP     TYPES
.ENDIF 

.IF 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   H. ( n -- )
;   display n in hexadecimal 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER HDOT,2,"H."
        CALL BASE 
        CALL AT 
        CALL TOR 
        CALL HEX 
        CALL UDOT 
        CALL RFROM 
        CALL BASE 
        JP STORE 
.ENDIF          

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       .       ( w -- )
;       Display an integer in free
;       format, preceeded by a space.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER DOT,1,"."
        CALL     BASE
        CALL     AT
        CALL     DOLIT
        .word      10
        CALL     XORR    ;?decimal
        CALL     QBRAN
        .word      DOT1
        JRA     UDOT
DOT1:   CALL     STR
        CALL     SPACE
        JP     TYPES

.IF 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       ?       ( a -- )
;       Display contents in memory cell.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER QUEST,1,"?"
        CALL     AT
        JRA     DOT
.ENDIF 

;; Parsing

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       PARS$   ( b u c -- b u delta ; <string> )
;       Scan string delimited by c.
;       Return found string and its offset.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;        _HEADER PARS,5,"PARS$"
PARS: 
        BUFF=3 ; string buffer  
        CHAR=2 ; target character 
        SLEN=1 ; string length 
        VSIZE=4  ; local var size 
        SUB   SP,#VSIZE 
        LD    A,(1,X)
        LD    (CHAR,SP),A ; c 
        LD    A,(3,X)
        JREQ  6$ 
        LD    (SLEN,SP),A ; u 
        LDW   Y,X 
        LDW   Y,(4,Y) ;b
        LDW   (BUFF,SP),Y 
0$: ; skip  all character <= SPACE 
        LD    A,(Y)
        CP    A,#SPC+1
        JRPL  1$ 
        INCW  Y 
        DEC   (SLEN,SP)
        JRNE  0$ 
        LDW   (4,X),Y 
        CLRW  Y 
        LDW   (2,X),Y 
        LDW   (X),Y 
        JRA   9$
1$:     LDW   (4,X),Y
        LDW   (BUFF,SP),Y        
2$:
        LD    A,(Y)
        CP    A,(CHAR,SP)
        JREQ  4$ 
        INCW  Y 
        DEC   (SLEN,SP)
        JRNE  2$ 
4$:
        LD   A,(3,X)
        SUB   A,(SLEN,SP)
        LD    (1,X),A 
        SUBW  Y,(BUFF,SP)
        LDW    (2,X),Y    ; b u 
        JRA    9$ 
6$:
        CLRW  Y 
        LDW   (X),Y
9$:
        ADDW  SP,#VSIZE
        RET  

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       PARSE   ( c -- b u ; <string> )
;       Scan input stream and return
;       counted string delimited by c.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER PARSE,5,"PARSE"
        CALL     TOR
        CALL     TIB
        CALL     INN
        CALL     AT
        CALL     PLUS    ;current input buffer pointer
        CALL     NTIB
        CALL     AT
        CALL     INN
        CALL     AT
        CALL     SUBB    ;remaining count
        CALL     RFROM
        CALL     PARS
        CALL     INN
        JP       PSTOR

.IF 0 ;**************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       .(      ( -- )
;       Output following string up to next ) .
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER DOTPR,IMEDD+2,".("
        CALL     DOLIT
        .word     41	; ")"
        CALL     PARSE
        JP     TYPES
.ENDIF ;************************

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       (       ( -- )
;       Ignore following string up to next ).
;       A comment.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER PAREN,IMEDD+1,"("
        CALL     DOLIT
        .word     41	; ")"
        CALL     PARSE
        JP     DDROP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       \       ( -- )
;       Ignore following text till
;       end of line.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER BKSLA,IMEDD+1,'\'
        mov UINN+1,UCTIB+1
        ret 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       WORD    ( c -- a ; <string> )
;       Parse a word from input stream
;       and copy it at HERE+CELLL.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER WORDD,4,"WORD"
        CALL     PARSE
        CALL     HERE
        CALL     CELLP
        CALL     PACKS
        RET 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       TOKEN   ( -- a ; <string> )
;       Parse a word from input stream
;       and copy it to name dictionary.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER TOKEN,5,"TOKEN"
        CALL     BLANK
        JP       WORDD

;; Dictionary search

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       >NAME   ( ca -- na | F )
;       Convert code address
;       to a name address.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER TNAME,5,">NAME"
        CALL     CNTXT   ;vocabulary link
TNAM2:  CALL     AT
        CALL     DUPP    ;?last word in a vocabulary
        CALL     QBRAN
        .word      TNAM4
        CALL     DDUP
        CALL     NAMET
        CALL     XORR    ;compare
        CALL     QBRAN
        .word      TNAM3
        CALL     CELLM   ;continue with next word
        JRA     TNAM2
TNAM3:  CALL     SWAPP
        JP     DROP
TNAM4:  CALL     DDROP
        JP     ZERO 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       NAME>   ( na -- ca )
;       Return a code address given
;       a name address.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER NAMET,5,"NAME>"
        CALL     COUNT
        CALL     DOLIT
        .word      31
        CALL     ANDD
        JP     PLUS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       SAME?   ( a a u -- a a f \ -0+ )
;       Compare u cells in two
;       strings. Return 0 if identical.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER SAMEQ,5,"SAME?"
        CALL     ONEM
        CALL     TOR
        JRA     SAME2
SAME1:  CALL     OVER
        CALL     RAT
        CALL     PLUS
        CALL     CAT
        CALL     OVER
        CALL     RAT
        CALL     PLUS
        CALL     CAT
        CALL     SUBB
        CALL     QDUP
        CALL     QBRAN
        .word      SAME2
        CALL     RFROM
        JP       DROP
SAME2:  CALL     DONXT
        .word      SAME1
        JP     ZERO 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       find    ( a va -- ca na | a F )
;       Search vocabulary for string.
;       Return ca and na if succeeded.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER FIND,4,"FIND"
        CALL     SWAPP
        CALL     DUPP
        CALL     CAT
        CALL     TEMP
        CALL     STORE
        CALL     DUPP
        CALL     AT
        CALL     TOR
        CALL     CELLP
        CALL     SWAPP
FIND1:  CALL     AT
        CALL     DUPP
        CALL     QBRAN
        .word      FIND6
        CALL     DUPP
        CALL     AT
        CALL     DOLIT
        .word      MASKK
        CALL     ANDD
        CALL     RAT
        CALL     XORR
        CALL     QBRAN
        .word      FIND2
        CALL     CELLP
        CALL     DOLIT
        .word     0xFFFF
        JRA     FIND3
FIND2:  CALL     CELLP
        CALL     TEMP
        CALL     AT
        CALL     SAMEQ
FIND3:  CALL     BRAN
        .word      FIND4
FIND6:  CALL     RFROM
        _DROP
        CALL     SWAPP
        CALL     CELLM
        JP     SWAPP
FIND4:  CALL     QBRAN
        .word      FIND5
        CALL     CELLM
        CALL     CELLM
        JRA     FIND1
FIND5:  CALL     RFROM
        _DROP
        CALL     SWAPP
        _DROP
        CALL     CELLM
        CALL     DUPP
        CALL     NAMET
        JP     SWAPP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       NAME?   ( a -- ca na | a F )
;       Search vocabularies for a string.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER NAMEQ,5,"NAME?"
        CALL   CNTXT
        JP     FIND

;; Terminal response

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       accept  ( b u -- b u )
;       Accept characters to input
;       buffer. Return with actual count.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER ACCEP,6,"ACCEPT"
        LD       A,(1,X)
        LDW     Y,X 
        LDW     Y,(2,Y)
        CALL    getline 
        LD      (1,X),A
        CLR     (X) 
        RET 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       QUERY   ( -- )
;       Accept input stream to
;       terminal input buffer.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER QUERY,5,"QUERY"
        CALL     TIB
        CALL     DOLIT
        .word    TIB_SIZE 
        CALL     ACCEP 
        CALL     NTIB
        CALL     STORE
        _DROP
        CALL     ZERO 
        CALL     INN
        JP       STORE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       ABORT   ( -- )
;       Reset data stack and
;       jump to QUIT.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER ABORT,5,"ABORT"
        CALL   PRESE
        JP     QUIT

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       abort"  ( f -- )
;       Run time routine of ABORT".
;       Abort with a message.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER ABORQ,COMPO+6,'ABORT"'
        CALL     QBRAN
        .word      ABOR2   ;text flag
        CALL     DOSTR
ABOR1:  MOV     BASE,#10 ; reset to default 
        CALL     SPACE
        CALL     COUNT
        CALL     TYPES
        CALL     DOLIT
        .word     63 ; "?"
        CALL     EMIT
        CALL     CR
        JP     ABORT   ;pass error string
ABOR2:  CALL     DOSTR
        JP     DROP

;; The text interpreter

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       $INTERPRET      ( a -- )
;       Interpret a word. If failed,
;       try to convert it to an integer.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;        _HEADER INTER,10,"$INTERPRET"
INTER: 
        CALL     NAMEQ
        CALL     QDUP    ;?defined
        CALL     QBRAN
        .word      INTE1
        CALL     AT
        CALL     DOLIT
	.word       0x4000	; COMPO*256
        CALL     ANDD    ;?compile only lexicon bits
        CALL     ABORQ
        .byte      13
        .ascii     " compile only"
        JP      EXECU
INTE1:  
        CALL     NUMBQ   ;convert a number 
        CALL     QBRAN
        .word    ABOR1
        RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       [       ( -- )
;       Start  text interpreter.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER LBRAC,IMEDD+1,"["
        CLR    USTATE 
        CLR    USTATE+1
        CALL   DOLIT
        .word  INTER
        CALL   TEVAL
        JP     STORE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       .OK     ( -- )
;       Display 'ok' while interpreting.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER DOTOK,3,".OK"
        CALL     STATE 
        CALL     AT
        CALL     TBRAN
        .word      DOTO1
.IF 0
        LDW      Y,UNEST 
        JRNE     DOTO2 
.ENDIF         
        CALL     DOTQP
        .byte      3
        .ascii     " ok"
DOTO1:  JP     CR
DOTO2:  RET 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       ?STACK  ( -- )
;       Abort if stack underflows.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER QSTAC,6,"?STACK"
        CALL     DEPTH
        CALL     ZLESS   ;check only for underflow
        CALL     ABORQ
        .byte      11
        .ascii     " underflow "
        RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       EVAL    ( -- )
;       Interpret  input stream.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER EVAL,4,"EVAL"
.IF 0
        LDW     Y,UNEST
        INCW    Y 
        LDW     UNEST,Y 
.ENDIF 
EVAL1:  CALL     TOKEN
        CALL     DUPP
        CALL     CAT     ;?input stream empty
        CALL     QBRAN
        .word    EVAL2
        CALL     TEVAL
        CALL     ATEXE
        CALL     QSTAC   ;evaluate input, check stack
        JRA     EVAL1 
EVAL2:  _DROP
.IF 0
        LDW     Y,UNEST 
        DECW    Y 
        LDW     UNEST,Y 
.ENDIF 
        JP       DOTOK

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       PRESET  ( -- )
;       Reset data stack pointer and
;       terminal input buffer.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER PRESE,6,"PRESET"
        CALL    DOLIT 
        .WORD   SPP 
        CALL    SPSTO 
        CALL     DOLIT
        .word    TIBB
        CALL     NTIB
        CALL     CELLP
        JP       STORE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       QUIT    ( -- )
;       Reset return stack pointer
;       and start text interpreter.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER QUIT,4,"QUIT"
        LDW    Y,#0 
        LDW    UNEST,Y 
;reset return stack 
        LDW     Y,#RPP 
        LDW     SP,Y 
QUIT1:  CALL     LBRAC   ;start interpretation
QUIT2:  CALL     QUERY   ;get input
        CALL     EVAL
        JRA     QUIT2   ;continue till error

;; The compiler

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       '       ( -- ca )
;       Search vocabularies for
;       next word in input stream.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER TICK,1,"'"
        CALL     TOKEN
        CALL     NAMEQ   ;?defined
        CALL     QBRAN
        .word    ABOR1
        RET     ;yes, push code address

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       ALLOT   ( n -- )
;       Allocate n bytes to RAM 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER ALLOT,5,"ALLOT"
        CALL     HERE
        CALL     PLUS 
        CALL     VPP 
        CALL     STORE 
        jp UPDATPTR 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  ,       ( w -- )
;  Compile an integer into
;  code space.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER COMMA,1,^/","/
        CALL     CPHERE
        CALL     DUPP
        CALL     CELLP   ;cell boundary
        CALL     CPP
        CALL     STORE
        JP       FSTOR

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  C,      ( c -- )
;  Compile a byte into
;  code space.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER CCOMMA,2,^/"C,"/
        CALL     CPHERE
        CALL     DUPP
        CALL     ONEP
        CALL     CPP
        CALL     STORE
        JP       FCSTOR

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       [COMPILE]       ( -- ; <string> )
;       Compile next immediate
;       word into code dictionary.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER BCOMP,COMPO+IMEDD+9,"[COMPILE]"
        CALL     TICK
        JP     JSRC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       COMPILE ( -- )
;       Compile next jsr in
;       colon list to code dictionary.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER COMPI,COMPO+7,"COMPILE"
        CALL     RFROM
        CALL     DUPP
        CALL     AT
        CALL     JSRC    ;compile subroutine
        CALL     CELLP
        ldw y,x 
        ldw y,(y)
        addw x,#CELLL 
        jp (y)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       LITERAL ( w -- )
;       Compile tos to dictionary
;       as an integer literal.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER LITER,COMPO+IMEDD+7,"LITERAL"
        CALL     COMPI
        .word DOLIT 
        JP     COMMA

.IF 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ['] <name>
; compile execution semantic of 
; <name>
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER COMPTICK,COMPO+IMEDD+3,"[']"
        CALL TICK 
        CALL LITER  
        RET 
.ENDIF 

.IF 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; DEFER <name>
; create word <name>
; whick action must be set 
; by DEFER! 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER DEFER,5,"DEFER"
        CALL   CREAT    
        CALL   HERE 
        CALL   DUPP 
        CALL   CELLP ; allot vector space  
        CALL   VPP 
        CALL   STORE
        CALL   DUPP  ; pfa pfa 
        CALL   COMMA  
        _DOLIT NOOP 
        CALL   SWAPP  
        CALL   STORE 
        CALL   COMPI 
        .WORD  ATEXE
        _DOLIT RET_CODE 
        CALL   CCOMMA  
        CALL   UPDATPTR 
NOOP:
        RET 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; DEFER! ( ca ca2  -- )
; sauvegarde ca1 dans la pfa 
; de ca2 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER DEFERSTORE,6,"DEFER!"
        CALL TBODY 
        JP   STORE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; DEFER@ ( ca1 -- ca2 )
; ca2  is code executed by 
; ca1 of defered word 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER DEFERAT,6,"DEFER@"
        CALL TBODY 
        JP   AT 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; DOES>  (  --  )
; complete last definition
; compile runtime DODOES 
; compile code follwing  DOES>
; render available the ca of this 
; code to DODOES 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER DOESS,COMPO+IMEDD+5,"DOES>" 
        CALL COMPI 
        .WORD DODOES  ;compile runtime of DOES>
        CALL  CPHERE 
        _DOLIT 3 
        CALL  PLUS     
        CALL  COMMA   ; address of code to append to new definition 
        _DOLIT RET_CODE 
        CALL  CCOMMA 
        RET 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  DODOES 
;  runtime of DOES>
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 DODOES:
        LDW Y,(1,SP)
        LDW Y,(Y)    ; new definition must jump to this address 
        SUBW X,#CELLL 
        LDW (X),Y 
        _DOLIT JPIMM 
        CALL CCOMMA
        CALL COMMA  ; JP addr  
        POPW Y 
        JP (2,Y) 
.ENDIF 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       $,"     ( -- )
;       Compile a literal string
;       up to next " .
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;        _HEADER STRCQ,3,^/'$,"'/
STRCQ:
        CALL     DOLIT
        .word    '"'   
        CALL     PARSE
        CALL     HERE
        CALL     PACKS   ;string to code dictionary
; copy string to FLASH memory at CPP        
        CALL     COUNT
        CALL     ONEP 
        CALL     TOR 
        CALL     ONEM 
        CALL     CPP
        CALL     AT 
        CALL     RAT 
        CALL     FCPY
        CALL     CPHERE  
        CALL     RFROM
        CALL     PLUS  
        CALL     CPP 
        JP       STORE 

;; Structures

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       FOR     ( -- a )
;       Start a FOR-NEXT loop
;       structure in a colon definition.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER FOR,COMPO+IMEDD+3,"FOR"
        CALL     COMPI
        .word    TOR 
        JP       CPHERE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       NEXT    ( a -- )
;       Terminate a FOR-NEXT loop.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER NEXT,COMPO+IMEDD+4,"NEXT"
        CALL     COMPI
        .word DONXT 
        JP     COMMA

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       I ( -- n )
;       stack COUNTER
;       of innermost FOR-NEXT  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER IFETCH,1,"I"
        ldw y,(3,sp)
        JP      DPUSH 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       J ( -- n )
;   stack COUNTER
;   of outer FOR-NEXT  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER JFETCH,1,"J"
        LDW Y,(5,SP)
        JP      DPUSH

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       BEGIN   ( -- a )
;       Start an infinite or
;       indefinite loop structure.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER BEGIN,COMPO+IMEDD+5,"BEGIN"
        JP     CPHERE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       UNTIL   ( a -- )
;       Terminate a BEGIN-UNTIL
;       indefinite loop structure.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER UNTIL,COMPO+IMEDD+5,"UNTIL"
        CALL     COMPI
        .word    QBRAN 
;        call     ADRADJ
        JP       COMMA

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       AGAIN   ( a -- )
;       Terminate a BEGIN-AGAIN
;       infinite loop structure.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER AGAIN,COMPO+IMEDD+5,"AGAIN"
        _DOLIT JPIMM 
        CALL  CCOMMA
;        call ADRADJ 
        JP     COMMA

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       IF      ( -- A )
;       Begin a conditional branch.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER IFF,COMPO+IMEDD+2,"IF"
        CALL     COMPI
        .word QBRAN
        CALL     CPHERE
        CALL     ZERO 
        JP     COMMA

.IF 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       ~IF      ( -- A )
;       Begin a conditional branch.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER TILDEIF,COMPO+IMEDD+3,"~IF"
        CALL     COMPI
        .WORD    TBRAN
        CALL     CPHERE
        CALL     ZERO 
        JP       COMMA
.ENDIF 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       THEN        ( A -- )
;       Terminate a conditional 
;       branch structure.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER THENN,COMPO+IMEDD+4,"THEN"
        CALL     CPHERE
        CALL     SWAPP
        JP     FSTOR

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       ELSE        ( A -- A )
;       Start the false clause in 
;       an IF-ELSE-THEN structure.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER ELSEE,COMPO+IMEDD+4,"ELSE"
        _DOLIT   JPIMM 
        CALL     CCOMMA 
        CALL     CPHERE
        CALL     ZERO 
        CALL     COMMA
        CALL     SWAPP
        CALL     CPHERE
        CALL     SWAPP
        JP       FSTOR

.IF 0 ;**********************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       AHEAD       ( -- A )
;       Compile a forward branch
;       instruction.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER AHEAD,COMPO+IMEDD+5,"AHEAD"
        _DOLIT JPIMM 
        CALL CCOMMA
        CALL     CPHERE
        CALL     ZERO 
        JP     COMMA
.ENDIF ;***************************

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       WHILE       ( a -- A a )
;       Conditional branch out of a 
;       BEGIN-WHILE-REPEAT loop.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER WHILE,COMPO+IMEDD+5,"WHILE"
        CALL     COMPI
        .WORD    QBRAN
        CALL     CPHERE
        CALL     ZERO 
        CALL     COMMA
        JP       SWAPP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       REPEAT      ( A a -- )
;       Terminate a BEGIN-WHILE-REPEAT 
;       indefinite loop.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER REPEA,COMPO+IMEDD+6,"REPEAT"
        _DOLIT JPIMM 
        CALL   CCOMMA
;        call   ADRADJ 
        CALL   COMMA
        CALL   CPHERE
;        call   ADRADJ 
        CALL   SWAPP
        JP     FSTOR

.IF 0 ;*********************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       AFT         ( a -- a A )
;       Jump to THEN in a FOR-AFT-THEN-NEXT 
;       loop the first time through.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER AFT,COMPO+IMEDD+3,"AFT"
        _DROP
        CALL     AHEAD
        CALL     CPHERE
        JP     SWAPP
.ENDIF ;*****************************

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       ABORT"      ( -- ; <string> )
;       Conditional abort with an error message.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER ABRTQ,IMEDD+6,'ABORT"'
        CALL     COMPI
        .word ABORQ
        JP     STRCQ

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       $"     ( -- ; <string> )
;       Compile an inline string literal.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;        _HEADER STRQ,IMEDD+COMPO+2,'$"'
STRQ: 
        CALL     COMPI
        .word STRQP 
        JP     STRCQ
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       ."          ( -- ; <string> )
;       Compile an inline string literal 
;       to be typed out at run time.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER DOTQ,IMEDD+COMPO+2,'."'
        CALL     COMPI
        .word    DOTQP 
        JP       STRCQ

;; Name compiler

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       ?UNIQUE ( a -- a )
;       Display a warning message
;       if word already exists.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER UNIQU,7,"?UNIQUE"
        CALL     DUPP
        CALL     NAMEQ   ;?name exists
        CALL     QBRAN
        .word      UNIQ1
        CALL     DOTQP   ;redef are OK
        .byte       7
        .ascii     " reDef "       
        CALL     OVER
        CALL     COUNT
        CALL     TYPES   ;just in case
UNIQ1:  JP     DROP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; $,N    ( na -- )
; Build a new dictionary name
; using string at na.
; compile in code space  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       _HEADER SNAME,3,^/"$,N"/
SNAME: 
        CALL     DUPP
        CALL     CAT     ;?null input
        CALL     QBRAN
        .word    PNAM1
        CALL     UNIQU   ;?redefinition
; write new link 
        CALL    CNTXT ; na cn 
        CALL    AT    ; na pna 
        CALL    CPHERE ; na pna cp 
        CALL    FSTOR  ; na 
; copy name to FLASH memory 
        CALL     CPHERE ; na cp  
        CALL     CELLP  ; new name field 
        CALL     DUPP
        CALL     LAST 
        CALL     STORE  ;new name field 
        CALL     OVER   ; na cp+ na 
        CALL     COUNT  ; na cp+ na+ cnt 
        CALL     SWAPP  ; na cp+ cnt na+
        _DROP           ; na cp+ cnt 
        CALL     ONEP   ; na cp+ cnt+
        CALL     DUPP   ; na cp+ cnt+ cnt+ 
        CALL     TOR    ; na cp+ cnt+ R: cnt+ 
        CALL     FCPY   ;
        CALL     LAST  ; cp+ R: cnt+  
        CALL     AT 
        CALL     RFROM   ; cp+ cnt+
        CALL     PLUS    ; cp++ 
        CALL     CPP     ;  
        CALL     STORE  ; update cp 
        RET    
PNAM1:  CALL     STRQP
        .byte      5
        .ascii     " name" ;null input
        JP     ABOR1

;; FORTH compiler

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       $COMPILE        ( a -- )
;       Compile next word to
;       dictionary as a token or literal.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;        _HEADER SCOMP,8,"$COMPILE"
SCOMP: 
        CALL     NAMEQ
        CALL     QDUP    ;?defined
        CALL     QBRAN
        .word      SCOM2
        CALL     AT
        CALL     DOLIT
        .word     0x8000	;  IMEDD*256
        CALL     ANDD    ;?immediate
        CALL     QBRAN
        .word      SCOM1
        JP     EXECU
SCOM1:  JP     JSRC
SCOM2:  CALL     NUMBQ   ;try to convert to number 
        CALL    QDUP  
        CALL     QBRAN
        .word      ABOR1
        _DROP 
        JP     LITER


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       OVERT   ( -- )
;       Link a new word into vocabulary.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER OVERT,5,"OVERT"
        CALL     LAST
        CALL     AT
        CALL     CNTXT
        JP       STORE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       ;       ( -- )
;       Terminate a colon definition.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER SEMIS,IMEDD+COMPO+1,^/";"/
        CALL DOLIT 
        .word 0x81   ; opcode for RET 
        CALL  CCOMMA 
        CALL  LBRAC
        CALL  OVERT
        CALL  UPDATPTR 
        RET 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       ]       ( -- )
;       Start compiling words in
;       input stream.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER RBRAC,1,"]"
        LDW    Y,#-1 
        LDW    USTATE,Y 
        CALL   DOLIT
        .word  SCOMP
        CALL   TEVAL
        JP     STORE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       CALL,    ( xt -- )
;       Compile a subroutine call.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;        _HEADER JSRC,5,^/"CALL,"/
JSRC: 
        _DOLIT  CALLL     ;CALL
        CALL     CCOMMA
        JP       COMMA

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  STATE ( -- adr )
;;  return system variable address 
;;  containning COMPILE/INTERPRET flag 
;;  0 == interpret 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER STATE,5,"STATE"
        LDW Y,#USTATE
        JP DPUSH   

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       :       ( -- ; <string> )
;       Start a new colon definition
;       using next word as its name.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER COLON,1,":"
        CALL   TOKEN
        CALL   SNAME
        JP     RBRAC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       IMMEDIATE       ( -- )
;       Make last compiled word
;       an immediate word.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER IMMED,9,"IMMEDIATE"
        CALL	DOLIT
        .word	(IMEDD<<8)
IMM01:  CALL	LAST
        CALL    AT
        CALL    AT
        CALL    ORR
        CALL    LAST
        CALL    AT
        CALL    FSTOR
        RET  

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;		COMPILE-ONLY  ( -- )
;		Make last compiled word 
;		a compile only word.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER COMPONLY,12,"COMPILE-ONLY"
        CALL     DOLIT
        .word    (COMPO<<8)
        JP       IMM01
		
;; Defining words

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; CREATE  ( -- ; <string> )
; Compile a new definition header 
; without allocating space.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER CREAT,6,"CREATE"
        CALL     TOKEN
        CALL     SNAME
        CALL     OVERT         
        CALL     COMPI 
        .WORD    DOVAR
        CALL     HERE 
        CALL     COMMA
        RET

.IF 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  >BODY ( ca -- pfa )
;  from ca goto data field address 
;  ca is from a word create using 
;  CREATE 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER TBODY,5,">BODY"
        _DOLIT 3
        CALL  PLUS 
        JP    AT 
.ENDIF 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       VARIABLE  ( -- ; <string> )
;       Compile a new variable
;       initialized to 0.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER VARIA,8,"VARIABLE"
        CALL     CREAT
        CALL     HERE  
        CALL     CELLP  ; move VP 1 cell up 
        CALL     VPP 
        CALL     STORE 
        JRA      complete 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       CONSTANT  ( n -- ; <string> )
;       Compile a new constant 
;       n CONSTANT name 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER CONSTANT,8,"CONSTANT"
        CALL     TOKEN
        CALL     SNAME
        CALL     OVERT         
        CALL     COMPI  
        .WORD    DOCONST 
        CALL     COMMA
complete:
        _DOLIT   RET_CODE 
        CALL     CCOMMA 
        CALL     UPDATPTR  
        RET  

;------------------------
; required by FORGET to 
; free erased variables 
;------------------------
DOVAR:
        NOP 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; CONSTANT runtime semantic 
; doCONST  ( -- n )
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DOCONST:
        subw x,#CELLL
        ldw y,(1,sp) 
        ldw y,(y) 
        ldw (x),y
        popw y  
        jp (2,y)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;    PRINT_VERSION ( c1 c2 -- )
;    c2 minor 
;    c1 major 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PRINT_VERSION:
     CALL BDIGS 
     CALL DIGS 
     CALL DIGS 
     _DOLIT '.' 
     CALL HOLD 
     _DROP 
     CALL DIGS 
     CALL EDIGS 
     CALL TYPES 
     RET  

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       hi      ( -- )
;       Display sign-on message.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;        _HEADER HI,2,"HI"
HI: 
        CALL     DOTQP   
        .byte      19 
        .ascii     "smallForth version "
	_DOLIT VER 
        _DOLIT MINOR 
        CALL PRINT_VERSION
        CALL    DOTQP
        .byte 15+34
        .ascii  " on stm8l151k6\n"
        .ascii "Copyright Jacques Deschenes, 2026\n"
        RET 


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       'BOOT   ( -- a )
;       The application startup vector.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;        _HEADER TBOOT,5,"'BOOT"
TBOOT:
        SUBW    X,#CELLL 
        LDW     Y,EEP_RUN
        JRNE    1$
        LDW     Y,#HI 
1$:     LDW     (X),Y 
        RET 

;------------------------------
; compare EEP values 
; with values from UZERO 
; table load if greater 
;-----------------------------
LOAD_EEP:
        _ldyz UCNTXT 
        cpw y,EEP_CNTXT 
        jruge 9$ 
        _ldyz UCP 
        cpw y,EEP_CP 
        jruge 9$ 
        _ldyz UVP 
        cpw y,EEP_VP 
        jrugt 9$ 
; load values from EEPROM 
        ldw y,EEP_CNTXT 
        _stryz UCNTXT 
        _stryz ULAST 
        ldw y,EEP_CP
        _stryz UCP 
        ldw y,EEP_VP 
        _stryz UVP 
9$:     ret 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       COLD    ( -- )
;       The hilevel cold start s=ence.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;        _HEADER COLD,4,"COLD"
COLD:
; initialize user variables from UZERO table. 
        CALL     DOLIT
        .word      UZERO
	CALL     DOLIT
        .word      UPP
        CALL     DOLIT
	.word      UEND-UZERO
        CALL     CMOVE   ; ( src dest cnt -- ) initialize user area
        CALL     LOAD_EEP
        CALL     UPDATPTR
        ; set autorun to HI  
        LDW      Y,EEP_RUN
        JRNE     COLD9
        _DOLIT   HI    ; default startup application  
        CALL UPDATRUN  
        JRA COLD9
COLD3: ; load system variables from EEPROM 
        LDW Y,EEP_CNTXT 
        _stryz UCNTXT 
        _stryz ULAST 
        LDW Y,EEP_CP 
        _stryz UCP 
        LDW Y,EEP_VP 
        _stryz UVP
COLD9:      
        CALL     PRESE   ;initialize data stack and TIB
        CALL     TBOOT
        CALL     EXECU   ;application boot
        CALL     OVERT
        JP       QUIT    ;start interpretation


	.include "stm8l151k6_iap.asm"
        .include "flash.asm"
        .include "interrupts.asm"

;-----------------------------
;   RESET ( -- )
; reset system to original 
; state removing all user 
; modification.
;-----------------------------
	_HEADER SYS_RST,5,"RESET"
        PUSH #8 
        _DOLIT EEPROM_BASE 
1$:     CALL ZERO 	
        CALL OVER 
        CALL FSTOR 
        DEC (1,SP)
        JREQ 2$ 
        CALL CELLP 
        JRA 1$ 
2$:	POP A
        _DROP 
        LDW Y,#app_space 
        CALL DPUSH 
        CALL RSTVEC 
        JP reboot 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  FREE 
;;  display free RAM and FLASH 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER FREE,4,"FREE"
        CALL CR 
        CALL DOTQP 
        .BYTE 4
        .ASCII "RAM:"
        CALL TIB  
        CALL PAD 
        CALL SUBB 
        CALL DOT
        CALL CR  
        CALL DOTQP 
        .BYTE 6
        .ASCII "FLASH:"
        _DOLIT FLASH_SIZE+FLASH_BASE
        CALL CPHERE  
        CALL SUBB 
        JP  DOT 


.if WANT_TOOLS
	.include "tools.asm"
.endif 

.if WANT_DOUBLE 
        .include "double.asm" 
.endif 

.if WANT_SCALING_CONST 
        .include "const_ratio.asm"
.endif

;===============================================================

LASTN =	LINK   ;last name defined

; application code begin here
	.bndry 16 ; align on flash block  
app_space: 
.word 0,0,0,0



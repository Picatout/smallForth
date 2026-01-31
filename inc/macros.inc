;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Copyright Jacques Deschênes 2019,2020,2021 
;; This file is part of stm32_eforth  
;;
;;     stm8_eforth is free software: you can redistribute it and/or modify
;;     it under the terms of the GNU General Public License as published by
;;     the Free Software Foundation, either version 3 of the License, or
;;     (at your option) any later version.
;;
;;     stm32_eforth is distributed in the hope that it will be useful,
;;     but WITHOUT ANY WARRANTY;; without even the implied warranty of
;;     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;     GNU General Public License for more details.
;;
;;     You should have received a copy of the GNU General Public License
;;     along with stm32_eforth.  If not, see <http:;;www.gnu.org/licenses/>.
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;--------------------------------------
;   console Input/Output module
;   DATE: 2019-12-11
;    
;   General usage macros.   
;
;--------------------------------------

    ; reserve space on rstack
    ; for local variabls
    .macro _VARS n 
    sub sp,#n 
    .endm 

    ; discard space reserved 
    ; for local vars on rstack 
    .macro _DROP_VARS n 
    addw sp,#n
    .endm 

    ; declare ARG_OFS for arguments 
    ; displacement on stack. This 
    ; value depend on local variables 
    ; size.
    .macro _argofs n 
    ARG_OFS=2+n 
    .endm 

    ; declare a function argument 
    ; position relative to stack pointer 
    ; _argofs must be called before it.
    .macro _arg name ofs 
    name=ARG_OFS+ofs 
    .endm 

    ; macro to create dictionary header record
    .macro _HEADER label,len,name 
        .word LINK 
        LINK=.
        .byte len  
        .ascii name
        label:
    .endm 

    ; runtime literal 
    .macro _DOLIT value 
    CALL DOLIT 
    .word value 
    .endm 

    ; branch if TOS<>0
    ; TBRANCH 
    .macro _TBRAN target 
    CALL TBRAN 
    .word target 
    .endm 
    
    ; branch if TOS==0 
    ; 0BRANCH 
    .macro _QBRAN target 
    CALL QBRAN
    .word target
    .endm 

    ; uncondittionnal BRANCH 
    .macro _BRAN target 
    JRA target  
    .endm 

    ; run time NEXT 
    .macro _DONXT target 
    CALL DONXT 
    .word target 
    .endm 

    ; drop TOS 
    .macro _DROP 
    ADDW X,#CELLL  
    .endm 
  
   ; drop a double 
   .macro _DDROP 
   ADDW X,#2*CELLL 
   .endm 

    ; drop n CELLS
    .macro _DROPN n 
    ADDW X,#n*CELLL 
    .endm 

   ; drop from rstack 
   .macro _RDROP 
   ADDW SP,#CELLL
   .endm 

   ; drop double from rstack
   .macro _DRDROP
   ADDW SP,#2*CELLL 
   .endm 

   ; test point, print character 
   ; and stack contain
   .macro _TP c 
   .if DEBUG 
   LD A,#c 
   CALL putc
   CALL DOTS 
   .endif  
   .endm 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


    ; software reset 
    .macro _swreset
.if 0
     sim 
     mov WWDG_CR,#0X80
     wfi 
.else 
    ;execute an ivalid machine code 
    .byte 0x75
.endif 
    .endm 

    ; increment zero page variable 
    .macro _incz v 
    .byte 0x3c, v 
    .endm 

    ; decrement zero page variable 
    .macro _decz v 
    .byte 0x3a,v 
    .endm 

    ; clear zero page variable 
    .macro _clrz v 
    .byte 0x3f, v 
    .endm 

    ; load A zero page variable 
    .macro _ldaz v 
    .byte 0xb6,v 
    .endm 

    ; store A zero page variable 
    .macro _straz v 
    .byte 0xb7,v 
    .endm 

    ; tnz zero page variable 
    .macro _tnz v 
    .byte 0x3d,v 
    .endm 

    ; load x from variable in zero page 
    .macro _ldxz v 
    .byte 0xbe,v 
    .endm 

    ; load y from variable in zero page 
    .macro _ldyz v 
    .byte 0x90,0xbe,v 
    .endm 

    ; store x in zero page variable 
    .macro _strxz v 
    .byte 0xbf,v 
    .endm 

    ; store y in zero page variable 
    .macro _stryz v 
    .byte 0x90,0xbf,v 
    .endm 

    ;  increment 16 bits variable
    ;  use 10 bytes  
    .macro _incwz  v 
        _incz v+1   ; 1 cy, 2 bytes 
        jrne .+4  ; 1|2 cy, 2 bytes 
        _incz v     ; 1 cy, 2 bytes  
    .endm ; 3 cy 

    ; xor op with zero page variable 
    .macro _xorz v 
    .byte 0xb8,v 
    .endm 
    
    ; move memory to memory in 0 page 
    .macro _movzz a1, a2 
    .byte 0x45,a2,a1 
    .endm 

    ; lock IAP programming 
    .macro _lock_iap 
        clr FLASH_IAPSR 
    .endm 
    
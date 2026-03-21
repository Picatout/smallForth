;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Copyright Jacques Deschênes 2026 
;; This file is part of smallForth  
;;
;;     smallForth is free software: you can redistribute it and/or modify
;;     it under the terms of the GNU General Public License as published by
;;     the Free Software Foundation, either version 3 of the License, or
;;     (at your option) any later version.
;;
;;     smallForth is distributed in the hope that it will be useful,
;;     but WITHOUT ANY WARRANTY;; without even the implied warranty of
;;     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;     GNU General Public License for more details.
;;
;;     You should have received a copy of the GNU General Public License
;;     along with smallForth.  If not, see <http:;;www.gnu.org/licenses/>.
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;--------------------------------------
    .area HOME 
;; STM8L151K6     
;; interrupt vector table at 0x8000
;;--------------------------------------

    int reset 			    ; RESET vector 
	int NotHandledInterrupt ; trap instruction 
	int NotHandledInterrupt ;int0 TLI 
	int NotHandledInterrupt ;int1 ASW     auto wake up from halt
	int NotHandledInterrupt ;int2 CLK 
	int NotHandledInterrupt ;int3 EXTI0 
	int NotHandledInterrupt ;int4 EXTI1 
	int NotHandledInterrupt ;int5 EXTI2
	int NotHandledInterrupt ;int6 EXTI3
	int NotHandledInterrupt ;int7 EXTI4  
	int NotHandledInterrupt ;int8 reserved 
	int NotHandledInterrupt ;int9 reserved 
	int NotHandledInterrupt ;int10 SPI 
	int NotHandledInterrupt ;int11 TIM1_OVF 
	int NotHandledInterrupt ;int12 TIM1_CCM 
	int NotHandledInterrupt ;int13 TIM2_OVF 
	int NotHandledInterrupt ;int14 TIM2_CCM 
	int NotHandledInterrupt ;int15 reserved 
	int NotHandledInterrupt ;int16 reserved 
	int NotHandledInterrupt ;int17 UART1_TX 
	int UartRxHandler       ;int18 UART1_RX  
	int NotHandledInterrupt ;int19 I2C  
	int NotHandledInterrupt ;int20 reserved  
	int NotHandledInterrupt ;int21 reserved  
	int NotHandledInterrupt ;int22 ADC1  
	int Timer4Handler      	;int23 TIM4_OVF
	int NotHandledInterrupt ;int24 FLASH 
	int NotHandledInterrupt ;int25 reserved 
	int NotHandledInterrupt ;int26 reserved 
	int NotHandledInterrupt ;int27 reserved 
	int NotHandledInterrupt ;int28 reserved 
	int NotHandledInterrupt ;int29 reserved 



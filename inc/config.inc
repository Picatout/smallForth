;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Copyright Jacques Deschênes 2019,2020,2021 
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
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; select end of line character
EOL_CR=1
EOL_LF=0 

; set to 1 to include 
; tools.asm 
WANT_TOOLS=1

; how many bytes are reserved 
; by system at EEPROM base.
EEPROM_RES = 16 

	.include "inc/macros.inc" 

STM8L151K6=1 
.IF STM8L151K6 
	RX_QUEUE_SIZE=16 ; uart receive queue size

	UART_PCKEN=CLK_PCKENR1_USART1
	UART_BRR1=USART1_BRR1 
	UART_BRR2=USART1_BRR2 
	UART_SR=USART1_SR 
	UART_CR1=USART1_CR1
	UART_CR1_PIEN=USART_CR1_PIEN 
	UART_CR2=USART1_CR2 
	UART_DR=USART1_DR 
	UART_CR2_TEN=USART_CR2_TEN
	UART_CR2_REN=USART_CR2_REN 
	UART_CR2_RIEN=USART_CR2_RIEN
	UART_SR_RXNE=USART_SR_RXNE 
	UART_SR_TXE=USART_SR_TXE
	UART_SR_TC=USART_SR_TC 

	BLOCK_SIZE=128    
	
	.include "inc/stm8l151k6.inc"
	.include "stm8l151k6-vec.asm"
.ENDIF 
	.include "bios.asm"

	

	

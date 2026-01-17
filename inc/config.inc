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
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; to enable _TP macro 
; set to 1 
DEBUG=0

; select end of line character
EOL_CR=1
EOL_LF=0 

; set to 1 to include 
; scaling constants vocabulary
; file: const_ratio.asm 
WANT_SCALING_CONST = 0

; set to 1 to make vocabulary 
; case sensitive 
CASE_SENSE = 0 

; how many bytes are reserved 
; by system at EEPROM base.
EEPROM_RES = 16 



	.include "inc/stm8l151.inc"
	.include "stm8l151-vec.asm
	

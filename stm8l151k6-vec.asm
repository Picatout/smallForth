;;--------------------------------------
    .area HOME 
;; STM8L151K6     
;; interrupt vector table at 0x8000
;;--------------------------------------

    int reset 			    ; RESET vector 
	int NotHandledInterrupt ; trap instruction 
	int NotHandledInterrupt ;int0 reserved 
	int NotHandledInterrupt ;int1 FLASH    auto wake up from halt
	int NotHandledInterrupt ;int2 DMA1 0/1
	int NotHandledInterrupt ;int3 DMA1 2/3
	int NotHandledInterrupt ;int4 RTC 
	int NotHandledInterrupt ;int5 EXTI E/F/PVD
	int NotHandledInterrupt ;int6 EXTIB/G external interrupt B/G
	int NotHandledInterrupt ;int7 EXTID/H external interrupt D/H 
	int NotHandledInterrupt ;int8 EXTI0 extenal interrupt 0
	int NotHandledInterrupt ;int9 EXTI1 extenal interrupt 1
	int NotHandledInterrupt ;int10 EXTI2 
	int NotHandledInterrupt ;int11 EXTI3
	int NotHandledInterrupt ;int12 EXTI4
	int NotHandledInterrupt ;int13 EXTI5 
	int NotHandledInterrupt ;int14 EXTI6
	int NotHandledInterrupt ;int15 EXTI7
	int NotHandledInterrupt ;int16 LCD 
	int NotHandledInterrupt ;int17 CLK/TIM1/DAC 
	int NotHandledInterrupt ;int18 COMP1/COMP2/ADC1 
	int NotHandledInterrupt ;int19 TIM2 udpade/overflow/trigger/break 
	int NotHandledInterrupt ;int20 TIM2 capture/compare 
	int NotHandledInterrupt ;int21 TIM3 update/overflow/trigger/break 
	int NotHandledInterrupt ;int22 TIM3 capture/compare 
	int NotHandledInterrupt	;int23 TIM1 update/overflow/trigger/COM  
	int NotHandledInterrupt ;int24 TIM1 capture/compare 
	int Timer4Handler       ;int25 TIM4 update/overflow/trigger
	int NotHandledInterrupt ;int26 SPI1 TX buffer empty/RX buffer not empty/error/wakeup
	int NotHandledInterrupt ;int27 USART1 TX register empty/transmit completed 
	int UartRxHandler       ;int28 USART1 RX ready/error 
	int NotHandledInterrupt ;int29 I2C1 



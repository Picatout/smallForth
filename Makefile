##################################
##  tinyForth make file
##################################

NAME=smallForth
# toolchain
SDAS=sdasstm8
SDCC=sdcc
CFLAGS=-mstm8 -lstm8  -Iinc
# sources files 
MAIN_FILE=ForthCore.asm
INC=inc/
INCLUDES=$(INC)config.inc $(INC)stm8l151k6.inc 
BUILD=build/$(MCU)/
OBJECTS=$(BUILD)$(SRC:.asm=.rel)
SYMBOLS=$(OBJECTS:.rel=.sym)
LISTS=$(OBJECTS:.rel=.lst)
FLASH=stm8flash

.PHONY: all

all: clean $(NAME).rel $(NAME).ihx  tinyForth clear_eevars  

$(NAME).rel: $(MAIN_FILE) $(INCLUDES)
	@echo
	@echo "**********************"
	@echo "assembling main file  to " $(NAME).rel  
	@echo "**********************"
	$(SDAS) -g -l -o $(BUILD)$(NAME).rel $(MAIN_FILE)

$(NAME).ihx: $(NAME).rel 
	@echo 
	@echo "**************************"
	@echo "linking files to " $(NAME).ihx 
	@echo "**************************"
	$(SDCC) $(CFLAGS) -Wl-u -o $(BUILD)$(NAME).ihx  $(BUILD)$(NAME).rel


.PHONY: clean 
clean: build
	@echo
	@echo "***************"
	@echo "cleaning files"
	@echo "***************"
	rm -f $(BUILD)*

.PHONY: clear_eevars 
clear_eevars:
	@echo
	@echo "****************************"
	@echo "erase EEPROM variables"
	@echo "and reset options to default"
	@echo "****************************"
	$(FLASH) -c $(PROGRAMMER) -p $(MCU) -u -s eeprom -b 16 -w zero.bin  

.PHONY: erase 
erase: clear_eevars 
	@echo "************************"
	@echo "  reset all flash types "
	@echo "************************"
	$(FLASH) -c $(PROGRAMMER) -p $(MCU) -u -s flash -b $(FLASH_SIZE) -w zero.bin   	

build:
	mkdir build

flash: $(LIB)
	@echo ""
	@echo "***************"
	@echo "flash program "
	@echo "***************"
	$(FLASH) -c $(PROGRAMMER) -p $(MCU) -w $(BUILD)$(NAME).ihx 
	$(FLASH) -c $(PROGRAMMER) -p $(MCU) -v $(BUILD)$(NAME).ihx 

compile: $(MAIN_FILE)  $(SRC) $(INCLUDES)
	@echo ""
	@echo "******************"
	@echo "  compiling       "
	@echo "******************"
	-rm $(BUILD)* 
	$(SDAS) -g -l -o $(BUILD)$(NAME).rel $(MAIN_FILE)
	$(SDCC) $(CFLAGS) -Wl-u -o $(BUILD)$(NAME).ihx  $(BUILD)$(NAME).rel
	objcopy -Iihex -Obinary  $(BUILD)$(NAME).ihx $(BUILD)$(NAME).bin 
	ls -l $(BUILD)$(NAME).bin

tinyForth: compile flash 
	

read_eevars:
	@echo ""
	@echo "******************************"
	@echo " read eeprom system variables"
	@echo "******************************"
	$(FLASH) -c $(PROGRAMMER) -p $(MCU) -s eeprom -b 16 -r eevars.bin
	@hexdump -C eevars.bin 
	@rm eevars.bin 

reset:
	$(FLASH) -c $(PROGRAMMER) -p $(MCU) -R 


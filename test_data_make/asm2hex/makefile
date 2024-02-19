TOOL_CHAIN = ~/opt/riscv/bin
CROSS_COMPILE = $(TOOL_CHAIN)/riscv32-unknown-elf-
SRC_DIR=src
BUILD_DIR=build/
NAME=zero

$(BUILD_DIR)%.o: $(SRC_DIR)/%.s
	$(CROSS_COMPILE)as $< -o $@ -march=rv32i
$(BUILD_DIR)%.om: $(BUILD_DIR)%.o
	$(CROSS_COMPILE)ld $< -o $@
$(BUILD_DIR)%.bin: $(BUILD_DIR)%.om
	$(CROSS_COMPILE)objcopy -O binary $<  $@
	rm -f $(BUILD_DIR)*.o $(BUILD_DIR)*.om
$(BUILD_DIR)%.data: $(BUILD_DIR)%.bin
	python3 bin2ascii.py $< $@
$(BUILD_DIR)%.hex: $(BUILD_DIR)%.data 
	python3 hexformat.py $< $@
	rm -f $(BUILD_DIR)*.data
	
all: $(BUILD_DIR)$(NAME).bin $(BUILD_DIR)$(NAME).hex
clean:
	rm -f $(BUILD_DIR).o $(BUILD_DIR)*.om $(BUILD_DIR)*.bin $(BUILD_DIR)*.hex $(BUILD_DIR)*.data
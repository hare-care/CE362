TOOL_CHAIN = ~/opt/riscv/bin
CROSS_COMPILE = $(TOOL_CHAIN)/riscv32-unknown-elf-
SRC_DIR=src/
BUILD_DIR=build/
NAME=zero

$(BUILD_DIR)%.o: $(SRC_DIR)%.c  #compile
	$(CROSS_COMPILE)gcc -o $@ $<
$(BUILD_DIR)%.s: $(SRC_DIR)%.c #make assemble file
	$(CROSS_COMPILE)gcc -S $< -o $@ 
	rm -f $(BUILD_DIR)*.o 
all: $(BUILD_DIR)$(NAME).s
clean:
	rm -f $(BUILD_DIR).o $(BUILD_DIR)*.s 
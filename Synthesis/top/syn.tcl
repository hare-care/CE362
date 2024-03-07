# importing libraries
set_db library /vol/ece303/genus_tutorial/NangateOpenCellLibrary_typical.lib
set_db lef_library /vol/ece303/genus_tutorial/NangateOpenCellLibrary.lef

# ifetch 
read_hdl ../../src/defines.v ../../src/ifetch.v ../../src/mini_decoder.v ../../src/mem_reg_library.v
elaborate

# decode
read_hdl ../../src/defines.v ../../src/decode_stage.v ../../src/decoder.v ../../src/mem_reg_library.v ../../src/branch_unit.v
elaborate


# execution
read_hdl ../../src/defines.v ../../src/alu.v ../../src/mul.v ../../src/execution.v
elaborate


# memory
read_hdl ../../src/defines.v ../../src/mem_access.v
elaborate


# writeback
read_hdl ../../src/defines.v ../../src/write_back.v
elaborate

# hazard and control
read_hdl ../../src/defines.v ../../src/control.v 
elaborate

read_hdl ../../src/defines.v ../../src/hazard.v 
elaborate

# read sdc file
read_sdc ../alu_conv.sdc

# core
read_hdl ../../src/defines.v ../../src/core.v
elaborate
current_design core
syn_generic
syn_map
syn_opt





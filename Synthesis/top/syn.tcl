# importing libraries
set_db library /vol/ece303/genus_tutorial/NangateOpenCellLibrary_typical.lib
set_db lef_library /vol/ece303/genus_tutorial/NangateOpenCellLibrary.lef

# ifetch 
read_hdl ../../src/defines.v ../../src/ifetch.v ../../src/mini_decoder.v ../../src/mem_reg_library.v
elaborate
current_design ifetch
syn_generic
syn_map
syn_opt

# decode
read_hdl ../../src/defines.v ../../src/decode_stage.v ../../src/decoder.v ../../src/mem_reg_library.v ../../src/branch_unit.v
elaborate
current_design decode_stage
syn_generic
syn_map
syn_opt

# execution
read_hdl ../../src/defines.v ../../src/alu.v ../../src/mul.v ../../src/execution.v
elaborate
current_design execution
syn_generic
syn_map
syn_opt

# memory
read_hdl ../../src/defines.v ../../src/mem_access.v
elaborate
current_design mem_access
syn_generic
syn_map
syn_opt

# writeback
read_hdl ../../src/defines.v ../../src/write_back.v
elaborate
current_design write_back
syn_generic
syn_map
syn_opt

# hazard and control
read_hdl ../../src/defines.v ../../src/control.v 
elaborate
current_design control
syn_generic
syn_map
syn_opt

read_hdl ../../src/defines.v ../../src/hazard.v 
elaborate
current_design hazard
syn_generic
syn_map
syn_opt
# read sdc file
read_sdc ../alu_conv.sdc

# core
read_hdl ../../src/defines.v ../../src/core.v
elaborate
current_design core
syn_generic
syn_map
syn_opt





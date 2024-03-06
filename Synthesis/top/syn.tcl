# importing libraries
set_db library /vol/ece303/genus_tutorial/NangateOpenCellLibrary_typical.lib
set_db lef_library /vol/ece303/genus_tutorial/NangateOpenCellLibrary.lef

#
read_hdl ../../src/defines.v ../../src/alu.v
elaborate

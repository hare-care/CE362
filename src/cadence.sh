source /vol/ece303/genus_tutorial/cadence.env
xrun -64bit -gui -access r defines.v alu.v decoder.v decode_stage.v execution.v ifetch.v mem_access.v mem_reg_library.v write_back.v control.v pipeline_top.v ./TB/Top_tb.v
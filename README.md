# CE362
CE362 Computer Architecture Project


## Recent update on modules:

* move operand select from execution to decoder_stage
* Identify Rdst_in and Rdst_out in decoder stage
* change most statements to always combination from assign 
* Optimize the branch and jump structures within execution stage and mem_access stage
* add all the data and control signals in Top level
* Check overall syntax, especially wire and reg
* Fix errors on wrEn, memwren, from active trigger to negative trigger
* Finish top level constructions, go thorugh basic operation using Pipeline1.s
## Current Stage
* add mini decoder to do JAL and static branch prediction at IF stage
* add branch and JALR calculation at Dec stage, need to stall and wait 1 cycle if conflict
* add data forwarding at Dec and Exec, detect the conflict at Dec, forward the data at Exec
## Future improvement
* data hazard and control hazard for branch and jump.
* testing with Pipeline2.s

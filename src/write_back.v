// pass rd to decode_stage
module write_back(
    //control unit
    input wb_sel,
    //from mem_access
    input [31:0] ALU_result,
    input [31:0]DataWord,
    input [31:0]instruction_WB,
    //write back data output 
    output [31:0]RWrdata,
    output [6:0] opcode_WB

);
//wb_sel 0->ALU_result  1->DataWord

assign RWrdata = (wb_sel)? DataWord:ALU_result; // data back to register 

assign opcode_WB = instruction_WB[6:0];
endmodule
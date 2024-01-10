// pass rd to decode_stage
module write_back(
    input [31:0] ALU_result,
    input [31:0]DataWord,
    //control unit
    input wb_sel,
    output [31:0]RWrdata

);

assign RWrdata = (wb_sel)? DataWord:ALU_result; // data back to register 

endmodule
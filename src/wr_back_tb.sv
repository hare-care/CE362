module write_back_tb ();


logic wb_sel_in;
logic [31:0] ALU_result_in;
logic [31:0] DataWord_in;
logic [31:0] RWrdata_out;

write_back DUT (
    .ALU_result(ALU_result_in),
    .DataWord(DataWord_in),
    .wb_sel(wb_sel_in),
    .RWrdata(RWrdata_out)
);

initial begin
    ALU_result_in = 32'b1;
    DataWord_in = 32'b10;
    wb_sel_in = 1'b0;
    #5
    $display(RWrdata_out);
    wb_sel_in = 1'b1;
    #5
    $display(RWrdata_out);
    $finish;
end

endmodule
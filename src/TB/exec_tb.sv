`timescale 1ns/1ns

module example_tb;

// IO file names
localparam string INPUT_FILE_NAME  = "../tests/exec/in.txt";
localparam string OUTPUT_FILE_NAME  = "../tests/exec/out.txt";
localparam string COMPARE_FILE_NAME  = "../tests/exec/cmp.txt";


localparam CLOCK_PERIOD = 10;

logic clock = 1'b1;
logic reset = 1'b1;
logic start = '0;
logic done = '0;

integer out_errors = '0;

// DUT IO signals
logic [5:0]     ALU_Control_in;
logic [1:0]     op_A_sel_in; 
logic           op_B_sel_in;          
logic [31:0]    Rdata1_in; 
logic [31:0]    Rdata2_in; 
logic [31:0]    imm32_in;
logic [31:0]    PC_in;
logic [31:0]    ALU_result_out;
logic           jump_flag_out;
logic [31:0]    jump_target_PC_out;


// Setting DUT
execution DUT (
    .ALU_Control(ALU_Control_in),
    .op_A_sel(op_A_sel_in),
    .op_B_sel(op_B_sel_in),
    .Rdata1(Rdata1_in),
    .Rdata2(Rdata2_in),
    .imm32(imm32_in),
    .PC(PC_in),
    .ALU_result(ALU_result_out),
    .jump_flag(jump_flag_out),
    .jump_target_PC(jump_target_PC_out)
);

// Creating Clock
always begin
    clock = 1'b1;
    #(CLOCK_PERIOD/2);
    clock = 1'b0;
    #(CLOCK_PERIOD/2);
end

// Reset for one clock cycle
initial begin
    @(posedge clock);
    reset = 1'b0;
    @(posedge clock);
    reset = 1'b1;
end


// Testbench Process
// Starts and waits for "done" to be true
initial begin: tb_process
    longint unsigned start_time, end_time;

    @(posedge reset);
    @(posedge clock);
    start_time = $time;

    $display("@ %0t: Beginning Simulation...", start_time);
    start = 1'b1;
    @(posedge clock);
    start = 1'b0;

    wait(done);
    end_time = $time;

    $display("@ %0t: Simulation completed.", end_time);
    $display("Total simulation cycle count: %0d", (end_time-start_time)/CLOCK_PERIOD);
    $display("Total error count: %0d", out_errors);

    $finish;
end

initial begin: input_read_process
    integer input_file, r;
    r = 1;

    @(posedge reset);
    $display("@ %0t: Loading file %s...", $time, INPUT_FILE_NAME);

    input_file = $fopen(INPUT_FILE_NAME, "rb");

    while (r != -1) begin
        @(negedge clock);
        r = $fscanf(input_file, "%h %h %h %h %h %h %h", ALU_Control_in, op_A_sel_in, op_B_sel_in, 
                                            Rdata1_in, Rdata2_in, imm32_in, PC_in);

    end

    $fclose(input_file);
end

initial begin: result_write_process
    integer output_file, compare_file, i, r;
    logic [31:0] ALU_result_cmp;
    logic [31:0] jump_target_PC_cmp;
    logic        jump_flag_cmp;
    r = 1;

    @(posedge reset);
    @(negedge clock);

    $display("@ %0t: Comparing file %s...", $time, OUTPUT_FILE_NAME);

    output_file = $fopen(OUTPUT_FILE_NAME, "wb");
    compare_file = $fopen(COMPARE_FILE_NAME, "rb");
    i = 0;
    while (r != -1) begin
        @(negedge clock);
        r = $fscanf(compare_file, "%h %h %h", ALU_result_cmp, jump_flag_cmp, jump_target_PC_cmp);
        $fwrite(output_file, "%h %h %h\n", ALU_result_out, jump_flag_out, jump_target_PC_out);
        
        if (ALU_result_cmp != {ALU_result_out}) begin
            out_errors++;
            $display("@ %0t: %s(%0d): ERROR: ALU_result %h != %h at address 0x%h.", $time, OUTPUT_FILE_NAME, i+1, {ALU_result_out}, ALU_result_cmp, i);
        end
        if (jump_flag_cmp != {jump_flag_out}) begin
            out_errors++;
            $display("@ %0t: %s(%0d): ERROR: jump_flag %h != %h at address 0x%h.", $time, OUTPUT_FILE_NAME, i+1, {jump_flag_out}, jump_flag_cmp, i);
        end
        if (jump_target_PC_cmp != {jump_target_PC_out}) begin
            out_errors++;
            $display("@ %0t: %s(%0d): ERROR: jump_PC_target %h != %h at address 0x%h.", $time, OUTPUT_FILE_NAME, i+1, {jump_target_PC_out}, jump_target_PC_cmp, i);
        end
        
        i++;
    end

    @(negedge clock);
    $fclose(output_file);
    $fclose(compare_file);

    done = 1'b1;
end








endmodule
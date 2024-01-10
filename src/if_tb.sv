`timescale 1ns/10ps

module example_tb;

// IO file names
localparam string INPUT_FILE_NAME  = "../tests/alu/in.txt";
localparam string OUTPUT_FILE_NAME  = "../tests/alu/out.txt";
localparam string COMPARE_FILE_NAME  = "../tests/alu/cmp.txt";


localparam CLOCK_PERIOD = 10;

logic clock = 1'b1;
logic reset = 1'b1;
logic start = '0;
logic done = '0;

integer out_errors = '0;

// DUT IO signals
logic [31:0] branch_pc_in = 32'b0;
logic [31:0] instruction_out, PC_out;
logic npc_control_in = 1'b0;


// Setting DUT
ifetch DUT (
    .branch_pc(branch_pc_in),
    .npc_control(npc_control_in),
    .rst(reset),
    .clk(clock),
    .instruction(instruction_out),
    .PC(PC_out)
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

    $readmemh("../sim/alu-mem_in.hex", DUT.IMEM.Mem);
    @(posedge reset);
    #50
    done = 1'b1;

end








endmodule
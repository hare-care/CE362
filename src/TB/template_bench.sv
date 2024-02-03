`timescale 1ns/10ps

module example_tb;

// IO file names
localparam string INPUT_FILE_NAME  = "../tests/alu/in.txt";
localparam string OUTPUT_FILE_NAME  = "../tests/alu/out.txt";
localparam string COMPARE_FILE_NAME  = "../tests/alu/cmp.txt";


localparam CLOCK_PERIOD = 10;

logic clock = 1'b1;
logic reset = '0;
logic start = '0;
logic done = '0;

integer out_errors = '0;

// DUT IO signals
logic [3:0] alu_op_in = 1'b1;
logic [31:0] a_in, b_in;
logic [31:0] result_out;


// Setting DUT
alu DUT (
    .alu_op(alu_op_in),
    .a(a_in),
    .b(b_in),
    .result(result_out)
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
    reset = 1'b1;
    @(posedge clock);
    reset = 1'b0;
end


// Testbench Process
// Starts and waits for "done" to be true
initial begin: tb_process
    longint unsigned start_time, end_time;

    @(negedge reset);
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

    @(negedge reset);
    $display("@ %0t: Loading file %s...", $time, INPUT_FILE_NAME);

    input_file = $fopen(INPUT_FILE_NAME, "rb");

    while (r != -1) begin
        @(negedge clock);
        r = $fscanf(input_file, "%h %h %h", alu_op_in, a_in, b_in);

    end

    $fclose(input_file);
end


initial begin: result_write_process
    integer output_file, compare_file, i, r;
    logic [31:0] cmp_out;
    r = 1;

    @(negedge reset);
    @(negedge clock);

    $display("@ %0t: Comparing file %s...", $time, OUTPUT_FILE_NAME);

    output_file = $fopen(OUTPUT_FILE_NAME, "wb");
    compare_file = $fopen(COMPARE_FILE_NAME, "rb");
    i = 0;
    while (r != -1) begin
        @(negedge clock);
        r = $fscanf(compare_file, "%h", cmp_out);
        $fwrite(output_file, "%h\n", result_out);
        
        if (cmp_out != {result_out}) begin
            out_errors++;
            $display("@ %0t: %s(%0d): ERROR: %h != %h at address 0x%h.", $time, OUTPUT_FILE_NAME, i+1, {result_out}, cmp_out, i);
        end
        i++;
    end

    @(negedge clock);
    $fclose(output_file);
    $fclose(compare_file);

    done = 1'b1;
end






endmodule
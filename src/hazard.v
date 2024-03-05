module hazard (
    input clk, rst,
    input [31:0] instruction,
    output stall_if, stall_dec, stall_ex
);

localparam state1 = 3'b000;
localparam state2 = 3'b001;
localparam state3 = 3'b011;

reg [2:0] state;
wire [2:0] state_c;
reg [4:0] wr_reg_hold;
wire [4:0] wr_reg_hold_c;

wire [6:0] opcode;
wire [4:0] wr_register;

assign opcode = instruction[6:0];
assign wr_register = instruction[11:7];

assign

always @(posedge clk or negedge rst) begin
    if (rst == 1'b0) begin
        state <= 3'b0;
        wr_reg_hold <= 5'b0;
    end
    else begin
        state <= state_c;
        wr_reg_hold <= wr_reg_hold_c;
    end
end

always @(*) begin
    case (state)
    state1: 
    begin
        // if find ld go to next state
        stall_if <= 1'b0;
        stall_ex <= 1'b0;
        stall_dec <= 1'b0;
        if (opcode == `I_TYPE_LOAD) begin
            wr_reg_hold_c <= wr_register;
            state_c <= state2;
        end
        else begin
            wr_reg_hold_c <= 5'b0;
            state_c <= state1;
        end

    end
    state2: 
    begin
        // if find a read with the proper register, stall
        // else go back to looking for ld
        // if (opcode == `I_TYPE_LOAD) begin
        //     wr_reg_hold_c <= register;
        //     state_c <= state2;
        // end
        // JALR (1); branch (2); store (2); I-type (1); R-type (2); Load (1)
        wr_reg_hold_c <= 5'b0;
        state_c <= state1;
        if (opcode == `I_TYPE_LOAD) begin
            if (instruction[19:15] == wr_reg_hold) begin
                // do output
                stall_if <= 1'b1;
                stall_ex <= 1'b1;
                stall_dec <= 1'b1;
            end
            wr_reg_hold_c <= register;
            state_c <= state2;
        end
        else if (opcode == `B_TYPE && (instruction[24:20] == wr_reg_hold || instruction[19:15] == wr_reg_hold)) begin
            // do output
            stall_if <= 1'b1;
            stall_ex <= 1'b1;
            stall_dec <= 1'b1;
        end
        else if (opcode == `S_TYPE && (instruction[24:20] == wr_reg_hold || instruction[19:15] == wr_reg_hold)) begin
            // do output
            stall_if <= 1'b1;
            stall_ex <= 1'b1;
            stall_dec <= 1'b1;
        end
        else if (opcode == `R_TYPE && (instruction[24:20] == wr_reg_hold || instruction[19:15] == wr_reg_hold)) begin
            // do output
            stall_if <= 1'b1;
            stall_ex <= 1'b1;
            stall_dec <= 1'b1;
        end
        else if (opcode == `I_TYPE && instruction[19:15] == wr_reg_hold) begin
            // do output
            stall_if <= 1'b1;
            stall_ex <= 1'b1;
            stall_dec <= 1'b1;
        end
        else if (opcode == `I_JALR && instruction[19:15] == wr_reg_hold) begin
            // do output
            stall_if <= 1'b1;
            stall_ex <= 1'b1;
            stall_dec <= 1'b1;
        end
    end
    endcase
end




endmodule
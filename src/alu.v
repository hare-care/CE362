module alu
(
    input [2:0] alu_op,
    input [31:0] a, b,
    output [31:0] result
);
    wire [31:0] add_result, sub_result, sl_result,
                and_result, or_result, xor_result,
                sra_result, srl_result;
    reg [31:0] result_temp;

    assign add_result = a + b;
    assign sub_result = a - b;
    assign sl_result = 32'b0;
    assign and_result = a & b;
    assign or_result = a | b;
    assign xor_result = a ^ b;
    assign sra_result = 32'b0;
    assign sla_result = 32'b0;

    assign result = result_temp;
    always @(*) begin
        case (alu_op)
            3'b000 : result_temp <= a + b;
            3'b001 : result_temp <= a + (~b + 1);
            3'b010 : result_temp <= a + (~b + 1);
            3'b011 : result_temp <= a + (~b + 1);
            3'b100 : result_temp <= a + (~b + 1);
            3'b101 : result_temp <= a + (~b + 1);
            3'b110 : result_temp <= a + (~b + 1);
            3'b111 : result_temp <= a + (~b + 1);
            default : result_temp <= 32'b0;
        endcase
    end



endmodule
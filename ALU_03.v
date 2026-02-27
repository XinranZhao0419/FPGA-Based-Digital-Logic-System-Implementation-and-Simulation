module ALU_03 (
    input  wire [31:0] a,        
    input  wire [31:0] b,         
    input  wire [3:0]  operator,  
    output reg  [31:0] out        
);

    reg [32:0] tmp;

    always @(*) begin
        out = 32'd0;
        tmp = 33'd0;

        case (operator)

            // ADD（1010）
            4'b1010: begin
                tmp = {1'b0, a} + {1'b0, b};
                out = tmp[31:0];
            end

            // SUB（1011）
            4'b1011: begin
                tmp = {1'b0, a} - {1'b0, b};
                out = tmp[31:0];
            end

            // OR（0010）
            4'b0010: begin
                out = a | b;
            end

            // AND（1101）
            4'b1101: begin
                out = a & b;
            end

            // NOT（1110）
            4'b1110: begin
                out = ~a;
            end

            // XOR（0101）
            4'b0101: begin
                out = a ^ b;
            end

            // NXOR（0110） = XNOR
            4'b0110: begin
                out = ~(a ^ b);
            end

            // ROR（0111）
            4'b0111: begin
                out = {a[0], a[31:1]};
            end

            default: out = 32'd0;
        endcase
    end

endmodule

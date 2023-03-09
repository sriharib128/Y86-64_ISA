module ALU(A,B,CONTROL,OUTPUT,overflow);
input signed [63:0] A;
input signed [63:0] B;
input [1:0] CONTROL;
output signed [63:0] OUTPUT;
reg signed [63:0] OUTPUT;
output overflow;
reg overflow;

wire signed [63:0] out_sum;
wire signed [63:0] out_diff;
wire signed [63:0] out_and;
wire signed [63:0] out_xor;
wire of_add,of_diff;

add_64 g1(A,B,out_sum,of_add);
sub_64 g2(A,B,out_diff,of_diff);
and_64 g3(A,B,out_and);
xor_64 g4(A,B,out_xor);

always @ (*) begin
    case(CONTROL)
        2'b00:begin
            OUTPUT = out_sum;
            overflow = of_add;
        end
        2'b01:begin
            OUTPUT = out_diff;
            overflow = of_diff;
        end
        2'b10:begin
            OUTPUT = out_and;
            overflow = 0;
        end
        2'b11:begin
            OUTPUT = out_xor;
            overflow = 0;
        end
    endcase
end
endmodule

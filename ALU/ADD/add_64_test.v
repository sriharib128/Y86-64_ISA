`timescale 1ns / 1ps
`include "./fulladder1bit.v"
`include "./add_64.v"

module testbench;
wire signed [63:0]OUTPUT;
wire overflow;
reg  signed [63:0]A;
reg  signed [63:0]B;
add_64 gate2(A,B,OUTPUT,overflow);

initial begin
    $dumpfile("runfile.vcd");
    $dumpvars(0,testbench);
    A = 64'b0000;
    B = 64'b0000;
end

initial  begin
$monitor("\ninputs A= ",A," B= ",B,"\noutputs = ",OUTPUT," overflow= ",overflow);

#10
A = 64'b0111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111;
B = 64'b0111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111;

#10
A = 64'b1000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;
B = 64'b1000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;

#10
A = 64'b0111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111;
B = 64'b1000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;

#10
A = 64'b1000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;
B = 64'b0111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111;

#10
A = 64'b1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111;
B = 64'b1000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;

#10
A = 64'b0101;
B = 64'b1110;

end
endmodule
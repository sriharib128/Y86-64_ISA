`timescale 1ns / 1ps

module xor_64(A,B,OUTPUT);
    input signed [63:0] A;
    input signed [63:0] B;
    output signed [63:0] OUTPUT;
    genvar i;
    generate for(i = 0;i<=63;i=i+1)
    begin
        xor(OUTPUT[i],A[i],B[i]);
    end
    endgenerate
endmodule
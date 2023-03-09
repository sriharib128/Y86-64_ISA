`timescale 1ns / 1ps

module add_64(A,B,OUTPUT,overflow);
    input signed [63:0] A;
    input signed [63:0] B;
    output signed [63:0] OUTPUT;
    output overflow;
    wire signed [64:0] carry;
    assign carry[0] = 1'b0;

    genvar i;

    generate for(i = 0;i<=63;i=i+1)
    begin
        Full gate1(A[i],B[i],carry[i],OUTPUT[i],carry[i+1]);
    end
    endgenerate

    // xor(overflow,carry[64],carry[63]);
    wire OF1,OF2,na,nb,ns;
    not(ns,OUTPUT[63]);
    not(nb,B[63]);
    not(na,A[63]);
    and(OF1,A[63],B[63],ns);
    and(OF2,na,nb,OUTPUT[63]);
    or(overflow,OF1,OF2);

endmodule
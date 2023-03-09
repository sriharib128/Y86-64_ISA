`timescale 1ns / 1ps

module sub_64(A,B,OUTPUT,overflow);
    input signed [63:0] A;
    input signed [63:0] B;
    output signed [63:0] OUTPUT;
    output overflow;
    wire overflow1;
    
    wire signed [63:0] nB;

    genvar i;

    generate for(i = 0;i<=63;i=i+1)
    begin
        not(nB[i],B[i]);
    end
    endgenerate

    wire [63:0] c;
    assign c = 64'b1;
    wire temp;

    wire signed [63:0] Bcomp;

    add_64 p1(nB,c,Bcomp,temp);

    add_64 p2(A,Bcomp,OUTPUT,overflow1);

    wire OF1,OF2,na,nb,ns;
    not(ns,OUTPUT[63]);
    not(nb,B[63]);
    not(na,A[63]);
    and(OF1,A[63],nb,ns);
    and(OF2,na,B[63],OUTPUT[63]);
    or(overflow,OF1,OF2);


endmodule
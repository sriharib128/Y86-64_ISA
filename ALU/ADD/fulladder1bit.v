`timescale 1ns / 1ps

module Full(a,b,c_in,s,c);
input a,b,c_in;
wire node1,node2,node3;
output s,c;

xor(s,a,b,c_in);
and(node1,a,b);
and(node2,c_in,b);
and(node3,a,c_in);

or(c,node1,node2,node3);

endmodule
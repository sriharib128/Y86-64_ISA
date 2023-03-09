module pipeline_ctrl(D_icode,d_srcA,d_srcB,E_icode,E_destM,e_Cnd,M_icode,m_stat,W_stat,setcc,F_stall,D_stall,D_bubble,E_bubble,M_bubble,W_stall);

input [3:0] D_icode;
input [3:0] d_srcA;
input [3:0] d_srcB;
input [3:0] E_icode;
input [3:0] E_destM;
input e_Cnd;
input [3:0] M_icode;
input [0:3] m_stat;
input [0:3] W_stat;

output reg setcc;
output reg F_stall;
output reg D_stall;
output reg D_bubble;
output reg E_bubble;
output reg M_bubble;
output reg W_stall;

always @(*) begin
    setcc = 1'b1;
    F_stall = 1'b0;
    D_stall = 1'b0; 
    D_bubble = 1'b0;
    E_bubble = 1'b0;
    M_bubble = 1'b0;
    W_stall = 1'b0;

    F_stall <= ( ((E_icode == 4'h3 || E_icode == 4'hB) && (E_destM == d_srcA || E_destM == d_srcB)) || (D_icode == 4'h9 || E_icode == 4'h9 || M_icode == 4'h9));
    D_stall <= ((E_icode == 4'h3 || E_icode == 4'hB) && (E_destM == d_srcA || E_destM == d_srcB));
    D_bubble <= (( E_icode == 4'h7 && !e_Cnd ) || (!(E_icode == 4'h3 || E_icode == 4'hB)  && (E_destM == d_srcA || E_destM== d_srcB) && (D_icode == 4'h9 || E_icode == 4'h9 || M_icode == 4'h9)));
    E_bubble <= (( E_icode == 4'h7 && !e_Cnd ) || ((E_icode == 4'h3 || E_icode == 4'hB)  && (E_destM == d_srcA || E_destM== d_srcB)));

    if(E_icode == 4'h0 | m_stat != 4'b1000 | W_stat != 4'b1000)
        begin
            setcc <= 1'b0;
        end
    end

endmodule

// D_bubble <= (( E_icode == 4'h7 && !e_Cnd ) || (!(E_icode == 4'h3 || E_icode == 4'hB)  && (((E_destM == d_srcA)&(d_srcA != 15)) || ((E_destM== d_srcB)&(d_srcB != 15))) && (D_icode == 4'h9 || E_icode == 4'h9 || M_icode == 4'h9)));
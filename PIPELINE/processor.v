`include "../ALU/ADD/fulladder1bit.v"
`include "../ALU/ADD/add_64.v"
`include "../ALU/AND/and_64.v"
`include "../ALU/SUB/sub_64.v"
`include "../ALU/XOR/xor_64.v"
`include "../ALU/alu.v"
`include "fetch.v"
`include "execute.v"
`include "decode_and_writeback.v"
`include "memory.v"
`include "pipeline_ctrl.v"

module processor;
    reg [0:3]stat_con = 4'b1000;
    reg clk;
    reg [7:0] Instruction_memory[0:1023]; //Instruction memory can have 1024 values of PC . 128 bytes with 8 bits each

    reg [0:79] current_instruction;
    wire [3:0] D_ifun,D_icode,D_rA,D_rB;
    wire signed [63:0] D_valC;
    wire [63:0] f_predPC,D_valP;
    wire  halt_prog , is_instruction_valid , pcvalid;

    wire [0:3] E_stat,D_stat,M_stat,W_stat,m_stat;

    wire [3:0] E_icode,E_ifun,d_srcA,d_srcB;
    wire signed [63:0] E_valC,E_valA,E_valB;
    wire [3:0] E_destE,E_destM,E_srcA,E_srcB;

    wire [3:0] M_icode,W_icode,e_destE,M_destE,M_destM,W_destE,W_destM;
    wire signed [63:0] M_valA, W_valM,e_valE,M_valE,m_valM,W_valE,e_valA;
    reg [63:0] F_predPC;
    wire M_Cnd,e_Cnd;
    wire [2:0] cc_in;

    wire F_stall,D_stall,D_bubble,E_bubble,M_bubble,W_stall,setcc;


    wire signed [63:0] register_memory0 , register_memory1 , register_memory2 ,register_memory3 , register_memory4 , register_memory5 ,register_memory6 ,register_memory7 ,register_memory8 , register_memory9 , register_memory10 ,register_memory11 , register_memory12 , register_memory13 , register_memory14; 

    Fetch fetch1(clk,F_predPC,f_predPC,M_valA,W_valM,M_Cnd,M_icode,W_icode,F_stall,D_stall,D_bubble,D_stat,D_icode,D_ifun,D_rA,D_rB,D_valC,D_valP,current_instruction,D_stat);
    decode_and_writeback decode1(clk,D_bubble,E_bubble,D_stat,D_icode,D_ifun,D_rA,D_rB,D_valC,D_valP,
                            e_destE,e_valE,M_destE,M_valE,M_destM,m_valM,W_destM,W_valM,W_destE,W_valE,
                            E_stat,E_icode,E_ifun,E_valC,E_valA,E_valB,E_destE,E_destM,E_srcA,E_srcB,
                            W_icode,d_srcA,d_srcB,
                            register_memory0 , register_memory1 , register_memory2 ,register_memory3 , register_memory4 , register_memory5 ,register_memory6 ,register_memory7 ,register_memory8 , register_memory9 , register_memory10 ,register_memory11 , register_memory12 , register_memory13 , register_memory14) ;

    Execute execute1(clk,E_stat,E_icode,E_ifun,E_valA,E_valB,E_valC,E_destE,E_destM,M_bubble,setcc,e_valE,e_destE,e_Cnd,M_stat,M_icode,M_Cnd,M_valE,M_valA,M_destE,M_destM,cc_in);
    data_memory memory1(clk,M_stat,M_icode,M_Cnd,M_valE,M_valA,M_destE,M_destM,m_stat,m_valM,W_stall,W_stat,W_icode,W_valE,W_valM,W_destE,W_destM);
    pipeline_ctrl ctrl1(D_icode,d_srcA,d_srcB,E_icode,E_destM,e_Cnd,M_icode,m_stat,W_stat,setcc,F_stall,D_stall,D_bubble,E_bubble,M_bubble,W_stall);
    

  always@(F_predPC) begin  
    current_instruction={
      Instruction_memory[F_predPC],
      Instruction_memory[F_predPC+1],
      Instruction_memory[F_predPC+2],
      Instruction_memory[F_predPC+3],
      Instruction_memory[F_predPC+4],
      Instruction_memory[F_predPC+5],
      Instruction_memory[F_predPC+6],
      Instruction_memory[F_predPC+7],
      Instruction_memory[F_predPC+8],
      Instruction_memory[F_predPC+9]
    };
  end

    always@(stat_con) begin
        if(stat_con==4'b0100) begin//halt//HLT
        $display("halt");
        $finish;
        end
        else if(stat_con==4'b0010) begin//Memory error//ADR
        $display("mem_error");
        $finish;
        end
        else if(stat_con==4'b0001) begin//invalid instruction//INS
        $display("instr_invalid");
        $finish;
        end
    end

    always @(W_stat)
    begin
        stat_con = W_stat;
    end

initial begin
    $dumpfile("processor.vcd");
    $dumpvars(0, processor);
end
always #10  begin 
        clk = ~clk;
    end
always @(posedge clk) 
        begin 
        if(!F_stall)
            F_predPC <= f_predPC ;
        end

always @(posedge clk)
    begin 
    $display("\n------------------------------------------------------------");
    $display("Fetch stage D_ :- clk=",clk," D_stat=",D_stat," F_predPC=",F_predPC," f_predPC=",f_predPC," icode=",D_icode," ifun=",D_ifun,"\n \t\t > rsp =",register_memory4," rA=",D_rA," rB=",D_rB," valC=",D_valC," D_valP=",D_valP);
    $display("Decode stage E_ :- clk=",clk," E_stat=",E_stat," icode=",E_icode," ifun=",E_ifun," rsp =",register_memory4,"\n \t\t > valA=",E_valA," valB=",E_valB, " valC=",E_valC," destE=",E_destE," destM=",E_destM," srcA=",E_srcA," srcB=",E_srcB);
    $display("Execute stage M_ :- clk=",clk," M_stat=",M_stat," icode=",M_icode," rsp =",register_memory4,"\n \t\t > CND=",e_Cnd," OF",cc_in[2]," SF",cc_in[1]," ZF",cc_in[0]," valA =",M_valA," valE=",M_valE," destE=",M_destE," destM=",M_destM);
    $display("Memory stage W_:- clk=",clk," W_stat=",W_stat," icode=",W_icode," rsp=",register_memory4,"\n \t\t > valM =",W_valM," valE=",W_valE," destE=",W_destE," destM=",W_destM);
    $display("fetch_stall",F_stall," D_bubble",D_bubble," D_stall",D_stall," E_bubble",E_bubble," M_bubble",M_bubble);
    $display("------------------------------------------------------------");
    end
initial begin
    stat_con = 4'b1000;//Normal Operation //AOK
    F_predPC=64'd0;
    clk=0;
Instruction_memory[0] = 8'h10; //nop
Instruction_memory[1]  = 8'h10; //nop

Instruction_memory[2] = 8'h20; //rrmovq
Instruction_memory[3] = 8'h12;

Instruction_memory[4] = 8'h30;//irmovq
Instruction_memory[5] = 8'hF2;
Instruction_memory[6] = 8'h00;
Instruction_memory[7] = 8'h00;
Instruction_memory[8] = 8'h00;
Instruction_memory[9] = 8'h00;
Instruction_memory[10] = 8'h00;
Instruction_memory[11] = 8'h00;
Instruction_memory[12] = 8'h00;
Instruction_memory[13] = 8'b00000010;

Instruction_memory[14] = 8'h40;//rmmovq
Instruction_memory[15] = 8'h24;
{Instruction_memory[16],Instruction_memory[17],Instruction_memory[18],Instruction_memory[19],Instruction_memory[20],Instruction_memory[21],Instruction_memory[22],Instruction_memory[23]} = 64'd1;

Instruction_memory[24] = 8'h40;//rmmovq
Instruction_memory[25] = 8'h53;
{Instruction_memory[26],Instruction_memory[27],Instruction_memory[28],Instruction_memory[29],Instruction_memory[30],Instruction_memory[31],Instruction_memory[32],Instruction_memory[33]} = 64'd0;

Instruction_memory[34] = 8'h50;//mrmovq
Instruction_memory[35] = 8'h53;
{Instruction_memory[36],Instruction_memory[37],Instruction_memory[38],Instruction_memory[39],Instruction_memory[40],Instruction_memory[41],Instruction_memory[42],Instruction_memory[43]} = 64'd0;

Instruction_memory[44] = 8'h60;//opq
Instruction_memory[45] = 8'h9A;

Instruction_memory[46] = 8'h73;//je
{Instruction_memory[47],Instruction_memory[48],Instruction_memory[49],Instruction_memory[50],Instruction_memory[51],Instruction_memory[52],Instruction_memory[53],Instruction_memory[54]} = 64'd56;

Instruction_memory[55] = 8'h00;

Instruction_memory[56] = 8'hA0;//pushq
Instruction_memory[57] = 8'h9F;

Instruction_memory[58] = 8'hB0;//popq
Instruction_memory[59] = 8'h9F;

Instruction_memory[60] = 8'h80;//call
{Instruction_memory[61],Instruction_memory[62],Instruction_memory[63],Instruction_memory[64],Instruction_memory[65],Instruction_memory[66],Instruction_memory[67],Instruction_memory[68]} = 64'd80;

Instruction_memory[69] = 8'h60;//OP
Instruction_memory[70] = 8'h56;

Instruction_memory[71] = 8'h70;//jump unconditional
{Instruction_memory[72],Instruction_memory[73],Instruction_memory[74],Instruction_memory[75],Instruction_memory[76],Instruction_memory[77],Instruction_memory[78],Instruction_memory[79]} = 64'd46;

Instruction_memory[80] = 8'h30;//irmovq
Instruction_memory[81] = 8'hF2;
Instruction_memory[82] = 8'h00;
Instruction_memory[83] = 8'h00;
Instruction_memory[84] = 8'h00;
Instruction_memory[85] = 8'h00;
Instruction_memory[86] = 8'h00;
Instruction_memory[87] = 8'h00;
Instruction_memory[88] = 8'h00;
Instruction_memory[89] = 8'b00000010;

Instruction_memory[90] = 8'h60;//OPq
Instruction_memory[91] = 8'h9A;

Instruction_memory[92] = 8'h10;//no op
Instruction_memory[93] = 8'h10;//halt

Instruction_memory[94] = 8'h90;// return
end
endmodule

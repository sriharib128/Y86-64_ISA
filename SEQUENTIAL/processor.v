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
`include "PC_Update.v"

module processor;
    reg [0:3]stat_con;
    wire [63:0] PC__Update;
    reg clk;
    reg [63:0]PC;
    wire [3:0] icode,ifun,rA,rB;
    wire signed [63:0] valA, valB, valC,valE,valM;
    wire  [63:0]valP;
    wire halt_prog,is_instruction_valid,pcvalid,cnd,memvalid;
    wire [2:0] cc_out;
    reg [2:0] cc_in;
    reg [7:0] Instruction_memory[0:255];
    reg [0:79] current_instruction;
    // wire ZF,SF,OF;
    wire signed [63:0] register_memory0 , register_memory1 , register_memory2 ,register_memory3 , register_memory4 , register_memory5 ,register_memory6 ,register_memory7 ,register_memory8 , register_memory9 , register_memory10 ,register_memory11 , register_memory12 , register_memory13 , register_memory14; 

    Fetch fetch1(clk, PC , icode , ifun , rA , rB , valC , valP , halt_prog , is_instruction_valid , pcvalid , current_instruction) ;
    decode_and_writeback decode1(valA , valB , valE , valM , clk , rA , rB , icode , cnd , register_memory0 , register_memory1 , register_memory2 ,register_memory3 , register_memory4 , register_memory5 ,register_memory6 ,register_memory7 ,register_memory8 , register_memory9 , register_memory10 ,register_memory11 , register_memory12 , register_memory13 , register_memory14) ;
    Execute execute1(icode,ifun,valA,valB,valC,valE,clk,cnd,cc_out,cc_in);

    always @(posedge clk) begin
        if(icode == 4'h6)
            begin   
                cc_in <=cc_out;
            end
    end

    data_memory memory1( clk , icode , valE , valA , valM , valP,memvalid) ;
    PC_UPDATE update1(clk,valP,valC,valM,cnd,icode,PC,PC__Update);

 always@(PC) begin

    current_instruction = {
      Instruction_memory[PC],
      Instruction_memory[PC+1],
      Instruction_memory[PC+2],
      Instruction_memory[PC+3],
      Instruction_memory[PC+4],
      Instruction_memory[PC+5],
      Instruction_memory[PC+6],
      Instruction_memory[PC+7],
      Instruction_memory[PC+8],
      Instruction_memory[PC+9]
    };
  end

always @(halt_prog,is_instruction_valid,memvalid,pcvalid)begin
    if(halt_prog == 1)begin 
        stat_con = 4'b0100;//halt//HLT
        $display("halt");
        $finish;
    end
    if((pcvalid == 1) || (memvalid == 1))begin 
        stat_con = 4'b0010;//Memory error//ADR
        $display("mem_error");
        $finish; 
    end
    if(is_instruction_valid == 0)begin 
        stat_con = 4'b0001;//invalid instruction//INS
        $display("instr_invalid");
        $finish; 
    end
end

initial begin
    $dumpfile("processor.vcd");
    $dumpvars(0, processor);
    stat_con = 4'b1000;//Normal Operation //AOK
    clk = 0;
    PC = 64'd1;

end
always #10  begin 
        clk = ~clk;
    end
always @(*) begin
    PC <= PC__Update;
end

always @(posedge clk)
    begin 
        $display(" > rsp = %d,PC = %d clk=%d \n > icode=%h ifun=%h rA=%d rB=%d,valC=%d,valP=%d,\n > valA = %d,valB = %d,valE = %d,valM = %d\n > ccodes OF,SF,ZF cc_in = %b || cc_out=%b and cnd = %b\n------------------------------------------------------------------\n",register_memory4,PC,clk,icode,ifun,rA,rB,valC,valP,valA,valB,valE,valM,cc_in,cc_out,cnd); 
    end

initial begin
    cc_in = 3'd0;
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

Instruction_memory[93] = 8'h90;// return
end
endmodule

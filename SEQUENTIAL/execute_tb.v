`include "../ALU/ADD/fulladder1bit.v"
`include "../ALU/ADD/add_64.v"
`include "../ALU/AND/and_64.v"
`include "../ALU/SUB/sub_64.v"
`include "../ALU/XOR/xor_64.v"
`include "../ALU/alu.v"
`include "fetch.v"
`include "decode_and_writeback.v"
`include "execute.v"

module execute_tb;

    reg clk;
    reg [63:0]PC;
    wire [3:0] icode,ifun,rA,rB;
    wire signed [63:0] valA, valB, valC,valE,valM;
    wire  [63:0]valP;
    wire halt_prog,is_instruction_valid , pcvalid,cnd; 
    reg [7:0] Instruction_memory[0:128];
    reg [0:79] current_instruction;
    wire [2:0] cc_out;
    reg [2:0] cc_in;
    wire signed [63:0] register_memory0 , register_memory1 , register_memory2 ,register_memory3 , register_memory4 , register_memory5 ,register_memory6 ,register_memory7 ,register_memory8 , register_memory9 , register_memory10 ,register_memory11 , register_memory12 , register_memory13 , register_memory14; 

    Fetch fetch1(clk, PC , icode , ifun , rA , rB , valC , valP , halt_prog , is_instruction_valid , pcvalid , current_instruction) ;
    decode_and_writeback decode1(valA , valB , valE , valM , clk , rA , rB , icode , cnd , register_memory0 , register_memory1 , register_memory2 ,register_memory3 , register_memory4 , register_memory5 ,register_memory6 ,register_memory7 ,register_memory8 , register_memory9 , register_memory10 ,register_memory11 , register_memory12 , register_memory13 , register_memory14) ;
    Execute execute1(icode,ifun,valA,valB,valC,valE,clk,cnd,cc_out,cc_in);

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

always@(icode) begin 
    if( halt_prog == 1)
    begin
        $finish; //stops the program if halt is encountered
    end
end
always@(pcvalid) begin 
    if(pcvalid == 1)begin
        $display("PC > 1023\n");
        $finish;
    end
end
always@(is_instruction_valid) begin 
    if(is_instruction_valid == 0)begin
        $display("invald instruction & pc is updated => now PC = %d",PC+1,"\n");
        PC = PC +1;
    end
end
always #3 
    begin 
        clk = ~clk;
    end
always @(posedge clk) 
    begin 
        PC <= valP; 
    end

initial begin
    $dumpfile("execute_tb.vcd");
    $dumpvars(0, execute_tb);
    clk = 0;
    PC = 64'd0;

end

always @(posedge clk)
    begin 
        $display("clk=%d icode=%h ifun=%h rA=%d rB=%d,valc=%d,valP=%d,valA = %d and valB = %d valE = %d",clk,icode,ifun,rA,rB,valC,valP,valA,valB,valE); 
    end

initial begin

   Instruction_memory[0]  = 8'h10; //nop pc = 1

    Instruction_memory[1] = 8'h20; //rrmovq
    Instruction_memory[2]  = 8'h01; //ra = 0 and rb =1 and pc = pc + 2 = 3

    Instruction_memory[3]  = 8'h30; //irmovq
    Instruction_memory[4]  = 8'h02; //F and rb = 2
    Instruction_memory[5]  = 8'hFF; //8bytes
    Instruction_memory[6]  = 8'hFF;
    Instruction_memory[7]  = 8'hFF;
    Instruction_memory[8]  = 8'hFF;
    Instruction_memory[9]  = 8'hFF;
    Instruction_memory[10]  = 8'hFF;
    Instruction_memory[11]  = 8'hFF;
    Instruction_memory[12]  = 8'hFF; //pc = pc +10 = 13

    Instruction_memory[13]  = 8'h60; //opq add
    Instruction_memory[14]  = 8'h23; //ra and rb pc = pc +2  = 15   

    Instruction_memory[15]  = 8'h70; //jmp
    Instruction_memory[16]  = 8'h00; //8bytes address
    Instruction_memory[17]  = 8'h00;
    Instruction_memory[18]  = 8'h00;
    Instruction_memory[19]  = 8'h00;
    Instruction_memory[20]  = 8'h00;
    Instruction_memory[21]  = 8'h00;
    Instruction_memory[22]  = 8'h11;
    Instruction_memory[23]  = 8'h10; //pc = pc+9 = 24

    Instruction_memory[24]  = 8'h80; //call
    Instruction_memory[25]  = 8'h00;//8byte destination
    Instruction_memory[26]  = 8'h00;
    Instruction_memory[27]  = 8'h00;
    Instruction_memory[28]  = 8'h10;
    Instruction_memory[29]  = 8'h00;
    Instruction_memory[30]  = 8'h00;
    Instruction_memory[31]  = 8'h00;
    Instruction_memory[32]  = 8'h01; //pc = pc+9 = 33
    
    Instruction_memory[33]  = 8'h90;//return and pc = pc+1 = 34; 
    
    Instruction_memory[34]  = 8'hA0; //pushq
    Instruction_memory[35]  = 8'h30; //ra and rb pc = pc+2 = 36

    Instruction_memory[36]  = 8'hB0; //popq
    Instruction_memory[37]  = 8'h30; //ra and rb pc = pc+2 = 38

    Instruction_memory[38]  = 8'h10; //invalid instruction

    Instruction_memory[39]  = 8'hB0; //popq
    Instruction_memory[40]  = 8'h30; //ra and rb pc = pc+2 = 38

    
    Instruction_memory[41]  = 8'h61; //opq sub
    Instruction_memory[42]  = 8'h9A; //ra and rb pc = pc +2  = 15

    Instruction_memory[43]  = 8'h63; //opq add
    Instruction_memory[44]  = 8'h56;

    Instruction_memory[45]  = 8'h00; //halt
    
end    
endmodule
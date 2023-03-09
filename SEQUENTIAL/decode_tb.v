`include "fetch.v"
`include "decode_and_writeback.v"

module decode_tb;

    reg clk;
    reg [63:0] PC;

    wire [3:0] icode,ifun,rA,rB;
    wire signed [63:0] valA, valB, valC,valE,valM;
    wire  [63:0]valP;
    wire is_instruction_valid , pcvalid; 
    reg [7:0] Instruction_memory[0:1023];
    reg [0:79] current_instruction;
    wire halt_prog;
    wire cnd = 1;

    wire signed [63:0] register_memory0 , register_memory1 , register_memory2 ,register_memory3 , register_memory4 , register_memory5 ,register_memory6 ,register_memory7 ,register_memory8 , register_memory9 , register_memory10 ,register_memory11 , register_memory12 , register_memory13 , register_memory14; 

    Fetch fetch1(clk, PC , icode , ifun , rA , rB , valC , valP , halt_prog , is_instruction_valid , pcvalid , current_instruction) ;
    decode_and_writeback decode1(valA , valB , valE , valM , clk , rA , rB , icode , cnd , register_memory0 , register_memory1 , register_memory2 ,register_memory3 , register_memory4 , register_memory5 ,register_memory6 ,register_memory7 ,register_memory8 , register_memory9 , register_memory10 ,register_memory11 , register_memory12 , register_memory13 , register_memory14) ;

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

always@(icode) 
    begin 
        if( halt_prog == 1)
        begin
            $finish; //stops the program if halt is encountered
        end
    end

always@(pcvalid) 
    begin 
        if(pcvalid == 1)begin
            $display("PC > 1023\n");
            $finish;
        end
    end

always@(is_instruction_valid) 
    begin 
        if(is_instruction_valid == 0)
        begin
            $display("invald instruction & pc is updated => now PC = %d",PC+1,"\n");
            PC = PC +1;
        end
    end
always #10 begin 
        clk = ~clk;
    end

always @(posedge clk) 
    begin 
        PC <= valP; 
    end

initial 
    begin
        $dumpfile("decode_tb.vcd");
        $dumpvars(0, decode_tb);
        clk = 0;
        PC = 64'd1;
    end

always @(posedge clk)
    begin 
        $display("clk=%d icode=%h ifun=%h rA=%d rB=%d,valc=%d,valP=%d,valA = %d and valB = %d\n",clk,icode,ifun,rA,rB,valC,valP,valA,valB); 
    end


initial begin

   Instruction_memory[1]  = 8'h10; //nop pc = 1

    Instruction_memory[2] = 8'h20; //rrmovq
    Instruction_memory[3]  = 8'h01; //ra = 0 and rb =1 and pc = pc + 2 = 3

    Instruction_memory[4]  = 8'h60; //opq add
    Instruction_memory[5]  = 8'h23; //ra and rb pc = pc +2  = 15   

    Instruction_memory[6]  = 8'h80; //call
    Instruction_memory[7]  = 8'h00;//8byte destination
    Instruction_memory[8]  = 8'h00;
    Instruction_memory[9]  = 8'h00;
    Instruction_memory[10]  = 8'h10;
    Instruction_memory[11]  = 8'h00;
    Instruction_memory[12]  = 8'h00;
    Instruction_memory[13]  = 8'h00;
    Instruction_memory[14]  = 8'h01; //pc = pc+9 = 33
    
    Instruction_memory[15]  = 8'h60; //opq add
    Instruction_memory[16]  = 8'h9A; //ra and rb pc = pc +2  = 15

    Instruction_memory[17]  = 8'h60; //opq add
    Instruction_memory[18]  = 8'h56;

    Instruction_memory[19]  = 8'h80; //call
    Instruction_memory[20]  = 8'h00;//8byte destination
    Instruction_memory[21]  = 8'h00;
    Instruction_memory[22]  = 8'h00;
    Instruction_memory[23]  = 8'h10;
    Instruction_memory[24]  = 8'h00;
    Instruction_memory[25]  = 8'h00;
    Instruction_memory[26]  = 8'h11;
    Instruction_memory[27]  = 8'h01; //pc = pc+9 = 33

    Instruction_memory[28]  = 8'h00; //halt
    
end
    
endmodule
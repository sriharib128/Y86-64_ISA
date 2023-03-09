module Fetch(clk, PC , icode , ifun , rA , rB , valC , valP , halt_prog , is_instruction_valid,pcvalid,current_instruction) ;

// 1. In the fetch stage, we need to read the instruction from current_instruction using the PC value
// 2. The first instruction byte is divided into two 4-bits referred to as icode and ifun
//    icode tells us the instruction
//    ifun tells the function of instruction ,else it is 0


// The inputs
input [63:0] PC ;
input clk ;
input [0:79] current_instruction; // max 10 bytes
// The outputs
output reg [3:0] ifun ;
output reg [3:0] icode ;
output reg [3:0] rA ;
output reg [3:0] rB ; 
output reg signed[63:0] valC ;
output reg [63:0] valP ;
output reg is_instruction_valid ;
output reg halt_prog ;
output reg pcvalid ;

// Registers
reg [0:7] byte1 ;//ifun icode
reg [0:7] byte2 ;//rA rB

// always@(posedge clk)
always@(*) 

  begin 

    byte1 = {current_instruction[0:7]} ;
    byte2 = {current_instruction[8:15]} ;

    icode = byte1[0:3];
    ifun  = byte1[4:7];

    is_instruction_valid = 1'b1 ;

    halt_prog = 0 ;
     
    // icode gives the instruction type
    if(icode == 4'b0000) // Halt instruction should be called
    begin
      halt_prog = 1;
      valP = PC + 64'd1;  // since only 1byte 
      $finish;
    end

    else if(icode == 4'b0001) //nop
    begin
      valP = PC + 64'd1;
    end

    else if(icode == 4'b0010) //cmovxx
    begin
      rA = byte2[0:3];
      rB = byte2[4:7];
      valP = PC + 64'd2;
    end

    else if(icode == 4'b0011) //irmovq
    begin
      rA = byte2[0:3];
      rB = byte2[4:7];
      valC = current_instruction[16:79];
      valP = PC + 64'd10;
    end

    else if(icode == 4'b0100) //rmmovq
    begin
      rA = byte2[0:3];
      rB = byte2[4:7];
      valC = current_instruction[16:79];

      valP = PC + 64'd10;
    end

    else if(icode == 4'b0101) //mrmovq
    begin
      rA = byte2[0:3];
      rB = byte2[4:7];
      valC = current_instruction[16:79];
      valP = PC + 64'd10;
    end

    else if(icode == 4'b0110) //OPq
    begin
      rA = byte2[0:3];
      rB = byte2[4:7];
      valP = PC + 64'd2;
    end

    else if(icode==4'b0111) //jxx
    begin
      valC = current_instruction[8:71];
      valP = PC + 64'd9;
    end

    else if(icode == 4'b1000) //call
    begin
      valC = current_instruction[8:71];
      valP = PC + 64'd9;
    end

    else if(icode == 4'b1001) //ret
    begin
      valP = PC+64'd1;
    end

    else if(icode == 4'b1010) //pushq
    begin
      rA = byte2[0:3];
      rB = byte2[4:7];
      valP = PC + 64'd2;
    end

    else if(icode==4'b1011) //popq
    begin
      rA = byte2[0:3];
      rB = byte2[4:7];
      valP = PC + 64'd2;
    end

    else 
    begin
      is_instruction_valid = 1'b0;
    end

    pcvalid = 0;
    if(PC > 1023)
    begin
      pcvalid = 1 ;
    end

  end

endmodule
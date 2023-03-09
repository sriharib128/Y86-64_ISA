`include "fetch.v"

module fetchtb;
  
  reg [63:0] PC;
  reg clk;
  // reg [7:0] memory[0:51] ;
  reg [7:0] Instruction_memory[0:1023]; //Instruction memory can have 1024 values of PC . 128 bytes with 8 bits each

  reg [0:79] current_instruction;
  wire [3:0] ifun,icode,rA,rB;
  wire [63:0] valC,valP;
  wire  halt_prog , is_instruction_valid , pcvalid;

  Fetch DUT(clk, PC , icode , ifun , rA , rB , valC , valP , halt_prog , is_instruction_valid , pcvalid , current_instruction) ;

  always@(PC) begin
    
    current_instruction={
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

  always @(icode) begin
    if(icode==0 && ifun==0) 
      $finish;
  end

  always #3 clk = ~clk;

  always @(posedge clk) PC<=valP;


// always @(posedge clk)
//     begin 
// 		$display("\nclk=",clk," PC=",PC," icode=",icode," ifun=",ifun," rA=",rA," rB=",rB," valC=",valC," valP=",valP," halt program =",halt_prog," is_instruction_valid = ",is_instruction_valid);
        
//         // $display("clk=%d icode=%h ifun=%h rA=%d rB=%d,valc=%d,valP=%d,valA = %d and valB = %d\n",clk,icode,ifun,rA,rB,valC,valP,valA,valB); 
//     end


  initial begin 
    clk=0; PC=64'd0;

    Instruction_memory[0] = 8'b01100000; //6 add
    Instruction_memory[1] = 8'b00000011; //%rax %rbx and store in rbx

    Instruction_memory[2] = 8'b00100000; // rrmovq 
    Instruction_memory[3] = 8'b00000011; // src = %rax dest = %rdx
    
    
    
    Instruction_memory[4] = 8'b01000000; //4-rmmovq 
    Instruction_memory[5] = 8'b00000011; //rax and (rbx)
    Instruction_memory[6] = 8'b00000000;  //VALC ---->from 6 to 13
    Instruction_memory[7] = 8'b00000000;
    Instruction_memory[8] = 8'b00000000;
    Instruction_memory[9] = 8'b00000000;
    Instruction_memory[10] = 8'b00000000;
    Instruction_memory[11] = 8'b00000000;
    Instruction_memory[12] = 8'b00000000;
    Instruction_memory[13] = 8'b00001111;
    

    Instruction_memory[14] = 8'b00010000; //no operation
    Instruction_memory[15] = 8'b00010000; //no operation
    Instruction_memory[16] = 8'b00000000; //halt

  end
 
  
  initial 
		$monitor("\nclk=",clk," PC=",PC," icode=",icode," ifun=",ifun," rA=",rA," rB=",rB," valC=",valC," valP=",valP," halt program =",halt_prog," is_instruction_valid = ",is_instruction_valid);
endmodule

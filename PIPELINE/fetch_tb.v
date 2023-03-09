`include "fetch.v"

module fetchtb;
  
  reg clk;
  reg [7:0] Instruction_memory[0:1023]; //Instruction memory can have 1024 values of PC . 128 bytes with 8 bits each

  reg [0:79] current_instruction;
  wire [3:0] D_ifun,D_icode,D_rA,D_rB;
  wire [0:3] D_stat;
  wire [63:0] D_valC,D_valP;
  wire [63:0] f_predPC;
  wire  halt_prog , is_instruction_valid , pcvalid;

  reg [3:0] M_icode,W_icode;
  reg signed [63:0] M_valA, W_valM;
  reg [63:0] F_predPC;
  reg M_Cnd;
  reg F_stall = 1'b0;
  reg D_bubble = 1'b0;
  reg D_stall = 1'b0;
  
  Fetch DUT(clk,F_predPC,f_predPC,M_valA,W_valM,M_Cnd,M_icode,W_icode,F_stall,D_stall,D_bubble,D_stat,D_icode,D_ifun,D_rA,D_rB,D_valC,D_valP,current_instruction,D_stat);

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

  always @(D_icode) begin
    if(D_icode==0 && D_ifun==0) 
      $finish;
  end


  always #3 clk = ~clk;

  always @(posedge clk) F_predPC <= f_predPC ;

  always @(posedge clk) 
		$display("\nclk=",clk," F_predPC=",F_predPC," f_predPC=",f_predPC," icode=",D_icode," ifun=",D_ifun,"\nrA=",D_rA," rB=",D_rB," valC=",D_valC," D_valP=",D_valP," D_stat=",D_stat,"\n-------------------------");


  initial begin 
    clk=0; F_predPC=64'd0;

    Instruction_memory[0] = 8'b00010000;
    Instruction_memory[1] = 8'b00010000;
    Instruction_memory[2] = 8'b01100000; //6 add
    Instruction_memory[3] = 8'b00000011; //%rax %rbx and store in rbx

    Instruction_memory[4] = 8'b00100000; // rrmovq 
    Instruction_memory[5] = 8'b00000011; // src = %rax dest = %rdx
  
    
    Instruction_memory[6] = 8'b01000000; //4-rmmovq 
    Instruction_memory[7] = 8'b00000011; //rax and (rbx)
    Instruction_memory[8] = 8'b00000000;  //VALC ---->from 6 to 13
    Instruction_memory[9] = 8'b00000000;
    Instruction_memory[10] = 8'b00000000;
    Instruction_memory[11] = 8'b00000000;
    Instruction_memory[12] = 8'b00000000;
    Instruction_memory[13] = 8'b00000000;
    Instruction_memory[14] = 8'b00000000;
    Instruction_memory[15] = 8'b00001111;
    

    Instruction_memory[16] = 8'b00010000; //no operation
    Instruction_memory[17] = 8'b00010000; //no operation

    Instruction_memory[18] = 8'b00000000; //halt

  end
 
endmodule

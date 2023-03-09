module Fetch(clk,F_predPC,f_predPC,M_valA,W_valM,M_Cnd,M_icode,W_icode,F_stall,D_stall,D_bubble,D_stat,D_icode,D_ifun,D_rA,D_rB,D_valC,D_valP,current_instruction,D_stat,PC);


// The inputs
input [63:0] F_predPC;
input clk ;
input [3:0] M_icode;
input [3:0] W_icode;
input signed [63:0] M_valA;
input signed [63:0] W_valM;
input M_Cnd;
input F_stall;
input D_stall;
input D_bubble;
input [0:79] current_instruction;

output reg [63:0] f_predPC;
output reg [3:0] D_ifun ;
output reg [3:0] D_icode ;
output reg [3:0] D_rA ;
output reg [3:0] D_rB ; 
output reg signed[63:0] D_valC ;
output reg [63:0] D_valP ;
output reg [0:3] D_stat;

// Registers
output reg [63:0] PC;
reg [0:7] byte1 ;//ifun icode
reg [0:7] byte2 ;//rA rB
reg [3:0] icode,ifun;
reg signed [63:0] valC;
reg [63:0] valP;
reg is_instruction_valid = 1'b1;
reg pcvalid = 1'b0;
reg halt_prog=1'b0;
reg [0:3] stat;
reg [3:0] rA,rB;

always @(*)
  begin
    if(M_icode == 4'b0111 & !M_Cnd)
      begin
        PC <= M_valA;
        f_predPC <=M_valA;
      end
    else if(W_icode == 4'b1001 )
      begin
        PC <= W_valM;
        f_predPC <= W_valM;
      end
    else
      PC <= F_predPC;
  end

always@(*) 

  begin 
    byte1 = {current_instruction[0:7]} ;
    byte2 = {current_instruction[8:15]} ;

    icode = byte1[0:3];
    ifun  = byte1[4:7];

    // halt_prog = 0 ;
     
    // icode gives the instruction type
    if(icode == 4'b0000) // Halt instruction should be called
    begin
      halt_prog = 1;
      valP = PC;  // since only 1byte
      f_predPC =  valP;
      // $finish;
    end

    else if(icode == 4'b0001) //nop
    begin
      valP = PC + 64'd1;
      f_predPC =  valP;
        // $display("77");
      
    end

    else if(icode == 4'b0010) //cmovxx
    begin
      rA = byte2[0:3];
      rB = byte2[4:7];
      valP = PC + 64'd2;
      f_predPC =  valP;
    end

    else if(icode == 4'b0011) //irmovq
    begin
      rA = byte2[0:3];
      rB = byte2[4:7];
      valC = current_instruction[16:79];
      valP = PC + 64'd10;
      f_predPC =  valP;
    end

    else if(icode == 4'b0100) //rmmovq
    begin
      rA = byte2[0:3];
      rB = byte2[4:7];
      valC = current_instruction[16:79];
      valP = PC + 64'd10;
      f_predPC =  valP;
    end

    else if(icode == 4'b0101) //mrmovq
    begin
      rA = byte2[0:3];
      rB = byte2[4:7];
      valC = current_instruction[16:79];
      valP = PC + 64'd10;
      f_predPC =  valP;
    end

    else if(icode == 4'b0110) //OPq
    begin
      rA = byte2[0:3];
      rB = byte2[4:7];
      valP = PC + 64'd2;
      f_predPC =  valP;
    end

    else if(icode==4'b0111) //jxx
    begin
      valC = current_instruction[8:71];
      valP = PC + 64'd9;
      f_predPC =  valC;
    end

    else if(icode == 4'b1000) //call
    begin
      valC = current_instruction[8:71];
      valP = PC + 64'd9;
      // $display("valC =",valC);
      f_predPC =  valC;
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
      f_predPC =  valP;
    end

    else if(icode==4'b1011) //popq
    begin
      rA = byte2[0:3];
      rB = byte2[4:7];
      valP = PC + 64'd2;
      f_predPC =  valP;
    end

    else 
    begin
      is_instruction_valid = 1'b0;
    end

    if(PC > 1023)
    begin
      pcvalid = 1'b1 ;
    end
  end

always @(*)begin
    stat = 4'b1000;
    if(halt_prog == 1)begin 
        stat = 4'b0100;//halt//HLT
        // $display("halt");
        // $finish;
    end
    if((pcvalid == 1))begin 
        stat = 4'b0010;//Memory error//ADR
        $display("mem_error");
        $finish; 
    end
    if(is_instruction_valid == 0)begin 
        stat = 4'b0001;//invalid instruction//INS
        $display("instr_invalid");
        $finish; 
    end
  end

  always @(posedge clk) begin
    // PC <= F_predPC;
    if (F_stall) 
      begin
        // F_predPC <= f_predPC;
        // PC = F_predPC;
      end
    if (D_stall) 
      begin  
      end
    else if (D_bubble) 
      begin
        D_icode <= 4'b0001;
        D_ifun <= 4'b0000;
        D_rA <= 4'b1111;
        D_rB <= 4'b1111;
        D_valC <= 64'b0;
        D_valP <= 64'b0;
        D_stat <= 4'b1000;
      end
    else
      begin
        D_icode <= icode;
        D_ifun <= ifun;
        D_rA <= rA;
        D_rB <= rB;
        D_valC <= valC;
        D_valP <= valP;
        D_stat <= stat;
      end
  end

endmodule
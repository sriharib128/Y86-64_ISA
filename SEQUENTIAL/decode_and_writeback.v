module decode_and_writeback(valA , valB , valE , valM , clk , rA , rB , icode , cnd , register_memory0 , register_memory1 , register_memory2 ,register_memory3 , register_memory4 , register_memory5 ,register_memory6 ,register_memory7 ,register_memory8 , register_memory9 , register_memory10 ,register_memory11 , register_memory12 , register_memory13 , register_memory14) ;

input clk ;
input [3:0] icode,rA,rB ;
input cnd ;
input signed [63:0] valE;
input [63:0] valM;
output reg signed [63:0] valA,valB ;
reg signed [63:0] register_memory[0:14] ;

// If we were to consider that we have 15 register_memory from %rax to %r14, the stack pointer is %rsp and it is in the 4th place
output reg signed [63:0] register_memory0;
output reg signed [63:0] register_memory1;
output reg signed [63:0] register_memory2;
output reg signed [63:0] register_memory3;
output reg signed [63:0] register_memory4;
output reg signed [63:0] register_memory5;
output reg signed [63:0] register_memory6;
output reg signed [63:0] register_memory7;
output reg signed [63:0] register_memory8;
output reg signed [63:0] register_memory9;
output reg signed [63:0] register_memory10;
output reg signed [63:0] register_memory11;
output reg signed [63:0] register_memory12;
output reg signed [63:0] register_memory13;
output reg signed [63:0] register_memory14;

// Decode stage
//randomly initialising register memory
initial 
  begin
    register_memory[0] = 64'd12;        //rax
    register_memory[1] = 64'd10;        //rcx
    register_memory[2] = 64'd101;       //rdx
    register_memory[3] = 64'd3;       //rbx
    register_memory[4] = 64'd254;       //rsp
    register_memory[5] = 64'd50;        //rbp
    register_memory[6] = -64'd143;      //rsi
    register_memory[7] = 64'd10000;     //rdi
    register_memory[8] = 64'd990000;    //r8
    register_memory[9] = -64'd12345;    //r9
    register_memory[10] = 64'd12345;    //r10
    register_memory[11] = 64'd10112;    //r11
    register_memory[12] = 64'd0;        //r12
    register_memory[13] = 64'd1567;     //r13
    register_memory[14] = 64'd8643;     //r14
  end

always@(*)
  begin
  
    if(icode == 4'b0010) //cmovxx
    begin
      valA = register_memory[rA] ;
      valB = 0 ;
    end

    else if(icode == 4'b0100) //rmmovq
    begin
      valA = register_memory[rA] ;
      valB = register_memory[rB] ;
    end

    else if(icode == 4'b0101) //mrmovq
    begin
      valA = 0 ;
      valB = register_memory[rB] ;
    end

    else if(icode == 4'b0110) //OPq
    begin
      valA = register_memory[rA] ;
      valB = register_memory[rB] ;
    end

    else if(icode == 4'b1000) //call
    begin
      // valA = 0; 
      valB = register_memory[4] ;
    end

    else if(icode == 4'b1001) //ret
    begin
      valA = register_memory[4] ;
      valB = register_memory[4] ;
    end

    else if(icode == 4'b1010) //pushq
    begin
      valA = register_memory[rA] ;
      valB = register_memory[4] ;
    end

    else if(icode == 4'b1011) //popq
    begin
      valA = register_memory[4] ;
      valB = register_memory[4] ;
    end
  end
  // Write back stage

always@(posedge clk)  
  begin

    if(icode == 4'b0010) //cmovxx
    begin
        if(cnd == 1'b1)  // cnd =1 when condition like < or  = or > or le etc are satisfied
        begin
          register_memory[rB] = valE ;
        end
    end
    else if(icode==4'b0011) //irmovq
      begin
        register_memory[rB] = valE;
      end
    else if(icode == 4'b0101) //mrmovq
      begin
          register_memory[rA] = valM ;
      end

    else if(icode == 4'b0110) //OPq
      begin
          register_memory[rB] = valE ;
      end

    else if(icode == 4'b1000) //call
      begin
          register_memory[4] = valE ;
      end

    else if(icode == 4'b1001) //ret
      begin
        register_memory[4] = valE ;
      end

    else if(icode == 4'b1010) //pushq
      begin
          register_memory[4] = valE ;
      end

    else if(icode == 4'b1011) //popq
      begin
          register_memory[4] = valE ;
          register_memory[rA] = valM ;
      end

    register_memory0 <= register_memory[0];
    register_memory1 <= register_memory[1];
    register_memory2 <= register_memory[2];
    register_memory3 <= register_memory[3];
    register_memory4 <= register_memory[4];
    register_memory5 <= register_memory[5];
    register_memory6 <= register_memory[6];
    register_memory7 <= register_memory[7];
    register_memory8 <= register_memory[8];
    register_memory9 <= register_memory[9];
    register_memory10 <= register_memory[10];
    register_memory11 <= register_memory[11];
    register_memory12 <= register_memory[12];
    register_memory13 <= register_memory[13];
    register_memory14 <= register_memory[14];
    
  end
endmodule

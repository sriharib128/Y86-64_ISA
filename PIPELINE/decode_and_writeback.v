module decode_and_writeback(clk,D_bubble,E_bubble,D_stat,D_icode,D_ifun,D_rA,D_rB,D_valC,D_valP,
                            e_destE,e_valE,M_destE,M_valE,M_destM,m_valM,W_destM,W_valM,W_destE,W_valE,
                            E_stat,E_icode,E_ifun,E_valC,E_valA,E_valB,E_destE,E_destM,E_srcA,E_srcB,
                            W_icode,d_srcA,d_srcB,
                            register_memory0 , register_memory1 , register_memory2 ,register_memory3 , register_memory4 , register_memory5 ,register_memory6 ,register_memory7 ,register_memory8 , register_memory9 , register_memory10 ,register_memory11 , register_memory12 , register_memory13 , register_memory14) ;

input clk ;
input [3:0] D_icode,D_ifun,D_rA,D_rB,e_destE,M_destE,M_destM,W_destE,W_destM,W_icode;
input [0:3] D_stat;
input signed [63:0] D_valC,e_valE,M_valE,m_valM,W_valE,W_valM;
input [63:0] D_valP;
input E_bubble,D_bubble;

output reg signed [63:0] E_valC,E_valA,E_valB;
output reg [3:0] E_icode,E_ifun,E_destE,E_destM,E_srcA,E_srcB,d_srcA,d_srcB;
output reg [0:3] E_stat;
reg [3:0] d_destE,d_destM;
reg signed [63:0] d_rvalA,d_rvalB,d_valA,d_valB;
reg [63:0] register_memory[0:14];

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
    register_memory[3] = 64'd3;         //rbx
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

    if(D_icode == 4'b0010) //cmovxx
    begin
      d_srcA = D_rA;
      d_destE = D_rB;
      d_rvalA = register_memory[D_rA] ;
      d_rvalB = 0 ;
    end

    else if(D_icode == 4'b0011) //irmovq
    begin
    // // // d_rvalB=64'b0 //
      d_destE=D_rB;
    end

    else if(D_icode == 4'b0100) //rmmovq
    begin
      d_srcA = D_rA;
      d_srcB = D_rB;
      d_rvalA = register_memory[D_rA] ;
      d_rvalB = register_memory[D_rB] ;
    end

    else if(D_icode == 4'b0101) //mrmovq
    begin
      d_srcB = D_rB;
      d_destM = D_rA;
      //d_rvalA = 0 ; // // //
      d_rvalB = register_memory[D_rB] ;
    end

    else if(D_icode == 4'b0110) //OPq
    begin
      d_srcA = D_rA;
      d_srcB = D_rB;
      d_destE = D_rB;
      d_rvalA = register_memory[D_rA] ;
      d_rvalB = register_memory[D_rB] ;
    end

    else if(D_icode == 4'b1000) //call
    begin
      d_srcB = 4;
      d_destE = 4;
      d_rvalB = register_memory[4] ;
    end

    else if(D_icode == 4'b1001) //ret
    begin
      d_srcA = 4;
      d_srcB = 4;
      d_destE = 4;
      d_rvalA = register_memory[4] ;
      d_rvalB = register_memory[4] ;
    end

    else if(D_icode == 4'b1010) //pushq
    begin
      d_srcA = D_rA;
      d_srcB = 4;
      d_destE = 4;
      d_rvalA = register_memory[D_rA] ;
      d_rvalB = register_memory[4] ;
    end

    else if(D_icode == 4'b1011) //popq
    begin
      d_srcA = 4;
      d_srcB = 4;
      d_destE = 4;
      d_destM = D_rA;
      d_rvalA = register_memory[4] ;
      d_rvalB = register_memory[4] ;
    end

    else
      begin
      d_srcA = 4'hF;
      d_srcB = 4'hF;
      d_destE = 4'hF;
      d_destM = 4'hF;
      end

      // Forwarding A
    if(D_icode==4'h7 | D_icode == 4'h8) //jxx or call
      d_valA = D_valP; //here we are using valA to hold value of valP
    else if(d_srcA==e_destE & e_destE!=4'hF)
      d_valA = e_valE;//data forwarding from execute to src register
    else if(d_srcA==M_destM & M_destM!=4'hF)
      d_valA = m_valM; //data forwarding from memory to src register
    else if(d_srcA==W_destM & W_destM!=4'hF)
      d_valA = W_valM; //data forwarding from write back stage
    else if(d_srcA==M_destE & M_destE!=4'hF)
      d_valA = M_valE; //data forwarding from memory stage
    else if(d_srcA==W_destE & W_destE!=4'hF)
      d_valA = W_valE;//data forwarding from writeback stage
    else
      d_valA = d_rvalA;//no Data forwading
    
    // Forwarding B
    if(d_srcB==e_destE & e_destE!=4'hF)      
      d_valB = e_valE;// data forwarding from execute stage
    else if(d_srcB==M_destM & M_destM!=4'hF) 
      d_valB = m_valM;// data forwarding from memory stage
    else if(d_srcB==W_destM & W_destM!=4'hF) 
      d_valB = W_valM; // data forwarding memory value from write back stage
    else if(d_srcB==M_destE & M_destE!=4'hF) 
      d_valB = M_valE; // data forwarding execute value from memory stage
    else if(d_srcB==W_destE & W_destE!=4'hF) 
      d_valB = W_valE; // data forwarding execute value from write back stage 
    else
      d_valB = d_rvalB;// no Data forwarding
  end

always@(posedge clk)
  begin 
    if(E_bubble)
    begin
    // $display("179");
      E_stat <= 4'b1000;
      E_icode <= 4'b0001;
      E_ifun <= 4'b0000;
      E_valC <= 4'b0000;
      E_valA <= 4'b0000;
      E_valB <= 4'b0000;
      E_destE <= 4'hF;
      E_destM <= 4'hF;
      E_srcA <= 4'hF;
      E_srcB <= 4'hF;
    end
    else
    begin
      // Execute register update
      E_stat <= D_stat;
      E_icode <= D_icode;
      E_ifun <= D_ifun;
      E_valC <= D_valC;
      E_valA <= d_valA;
      E_valB <= d_valB;
      E_srcA <= d_srcA;
      E_srcB <= d_srcB;
      E_destE <= d_destE;
      E_destM <= d_destM;
    end

  end

// Write back stage
always@(posedge clk)  
  begin

    if(W_icode == 4'b0010) //cmovxx
      begin
        register_memory[W_destE] = W_valE ;
      end
    else if(W_icode==4'b0011) //irmovq
      begin
        register_memory[W_destE] = W_valE;
      end
    else if(W_icode == 4'b0101) //mrmovq
      begin
          register_memory[W_destM] = W_valM ;
      end

    else if(W_icode == 4'b0110) //OPq
      begin
          register_memory[W_destE] = W_valE ;
      end

    else if(W_icode == 4'b1000) //call
      begin
          register_memory[W_destE] = W_valE ;
      end

    else if(W_icode == 4'b1001) //ret
      begin
        register_memory[W_destE] = W_valE ;
      end

    else if(W_icode == 4'b1010) //pushq
      begin
          register_memory[W_destE] = W_valE ;
      end

    else if(W_icode == 4'b1011) //popq
      begin
          register_memory[W_destE] = W_valE;
          register_memory[W_destM] = W_valM;
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

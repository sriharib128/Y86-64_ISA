`include "fetch.v"
`include "decode_and_writeback.v"

module decode_tb;

    reg clk;
    reg [7:0] Instruction_memory[0:1023]; //Instruction memory can have 1024 values of PC . 128 bytes with 8 bits each

    reg [0:79] current_instruction;
    wire [3:0] D_ifun,D_icode,D_rA,D_rB;
    wire signed [63:0] D_valC;
    wire [63:0] f_predPC,D_valP;
    wire  halt_prog , is_instruction_valid , pcvalid;

    wire [0:3] E_stat,D_stat;

    wire [3:0] E_icode,E_ifun,d_srcA,d_srcB;
    wire signed [63:0] E_valC,E_valA,E_valB;
    wire [3:0] E_dstE,E_dstM,E_srcA,E_srcB;

    reg [3:0] M_icode,W_icode,e_dstE,M_dstE,M_dstM,W_dstE,W_dstM;
    reg signed [63:0] M_valA, W_valM,e_valE,M_valE,m_valM,W_valE;
    reg [63:0] F_predPC;
    reg M_Cnd;
    reg F_stall = 1'b0;
    reg D_bubble = 1'b0;
    reg D_stall = 1'b0;


    wire signed [63:0] register_memory0 , register_memory1 , register_memory2 ,register_memory3 , register_memory4 , register_memory5 ,register_memory6 ,register_memory7 ,register_memory8 , register_memory9 , register_memory10 ,register_memory11 , register_memory12 , register_memory13 , register_memory14; 

    Fetch fetch1(clk,F_predPC,f_predPC,M_valA,W_valM,M_Cnd,M_icode,W_icode,F_stall,D_stall,D_bubble,D_stat,D_icode,D_ifun,D_rA,D_rB,D_valC,D_valP,current_instruction,D_stat);
    decode_and_writeback decode1(clk,D_bubble,D_stat,D_icode,D_ifun,D_rA,D_rB,D_valC,D_valP,
                            e_dstE,e_valE,M_dstE,M_valE,M_dstM,m_valM,W_dstM,W_valM,W_dstE,W_valE,
                            E_stat,E_icode,E_ifun,E_valC,E_valA,E_valB,E_dstE,E_dstM,E_srcA,E_srcB,
                            W_icode,d_srcA,d_srcB,
                            register_memory0 , register_memory1 , register_memory2 ,register_memory3 , register_memory4 , register_memory5 ,register_memory6 ,register_memory7 ,register_memory8 , register_memory9 , register_memory10 ,register_memory11 , register_memory12 , register_memory13 , register_memory14) ;

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
                $display("invald instruction & pc is updated => now PC = %d",F_predPC+1,"\n");
                F_predPC = F_predPC +1;
            end
        end
    always #3 begin 
            clk = ~clk;
        end

    always @(posedge clk) 
        begin 
            F_predPC <= f_predPC ;
        end

    initial 
        begin
            $dumpfile("decode_tb.vcd");
            $dumpvars(0, decode_tb);
        end

 always @(posedge clk) 
		$display("\nclk=",clk," F_predPC=",F_predPC," f_predPC=",f_predPC," icode=",D_icode," ifun=",D_ifun,"\nrA=",D_rA," rB=",D_rB," valC=",D_valC," D_valP=",D_valP," D_stat=",D_stat,"\n-------------------------");



initial begin
    clk=0; F_predPC=64'd0;

    Instruction_memory[0] = 8'b00010000;
    Instruction_memory[1]  = 8'h10; //nop pc = 1

    Instruction_memory[2] = 8'h20; //rrmovq
    Instruction_memory[3]  = 8'h01; //ra = 0 and rb =1 and pc = pc + 2 = 3

    Instruction_memory[4]  = 8'h60; //opq add
    Instruction_memory[5]  = 8'h23; //ra and rb pc = pc +2  = 15   
    
    Instruction_memory[6]  = 8'h60; //opq add
    Instruction_memory[7]  = 8'h9A; //ra and rb pc = pc +2  = 15

    Instruction_memory[8]  = 8'h60; //opq add
    Instruction_memory[9]  = 8'h56;

    Instruction_memory[10]  = 8'h80; //call
    Instruction_memory[11]  = 8'h00;//8byte destination = 19
    Instruction_memory[12]  = 8'h00;
    Instruction_memory[13]  = 8'h00;
    Instruction_memory[14]  = 8'h00;
    Instruction_memory[15]  = 8'h00;
    Instruction_memory[16]  = 8'h00;
    Instruction_memory[17]  = 8'h00;
    Instruction_memory[18]  = 8'h14; //pc = pc+9 = 33

    Instruction_memory[19]  = 8'h00; //halt

    Instruction_memory[20]  = 8'h10; //no op
    Instruction_memory[21]  = 8'h00; //halt
    
end
    
endmodule
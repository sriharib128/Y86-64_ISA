module data_memory(clk,M_stat,M_icode,M_Cnd,M_valE,M_valA,M_destE,M_destM,m_stat,m_valM,W_stall,W_stat,W_icode,W_valE,W_valM,W_destE,W_destM);

  input clk;
  input [0:3] M_stat;
  input [3:0] M_icode;
  input M_Cnd;
  input [63:0] M_valE;
  input [63:0] M_valA;
  input [3:0] M_destE;
  input [3:0] M_destM;
  input W_stall;

  output reg [0:3] m_stat;
  output reg signed [63:0] m_valM;
  output reg [0:3] W_stat;
  output reg [3:0] W_icode;
  output reg signed [63:0] W_valE;
  output reg signed [63:0] W_valA;
  output reg signed [63:0] W_valM;
  
  output reg [3:0] W_destE;
  output reg [3:0] W_destM;

  reg [63:0] data_memory [255:0];
  reg memvalid = 0;

  always @(*) begin
      if(memvalid)
      m_stat = 4'b0010;
      else
      m_stat = M_stat;
  end
 
  always@(*)
  begin
    
    //mrmovq
    if(M_icode == 4'b0101) 
    begin
      if(M_valE > 255)
        begin
            memvalid = 1;
        end
      m_valM = data_memory[M_valE] ;
    end

    // ret
    else if(M_icode == 4'b1001) 
    begin
      if(M_valA > 255)
          begin
              memvalid = 1;
          end
      m_valM = data_memory[M_valA];
    end
    
    // popq
    else if(M_icode == 4'b1011) 
    begin
      if(M_valE > 255)
        begin
            memvalid = 1;
        end
      m_valM = data_memory[M_valA];
    end
    else
      begin
        memvalid =0;
      end
  end

  always @ (posedge clk) begin
    memvalid=0;
    // rmmovq
    if(M_icode == 4'b0100) 
    begin
      if(M_valE > 255)
        begin
            memvalid = 1;
        end
      data_memory[M_valE] <= M_valA;
    end

    // call
    else if(M_icode == 4'b1000) 
    begin
      if(M_valE > 255)
        begin
            memvalid = 1;
        end
      data_memory[M_valE] <= M_valA;
    end

    // pushq
    else if(M_icode == 4'b1010) 
    begin
      if(M_valE > 255)
        begin
            memvalid = 1;
        end
      data_memory[M_valE] <= M_valA;
    end
  end

  always @(posedge clk) 
    begin    
      W_stat <= m_stat;
      W_icode <= M_icode;
      W_valE <= M_valE;
      W_valM <= m_valM;
      W_destE <= M_destE;
      W_destM <= M_destM;
    end
endmodule

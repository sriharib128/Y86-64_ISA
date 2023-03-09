module data_memory( clk , icode , valE , valA , valM , valP,memvalid) ;

  input clk;
  input [3:0] icode;
  input signed[63:0] valA,valE;
  input [63:0] valP;
  
  output reg signed [63:0] valM;
  output reg memvalid;
  reg [63:0] data_memory[255:0];
 
  always@(*)
  begin
    
    //mrmovq
    if(icode == 4'b0101) 
    begin
      if(valE > 255)
        begin
            memvalid = 1;
        end
      valM = data_memory[valE] ;
    end

    // ret
    else if(icode == 4'b1001) 
    begin
      if(valA > 255)
          begin
              memvalid = 1;
          end
      valM = data_memory[valA];
    end
    
    // popq
    else if(icode == 4'b1011) 
    begin
      if(valE > 255)
        begin
            memvalid = 1;
        end
      valM = data_memory[valA];
    end
    else
      begin
        memvalid =0;
      end
  end

  always @ (posedge clk) begin
    memvalid=0;
    // rmmovq
    if(icode == 4'b0100) 
    begin
      if(valE > 255)
        begin
            memvalid = 1;
        end
      data_memory[valE] <= valA;
    end

    // call
    else if(icode == 4'b1000) 
    begin
      if(valE > 255)
        begin
            memvalid = 1;
        end
      data_memory[valE] <= valP;
    end

    // pushq
    else if(icode == 4'b1010) 
    begin
      if(valE > 255)
        begin
            memvalid = 1;
        end
      data_memory[valE] <= valA;
    end
  end
endmodule

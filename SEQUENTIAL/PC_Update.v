module PC_UPDATE(clk,valP,valC,valM,cnd,icode,PC,PC__Update);
  input clk;
  input [63:0] valP; //Incremented PC
  input signed [63:0] valC; //Insruction Constant
  input signed [63:0] valM; //Value from Memory
  input cnd;         //Branch Flag
  input [3:0] icode; //Instruction Code
  input [63:0] PC;   
  output reg [63:0] PC__Update;
  
  
  always@(posedge clk) begin 
    if (icode == 4'b0111) //jxx - jmp, jle, jl, je, jne, jge, and jg
      begin
        //Program Counter is set to Dest if branch is taken (Takes valC)
        //Otherwise PC is incremented by 9 (Takes valP) 
        if  (cnd == 1) 
          begin
            PC__Update <= valC;
          end
        else 
          begin
            PC__Update <= valP;
          end
    end
    
    else if (icode == 4'b1000) //call
      begin
        //Program Counter is set to Dest (Takes valC)
        PC__Update <= valC;
      end
    
    else if (icode == 4'b1001) //ret
      begin
      //Program Counter is set to return address (Takes valP)
        PC__Update <= valM;
     end
    
    else 
      begin
        PC__Update <= valP;
      end
  end   
endmodule

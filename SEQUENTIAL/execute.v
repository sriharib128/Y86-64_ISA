module Execute(icode,ifun,valA,valB,valC,valE,clk,cnd,cc_out,cc_in);

  input clk;
  input [3:0] icode,ifun;
  input [2:0] cc_in;
  input signed [63:0] valA,valB,valC; 
  output reg [63:0] valE;
  output reg cnd;
  output reg [2:0] cc_out;
  reg in1,in2,in3,in4,in5,in6,in7;
  wire OUTP1,OUTP2,OUTP3,OUTP4;
  reg [1:0] CONTROL;
  reg signed [63:0] Input1,Input2,Op;
  wire signed [63:0] Output;
  wire OVERFLOW;

  ALU alu1(Input1,Input2,CONTROL,Output,OVERFLOW);
  
  always @(*) 
    begin
      if (icode == 4'b0010) begin //cmovXX-rrmovq,cmovle,cmovl,cmove,cmovne,cmovge,cmovg
        valE <= valA;
      end
      else if (icode == 4'b0111) begin //jmp
      end
      else if (icode == 4'b0011) begin //irmovq
        valE <= valC;
      end
      
      else if (icode == 4'b0100) begin //rmmovq
        // valE <= valB + valC;
        CONTROL = 2'b00;
        Input1 = valB;
        Input2 = valC;
        valE <= Output ;
      end
      
      else if (icode == 4'b0101) begin //mrmovq
        // valE <= valB + valC;
        CONTROL = 2'b00;
        Input1 = valB;
        Input2 = valC;
        valE <= Output ;
      end
      
      else if (icode == 4'b0110) begin //OPq - Addition, Subtraction, AND, XOR
        
        cc_out[2] <= OVERFLOW;
        cc_out[1] <=valE[63];
        cc_out[0] <= (valE ==0) ? 1'b1:1'b0;

        
        if (ifun == 4'b0000) begin //ADD
          CONTROL = 2'b00;
          Input1 = valA;
          Input2 = valB;
        end
        
        else if (ifun == 4'b0001) begin //SUBTRACT
          CONTROL = 2'b01;
          Input1 = valA;
          Input2 = valB;
        end
        
        else if (ifun == 4'b0010) begin //AND
          CONTROL = 2'b10;
          Input1 = valA;
          Input2 = valB;
        end
                
        else if (ifun == 4'b0011) begin //XOR
          CONTROL = 2'b11;
          Input1 = valA;
          Input2 = valB;
        end
        
        valE <= Output;
      end
   
      else if (icode == 4'b1000) begin //Call
        // valE <= valB - 64'd1;
        CONTROL = 2'b01;
        Input1 = valB;
        Input2 = 64'd1;
        valE <= Output ;
      end
      
      else if (icode == 4'b1001) begin //Ret
        // valE <= valB + 64'd1;
        CONTROL = 2'b00;
        Input1 = valB;
        Input2 = 64'd1;
        valE <= Output ;
      end
      
      else if (icode == 4'b1010) begin //pushq
        // valE <= valB - 64'd1;
        CONTROL = 2'b01;
        Input1 = valB;
        Input2 = 64'd1;
        valE <= Output ;
      end
      
      else if (icode == 4'b1011) begin //popq
        // valE <= valB + 64'd1;
        CONTROL = 2'b00;
        Input1 = valB;
        Input2 = 64'd1;
        valE <= Output ;
      end
    end 
  wire zf,sf,of;
  assign zf = cc_in[0];
  assign sf = cc_in[1];
  assign of = cc_in[2];

  always @(posedge clk)
  begin
      if(icode == 4'b0010 || icode == 4'b0111) //cmovXX && jgXX
      begin
          if(ifun == 4'h0)begin //unconditional 
              cnd = 1;
          end
          else if(ifun== 4'h1)begin //le
              cnd = (of^sf)|zf; 
          end
          else if(ifun == 4'h2)begin //l
              cnd = (of^sf); 
          end
          else if(ifun == 4'h3)begin //e
              cnd = zf; 
          end
          else if(ifun == 4'h4)begin //ne
              cnd = ~zf;  
          end
          else if(ifun == 4'h5)begin //ge
              cnd = ~(of^sf); 
          end
          else if(ifun == 4'h6)begin //g
              cnd = ~(of^sf) & ~(zf);
          end
      end
  end
endmodule

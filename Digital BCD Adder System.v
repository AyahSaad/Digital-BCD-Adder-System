/**	
Ayah Saad
1191334
***/


//////////////////////// STAGE 1 ///////////////////////////   

//Structural code for 1-bit full adder
	
module One_Bit_Full_Adder(input X1, X2, Cin, output Sum, Cout);  						   
 
 wire a1, a2, a3;  
 
 //a1=x1^x2
 //a2=x1&x2
 //a3=x1&x2&cin	
 
 xor #12ns u1(a1,X1,X2);
 and #8ns u2(a2,X1,X2);
 and #8ns u3(a3,a1,Cin);
 or  #8ns u4(Cout,a2,a3);
 xor #12ns u5(Sum,a1,Cin); 	
 
endmodule 

//Testbench For 1-bit full adder
	
module Testbench_One_Bit;
	reg X1,X2,Cin;   //inputs
	wire Sum,Cout;  //outputs	   
	
	//instantiate the module into the testbench
	One_Bit_Full_Adder tb(X1,X2,Cin,Sum,Cout);	
	
	initial 
		begin 
		 $monitor("Time %0d  X1=%b X2=%b Cin=%b Sum=%b Cout=%b",$time,X1,X2,Cin,Sum,Cout);	  
	  	  
		 {X1,X2,Cin} = 3'b000;	
			repeat(7)
			#25ns {X1,X2,Cin} = {X1,X2,Cin} + 3'b001; 
		end 
	endmodule	
		  

//Structural module for a 4-bit ripple adder

module ripple_adder_4 (x,y,sum,cout,cin);
	
	input [0:3]x,y;	//two 4-bit inputs
	input cin; 
	
	output [0:3] sum;
	output cout;
	
	wire n1,n2,n3; 
	
	// instantiating 4 1-bit full adders in Verilog	
	
	One_Bit_Full_Adder FA1(x[3],y[3],cin,sum[3],n1);
	One_Bit_Full_Adder FA2(x[2],y[2],n1,sum[2],n2);
	One_Bit_Full_Adder FA3(x[1],y[1],n2,sum[1],n3);
	One_Bit_Full_Adder FA4(x[0],y[0],n3,sum[0],cout);	
	
endmodule	

//Test bench module for the 4-bit ripple adder

module ripple_adder_4_tb; 
	
    reg [3:0]x, y;
    reg cin;
    wire [3:0] sum;
    wire cout; 
	
	//instantiate the module into the testbench
    ripple_adder_4 inst1 (.x(x),.y(y),.sum(sum),.cout(cout),.cin(cin));
	
    //display variables
   initial
	   begin  	
		    $monitor ("x=%b y=%b  cin=%b sum=%b cout=%b",x,y,cin,sum,cout);  
		    {x,y,cin} = 3'b000;	
			repeat(200)
			#100ns {x,y,cin} = {x,y,cin} + 3'b001; 
	   end	

endmodule 	  


//Structural module for a BCD adder
		
module Bcd_adder(x,y,cin,c_out,sum);  
	//inputs
	input [0:3]x,y; 
	input cin; 
	//outputs
	output c_out; 
	output [0:3]sum; 
	wire z;	// carry out of 4-bit Binary adder #1
	wire n1,n2; 
	/*	 
	n1=wire of and gate #1
	n2=wire of and gate #2
	*/
	wire m;               //cout of BCD #2 and was ignored
	wire [0:3] l;		  //Erorr detection
	wire [0:3]wire_sum;	 //the output sum of 4-bit Binary adder #1
	and (n1,wire_sum[0],wire_sum[1]); 
	and (n2,wire_sum[0],wire_sum[2]); 
	or  (c_out,n1,n2,z); 
	
	//four bit adder body from instance of full_adder
	ripple_adder_4 add0(x,y,wire_sum,z,cin); 
	assign l= {1'b0,c_out,c_out,1'b0};
	ripple_adder_4 add1(wire_sum,l,sum,m,1'b0);	
	
endmodule					   


//Test bench module for the Ripple BCD adder	
	
module Testbench_BCD_adder;

    // inputs
    reg [3:0] x,y;
	reg cin ; 
	assign cin = 1'b0;
    
    // outputs
    wire [3:0] sum;
    wire c_out;	

    //instantiate the module into the testbench	
	Bcd_adder inst2 (x,y,cin,c_out,sum);

    initial 
		begin
		$monitor (" x = %b y = %b cin = %b c_out = %b  sum = %b",x,y,cin,c_out,sum); 
		{x,y} = 2'b00;	
	    repeat(200)
	    #100ns {x,y} = {x,y} + 2'b01;  
		end 
		
endmodule	 

	 
//Structural module for all the system
	
module All_System(x,y,cin,sum,CLK,RST);
	
	//inputs
	input [0:7] x,y;
	input cin,CLK,RST; 
	//outputs
	output [0:8]sum; 
	wire cout; 	  
	wire c_out; 
	wire [0:15]SUM; 
	wire [0:7]out;
    
	Sixteen_Bit_Register inst1({x,y},CLK,RST,SUM); 	    //input Register
	Nine_Bit_Register inst2({c_out,out},CLK,RST,sum); 	//output Register
	
    Bcd_adder u1(SUM[4:7],SUM[12:15],1'b0,cout,out[4:7]);	  
	Bcd_adder u2(SUM[0:3],SUM[8:11],cout,c_out,out[0:3]); 

endmodule 


module Testbench_for_System; 
	
	//inputs
	reg [0:7]x;
    reg [0:7]y;
	reg cin,CLK,RST; 

    // Outputs
    wire [0:8]sum;

	All_System sy(x,y,cin,sum,CLK, RST);
	always #700 CLK=~CLK;
	initial begin 
			CLK=0;   
			RST=1; 
			x=0; 
			y=0; 	
			cin=0; 	
		   $monitor (" x1 = %b  y1 = %b  x2 = %b y2 = %b sum = %b  cout = %b CLK=%b",x[0:3],y[0:3],x[4:7],y[4:7],sum[1:8],sum[0],CLK);
		   repeat(5) begin	
		   #300ns x[0:3]=x[0:3]+1'b1; 
		   #500ns y[0:3]=y[0:3]+1'b1; 
		   #700ns x[4:7]=x[4:7]+1'b1; 
		   #700ns y[4:7]=y[4:7]+1'b1;
		   end 
    end
				
endmodule
    	
//Build 2-Digit BCD Adder from 1-Digit BCD 

module Two_Digit_BCD(x,y,sum,COUT);		 
	
	//inputs	
	input [0:7] x; 
	input [0:7] y; 

	//outputs
	output COUT; 	
	output [0:7]sum;
	
	wire cout;

     Bcd_adder b1(x[4:7],y[4:7],1'b0,cout,sum[4:7]);	  
	 Bcd_adder b2(y[0:3],y[0:3],cout,COUT,sum[0:3]);  	 
	 
endmodule 	


//Test bench module for the Ripple 2 BCD adder	
	
module Testbench_BCD2_adder;

    // inputs
    reg [3:0] x,y;
    
    // outputs
    wire [3:0] sum;
    wire COUT;	

    //instantiate the module into the testbench	
	Two_Digit_BCD inst0 (x,y,sum,COUT);

    initial 
		begin
		$monitor (" x = %b y = %b  sum = %b  COUT = %b",x,y,sum,COUT); 
		{x,y}=2'b00;	
	    repeat(200)
	    #100ns {x,y}={x,y}+2'b01;  
		end 
		
endmodule	 


//D flip-flop with asynchronous reset.	 

module DFF (D,CLK,Q,Qb,RST);
   output Q,Qb;
   input D,CLK,RST;
   reg Q;	  
   assign Qb = ~ Q ;
   always @(posedge CLK or negedge RST)    
	   begin
         if (~RST) Q = 1'b0;    
         else Q = D;	 
	 end   
	 
endmodule  

//16-bit D flip-flop

module Sixteen_Bit_Register (a,clk,RST,q); 
	
	parameter N=16;
	input [0:N-1] a;
	input clk,RST;	
	output wire [0:N-1] q;
	wire [0:N-1] qb;
	reg [0:N-1] d;	
	
	//declare a loop   variable to be used during Genaration
	genvar i;	  
	
	//Generate for loop to instantiate N times
	generate
	for	(i=0; i<N; i=i+1)
		begin
			DFF u0(d[i],clk,q[i],qb[i],RST);
		end
		endgenerate
			
    always @(posedge clk or negedge RST) 
		begin
         if (~RST) d = 1'b0;    
         else
			 d[0]=a[0];d[1]=a[1];d[2]=a[2];d[3]=a[3];d[4]=a[4];d[5]=a[5];d[6]=a[6];d[7]=a[7];
			 d[8]=a[8];d[9]=a[9];d[10]=a[10];d[11]=a[11];d[12]=a[12];d[13]=a[13];d[14]=a[14];
		     d[15]=a[15];
		 end
endmodule	

//9-bit Register
module Nine_Bit_Register(d,CLK,RST,q);
	input [8:0]d;
	input CLK,RST;
	output reg [8:0]q;	 
	
	 always @ (posedge CLK or negedge RST)  
       if (!RST)  q <= 0;  
       else  
          q <= d;  
    
endmodule	   


/////////////////////// STAGE 2 ////////////////////////////  

// 1-bit Carry Look ahead module 

module Look_Ahead (x,y,cin,sum,a,b);
	
	 //inputs
	 input x,y,cin;
     output sum,a,b; 
     wire w;	
	 
	 //outputs
     xor #12ns u1(w,x,y);
	 and #8ns u3(b,x,y);
     or  #8ns u2(a,x,y);
     xor #12ns u4(sum,w,cin);	 
	 
endmodule  

// 4-bit Carry Look ahead module 
	
module Carry_Lookahead_4_Bit (A,B,S,Cout,Cin);
	
	//inputs
	input [0:3]A,B;
	input Cin; 	
	
	//outputs
	output Cout;
	output [0:3]S;  
	
	wire [0:21]w;

	//instantiate the module
	Look_Ahead U1 (A[3],B[3],Cin,S[3],w[21],w[20]);  
	or #8ns (w[18],w[19],w[20]);
	and #8ns (w[19],Cin,w[21]);
	
	//instantiate the module
	Look_Ahead U2(A[2],B[2],w[18],S[2],w[17],w[16]);	 
	or #8ns (w[13],w[16],w[14],w[15]);
	and #8ns (w[14],w[20],w[17]);
	and #8ns (w[15],Cin,w[21],w[17]);

	//instantiate the module
	Look_Ahead U3(A[1],B[1],w[13],S[1],w[12],w[11]);	
	or #8ns (w[7],w[11],w[10],w[9],w[8]);	
	and #8ns (w[8],w[16],w[12]);	
	and #8ns  (w[9],w[20],w[17],w[12]);	
	and #8ns (w[10],cin,w[21],w[17],w[12]);
	
	//instantiate the module
	Look_Ahead U4(A[0],B[0],w[7],S[0],w[6],w[5]);  
	or #8ns (w[0],w[1],w[2],w[3],w[4]); 
	and #8ns (w[1],w[11],w[6]);	   
	and #8ns (w[2],w[16],w[12],w[6]);  
	and #8ns (w[3],w[20],w[17],w[12],w[6]);
	and #8ns (w[4],Cin,w[21],w[17],w[12],w[6]);
	assign Cout = w[0];	  
	
endmodule


//Test bench module for the 4-bit Carry lookahead module

module carry_lookahead_4_tb;   
	
	//inputs
    reg [3:0]A,B;
    reg Cin;  
	
	//outputs
    wire [3:0]S;
    wire Cout; 													
												 		
	//instantiate the module into the testbench
    Carry_Lookahead_4_Bit inst4 (.A(A),.B(B),.S(S),.Cout(Cout),.Cin(Cin));	 
	
    //display variables
   initial
	   begin  	
		    $monitor ("A=%b B=%b S=%b Cout=%b Cin=%b",A,B,S,Cout,Cin);  
		    {A,B,Cin} = 3'b000;	
			repeat(100)
			#100ns {A,B,Cin} = {A,B,Cin} + 3'b001; 
	   end	

endmodule 	 


//Structural module for a BCD Look Ahead adder
		
module Bcd_LookAhead_adder (x,y,cin,c_out,sum);  
	//inputs
	input [0:3]x,y; 
	input cin; 
	
	//outputs
	output c_out; 
	output [0:3]sum; 
	wire z;	// carry out of 4-bit Binary adder #1
	wire n1,n2; 
	/*	 
	n1=wire of and gate #1
	n2=wire of and gate #2
	*/
	
	wire m;               //cout of BCD #2 and was ignored
	wire [0:3] l;		  //Erorr detection
	wire [0:3]wire_sum;	 //the output sum of 4-bit Binary adder #1
	and (n1,wire_sum[0],wire_sum[1]); 
	and (n2,wire_sum[0],wire_sum[2]); 
	or  (c_out,n1,n2,z); 
	
	//four bit adder body from instance of full_adder
	Carry_Lookahead_4_Bit add4(x,y,wire_sum,z,cin); 	
	assign l= {1'b0,c_out,c_out,1'b0};							
	Carry_Lookahead_4_Bit add5(wire_sum,l,sum,m,1'b0);	
	
endmodule

	 
//Structural module for all the system
	
module All_System2(x,y,cin,sum,CLK,RST);
	
	//inputs
	input [0:7] x,y;
	input cin,CLK,RST; 
	//outputs
	output [0:8]sum; 
	wire cout; 	  
	wire c_out; 
	wire [0:15]SUM; 
	wire [0:7]out;
    
	Sixteen_Bit_Register inst1({x,y},CLK,RST,SUM); 	    //input Register
	Nine_Bit_Register inst2({c_out,out},CLK,RST,sum); 	//output Register
	
    Bcd_lookahead_adder u3(SUM[4:7],SUM[12:15],1'b0,cout,out[4:7]);	  
	Bcd_lookahead_adder u4(SUM[0:3],SUM[8:11],cout,c_out,out[0:3]); 

endmodule 


module Testbench_for_System2; 
	
	//inputs
	reg [0:7]x;
    reg [0:7]y;
	reg cin,CLK,RST; 

    // Outputs
    wire [0:8]sum;

	All_System2 m(x,y,cin,sum,CLK, RST);
	always #700 CLK=~CLK;
	initial begin 
			CLK=0;   
			RST=1; 
			x=0; 
			y=0; 	
			cin=0; 	
		   $monitor (" x1 = %b  y1 = %b  x2 = %b y2 = %b sum = %b  cout = %b CLK=%b",x[0:3],y[0:3],x[4:7],y[4:7],sum[1:8],sum[0],CLK);
		   repeat(5) begin	
		   #300ns x[0:3]=x[0:3]+1'b1;  
		   #500ns y[0:3]=y[0:3]+1'b1;
		   #700ns x[4:7]=x[4:7]+1'b1;
		   #700ns y[4:7]=y[4:7]+1'b1;
		   end 
           end			
endmodule  


/* Another Code for 4-bit lookahead	 
	
module Carry_Lookahead_4_Bit (A,B,S,Cout,Cin);	
	
  parameter N=4;
  input [N-1:0] A,B; 
  output [N-1:0] S;
  input Cin;
  output Cout; 

  wire [3:1]C;
  wire [0:3]P,G;  
  
     /// Making Ps
    //declare a loop variable to be used during Genaration
	genvar i;	  
	generate
	for	(i=0; i<N; i=i+1)
		begin
			xor #(12ns) p(P[i],A[i],B[i]);
		end
		endgenerate	 
		
    /// Making Gs
    //declare a loop variable to be used during Genaration
	genvar k;	  
	generate
	for	(k=0; k<N; k=k+1)
		begin
			and #(8ns) g(G[k],A[k],B[k]);
		end
		endgenerate
  
   /// Making C1
   wire tmp1;
   and #(8ns) c1(tmp1,P[0],Cin);
   or #(8ns) c2(C[1],G[0],tmp1);
  
   /// Making C2
   wire tmp2;
   wire tmp3;
   and #(8ns) v1(tmp2,P[1],G[0]);
   and #(8ns) v2(tmp3,P[1],P[0],Cin);
   or #(8ns) v3(C[2],tmp2,tmp3,G[1]);
  
   /// Making C3
   wire tmp4;
   wire tmp5;
   wire tmp6;
   and #(8ns) v4(tmp4,P[2],G[1]);
   and #(8ns) v5(tmp5,P[2],P[1],G[0]);
   and #(8ns) v6(tmp6,P[2],P[1],P[0],Cin);
   or #(12ns) v7(C[3],tmp4,tmp5,tmp6,G[2]);
  
   /// Making Cout (C4)
   wire tmp7;
   wire tmp8;
   wire tmp9;
   wire tmp10;
   and #(8ns) v8(tmp7,P[3],G[2]);
   and #(8ns) v9(tmp8,P[3],P[2],G[1]);
   and #(8ns) v10(tmp9,P[3],P[2],P[1],G[0]);
   and #(8ns) v11(tmp10,P[3],P[2],P[1],P[0],Cin);
   or #(8ns) v12(Cout,tmp7,tmp8,tmp9,tmp10,G[3]);
  
    /// Making Sums 
   xor #(12ns) s0(S[0],P[0],Cin);
   xor #(12ns) s1(S[1],P[1],C[1]);
   xor #(12ns) s2(S[2],P[2],C[2]);
   xor #(12ns) s3(S[3],P[3],C[3]);
  
endmodule */
	 

//////////////////////////////////////////////
//Behavioral module to be used in verification   
	
module bcd_adder(a,b,carry_in,sum,carry);

//declare the inputs and outputs of the module with their sizes.
    input [3:0] a,b;
    input carry_in;
    output [3:0] sum;
    output carry;
    //Internal variables
    reg [4:0] sum_temp;
    reg [3:0] sum;
    reg carry;  

//always block for doing the addition
    always @(a,b,carry_in)
    begin
        sum_temp = a+b+carry_in; //add all the inputs
        if(sum_temp > 9)    
			begin
            sum_temp = sum_temp+6; //add 6, if result is more than 9.
            carry = 1;  //set the carry output
            sum = sum_temp[3:0];   
			end
        else    
			begin
            carry = 0;
            sum = sum_temp[3:0];
        end
    end     

endmodule  

//Testbench for BCD adder:

module tb_bcdadder;

    // Inputs
    reg [3:0] a;
    reg [3:0] b;
    reg carry_in;

    // Outputs
    wire [3:0] sum;
    wire carry;

    // Instantiate the Unit Under Test (UUT)
    bcd_adder uut (.a(a),.b(b),.carry_in(carry_in),.sum(sum),.carry(carry));

    initial begin
        // Apply Inputs
        a = 0;  b = 0;  carry_in = 0;   #100;
        a = 6;  b = 9;  carry_in = 0;   #100;
        a = 3;  b = 3;  carry_in = 1;   #100;
        a = 4;  b = 5;  carry_in = 0;   #100;
        a = 8;  b = 2;  carry_in = 0;   #100;
        a = 9;  b = 9;  carry_in = 1;   #100;
    end
      
endmodule



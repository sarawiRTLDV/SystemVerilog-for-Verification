// Code your testbench here
// or browse Example

module tb();
  
  bit a = 0;
  
  // to use a variable datatype we declare them as flow
  // 1.two states variables
  // if we want to use a signed variables
  
  byte b = 0;
  shortint c = 0;
  int d = 0;
  longint e = 0;
  // ===> bear in mind that if we didn't initialize this variables they will have 0 as a default value
  
  //if we want to use unsigned variables 
  bit [7: 0]f = 8'b00000000; 
  bit [15: 0] g = 16'h0000; 
  bit [31: 0] h = 31'h00000000;
  bit [64: 0] i = 64'h0000000000000000; 
  
  //2. in case of 4-states variable we have only one datatype ==> integer
  
  integer j = 0; // if we didn't initialize it, it will have x as its defauld value
  
  //now if we want to store a floating point number we have to use the fixed point variable
  // in sv we have only real datatype for floating point numbers
  real r = 0.0;
  
  initial #5 f = 255;
  initial begin 
    #5
    $display("the value of f is: %0d", f);
  end
  initial #200 $finish();
  
  
endmodule


/*  
simulation datatypes 
 -fixed point -> time
 -floating point -> realtime
*/


`timescale 1ns / 1ps

module tb();
  
  time Fixed_time = 0; // store fixed point time value
  realtime Floating_time = 0; // store floatin point time value 
  
  initial begin
    // $time() -> return current simulation time in fixed point format
    // $realtime(); -> return Current simulation time in floating point format
    
    #10.112
    Fixed_time = $time();
    Floating_time = $realtime();
    
    $display("the Fixed point time is -> %0t, and the floating point time is -> %0t", Fixed_time, Floating_time);
    
  end
  
endmodule

// this is an example showing the deficulty of working with reg type 
// if we try to use a wire in procedural assignement block it will simply throw an error 
// similary if we try to use a reg type in continous assignement 
// to solve this confusion system verilog provide the logic type that will behave 
// as reg type or wire type depeding on the situation
// the logic type is pretty useful especially in case of working with interfaces
/*

`timescale 1ns/1ps

module mux(
  input a, b, sel, 
  output y
			);
  logic temp;
  
  
  always@(*) begin
    if(sel == 1) temp = a;
    else temp = b;
  end
  
  assign y = temp;
   
endmodule

*/

//in the comming example we did prove that we cannot use a reg type in case of a continous assignement


`timescale 1ns/1ps

module HalfAdder(
            input wire a, b, 
            output wire sum, cout
                  );

    assign sum = a ^ b;
    assign cout = a & b;
endmodule

module FullAdder_2bits(input wire A, B, input wire Cin,
                       output wire Sout, Cout
                       );
//reg s_sig, c_sig1, c_sig2; // it did throw an error because the reg type is not allowed in a wire/net connection 

// so for that we have to use the wire type 
//wire s_sig, c_sig1, c_sig2;
logic s_sig, c_sig1, c_sig2;



HalfAdder h1(A, B, s_sig, c_sig1);
HalfAdder h2(Cin, s_sig, Sout, c_sig2);
assign Cout = c_sig1 | c_sig2;

endmodule     

// to solve this confusion system verilog provide the logic type that will
// in this part I was mistaken I though I had to built a 2bits full adder based on 1bit full adder
/*
`timescale 1ns/1ps                                                    
                                                                                        
module FullAdder(                                                                       
            input wire a, b, cin,                                                       
            output wire sum, cout                                                       
                  );                                                                    
    reg a_sig, b_sig, cin_sig, cout_sig, sum_sig;                                       
    reg axorb;                                                                          
                                                                                        
    assign a_sig = a;                                                                   
    assign b_sig = b;                                                                   
    assign cin_sig = cin;                                                               
                                                                                        
    assign axorb = a_sig ^ b_sig;                                                       
    assign cout_sig = (a_sig & b_sig) | (axorb) & cin_sig;                              
    assign sum_sig = (axorb) ^ cin;                                                     
    assign sum = sum_sig;                                                               
    assign cout = cout_sig;                                                             
endmodule                                                                               
                                                                                        
module FullAdder_2bits(input wire [1:0]A, [1:0]B, input wire Cin,                       
                       output wire Sout, Cout                                           
                       );                                                               
FullAdder h1(A[0], B[0], Cin, s_sig, c_sig1);                                           
FullAdder h2(A[1], B[1], s_sig, Sout, c_sig2);                                          
assign Cout = c_sig1 | c_sig2;                                                          
                                                                                        
endmodule                                                                               
*/                                                                                     
                                                                                        
                  

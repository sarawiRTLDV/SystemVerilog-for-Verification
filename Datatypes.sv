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

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
   

//in the comming example we did prove that we cannot use a reg type in case of a continous assignement


`timescale 1ns/1ps

module Arrays();
/*
  // to declare an array we have to ways
  // these two methode give us the ability to declare a fixed size array
  //1.the first is just like in the c language 
  
  bit arr1[8];
  //2. the second is:
  // in this case if we didn't initialize the arr2 means we just declare like
  //bit arr2[]; the arr2 will be empty means doesn't hold any element
  
  bit arr2[] = {1, 1, 1, 0, 0, 1}; // in this case we let the compiler predict the size of the arr2 -> 6
  
  
  // now lets display the size of each of them 
  // to do so we can use $size(element) which returns the size of element
  
  //initial  $display("size of arr1 is -> %0d and size of arr2 is -> %0d ", $size(arr1), $size(arr2));
 
  

  
  initial begin
    
    // now if we want to display and element of that array, we do it just like in c language

    $display(" the first element of arr2 is -> %0d ", arr2[0]);
    
      // if we want to change the value of a specific element in the array

    
    $display(" the seconde element of arr1 is -> %0d ", arr1[1]);
    arr1[1] = arr2[2];
    $display(" the seconde element of arr1 is -> %0d ", arr1[1]);
    
    // if we want to display the holl array at once we use %0p
    
    $display(" arr1 is -> %0p ", arr1);
    
  end
  
  */
  // now lets talk a little bit about array initialization
  // there are 4 categories 
  
  // 1.unique values
  
  int arr1[] = '{1, 3, 5, 8};
  //or we can specify the size
  // int arr1[4] = '{1, 3, 5, 8}; // in this case we have to initialize all the elements of our array (if we don't the compiler will throw an error
  
  
  //2.repetitive values
  
  int arr2[8] = '{ 8{4} };
  
  //3.default value
  
  int arr3[5] = '{ default : 7};
  
  //4. uninitialized array -> the array elements will be initialized by theire default values: x in case of 4 state  data type and 0 in case of 2 state data type
  
  logic arr[3]; // here all the elements of arr will have a default value of x because -> logic is a 4 state data type
  bit arr4[3]; // here all the elements of arr will have a default value of 0 because -> logic is a 0 state data type
  
  initial $display(" arr1 -> %0p, arr2 -> %0p, arr3 -> %0p, arr -> %0p, arr4 -> %0p ", arr1, arr2, arr3, arr, arr4);
  
  
  
endmodule


/* now lets talk about dynamic arrays and queue
Dynamic arrays and queues actually perform very similar functions in SystemVerilog as they are both allocated memory at run time. 
As a result of this, we can resize both of these data structures whilst our code is running.

but when we have the choice between these two we frequently use queue because they are so afficient 
*/

// General syntax for the push_front method
<queue_name>.push_front( <value> );

// General syntax for the push_back method
<queue_name>.push_back( <value> );

// now if we want to read elements from the queue
// General syntax for the pop_front method
a = <queue_name>.pop_front();
// General syntax for the pop_back method
b = <queue_name>.push_back();
 
// so what if we want to insert a value in a geven index
// Insert a value into the queue
<queue_name>.insert(<index>, <value>);
// if we want to delete the queue (free the queue)
<queue_name>.delete();

/* in the coming lines of code we will be understanding the real use of fixed, dynamic arrays and queue*/

// Code your testbench here
// or browse Examples
class transaction; //
  
  rand bit [7:0] din; // the data that we will be writing into our memory
  randc bit [7:0] addr;// the memory address where we will be writing / in case of a fifo we don't need this 
  bit wr;// write enable
  bit [7:0] dout;// this is the output data bus
  
  constraint addr_c {addr > 10; addr < 18;};// constraints are nothing more than a way to let us define what legal values should be assigned to the random variables.
  
endclass

class generator;
  
  transaction t;// creating a object of the transaction class
  integer i;
  
  task run();
    for(i = 0; i < 100; i++) begin // here we are performing a generation of 100 stimulas by using randomize() fuction after creating a constractor of t object. these stimulas will be sent to our design under test(DUT)
      
      t = new(); 
      t.randomize();
      
      
    end
  endtask
endclass
    
class scoreboard;
  
  bit [7:0] tarr[256] = '{default: 0}; // here is an example of where we could use a fixed size array for memory data verification
  
  transaction t;
  
  task run();
    
 /* ----------------------------------------- */
    
    if(t.wr == 1'b0) begin
      
      if(t.dout ==0)
        $display("[sco] : No Data written at this location Test passed");
      else if(t.dout == tarr[t.addr])
        $display("[sco] : valid Data found -> Test Passed");
      else
        $display("[sco] : Test Failed??");
    end
      
    end
    
  endtask
  
endclass


// now we will try understand the use of a queue 

class transaction;
  
  rand bit [7:0] wdata;
  bit [7:0] rdata;
  rand bit wreq, rreq;
  
endclass

class generator;
  
 tranasaction trans;
  
  task run();
    
    repeat(count) begin
      
      trans = new();
      assert(trans.randomize()) else ("Randomization Failed");
    end
    
  endtask
  
endclass

class scoreboard;
  
  bit [7:0] rdata;
  bit [7:0] queue[$];
  
  transaction tr;
  
  task run();
    
    if(wreq == 1'b1) begin
      
      queue.push_front(tr.wdata);
      
    end
    else if (tr.rreq) begin
      
      if(tr.rdata != queue.pop_back())
      $display("Data Mismatch at %0t", $time);
    end
    end
    
  endtask
  
  
endclass


/*=================================================================*/

// now lets talk about constraint Operators 
//1. implication operator (->)
//2. equivalence operator (<->)
//3. if{}else{} operator

class generator;
  randc bit [3:0] raddr;
  randc bit [3:0] waddr;
  
  rand bit rst, ce, wr;
  
  
  constraint control_rst_ce {
    rst dist {0:=30, 1:= 70};
    ce dist {0:=70, 1:=30};
  }
  
  //implication and equivalence are most of the cases used with control signals
 /* constraint Op_rst_ce{
    (rst == 0) -> (ce ==0);// this means that when ever rst = 0 ce must be = 0 as well
  }*/
  
  // equivalence
  constraint Op_rst_ce{
    (wr == 1) <-> (ce == 1);// this means that when ever rst = 0 , ce = 0 as well and when ever ce = 0 rst = 1
  }
  
  // if{} else{}
  
  constraint if_else{
    if(wr == 1){
    	raddr == 0;
      waddr inside {[10:13]};
    
    }else {
      raddr inside {[10:13]};
      waddr == 0;
    }
  }
  
  
  
endclass

module tb;
  
  generator g;
  
  initial begin
    g = new();
    for(int i = 0; i < 10; i++) begin
    g.randomize();
    $display("rst = %0d and ce = %0d", g.rst, g.ce);
      $display("wr = %0d , raddr = %0d and waddr = %0d", g.wr, g.raddr, g.waddr);
    end
  end
endmodule


class generator;
  
  randc bit [3:0] raddr, waddr;
  rand bit wr; ///write to mem
  rand bit oe; ///output enable
  
  constraint wr_c {
    wr dist {0:= 50, 1 := 50};
  }
  
  
  constraint oe_c {
    oe dist {1:= 50, 0 := 50};
  }
  
  constraint wr_oe_c {
    ( wr == 1 ) -> (oe == 0); 
  }
 
    
  
endclass
 
module tb;
  
  generator g;
  
  initial begin
    g = new();
   
    g.wr_oe_c.constraint_mode(0); ///1 -> COnstraint is on // 0-> constraint is off 
      $display("Constraint Status oe_c : %0d",g.wr_oe_c.constraint_mode()); 
    for (int i = 0; i<20 ; i++) begin
      assert(g.randomize()) else $display("Randomization Failed");
      $display("Value of wr : %0b | oe : %0b | ", g.wr, g.oe);
    end
    
  end
 
  
endmodule

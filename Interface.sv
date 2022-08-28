/*======================================================*/

// here we will be understanding how to work with an interface
// in general the data that we have in a driver class we need to upply it to a DUT, this is done by using an interface
//here is how we define an interface
interface and_if;
  logic [3:0] a;
  logic [3:0] b;
  logic [3:0] y;
    
  endinterface
 
 
module tb;
  
  and_if aif();//here we instanciate an object of the interface module
  
  // here we instanciate a dut of our and4 module and made the necesserry connections
  //and4 dut (.a(aif.a), .b(aif.b), .y(aif.y));//here we use mapping by name 
  and4 dut (aif.a, aif.b, aif.y);//here we use mapping by position-> we need to respect the position of ports in the design   
  
  
  initial begin
    aif.a = 4'b0100;
    aif.b = 4'b1100;
    #10;
    $display("a : %b , b : %b and y : %b",aif.a, aif.b, aif.y );
  end
  
endmodule

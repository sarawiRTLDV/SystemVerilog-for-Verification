/*======================================================*/

// here we will be understanding how to work with an interface
// in general the data that we have in a driver class we need to upply it to a DUT, this is done by using an interface

// here our design;
module and4(
  input [3:0] a,
  input [3:0] b,
  output [3:0] y
);
  
  assign y = a + b;
  
endmodule


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
  
  

/*======================================================*/

/* here we will be understanding how to work with an interface
 in general the data that we have in a driver class we need to upply it to a DUT, this is done by using an interface
 -> an other thing that we have to keep in mind whenever we are applying or sending data to our dut trough the interface we have to go with a non-blocking assignement
 */
// here our DUT
module and4(
  input [3:0] a,
  input [3:0] b,
  input clk,
  output logic [3:0] y
  
);
  // here we use a blocking assignement
  
  //assign y = a + b;
  
  // and here we use non blocking assignement
  
  always @(posedge clk) begin
  	y <= a + b;
  end
  
endmodule
//here is how we define an interface
interface and_if;
  logic [3:0] a;
  logic [3:0] b;
  logic [3:0] y;
  logic clk;// for the non
endinterface
 
/*
1.-> if we use an interface with reg type for output variables of the interface, then we won't be allowed to connect output variable in the interface with the output ports of the DUt.
2.-> if we use an interface with variables of wire datatype, then we are not allowed to apply stimulus to those variables using initial or always blocks
*/
 
module tb;
  
  and_if aif();//here we instanciate an object of the interface module
  
  // here we instanciate a dut of our and4 module and made the necesserry connections
  //and4 dut (.a(aif.a), .b(aif.b), .y(aif.y));//here we use mapping by name 
  and4 dut (aif.a, aif.b, aif.clk, aif.y);//here we use mapping by position-> we need to respect the position of ports in the design   
  
  //remember that when we use logic type for our clk we need to initialize it 
  // because a logic type is initialized by default to x value
  initial begin
    aif.clk = 0;
  end
  always #10 aif.clk = ~aif.clk;
  
  initial begin
    aif.a = 4'b0100;
    aif.b = 4'b1100;
     // if we have used a non-blocking assignement in our dut, we can control stimulus using the clk edges, unlike blocking we have to use #10ns
    
    // if we use nonblocking assignement we can use this 
    @(posedge aif.clk); // means that the values of both a and b will not be changed till the first positive edge of the clock
    repeat(5) @(posedge aif.clk);// here we can also use repeat to wait for several clock cycles 
    
   // unlike blocking assignement we have to use #10ns
    #10;
    aif.a = 2;
    aif.b = 5;
    #10;
    aif.a = 5;
    aif.b = 7;
    #10;
    
    $display("a : %b , b : %b and y : %b",aif.a, aif.b, aif.y );
  end
  
  initial begin 
    
    $dumpfile("dump.vcd"); 
    $dumpvars;
    #100;
    
    $finish();
  end
  
endmodule
  
  initial begin
    // here basically we are applaying value to the dut by using an interface and we will be able to see the response of it;
    aif.a = 4'b0100;
    aif.b = 4'b1100;
    #10;
    $display("a : %b , b : %b and y : %b",aif.a, aif.b, aif.y );
  end
  
endmodule


/*===================================================================*/



// here is our design

module add8(
  input [7:0] a,
  input [7:0] b, 
  input clk,
  output logic [8:0] y
);
  
  // here we are non blocking assignement
  always @(posedge clk) y <= a+b;
  
endmodule
//modport

/*mod port is used to specify the diriction which helps us to prevents incorrect wiring of signals, 
so, use the modport to restrict the driver to driver only the input ports of our DUT(which are output for the driver),
and restrict the monitor to capture only the output ports of our DUT(which are inputs for the monitor)*/ 

// lets add a driver code to the interface 

interface add_inf;
  
  logic [7:0] a;
  logic [7:0] b;
  logic clk;
  logic [8:0] y;
  
  modport DRV(output a, b, input clk, input y); // here we are restricting the a and b port to be an output from the driver class and clk and y to be inputs to the driver class
endinterface


// here we create our driver class


class driver;
  // we added .DRV to stik to the restrictions of modport
  virtual add_inf.DRV aif;// here virtual indecates that the add_inf is defined outside the driver class
  
  task run();
    // since the driver class will be always waiting for data(or commands from a generator class we use forever
    
    forever begin
      // here is how we will drive the signals of our dut, remember use always non-blocking, cuz,it prevents us from dropping values.
      @(posedge aif.clk); // here we are waiting for the positive edge of the clok
      aif.a <= 3; /* in fact, here we will apply data of transactions generated by generator class*/
      aif.b <= 6;
      @(posedge aif.clk);
      aif.a <= 2;
      aif.b <= 8;
      
    end
  endtask
  
  
endclass


module tb;
  
  driver drv;
  
  // lets declare an interface for our tb
  add_inf aif();// unlike inside the driver class here we have to use the brakets
  add8 DUT(.a(aif.a), .b(aif.b), .clk(aif.clk), .y(aif.y));
  initial begin
    aif.clk = 0;
  end
  
  always #10 aif.clk = ~aif.clk;// here we generate the clock of our tb interface
  /*initial begin
    
    @(negedge aif.clk);
    aif.a = 1;
    aif.b = 2;
    
  end*/
  
  initial begin 
    drv = new();// allocating memory for our drv obj
    drv.aif = aif; // here we are connecting the interface of our tb to the one of drv obj
    drv.run();
    
  end
  
  initial begin
    
    $dumpfile("dump.vcd"); $dumpvars;
    #100;
    $finish();
    
  end
  
endmodule

/*Now we are ready to start another section of the course -> Randomization*/ 

class generator;
  
  /*we use either the rand or randc to generate a pseudo random value
  the difference between these two is that:
  in some situations we need so value to be repeated in that case we go with rand 
  in some other situations where we don't want to generate repeated value we go with randc
  means that randc will not show any repeated value till it covers all the possible values of that range
  */
  rand bit[3:0] a, b;
  bit[3:0] y;
  // we could use a constraint that the randomization should respect
  
  constraint data {a > 9; b < 2;}
  
endclass

module Testbench;
  
  generator g;// here we create an empty object from the generator class
  int i;
  
  initial begin
    // lets allocate a memory for our object 
    g = new();
    
    // now it's time to give a and b some generated random values
    /*for(i = 0; i < 10; i++) begin
      g.randomize();
      $display("a = %0d, b = %0d", g.a, g.b);
    end */
    /* so how we check if the randomization was successfull or not
    Well, we have two methods either we use if-else or assert
    */
    
    
    //using the if else statment
    
    for(i = 0; i < 10; i++) begin
      // here we check if the randomization is failed, if so we display a message and finish the simulation
     //So this will generate a new value for our data members and that will be updating
      if(!g.randomize())begin// one thing you should know is that randomize() function returns and int
        $display("Randomization Faild at time -> %0t", $time);
        $finish();
      end
      $display("a = %0d, b = %0d", g.a, g.b);
      #10 // here we gave 10 ns for each iteration means for randomization
      /*but what if that is not enough for our obj to go through the intire process of verification
    	well, in that case we just need to allocate memory of our obj(g = new()) for each iteration 
        means to put (g = new();) inside the repeated loop
        */
      
      
      // if we shoose to go with assert:
      assert(g.randomize())else // just like if-else; here if the randomization is true(returns 1), we do nothings else we throw a message
        begin
          $display("Randomization Faild at time -> %0t", $time);
       	  $finish();
        end
      $display("a = %0d, b = %0d", g.a, g.b);
    end
    
    
    
    
  end
  
  
endmodule 






/* ============================================================= */
// understanding constraint
class generator;
  
  randc bit [3:0] a, b; ////////////rand or randc 
  bit [3:0] y;
  /*
  constraint data_a {a > 3; a < 7;}
  
  constraint data_b {b == 3;}
  */
  
  //constraint data {a > 3; a < 7 ; b > 0;}
  
/*
here if we want to apply randomization in some specific ranges 
  constraint data {
    a inside {[0:8],[10:11],15} ; //0 1 2 3 4 5 6 7 8  10 11 15  
    b inside {[3:11]} ;  // 3 4 5 6 7 8 9 10 11
                  
                  }
*/
  
  /*however you might find some situations where you want to skip some values whithing a certain range*/ 
  constraint data {
    !(a inside {[3:7]});
    !(b inside {[5:9]});
  
  }
  
  
  
  ///// a = 3:7, b = 5:9
  
endclass
 
module tb;
  generator g;
  int i = 0;
  
  initial begin
   g = new();
    
    for(i=0;i<15;i++) begin
      
      assert(g.randomize()) else $display("Randomization Failed");
      $display("Value of a :%0d and b: %0d", g.a,g.b);
      #10;
    end
    
  end
endmodule


/*=================================================================================*/
// External functions/contraint

class generator;
  
  randc bit[3:0] a, b;
  
  extern constraint data;
  extern function void display();
  
endclass

constraint generator::data{
  a inside {[0:7], [12:15]};
  b inside {[8:11]};
  !(a inside {[3:4]});
};

    function void generator::display();
    
      $display("a = %0d, b = %0d", a, b);
    
    endfunction
    
module tb();
  
  generator gen;
  int i;
  
  initial begin 
    
    gen  = new();
    for(i = 0; i < 10; i++) begin
      gen.randomize();
      gen.display();
    end
    
  end
  
endmodule


/*=======================================================================================================*/

//pre_randomize and post_randomize

//pre_randomize will be executed prior to randomization, while post_randomize will be executed after randomization becomes successful.
 
class generator;
  
  randc bit [3:0] a,b; 
  bit [3:0] y;
  
  int min;
  int max;
  
  function void pre_randomize(input int min, input int max);
  this.min = min;
  this.max = max;  
  endfunction
  
  constraint data {
    a inside {[min:max]};
    b inside {[min:max]};
  }
  
  function void post_randomize();
    $display("Value of a :%0d and b: %0d", a,b);
  endfunction
   
  
  
endclass
 
module tb;
  
  int i =0;
  generator g;
  
  initial begin
    g = new();
    
    for(i = 0; i<10;i++)begin
      g.pre_randomize(3,8);
      g.randomize();
      #10;
    end
    
  end
endmodule



/*===================================================================*/

// now lets have a deep understanding of the Wieghted distrebution

class distribution;
  
  // actually if we are not using ranges of values there is no diff between (:=) and (:/) operators
  rand bit sel;// :=
  rand bit en;// :/
  
  // but if we use ranges of values there we can recognize the diff
  
  rand bit [0:3] data1;//:=
  rand bit [0:3] data2;//:/
  
  constraint one{
    sel dist {0:=10, 1:=90};
    en dist {0:/10, 1:/90};
    data1 dist {0:=10, [1:3]:=60};
    data2 dist {0:/10, [1:3]:/60};
  }
  
endclass
  
module tb();
  
  distribution d;
  
  initial begin
    d = new();
    
    for(int i = 0; i < 10; i++) begin
      if(d.randomize()) begin 
      end else begin
        $display("randomization failed");
      end
    #10 
      $display("sel = %0d, en = %0d ", d.sel, d.en);
      $display("data1 = %0d, data2 = %0d ", d.data1, d.data2);
      
    end
  end
  
endmodule
  


/*================================================================================*/
//Understanding randc bucket

class generator;
  
  randc bit [3:0] a,b; 
  bit [3:0] y;
  
  int min;
  int max;
  
  function void pre_randomize(input int min, input int max);
  this.min = min;
  this.max = max;  
  endfunction
  
  constraint data {
    a inside {[min:max]};
    b inside {[min:max]};
  }
  
  function void post_randomize();
    $display("Value of a :%0d and b: %0d", a,b);
  endfunction
   
  
  
endclass
 
 
 
 
 
 
 
module tb;
  
  int i =0;
  generator g;
  
  initial begin
    g = new();
    
    $display("SPACE 1");
    g.pre_randomize(3,12);
    for(i = 0; i<6;i++)begin
      g.randomize();
      #10;
    end
    $display("SPACE 2");
    // the randomize function will generate fresh values even if they have already generated in the previous iteration
    g.pre_randomize(3,12);//3 4 5 6 7 8 9 10 11 12
     for(i = 0; i<6;i++)begin
      g.randomize();
      #10;
    end
  end
endmodule

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
/*===============================================================================*/
// here is some explanation about how/what we use transaction for
//-> our design 
module FIFO(
input wreq, rreq, 
  input rst, clk,
  input [7:0] wdata,
  output [7:0]rdata, 
  output f,e
);
	
// -> here is the test bench top
class transaction;
  // generlly speaking we don't use the pseudo random number generator with global variale specially the clk -> we generate them inside tb
  // depending on the port signals that we have on our design we can choose to work with 4-state variables or 2-state variables
  // -> so if we are interested in 2-state we use bit type else if we are interested in 4-state we use logic type
  
  bit clk, rst;// these two are global signals
  
  rand bit wreq, rreq;// but here we use pseudo random generator
  rand bit [7:0] wdata;
  
  // we can't use pseudo random generator with output ports 
  bit [7:0] rdata;
  bit f,e;
  
  constraint ctrl_wreq_rreq{
    wreq dist {0:=30, 1:=70};
    rreq dist {0:=30, 1:=70};
  }
  
  // this constraint is to specify th we can not read and write at the same time
  constraint ctrl_wr_rd{
   	wreq != rreq; 
  }
  
  /*a long with this transactions we could also have some methodes we we are writing the test bench for a complex system 
  for example the transaction class for the UART we need to generate the parity;
  means we need to create the data first and generate the parity then create our packet
  
or for example for the internet we need to generate the checksum, these thinks could be done by adding some methodes to the transaction class
an other situation where we use the transaction class is when we want to print the data that we have generated
  */
endclass
  
endmodule

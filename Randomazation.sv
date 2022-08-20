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

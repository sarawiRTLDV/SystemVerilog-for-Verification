
// a class is a dynamic object and a module is a static object 
// so when we say static we mean that when we performe a simulation the module object will be there right from the start of our simulation tell the end even if we do not use it
// Whereas when we consider a class, we may require to use an object from a class and when we no longer need it we could just delete it during a simulation.
class first;                         
                                      
  reg [2:0] data; 
  reg [1:0] data2;
  
  
endclass
 
 
module tb;
  
  first f;
  
  initial begin
    f = new();// here we use new in order to create an object which means that we are allocating a memory for our object
              //if we don't do it f object will be just a NULL pointer
    f.data = 3'b111;// here is how we can access the atributs of our object
    f.data2 = 2'b01;
    
    f = null;// here we deallocate the memory of our object means f will be pointing to null again
    
    #1;
    $display("Value of data : %0d and data2 : %0d",f.data, f.data2);
  end
  
  
  
endmodule

 // if we use a module instead of class  in verilog
/*====================================*/
module top( input a, b, output y);
  reg temp;
  assign y = a & b; // this a continous assignment
  
endmodule

//we use the module here

module top2(input c, d, output e);
  
  top dut(c, d, e);// this is how we create an instance of our module
  dut.temp; // here is how to access a variable of our object
  
endmodule

/*===================================*/



// in general functions are just like in c language 
module test();
  
  // we could also initialize the arguments in function declaration
  /* we could use add() as folow
  function bit[7:0] add();
  
    return a + b;
  
  endfunction
  -> but in this case a and b should be visible to the function 
  
  ===============================================
  or we could also use the following declaration
  
  function void add(input bit[6:0] a, b);
  
    $display("a = %0d and b = %0d ", a, b);
    
  
  endfunction
  
  -> we refere to this declaration in case we want to display variables or somthing
  ================================================
  we can not controling time using a function 
  because time controling is not allowed inside a function
  for that we use task  instead
  */
  function bit[7:0] add(input bit[6:0] a, b);
  
    return a + b;
  
  endfunction
  
  bit [6:0] ain = 3, bin = 6;

  bit[9:0] res = 0;

  initial begin
	// we could do this 
    res = add(4, 3);
    // we could also do this 
    res = add(ain, bin);
    // and this
    res = add(); /* but in this case we have declare "a" and "b" before declaring the 							function so that they will be visible to the add function*/
    $display("result is -> %0d", res);

  end
    
endmodule




// here is how to use a task methode 

module tb;
  
  
  
  /// the default arguments direction : input
  // here if we want to pass parameters to our task
  /*
  task add (input bit [3:0] a, input bit [3:0] b, output bit [4:0] y);
   y = a + b;
  endtask
  */
  
  
  bit [3:0] a,b;
  bit [4:0] y;
  
  bit clk = 0;
  //here we are calling in on this always block without a sensitivity-> this will run for ever so to stop the simulatio we need to use $finish function inside an initial block
  always #5 clk = ~clk;  ///10 ns --> 100Mhz
 
  task add ();
   y = a + b;
    $display("a : %0d and b : %0d and y : %0d at %0t",a,b,y, $time);
  endtask
  
  task stim_a_b();
    a = 1;
    b = 3;
    add();
    #10;// since inside task we can use time control
    a = 5;
    b = 6;
    add();
    #10;
    a = 7;
    b = 8;
    add();
    #10;
  endtask
  
  
  task stim_clk ();
    @(posedge clk);    // wait for the positive edge of the clock just like rising edge ! we could use wait as will
    a = $urandom();//So this will basically generate an unsigned random 32 bit.

    b = $urandom();
    add();
  endtask
  
  initial begin
    stim_a_b();
    #110;
    $finish();
  end
  
  
 
  initial begin
    
    // this comming for loop is just to execute the stim_clk 11 time 
    for(int i = 0; i< 11 ; i++) begin
      stim_clk();
    end
  
  end
 
  
  
endmodule




//======================================================================================

/*** now let's talk about the difference between functions and task ***/

module tb;
 
  //////pass by value
  
  task swap ( input bit [1:0] a, [1:0] b); 
    bit [1:0] temp;
    temp = a;
    a = b;
    b = temp;   
    $display("Value of a : %0d and b : %0d", a,b);
  endtask
  
  
  
  
  
  
  //////pass by reference
  
   task automatic swap ( ref bit [1:0] a, [1:0] b); /// function automatic bit [1:0] add (arguments);
    bit [1:0] temp;
    temp = a;
    a = b;
    b = temp;
    
    $display("Value of a : %0d and b : %0d", a,b);
  endtask
 
  
  ////restrict access to variables
  task automatic swap (const ref bit [1:0] a, ref bit [1:0] b); /// function automatic bit [1:0] add (arguments);
    bit [1:0] temp;
    
    temp = a;
  //  a = b;
    b = temp;
    
    $display("Value of a : %0d and b : %0d", a,b);
  endtask
  
  bit [1:0] a;
  bit [1:0] b;
  
  initial begin
    a = 1;
    b = 2;
    
    swap(a,b);
    
    $display("Value of a : %0d and b : %0d", a,b);
  end
  
  
endmodule


// here is the difference between passing by refence and passing by value using a function


module tb;
  
  bit [3:0] res[16];
  
  // this function will pass by reference through the intire given array
  function automatic void init_arr (ref bit [3:0] a[16]);  
    for(int i =0; i <= 15; i++) begin
      a[i] = i;
    end
  endfunction 
  
  // but this one will just pass by value so it will not change the values of the array
  //means it will just change the copy of the array
  
  function void passByvalue(input bit [3:0] array[16]);
  
  for(int i = 0; i < 16; i++) begin
  
    array[i] = i + 1;
    
  end
  
  
  endfunction
  initial begin
    
    passByvalue(res);
    for(int i =0; i <= 15; i++) begin
      $display("res[%0d] : %0d", i, res[i]);
    end
    
    init_arr(res);
    $display("the values inside the array are -> %0p", res);  
    
    
  end
  
  
endmodule

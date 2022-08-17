
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

class test; // remember a class is always declared outside the tb()
    // here is how we can create the constructor of our class
    // to do so we use the special function -> new()solve
    // remember you are are not allowed to specify the type of return
    
    int data;
    
    function new(input int datain = 0);// 
        
       // data = 32;
        data = datain;
    endfunction  
    endclass

module SV();
    
    initial begin
        // first of all we have to create an object of the test class
        test f1;
        //also we have to create a constructor of our object
        f1 = new(43);
        $display("data = %0d", f1.data);
    end

endmodule

//here is how to use functions and task inside a class

class first;
  
  int data1;
  bit [7:0] data2;
  shortint data3;
  
  function new(input int data1 = 0, input bit[7:0] data2 = 8'h00, input shortint data3 = 0);
   // in case we want to use the same name of the class data members we need to use the key word this
   this.data1 = data1;
   this.data2 = data2;
   this.data3 = data3;    
  endfunction
  
	
  task display();
	  $display("Data1 : %0d, Data2 : %0d and Data3 : %0d", data1, data2, data3); 
  endtask
  
endclass
 
 
module sim_tb;
  
  first f1;
  
  initial begin
    //f1 = new(23,,35); ///if we want to follow position
    f1 = new( .data2(4), .data3(5), .data1(23)); //if we want to follow name
    f1.display();// this is how to call a task of an instructor 
  end
  
  
endmodule


/*===================================================================*/
//here is how to use a class inside other class 

class one;
// if we want to protect the class atributes we need to use the key word local
// just like private in c++ used to restrict atributes of a class
//int data = 7;
local int data = 7;

// to access data we need to create a task to set and function to get it
task set(int data);
    this.data = data;
endtask

function int get();
    return this.data;
endfunction 

task display();
    $display("the value of data of obj is: %0d", data);
endtask
endclass

class two;
    
    one obj1;
    function new();
        obj1 = new();
    endfunction    
    
endclass


module tb;
    one obj3;
    two obj2;
    int ret;
    initial begin
        obj2 = new();
        obj3 = new();
        // we can change the value of the atributes of class one using the handler declared inside the class two
      
        obj2.obj1.display();
        obj2.obj1.set(59);
        ret = obj2.obj1.get();
        $display("reterned value is: %0d", ret);
        obj2.obj1.display();
        obj3.display();// if we display the data of obj3 we will get 7 
        // that's because every object from the class will hav its own variable
        // means that if we change the value of data of obj1 the data of obj3 will not be changed
    end 

endmodule


class one;
// if we want to protect the class atributes we need to use the key word local
// just like private in c++ used to restrict atributes of a class
int data = 7;
// to access data we need to create a task to set and function to get it
task set(int data);
    this.data = data;
endtask

function int get();
    return this.data;
endfunction 

task display();
    $display("the value of data of obj is: %0d", data);
endtask
endclass

class two;
    
    one obj1;
    function new();
        obj1 = new();
    endfunction    
    
endclass


module tb;
    one obj3;
    two obj2;
    int ret;
    initial begin
        obj2 = new();
        obj3 = new();
        // we can change the value of the atributes of class one using the handler declared inside the class two
      
        obj2.obj1.display();
        obj2.obj1.set(59);
        ret = obj2.obj1.get();
        $display("reterned value is: %0d", ret);
        obj2.obj1.display();
        obj3.display();// if we display the data of obj3 we will get 7 
        // that's because every object from the class will hav its own variable
        // means that if we change the value of data of obj1 the data of obj3 will not be changed
    end 

endmodule


class one;
// if we want to protect the class atributes we need to use the key word local
// just like private in c++ used to restrict atributes of a class
int data = 7;
// to access data we need to create a task to set and function to get it
task set(int data);
    this.data = data;
endtask

function int get();
    return this.data;
endfunction 

task display();
    $display("the value of data of obj is: %0d", data);
endtask
endclass

class two;
    
    one obj1;
    function new();
        obj1 = new();
    endfunction    
    
endclass


module tb;
    one obj3;
    two obj2;
    int ret;
    initial begin
        obj2 = new();
        obj3 = new();
        // we can change the value of the atributes of class one using the handler declared inside the class two
      
        obj2.obj1.display();
        obj2.obj1.set(59);
        ret = obj2.obj1.get();
        $display("reterned value is: %0d", ret);
        obj2.obj1.display();
        obj3.display();// if we display the data of obj3 we will get 7 
        // that's because every object from the class will hav its own variable
        // means that if we change the value of data of obj1 the data of obj3 will not be changed
    end 

endmodule

class one;
// if we want to protect the class atributes we need to use the key word local
// just like private in c++ used to restrict atributes of a class
int data = 7;
// to access data we need to create a task to set and function to get it
task set(int data);
    this.data = data;
endtask

function int get();
    return this.data;
endfunction 

task display();
    $display("the value of data of obj is: %0d", data);
endtask
endclass

class two;
    
    one obj1;
    function new();
        obj1 = new();
    endfunction    
    
endclass


module tb;
    one obj3;
    two obj2;
    int ret;
    initial begin
        obj2 = new();
        obj3 = new();
        // we can change the value of the atributes of class one using the handler declared inside the class two
      
        obj2.obj1.display();
        obj2.obj1.set(59);
        ret = obj2.obj1.get();
        $display("reterned value is: %0d", ret);
        obj2.obj1.display();
        obj3.display();// if we display the data of obj3 we will get 7 
        // that's because every object from the class will hav its own variable
        // means that if we change the value of data of obj1 the data of obj3 will not be changed
    end 

endmodule

class one;
// if we want to protect the class atributes we need to use the key word local
// just like private in c++ used to restrict atributes of a class
int data = 7;
// to access data we need to create a task to set and function to get it
task set(int data);
    this.data = data;
endtask

function int get();
    return this.data;
endfunction 

task display();
    $display("the value of data of obj is: %0d", data);
endtask
endclass

class two;
    
    one obj1;
    function new();
        obj1 = new();
    endfunction    
    
endclass


module tb;
    one obj3;
    two obj2;
    int ret;
    initial begin
        obj2 = new();
        obj3 = new();
        // we can change the value of the atributes of class one using the handler declared inside the class two
      
        obj2.obj1.display();
        obj2.obj1.set(59);
        ret = obj2.obj1.get();
        $display("reterned value is: %0d", ret);
        obj2.obj1.display();
        obj3.display();// if we display the data of obj3 we will get 7 
        // that's because every object from the class will hav its own variable
        // means that if we change the value of data of obj1 the data of obj3 will not be changed
    end 

endmodule


class one;
// if we want to protect the class atributes we need to use the key word local
// just like private in c++ used to restrict atributes of a class
int data = 7;
// to access data we need to create a task to set and function to get it
task set(int data);
    this.data = data;
endtask

function int get();
    return this.data;
endfunction 

task display();
    $display("the value of data of obj is: %0d", data);
endtask
endclass

class two;
    
    one obj1;
    function new();
        obj1 = new();
    endfunction    
    
endclass


module tb;
    one obj3;
    two obj2;
    int ret;
    initial begin
        obj2 = new();
        obj3 = new();
        // we can change the value of the atributes of class one using the handler declared inside the class two
      
        obj2.obj1.display();
        obj2.obj1.set(59);
        ret = obj2.obj1.get();
        $display("reterned value is: %0d", ret);
        obj2.obj1.display();
        obj3.display();// if we display the data of obj3 we will get 7 
        // that's because every object from the class will hav its own variable
        // means that if we change the value of data of obj1 the data of obj3 will not be changed
    end 

endmodule


class one;
// if we want to protect the class atributes we need to use the key word local
// just like private in c++ used to restrict atributes of a class
int data = 7;
// to access data we need to create a task to set and function to get it
task set(int data);
    this.data = data;
endtask

function int get();
    return this.data;
endfunction 

task display();
    $display("the value of data of obj is: %0d", data);
endtask
endclass

class two;
    
    one obj1;
    function new();
        obj1 = new();
    endfunction    
    
endclass


module tb;
    one obj3;
    two obj2;
    int ret;
    initial begin
        obj2 = new();
        obj3 = new();
        // we can change the value of the atributes of class one using the handler declared inside the class two
      
        obj2.obj1.display();
        obj2.obj1.set(59);
        ret = obj2.obj1.get();
        $display("reterned value is: %0d", ret);
        obj2.obj1.display();
        obj3.display();// if we display the data of obj3 we will get 7 
        // that's because every object from the class will hav its own variable
        // means that if we change the value of data of obj1 the data of obj3 will not be changed
    end 

endmodule

class one;
// if we want to protect the class atributes we need to use the key word local
// just like private in c++ used to restrict atributes of a class
int data = 7;
// to access data we need to create a task to set and function to get it
task set(int data);
    this.data = data;
endtask

function int get();
    return this.data;
endfunction 

task display();
    $display("the value of data of obj is: %0d", data);
endtask
endclass

class two;
    
    one obj1;
    function new();
        obj1 = new();
    endfunction    
    
endclass


module tb;
    one obj3;
    two obj2;
    int ret;
    initial begin
        obj2 = new();
        obj3 = new();
        // we can change the value of the atributes of class one using the handler declared inside the class two
      
        obj2.obj1.display();
        obj2.obj1.set(59);
        ret = obj2.obj1.get();
        $display("reterned value is: %0d", ret);
        obj2.obj1.display();
        obj3.display();// if we display the data of obj3 we will get 7 
        // that's because every object from the class will hav its own variable
        // means that if we change the value of data of obj1 the data of obj3 will not be changed
    end 

endmodule

class one;
// if we want to protect the class atributes we need to use the key word local
// just like private in c++ used to restrict atributes of a class
int data = 7;
// to access data we need to create a task to set and function to get it
task set(int data);
    this.data = data;
endtask

function int get();
    return this.data;
endfunction 

task display();
    $display("the value of data of obj is: %0d", data);
endtask
endclass

class two;
    
    one obj1;
    function new();
        obj1 = new();
    endfunction    
    
endclass


module tb;
    one obj3;
    two obj2;
    int ret;
    initial begin
        obj2 = new();
        obj3 = new();
        // we can change the value of the atributes of class one using the handler declared inside the class two
      
        obj2.obj1.display();
        obj2.obj1.set(59);
        ret = obj2.obj1.get();
        $display("reterned value is: %0d", ret);
        obj2.obj1.display();
        obj3.display();// if we display the data of obj3 we will get 7 
        // that's because every object from the class will hav its own variable
        // means that if we change the value of data of obj1 the data of obj3 will not be changed
    end 

endmodule

class one;
// if we want to protect the class atributes we need to use the key word local
// just like private in c++ used to restrict atributes of a class
int data = 7;
// to access data we need to create a task to set and function to get it
task set(int data);
    this.data = data;
endtask

function int get();
    return this.data;
endfunction 

task display();
    $display("the value of data of obj is: %0d", data);
endtask
endclass

class two;
    
    one obj1;
    function new();
        obj1 = new();
    endfunction    
    
endclass


module tb;
    one obj3;
    two obj2;
    int ret;
    initial begin
        obj2 = new();
        obj3 = new();
        // we can change the value of the atributes of class one using the handler declared inside the class two
      
        obj2.obj1.display();
        obj2.obj1.set(59);
        ret = obj2.obj1.get();
        $display("reterned value is: %0d", ret);
        obj2.obj1.display();
        obj3.display();// if we display the data of obj3 we will get 7 
        // that's because every object from the class will hav its own variable
        // means that if we change the value of data of obj1 the data of obj3 will not be changed
    end 

endmodule

class one;
// if we want to protect the class atributes we need to use the key word local
// just like private in c++ used to restrict atributes of a class
int data = 7;
// to access data we need to create a task to set and function to get it
task set(int data);
    this.data = data;
endtask

function int get();
    return this.data;
endfunction 

task display();
    $display("the value of data of obj is: %0d", data);
endtask
endclass

class two;
    
    one obj1;
    function new();
        obj1 = new();
    endfunction    
    
endclass


module tb;
    one obj3;
    two obj2;
    int ret;
    initial begin
        obj2 = new();
        obj3 = new();
        // we can change the value of the atributes of class one using the handler declared inside the class two
      
        obj2.obj1.display();
        obj2.obj1.set(59);
        ret = obj2.obj1.get();
        $display("reterned value is: %0d", ret);
        obj2.obj1.display();
        obj3.display();// if we display the data of obj3 we will get 7 
        // that's because every object from the class will hav its own variable
        // means that if we change the value of data of obj1 the data of obj3 will not be changed
    end 

endmodule

class one;
// if we want to protect the class atributes we need to use the key word local
// just like private in c++ used to restrict atributes of a class
int data = 7;
// to access data we need to create a task to set and function to get it
task set(int data);
    this.data = data;
endtask

function int get();
    return this.data;
endfunction 

task display();
    $display("the value of data of obj is: %0d", data);
endtask
endclass

class two;
    
    one obj1;
    function new();
        obj1 = new();
    endfunction    
    
endclass


module tb;
    one obj3;
    two obj2;
    int ret;
    initial begin
        obj2 = new();
        obj3 = new();
        // we can change the value of the atributes of class one using the handler declared inside the class two
      
        obj2.obj1.display();
        obj2.obj1.set(59);
        ret = obj2.obj1.get();
        $display("reterned value is: %0d", ret);
        obj2.obj1.display();
        obj3.display();// if we display the data of obj3 we will get 7 
        // that's because every object from the class will hav its own variable
        // means that if we change the value of data of obj1 the data of obj3 will not be changed
    end 

endmodule

class one;
// if we want to protect the class atributes we need to use the key word local
// just like private in c++ used to restrict atributes of a class
int data = 7;
// to access data we need to create a task to set and function to get it
task set(int data);
    this.data = data;
endtask

function int get();
    return this.data;
endfunction 

task display();
    $display("the value of data of obj is: %0d", data);
endtask
endclass

class two;
    
    one obj1;
    function new();
        obj1 = new();
    endfunction    
    
endclass


module tb;
    one obj3;
    two obj2;
    int ret;
    initial begin
        obj2 = new();
        obj3 = new();
        // we can change the value of the atributes of class one using the handler declared inside the class two
      
        obj2.obj1.display();
        obj2.obj1.set(59);
        ret = obj2.obj1.get();
        $display("reterned value is: %0d", ret);
        obj2.obj1.display();
        obj3.display();// if we display the data of obj3 we will get 7 
        // that's because every object from the class will hav its own variable
        // means that if we change the value of data of obj1 the data of obj3 will not be changed
    end 

endmodule

class one;
// if we want to protect the class atributes we need to use the key word local
// just like private in c++ used to restrict atributes of a class
int data = 7;
// to access data we need to create a task to set and function to get it
task set(int data);
    this.data = data;
endtask

function int get();
    return this.data;
endfunction 

task display();
    $display("the value of data of obj is: %0d", data);
endtask
endclass

class two;
    
    one obj1;
    function new();
        obj1 = new();
    endfunction    
    
endclass


module tb;
    one obj3;
    two obj2;
    int ret;
    initial begin
        obj2 = new();
        obj3 = new();
        // we can change the value of the atributes of class one using the handler declared inside the class two
      
        obj2.obj1.display();
        obj2.obj1.set(59);
        ret = obj2.obj1.get();
        $display("reterned value is: %0d", ret);
        obj2.obj1.display();
        obj3.display();// if we display the data of obj3 we will get 7 
        // that's because every object from the class will hav its own variable
        // means that if we change the value of data of obj1 the data of obj3 will not be changed
    end 

endmodule



class one;
// if we want to protect the class atributes we need to use the key word local
// just like private in c++ used to restrict atributes of a class
int data = 7;
// to access data we need to create a task to set and function to get it
task set(int data);
    this.data = data;
endtask

function int get();
    return this.data;
endfunction 

task display();
    $display("the value of data of obj is: %0d", data);
endtask
endclass

class two;
    
    one obj1;
    function new();
        obj1 = new();
    endfunction    
    
endclass


module tb;
    one obj3;
    two obj2;
    int ret;
    initial begin
        obj2 = new();
        obj3 = new();
        // we can change the value of the atributes of class one using the handler declared inside the class two
      
        obj2.obj1.display();
        obj2.obj1.set(59);
        ret = obj2.obj1.get();
        $display("reterned value is: %0d", ret);
        obj2.obj1.display();
        obj3.display();// if we display the data of obj3 we will get 7 
        // that's because every object from the class will hav its own variable
        // means that if we change the value of data of obj1 the data of obj3 will not be changed
    end 

endmodule

class one;
// if we want to protect the class atributes we need to use the key word local
// just like private in c++ used to restrict atributes of a class
int data = 7;
// to access data we need to create a task to set and function to get it
task set(int data);
    this.data = data;
endtask

function int get();
    return this.data;
endfunction 

task display();
    $display("the value of data of obj is: %0d", data);
endtask
endclass

class two;
    
    one obj1;
    function new();
        obj1 = new();
    endfunction    
    
endclass


module tb;
    one obj3;
    two obj2;
    int ret;
    initial begin
        obj2 = new();
        obj3 = new();
        // we can change the value of the atributes of class one using the handler declared inside the class two
      
        obj2.obj1.display();
        obj2.obj1.set(59);
        ret = obj2.obj1.get();
        $display("reterned value is: %0d", ret);
        obj2.obj1.display();
        obj3.display();// if we display the data of obj3 we will get 7 
        // that's because every object from the class will hav its own variable
        // means that if we change the value of data of obj1 the data of obj3 will not be changed
    end 

endmodule

class one;
// if we want to protect the class atributes we need to use the key word local
// just like private in c++ used to restrict atributes of a class
int data = 7;
// to access data we need to create a task to set and function to get it
task set(int data);
    this.data = data;
endtask

function int get();
    return this.data;
endfunction 

task display();
    $display("the value of data of obj is: %0d", data);
endtask
endclass

class two;
    
    one obj1;
    function new();
        obj1 = new();
    endfunction    
    
endclass


module tb;
    one obj3;
    two obj2;
    int ret;
    initial begin
        obj2 = new();
        obj3 = new();
        // we can change the value of the atributes of class one using the handler declared inside the class two
      
        obj2.obj1.display();
        obj2.obj1.set(59);
        ret = obj2.obj1.get();
        $display("reterned value is: %0d", ret);
        obj2.obj1.display();
        obj3.display();// if we display the data of obj3 we will get 7 
        // that's because every object from the class will hav its own variable
        // means that if we change the value of data of obj1 the data of obj3 will not be changed
    end 

endmodule

class one;
// if we want to protect the class atributes we need to use the key word local
// just like private in c++ used to restrict atributes of a class
int data = 7;
// to access data we need to create a task to set and function to get it
task set(int data);
    this.data = data;
endtask

function int get();
    return this.data;
endfunction 

task display();
    $display("the value of data of obj is: %0d", data);
endtask
endclass

class two;
    
    one obj1;
    function new();
        obj1 = new();
    endfunction    
    
endclass


module tb;
    one obj3;
    two obj2;
    int ret;
    initial begin
        obj2 = new();
        obj3 = new();
        // we can change the value of the atributes of class one using the handler declared inside the class two
      
        obj2.obj1.display();
        obj2.obj1.set(59);
        ret = obj2.obj1.get();
        $display("reterned value is: %0d", ret);
        obj2.obj1.display();
        obj3.display();// if we display the data of obj3 we will get 7 
        // that's because every object from the class will hav its own variable
        // means that if we change the value of data of obj1 the data of obj3 will not be changed
    end 

endmodule

class one;
// if we want to protect the class atributes we need to use the key word local
// just like private in c++ used to restrict atributes of a class
int data = 7;
// to access data we need to create a task to set and function to get it
task set(int data);
    this.data = data;
endtask

function int get();
    return this.data;
endfunction 

task display();
    $display("the value of data of obj is: %0d", data);
endtask
endclass

class two;
    
    one obj1;
    function new();
        obj1 = new();
    endfunction    
    
endclass


module tb;
    one obj3;
    two obj2;
    int ret;
    initial begin
        obj2 = new();
        obj3 = new();
        // we can change the value of the atributes of class one using the handler declared inside the class two
      
        obj2.obj1.display();
        obj2.obj1.set(59);
        ret = obj2.obj1.get();
        $display("reterned value is: %0d", ret);
        obj2.obj1.display();
        obj3.display();// if we display the data of obj3 we will get 7 
        // that's because every object from the class will hav its own variable
        // means that if we change the value of data of obj1 the data of obj3 will not be changed
    end 

endmodule
the handler declared inside the class two
class one;
// if we want to protect the class atributes we need to use the key word local
// just like private in c++ used to restrict atributes of a class
int data = 7;
// to access data we need to create a task to set and function to get it
task set(int data);
    this.data = data;
endtask

function int get();
    return this.data;
endfunction 

task display();
    $display("the value of data of obj is: %0d", data);
endtask
endclass

class two;
    
    one obj1;
    function new();
        obj1 = new();
    endfunction    
    
endclass


module tb;
    one obj3;
    two obj2;
    int ret;
    initial begin
        obj2 = new();
        obj3 = new();
        // we can change the value of the atributes of class one using the handler declared inside the class two
      
        obj2.obj1.display();
        obj2.obj1.set(59);
        ret = obj2.obj1.get();
        $display("reterned value is: %0d", ret);
        obj2.obj1.display();
        obj3.display();// if we display the data of obj3 we will get 7 
        // that's because every object from the class will hav its own variable
        // means that if we change the value of data of obj1 the data of obj3 will not be changed
    end 

endmodule

class one;
// if we want to protect the class atributes we need to use the key word local
// just like private in c++ used to restrict atributes of a class
int data = 7;
// to access data we need to create a task to set and function to get it
task set(int data);
    this.data = data;
endtask

function int get();
    return this.data;
endfunction 

task display();
    $display("the value of data of obj is: %0d", data);
endtask
endclass

class two;
    
    one obj1;
    function new();
        obj1 = new();
    endfunction    
    
endclass


module tb;
    one obj3;
    two obj2;
    int ret;
    initial begin
        obj2 = new();
        obj3 = new();
        // we can change the value of the atributes of class one using the handler declared inside the class two
      
        obj2.obj1.display();
        obj2.obj1.set(59);
        ret = obj2.obj1.get();
        $display("reterned value is: %0d", ret);
        obj2.obj1.display();
        obj3.display();// if we display the data of obj3 we will get 7 
        // that's because every object from the class will hav its own variable
        // means that if we change the value of data of obj1 the data of obj3 will not be changed
    end 

endmodule

class one;
// if we want to protect the class atributes we need to use the key word local
// just like private in c++ used to restrict atributes of a class
int data = 7;
// to access data we need to create a task to set and function to get it
task set(int data);
    this.data = data;
endtask

function int get();
    return this.data;
endfunction 

task display();
    $display("the value of data of obj is: %0d", data);
endtask
endclass

class two;
    
    one obj1;
    function new();
        obj1 = new();
    endfunction    
    
endclass


module tb;
    one obj3;
    two obj2;
    int ret;
    initial begin
        obj2 = new();
        obj3 = new();
        // we can change the value of the atributes of class one using the handler declared inside the class two
      
        obj2.obj1.display();
        obj2.obj1.set(59);
        ret = obj2.obj1.get();
        $display("reterned value is: %0d", ret);
        obj2.obj1.display();
        obj3.display();// if we display the data of obj3 we will get 7 
        // that's because every object from the class will hav its own variable
        // means that if we change the value of data of obj1 the data of obj3 will not be changed
    end 

endmodule

class one;
// if we want to protect the class atributes we need to use the key word local
// just like private in c++ used to restrict atributes of a class
int data = 7;
// to access data we need to create a task to set and function to get it
task set(int data);
    this.data = data;
endtask

function int get();
    return this.data;
endfunction 

task display();
    $display("the value of data of obj is: %0d", data);
endtask
endclass

class two;
    
    one obj1;
    function new();
        obj1 = new();
    endfunction    
    
endclass


module tb;
    one obj3;
    two obj2;
    int ret;
    initial begin
        obj2 = new();
        obj3 = new();
        // we can change the value of the atributes of class one using the handler declared inside the class two
      
        obj2.obj1.display();
        obj2.obj1.set(59);
        ret = obj2.obj1.get();
        $display("reterned value is: %0d", ret);
        obj2.obj1.display();
        obj3.display();// if we display the data of obj3 we will get 7 
        // that's because every object from the class will hav its own variable
        // means that if we change the value of data of obj1 the data of obj3 will not be changed
    end 

endmodule

class one;
// if we want to protect the class atributes we need to use the key word local
// just like private in c++ used to restrict atributes of a class
int data = 7;
// to access data we need to create a task to set and function to get it
task set(int data);
    this.data = data;
endtask

function int get();
    return this.data;
endfunction 

task display();
    $display("the value of data of obj is: %0d", data);
endtask
endclass

class two;
    
    one obj1;
    function new();
        obj1 = new();
    endfunction    
    
endclass


module tb;
    one obj3;
    two obj2;
    int ret;
    initial begin
        obj2 = new();
        obj3 = new();
        // we can change the value of the atributes of class one using the handler declared inside the class two
      
        obj2.obj1.display();
        obj2.obj1.set(59);
        ret = obj2.obj1.get();
        $display("reterned value is: %0d", ret);
        obj2.obj1.display();
        obj3.display();// if we display the data of obj3 we will get 7 
        // that's because every object from the class will hav its own variable
        // means that if we change the value of data of obj1 the data of obj3 will not be changed
    end 

endmodule


class one;
// if we want to protect the class atributes we need to use the key word local
// just like private in c++ used to restrict atributes of a class
int data = 7;
// to access data we need to create a task to set and function to get it
task set(int data);
    this.data = data;
endtask

function int get();
    return this.data;
endfunction 

task display();
    $display("the value of data of obj is: %0d", data);
endtask
endclass

class two;
    
    one obj1;
    function new();
        obj1 = new();
    endfunction    
    
endclass


module tb;
    one obj3;
    two obj2;
    int ret;
    initial begin
        obj2 = new();
        obj3 = new();
        // we can change the value of the atributes of class one using the handler declared inside the class two
      
        obj2.obj1.display();
        obj2.obj1.set(59);
        ret = obj2.obj1.get();
        $display("reterned value is: %0d", ret);
        obj2.obj1.display();
        obj3.display();// if we display the data of obj3 we will get 7 
        // that's because every object from the class will hav its own variable
        // means that if we change the value of data of obj1 the data of obj3 will not be changed
    end 

endmodule


// the following code shows us how to create a copy of our class Object
class first;
  
  int data;
  
endclass
 
module tb;
  
  first f1;
  first p1;
  first f2;
  
  
  initial begin
    f1 = new();  ///1. constructor 
    ///////////////
    f1.data = 24;   ///2. processing 
                    // in this part we do multiple operation on our original object
    /////////////////
    
    p1 = new f1;  /// 3. creating p1 and copying data from f1 to p1
    
    /////////////
    
    $display("Value of data member : %0d", p1.data);  //4. processing 
    
    p1.data = 12; // this will just change the data of p1 not f1
    $display("Value of data of p1 : %0d", f1.data);
       
    
  end
  
  
  
endmodule

	
/*in the comming part we explain how to coppy an objec in case the class doesn't have any other class declared inside it, means there are only data members*/
class first;
  
  int data  = 1;
  bit [2:0] temp = 3'b110;
  
  // the recomended method to coppy an objct is to use a custom copy method
  
  function first copy(); 
    
    copy = new();
    // here we create an object based on the caller object 
    // bear in mind that the function is itself the object
    copy.data = data;
    copy.temp = temp;
    
  endfunction
  
  
endclass


module tb;
  // first of all we need to create our objects
  first f1;
  first f2;
  
  initial begin
  // then we allocate memory to our original object 
  f1 =  new();
  
  // then we do our process on the f1 object 
  
  f1.data = 32;
  
  // lastelly we copy the original object to the second object 
  // means we coppy the memory allocated to the f1 object and allocate it to f2 obj
  
  //f2 = new f1;
  // an other way to do it is to use the custom copy method
  
    f2 = f1.copy();
  
  $display("data of f2 is %d", f2.data);
  end
endmodule

/*================================================================*/
	
// here we will be understanding very clearlly the difference between Shallow copy and Deep Copy
	
// Code your testbench here
// or browse Examples


class two;
  
  int data2 = 2;
  
  function two copy2();// this function will be used to create a copy of an original obj
    
    copy2 = new(); // this line of code to allocate a memory for our copy
    copy2.data2 = data2;
    
  endfunction
  
endclass

class one; 
  
  int data1 = 1;
  two t;// here we create an instance of the two class
  
  function new();
    
    t = new();// here we allocate a memory to our instance
    
  endfunction
  
  function one copy();// this function will be used if we want to use a shallow copy
    
    copy = new();
    copy.data1 = data1;
    copy.t = t;
    
  endfunction
  
  function one copy1();// this methode will be use if we want to use a Deep copy
    
    copy1 = new();
    copy1.data1 = data1;
    copy1.t = t.copy2();// this will return a copy of the original t obj
    
  endfunction
  
  
endclass

module tb();
  
  one o1, o2;
  
  
  initial begin
    // 1. create our constuctors
    o1=new();
    o2=new();

    // 2. processing
    o1.data1 = 100;
    o1.t.data2 = 200;

    $display("data1 = %0d, data2 = %0d", o1.data1, o1.t.data2);
    $display("=================================================");
    // 3.copying object
    o2 = o1.copy(); // is we use copy instead of copy1 we are doing a shallow copy 

    $display("data1ofo1 = %0d, data1ofo2 = %0d, data2ofo1 = %0d, data2ofo2", o1.data1, o2.data1, o1.t.data2, o2.t.data2);
    $display("==================================================");
    // let's try to change the value of data2 of o2 and verify that we are using a shallow copy
    o2.data1 = 300;
    o2.t.data2 = 400;
    
    $display("data1ofo1 = %0d, data1ofo2 = %0d, data2ofo1 = %0d, data2ofo2", o1.data1, o2.data1, o1.t.data2, o2.t.data2);
    $display("===================================================");
    
    //now let's use the Deep copy methode
    o2 = o1.copy1();
    // let's try to change the value of data2 of o2 and verify that we are using a shallow copy
    o2.data1 = 700;
    o2.t.data2 = 900;
    
    $display("data1ofo1 = %0d, data1ofo2 = %0d, data2ofo1 = %0d, data2ofo2", o1.data1, o2.data1, o1.t.data2, o2.t.data2);
    $display("===================================================");
    
  end
  
endmodule


	
	
/*==================================================================================================*/

/*inheritance and Polymorphism*/	
class first;  ///parent class
  
  int data = 12;
  // this comming function will be used the the child class only if the child class doesn't have one
  virtual function void display();// polymorphism
     $display("FIRST : Value of data : %0d", data);
  endfunction
  
 
  
endclass
 
// we use the keyword extends for inhiretance 
class second extends first; //child class
  
  int temp = 34;
  
  function void add();
    $display("secomd:Value after process : %0d", temp+4);
  endfunction
  
 
  function void display();
    $display("SECOND : Value of data : %0d", data);
  endfunction
 
  
  
  
endclass
 
 
module tb;
  
  first f;
  second s;
  
  
  initial begin
    f = new();
    s = new();
    
    f = s;
    f.display();
    
  end
endmodule
	

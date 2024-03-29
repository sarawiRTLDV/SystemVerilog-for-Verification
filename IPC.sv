/*=============================================================*/

//IPC

/*so, we have a various mechanishm to convey the data or some important message between the classes, we have two situation that we frequently find while writing the tb:
1-> When we want to convey that certain process is completed -> we use event.
2-> Where we wnat to communicate the data between the classes -> we use the Semaphore or Mailbox

Well, we already know that the data that the Generator class will generate should be sent to a driver and then driver will apply to a duty; to do so we need to use IPC mechanisim and simelarly between the monitor and the Scoreboard

*/

// 1-> Event

// events are not use to communicate the data, instead they used to communicate messages between classes

// here are the Event operators

///Trigger: ->      which is used to trigger and event
///edge sensitive_blocking: @()
//level_sensitive_nonblocking:  wait()

module tb; 
  
  event ev; // this is how we declare an event 
  
  // these two events are to understand the difference between @() and wait()
  event ev1;
  event ev2;
  
  initial begin
    -> ev1;
    -> ev2;
    #10 // we will wait for 10 ns before triggering our event 
    -> ev;
    
  end
  
  initial begin
    // in this example there is no difference between using @() and wait()
    // 1.edge sensitive_blocking 
    //@(ev);
    // 2.level sensitive_nonblocking
    /*wait(ev.triggered);
    $display("The event is triggered at %0t", $time);*/
    
    // here we will understand the difference between @() and wait()
    //if we go with edge sensitive_blocking @() for ev1 and ev2 we will miss sensing there trigger
    // means that the dipslay function will not be executed for both of them maybe because they are triggered at 0ns
   /* @(ev1);
    $display("EV1 Triggered at %0t", $time);
    @(ev2.triggered);
    $display("EV2 Triggered at %0t", $time);*/
    
    // but if we go with level sensing_nonblocking wait(), we will not miss sensing there trigger
    // here the first display will be executed but the second will not
    // another important thing to add is that if there is any @(event); statement ,wait() will not be executed tell @() sense the triggering of event
    wait(ev1.triggered);
    $display("EV1 Triggered at %0t", $time);
    wait(ev2.triggered);
    $display("EV2 Triggered at %0t", $time);
    
  end
endmodule

/*=============================================================================*/
// just for the understanding perpose will will just use the a tb top
// bare in miind that when ever we use multiple initial blocks, we can't predicte which one of them  will have the higher priority
module tb;
  
  int data1, data2;
  
  event done;
  // Generator
  initial begin
    for(int i = 0; i < 10; i++) begin
      data1 = $urandom(); // this will generate an unsigned 32 bit and store it into data1
      $display("Data send to the driver at %0t: data1 = %0d",$time,data1); 
      #10
      $display("");
    end
    -> done;
  end
  
  // Driver 
  // because both the generator class and driver class need to operating in parallel that's why we used two blocks of initial begin
  // so that both of them will start exectuting from 0ns
  initial begin 
    // we use forever because the driver needs to be continouselly executed
    forever begin
      
      #10
      data2 = data1; // store the data comes from the generator into data2 of the driver
      $display("Data recieved from the Generator at %0t: data2 = %0d", $time, data2);
    end
    
  end
  
  // because the Generator and the driver can't control the simulation we need to use an other initial block to control it
  initial begin
    wait(done.triggered);
    $finish();
  end
endmodule 

// by running this code you will get some unexpected result, means some data sent by generator and not recieved by the driver, also you might observe that driver recieves data that generator didn't send
// to get rid of this problem, we will use fork join, this is something that we use frequently whenever we have multiple processes, and we want to execute them in parallel


/*===================================================================================*/

// why we need to use fork join instead of multiple initial blocks

module tb;
  int i =0;
  bit [7:0] data1,data2;
  event done;// for the end of our simulation
  event next;// this event is for synchronisation porpuses between the driver and generator so the generator will not send the next data tell it gets a notification from the driver
  
  task generator();// this will be the main task for our generator class 
   for(i = 0; i<10; i++) begin  
      data1 = $urandom();
      $display("Data Sent : %0d", data1);
     #10;
    
     wait(next.triggered);// this means that the generator will not send the next data tell the driver notified it, this will help us to get rid of extras samples at the beggining and the end of our simulation
     
    end
    
   -> done; 
  endtask
  
  
  
  task receiver();// this will be the main task for our driver class
     forever begin
       #10;
      data2 = data1;
      $display("Data RCVD : %0d",data2);
      ->next;// this is used to notify the generator
    end
   
  endtask
  
  
  
  
  task wait_event();// this task is for holding the simulation
     wait(done.triggered);
    $display("Completed Sending all Stimulus");
     $finish();
  endtask
  
  
  
 initial begin
   //for join Not allow us to execute the code that we have after the join until and unless all the processes that we specified incited execute or complete its operation.
    fork
      generator();
      receiver();
      wait_event();
    join 
   
   
   ///////
     
  end
  
  
endmodule


//*========================================================*/
// here we will be understanding the difference between fork join/join_any/none

module tb;
  task one();
    $display("Task one started! at %0t", $time);
    #5
    $display("Task one finished! at %0t", $time);
  endtask
  
  task two();
    $display("Task two started! at %0t", $time);
    #10
    $display("Task two finished! at %0t", $time);
  endtask
  
  task three();
    $display("Task three which is after join started! at %0t", $time);
    #15
    $display("Task three finished! at %0t", $time);
  endtask
  
  initial begin
 /*   fork
      one();
      two();
    join */

    //three();// this task will not start till the longest task inside fork join ends which is in this case task two() -> task three will start at 10ns
    /*
    fork
      one();
      two();
    join_any 
*/
    //three();// this task will start as soon as the shortest task inside fork join ends which is in this case task one() -> task three will start at 5ns
    
    fork
      one();
      two();
    join_none

    three();// this task will start at the beggining of the simulation 0ns -> task three will start at 0ns
  end
  
endmodule
  


/*===============================================================*/

//to Communicate the data between a Generator Class and a Driver class we need to use a mailbox
// 
class generator;
  
  int data = 7;// this is the data member that we want to send to a driver class
  // to do so we have to use a mailbox
  mailbox mbx_gen2driv;// the mailbox of the generator class
  
  task run();
    // this is used to put data in the IPC
    mbx_gen2driv.put(data);// the put methode allows us to send data to driver
    $display("[GEN]: sent data -> %0d", data);
  endtask
  
  // here is the custom constructor of this class
  function new(mailbox mbx);
   this.mbx_gen2driv = mbx;
  endfunction
  
  
endclass

// now lets create the drv class

class driver;
  
  // here we have to declare a data container to hold the data recieved from a generator
  int datac;

  // to get the data from generator the driver class must also have its own mailbox
  
  mailbox mbx_drv_from_gen;
  
  task run();
    // to get the data from the generator we use the get() methode 
    mbx_drv_from_gen.get(datac);// this will get the data from generator and hold it inside datac
    $display("[DRV]: RCVD data -> %0d", datac);
  endtask
  
    // here is the custom constructor of this class
  function new(mailbox mbx);
   this.mbx_drv_from_gen = mbx;
  endfunction
  
endclass



module tb();
  //lets create an object for each class
  generator gen;
  driver drv;
  
  // to connect both the generator and the driver mailboxes we have to use an other mailbox inside the tb() top
  
  mailbox mbx_connect;
  initial begin
    // here we have to allocate a memory for our object including mailbox obj
    //gen = new();
    //drv = new();
    mbx_connect = new();
    
    // to connect gen mailbox to drv mailbox we do this 
    // but instead of doing this
    //gen.mbx_gen2driv = mbx_connect;
    //drv.mbx_drv_from_gen = mbx_connect;
    
    // to simplify the task of connecting drv and gen mailboxes we create a custom constructor inside each of them
    gen = new(mbx_connect);
    drv = new(mbx_connect);
    gen.run();
    drv.run();
   
  end
  
endmodule



/*=========================================================*/
// now let us understand how we use a transation class to communicates between two classes inside a testbench

class transaction;
  
  rand bit [3:0] din1;
  rand bit [3:0] din2;
  bit [4:0] dout;
 
  
endclass
 
 
class generator;
 
  transaction t;// here we create a handler of the trunsaction class
  mailbox mbx;
  // here is our custom genertor to connect between mailboxes
  // this allow us to spicify the mailbox that is communicating between classes
  function new(mailbox mbx);
  this.mbx = mbx;  
  endfunction
  
  task main();
    // here we plan to send 10 random transaction
    
    // if we use this we will be updating the same object; cuz we creating a single obj
    // the problem with this is the transaction is generater faster, the generator may ovewrite an existed transaction
    //t = new();
    // that's why we need to create a new() object for each transaction
    for(int i = 0; i < 10; i++) begin
      t = new();// here we create a new object for each transaction
      assert(t.randomize) else $display("Randomization Failed");// here we generate random value for t inputs
      $display("[GEN] : DATA SENT : din1 : %0d and din2 : %0d", t.din1, t.din2);
      mbx.put(t);//to put the data on the mbx communicator of tb
      #10;
    end
  endtask
  
endclass
 
 
class driver;
  
  transaction dc;
  mailbox mbx;
  
  function new(mailbox mbx);
  this.mbx = mbx;  
  endfunction
  
  task main();
    
    forever begin //this basically signifies that we will be reading right from the start of a simulation; means that the driver will be ready to receive the data any time sent from the generator 
      mbx.get(dc);
      $display("[DRV] : DATA RCVD : din1 : %0d and din2 : %0d", dc.din1, dc.din2);
      #10;// this is allways required for a forever loop
    end
    endtask
  
endclass
 
module tb;
  generator g;
  driver d;
  mailbox mbx;
  
  initial begin
    mbx = new();
    g = new(mbx);
    d = new(mbx);
    
    /*we need to hold the simulation untill all the transations have been sent from the generator and received by the driver
    so, for that we use fork join
    */
    fork 
      g.main();
      d.main();
    join
      
  end
  
  
  
  
endmodule


/*=======================================================*/

//Prametrized Mailbox
//mailbox is a parametrized class, means to work with mailboxes we need to specify the type of data that we are sending trough the mailbox 
// if we didn't specify the data type of it, we will be getting a warning or maybe an error in some cases
//So if we specify the different data type whenever we actually plan to work with mailbox bugs could easily takled

class transaction;
  
  rand int data;
  
  constraint datac { data <30; data >10;}
  
endclass

class generator;
  
  transaction t;
  mailbox #(transaction) mbx_gen; // here we specify the type of data that we are sending trough the mailbox we need to do this for each mailbox declation
  task main();
    assert(t.randomize()) else $display("Randomization Failed");
    #5
    mbx_gen.put(t);
    $display("[GEN]: transaction data SENT: %0d", t.data);
  endtask
  function new(mailbox #(transaction) mbx);
    t = new();
    this.mbx_gen = mbx;
  endfunction
  
endclass
	
class driver;
  
  transaction t;
  mailbox #(transaction) mbx_drv; // here we specify the type of data that we are sending trough the mailbox we need to do this for each mailbox declation
  task main();
    assert(t.randomize()) else $display("Randomization Failed");
    mbx_drv.get(t);
    #5
    $display("[DRV]: Transaction data RCVD: %0d", t.data);
  endtask
  
  function new(mailbox #(transaction) mbx);
    t = new();
    this.mbx_drv = mbx;
  endfunction
  
endclass


module tb;
  generator gen;
  driver drv;
  
  mailbox #(transaction) mbx;
  
  initial begin
    mbx = new();
    gen = new(mbx);
    drv = new(mbx);
    
    fork
      gen.main();
      drv.main();
    join
    
  end
endmodule


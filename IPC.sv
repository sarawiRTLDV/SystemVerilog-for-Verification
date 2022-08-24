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



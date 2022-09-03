/*========================================================================*/
/*
putting it all togother
**************************
**************************
**************************/


// here is our design
module mult
(
  input clk,
  input [3:0] a,b,
  output reg [7:0] mul
);
  
  always@(posedge clk)
    begin
     mul <= a * b;
    end
  
endmodule



class transaction;
  randc bit[3:0] a, b;
  // we need to use a deep copy that's why we declared this function
  function transaction copy();
    copy = new();
    copy.a = this.a;
    copy.b = this.b;
  endfunction
  
  function void DRV_display();
    $display("[DRV]: DATA sent: a = %0d \t b = %0d", a, b);
  endfunction
  
  function void GEN_display();
    $display("[GEN]: DATA received: a = %0d \t b = %0d", a, b);
  endfunction
  
endclass

class generator;
  transaction t;
  mailbox #(transaction) mbx;
  
  event done;
  int i;
  function new(mailbox #(transaction)mbx);
    t = new();
    this.mbx = mbx;
  endfunction
  
  task run();
    for(i = 0; i < 10; i++) begin
      t.randomize();
      mbx.put(t.copy());
      #20;
      t.GEN_display();
    end
    -> done;
  endtask
endclass

interface interf;
  logic clk;
  logic [3:0] a, b;
  logic [7:0]mul;
  
  //modport DRV(output a, b, input clk, mul);
  //modport MON(input mul, output a, b, clk);
endinterface

class driver;
  virtual interf inter;
  transaction t;
  
  mailbox #(transaction) mbx;
  
  function new(mailbox #(transaction) mbx);
    t = new();
    this.mbx = mbx;
  endfunction
  
  task run();
    forever begin
      mbx.get(t);
      inter.a <= t.a;
      inter.b <= t.b;
      #20;
      t.DRV_display();
    end
  endtask
endclass

class response;
  bit [7:0] mul;
  
  function response copy();
    copy = new();
    copy.mul = this.mul;
  endfunction
  
  function void MON_display();
    $display("[MON]: DATA sent: mul = %0d", mul);
  endfunction
  function void SCRB_display();
    $display("[SCRB]: DATA received: mul = %0d", mul);
  endfunction
endclass

class monitor;
  // here we require to use the interface because we need to get responses from the dut
  virtual interf inter;
  response res;
  
  mailbox #(response)mbx;
  
  function new(mailbox #(response) mbx);
    res = new();
    this.mbx = mbx;
  endfunction
  
  task run();
    forever begin
      repeat(2)@(posedge inter.clk);
 	  res.mul = inter.mul;
      mbx.put(res.copy());
      res.MON_display();
    end
  endtask
  
endclass

class scoreboard;
  response res;
  mailbox #(response) mbx;
  
  function new(mailbox #(response) mbx);
    res = new();
    this.mbx = mbx;
  endfunction
  
  // let's create an other task to check if we are getting valid response from our dut
  
  task compare(input response res, input transaction trans);
    
    if(res.mul == (trans.a * trans.b)) 
      $display("[SCRB]: Result Mutch");
    else 
      $error("[SCRB]: Result MissMutch");//$warning, $fatal
    
  endtask
  
  
  task run(input transaction trans);
    forever begin
      #20;
      mbx.get(res);
      res.SCRB_display();
      compare(res, trans);
    end
  endtask
  
endclass

module tb; 
  generator gen;
  driver drv;
  monitor mon;
  scoreboard scor;
  
  mailbox #(transaction) mbx1;
  interf tb_interf();
  mailbox #(response) mbx2;
  
  event done;
  
  mult m(.a(tb_interf.a), .b(tb_interf.b), .clk(tb_interf.clk), .mul(interf.mul));
  initial begin
    tb_interf.clk = 0;
  end
  
  always begin
    #10;
    tb_interf.clk = ~tb_interf.clk;
  end
  
  initial begin
    
    mbx1 = new();
    mbx2 = new();
    gen = new(mbx1);
    drv = new(mbx1);
    mon = new(mbx2);
    scor = new(mbx2);
    drv.inter = tb_interf;
    mon.inter = tb_interf;
    
    done = gen.done;
  end
  
  initial begin
    fork
      gen.run();
      drv.run();
      mon.run();
      scor.run(drv.t);
    join_none
  end
  
  initial begin
  	$dumpfile("dump.vcd"); 
    $dumpvars;
  end
  initial begin
    wait(done.triggered);
    $finish();
  end
  
endmodule


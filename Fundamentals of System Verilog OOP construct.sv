
class first;
  
  reg [2:0] data; 
  reg [1:0] data2;
  
  
endclass
 
 
module tb;
  
  first f;
  
  initial begin
    f = new(); 
    #1;
    $display("Value of data : %0d and data2 : %0d",f.data, f.data2);
  end
  
  
  
endmodule

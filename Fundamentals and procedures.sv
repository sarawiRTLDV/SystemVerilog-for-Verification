`timescale 1ns/1ps
module tb();

reg clk = 0;
reg clk50 = 0;

real phase;
real Ton;
real Toff;

always #5 clk =~clk;

task ClkGen(input real phase, input real Ton, input real Toff);
   #phase;
   while(1) begin
    clk50 = 1;
    #Ton
    clk50 = 0;
    #Toff;
    end
endtask
task Calc(input real Freq_Hz, input real Duty_Cycle, input real phase, output real phout, output real Ton, output real Toff);
    
    phout = phase;
    Ton = (1.0 / Freq_Hz) * 1000_000_000 * (Duty_Cycle / 100);
    Toff = (1000_000_000 / Freq_Hz) - Ton;

endtask


initial begin

Calc(100_000_000, 20, 13, phase, Ton, Toff);
ClkGen(phase, Ton, Toff);
end

initial begin
    #200
    $finish();
end
endmodule

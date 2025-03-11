`timescale 1ns / 1ps

module seg7_tb();
    reg ck25MHz;
    reg [8:0] maxFreq;
    wire [6:0] seg;
    wire [2:0] an;
    
    seg7Ctrl seg7(
        .ck25MHz(ck25MHz),
        .maxFreq(maxFreq),
        .seg(seg),
        .an(an));
        
     always #5 ck25MHz = ~ck25MHz;
     
     initial begin
        ck25MHz = 0;
        maxFreq = 123;
     end
endmodule

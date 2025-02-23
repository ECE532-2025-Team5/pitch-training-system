`timescale 1ns / 1ps

module top(
    input CLK100MHZ,
    input PS2_CLK,
    input PS2_DATA,
    input CPU_RESETN,
    output [6:0] SEG7_SEG,
    output [7:0] SEG7_AN,
    output SEG7_DP
);
    
    reg CLK50MHZ=0;        
    always @(posedge CLK100MHZ)begin
        CLK50MHZ<=~CLK50MHZ;
    end
    
    // Keyboard
    wire new_key_pressed;
    wire [7:0] key_code;
    wire [7:0] key_ascii;
    
    keyboard_ps2 kb0(
        .clk(CLK50MHZ),
        .ps2_clk(PS2_CLK),
        .ps2_data(PS2_DATA),
        .resetn(CPU_RESETN),
        .new_key(new_key_pressed),
        .key_code(key_code),
        .key_ascii(key_ascii)
    );
    
    // debug, only display on leftmost 7seg
    seg7x8 ss0(
        .clk(CLK100MHZ),
        .resetn(CPU_RESETN),
        .en(new_key_pressed),
        .seg7id(3'h7),  // leftmost 7seg
        .ascii(key_ascii),
        .dp(SEG7_DP),
        .seg(SEG7_SEG[6:0]),
        .an(SEG7_AN[7:0])
    );
     
endmodule

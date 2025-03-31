`timescale 1ns / 1ps

module top(
    input CLK100MHZ,
    input [11:0] SW,         // 12 switches for quadrant color control
    output [3:0] VGA_R,
    output [3:0] VGA_G,
    output [3:0] VGA_B,
    output VGA_HS,
    output VGA_VS
);

    wire [11:0] colour_ctrl = SW[11:0];
    wire clk25mhz;
    clk_div_25mhz clkdiv25m(
        .clk_100MHz(CLK100MHZ),
        .reset(1'b0),
        .clk_25MHz(clk25mhz)
    );
    
    vga v0 (
        .clk_25MHz(clk25mhz),         // 25 MHz pixel clock
        .colour_ctrl(colour_ctrl),         // 12 switches for quadrant color control
        .vga_r(VGA_R),       // VGA Red signals (4 bits)
        .vga_g(VGA_G),       // VGA Green signals (4 bits)
        .vga_b(VGA_B),       // VGA Blue signals (4 bits)
        .vga_hs(VGA_HS),            // Horizontal Sync
        .vga_vs(VGA_VS)             // Vertical Sync 
    );
    
endmodule

module clk_div_25mhz(
    input wire clk_100MHz,     // 100 MHz input clock
    input wire reset,          // Active-high reset
    output reg clk_25MHz       // 25 MHz output clock
);

    reg [1:0] counter = 2'b00; // 2-bit counter

    always @(posedge clk_100MHz or posedge reset) begin
        if (reset) begin
            counter   <= 2'b00;
            clk_25MHz <= 1'b0;
        end else begin
            if (counter == 2'b01) begin
                clk_25MHz <= ~clk_25MHz; // Toggle output clock
                counter <= 2'b00;
            end else begin
                counter <= counter + 1;
            end
        end
    end

endmodule
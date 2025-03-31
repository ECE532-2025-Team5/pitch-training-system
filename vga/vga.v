`timescale 1ns / 1ps

module vga(
    input  wire clk_25MHz,         // 25 MHz pixel clock
    input  wire [11:0] colour_ctrl,         // 12 switches for quadrant color control
    output wire [3:0] vga_r,       // VGA Red signals (4 bits)
    output wire [3:0] vga_g,       // VGA Green signals (4 bits)
    output wire [3:0] vga_b,       // VGA Blue signals (4 bits)
    output wire vga_hs,            // Horizontal Sync
    output wire vga_vs             // Vertical Sync
);

    // VGA timing parameters
    localparam H_VISIBLE   = 640;
    localparam H_FRONT_PORCH = 16;
    localparam H_SYNC_PULSE = 96;
    localparam H_BACK_PORCH  = 48;
    localparam H_TOTAL = H_VISIBLE + H_FRONT_PORCH + H_SYNC_PULSE + H_BACK_PORCH;

    localparam V_VISIBLE   = 480;
    localparam V_FRONT_PORCH = 10;
    localparam V_SYNC_PULSE = 2;
    localparam V_BACK_PORCH  = 33;
    localparam V_TOTAL = V_VISIBLE + V_FRONT_PORCH + V_SYNC_PULSE + V_BACK_PORCH;

    // Counters for pixel position
    reg [9:0] h_count = 0;
    reg [9:0] v_count = 0;

    // Horizontal counter
    always @(posedge clk_25MHz) begin
        if (h_count == H_TOTAL - 1) begin
            h_count <= 0;
            if (v_count == V_TOTAL - 1)
                v_count <= 0;
            else
                v_count <= v_count + 1;
        end else begin
            h_count <= h_count + 1;
        end
    end

    // Sync pulses
    assign vga_hs = ~(h_count >= (H_VISIBLE + H_FRONT_PORCH) &&
                      h_count <  (H_VISIBLE + H_FRONT_PORCH + H_SYNC_PULSE));

    assign vga_vs = ~(v_count >= (V_VISIBLE + V_FRONT_PORCH) &&
                      v_count <  (V_VISIBLE + V_FRONT_PORCH + V_SYNC_PULSE));

    // Video on/off (inside visible area)
    wire video_on = (h_count < H_VISIBLE) && (v_count < V_VISIBLE);

    // Color selection logic
    reg [2:0] quadrant_color;

    always @(*) begin
        if (h_count < H_VISIBLE / 2) begin
            if (v_count < V_VISIBLE / 2)
                quadrant_color = colour_ctrl[2:0];   // Top-left quadrant
            else
                quadrant_color = colour_ctrl[8:6];   // Bottom-left quadrant
        end else begin
            if (v_count < V_VISIBLE / 2)
                quadrant_color = colour_ctrl[5:3];   // Top-right quadrant
            else
                quadrant_color = colour_ctrl[11:9];  // Bottom-right quadrant
        end
    end

    // Output color signals (expanded from 1 bit to 4 bits)
    assign vga_r = (video_on && quadrant_color[2]) ? 4'b1111 : 4'b0000;
    assign vga_g = (video_on && quadrant_color[1]) ? 4'b1111 : 4'b0000;
    assign vga_b = (video_on && quadrant_color[0]) ? 4'b1111 : 4'b0000;

endmodule

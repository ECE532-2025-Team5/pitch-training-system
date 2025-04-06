`timescale 1ns / 1ps

module piano_octave(
    input clk,
    input resetn,
    input [2:0] octave_num,
    input play_en,
    input [11:0] piano_keys,    // [0]C, [1]C#..., [11]B
    input vol_up,
    input vol_down,
    output aud_sd,
    output aud_pwm,
    output [3:0] volume_monitor
);
    localparam NUMNOTES = 12;
    
    parameter [32*12-1:0] BASE_CLKS_PER_PERIOD = {     
        32'd1213491,    // E
        32'd1285649,    // D#
        32'd1362097,    // D
        32'd1443092,    // C#
        32'd1528903,    // C
        32'd1619816,    // B
        32'd1716135,    // A#
        32'd1818182,    // A
        32'd1926296,    // G#
        32'd2040840,    // G
        32'd2162195,    // F#                                               
        32'd2290765 };  // F
        
    reg [3:0] volume;
    initial volume = 4'd0;
    assign volume_monitor = volume;
    
    reg vol_up_, vol_down_; // rising edge detection
    always @(negedge resetn or posedge clk) begin
        if (!resetn) begin;
            volume <= 4'd0;
        end
        else if (!vol_up_ && vol_up) begin
            volume <= (volume < 4'd15) ? (volume + 1) : volume;
        end
        else if (!vol_down_ && vol_down) begin
            volume <= (volume > 4'd0) ? (volume - 1) : volume;
        end
        
        vol_down_ <= vol_down;
        vol_up_ <= vol_up;
    end

    // Audio Jack logic
    // piano_keys[0] is C, which is the lease significant word in BASE_CLKS_PER_PERIOD
    genvar i;
    wire [NUMNOTES-1:0] out_pwm;
    generate
    for (i = 0; i < NUMNOTES; i = i+1) begin
        piano_note #(.BASE_CLK_PER_PERIOD(BASE_CLKS_PER_PERIOD[32*i +: 32])) pN (
            .clk(clk),
            .resetn(resetn),
            .volume(volume),
            .octave(octave_num),
            .key_press(piano_keys[i]),
            .output_pwm(out_pwm[i])
        );
    end
    endgenerate
                
    wire out_pwm_union;
    assign out_pwm_union = |out_pwm;    // bitwise-OR everything
    assign aud_pwm = (out_pwm_union) ? 1'b1 : 1'b0;   // that's just how it works
    assign aud_sd = play_en;
    
endmodule

`timescale 1ns / 1ps

module top(
    input CLK,
    input [15:0] SW,
    input BTNU,
    input BTND,
    input RESETN,
    output [15:0] LED,
    output AUD_SD,
    output AUD_PWM
);
    // Controls
    //   Switches: an octave on the keyboard from C:=SW[11] to B:=SW[0]
    //             octave number on SW[14:12]
    //   Volume: Up (incr), Down (decr)
    
    // Test Input Controls
    wire play_en = SW[15];
    wire [2:0] octave = SW[14:12];
    wire [11:0] piano_keys; // SW11[C], SW10[C#], ..., SW0[B]
    generate for (genvar i=0; i<12; i=i+1) assign piano_keys[i] = SW[12-i-1]; endgenerate
    
    // Debug Outputs
    wire led_sec_counter;
    wire [3:0] led_volume;
    assign LED[15] = led_sec_counter;
    assign LED[14:12] = octave;
    assign LED[3:0] = led_volume;
    
    piano_octave poct(
        .clk(CLK),
        .resetn(RESETN),
        .octave_num(octave),
        .play_en(play_en),
        .piano_keys(piano_keys),
        .vol_up(BTNU),
        .vol_down(BTND),
        .aud_sd(AUD_SD),
        .aud_pwm(AUD_PWM),
        .volume_monitor(led_volume)
    );

    // Show 100 MHz clock is working on led[15]
    reg [32:0] second_counter;
    reg sec_blink;
    assign led_sec_counter = sec_blink;
    initial sec_blink = 1'b0;
    always @(posedge CLK) begin
        if (second_counter == 0) begin
            second_counter <= 32'd50000000;
            sec_blink = ~sec_blink;
        end
        else begin
            second_counter <= second_counter - 1'b1;
        end
    end

endmodule
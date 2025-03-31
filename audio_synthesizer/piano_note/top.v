`timescale 1ns / 1ps

module top(
    input CLK100MHZ,
    input [15:0] SW,
    input BTNU,
    input BTND,
    input CPU_RESETN,
    output [15:0] LED,
    output AUD_SD,
    output AUD_PWM
);

//    assign cur_note = NUMNOTES - 1 - lowest_note;
//    reg [31:0] c1scale [NUMNOTES-1:0];
//    always @* begin
//        case (cur_note)
//            0:  c1scale[0]  = 32'd3057805;   // C1
//            1:  c1scale[1]  = 32'd2886184;   // C#1
//            2:  c1scale[2]  = 32'd2724194;   // D1
//            3:  c1scale[3]  = 32'd2571298;   // D#1
//            4:  c1scale[4]  = 32'd2426982;   // E1
//            5:  c1scale[5]  = 32'd2290765;   // F1
//            6:  c1scale[6]  = 32'd2162195;   // F#1
//            7:  c1scale[7]  = 32'd2040840;   // G1
//            8:  c1scale[8]  = 32'd1926296;   // G#1
//            9:  c1scale[9]  = 32'd1818182;   // A1
//            10: c1scale[10] = 32'd1716135;   // A#1
//            11: c1scale[11] = 32'd1619816;   // B1
//         endcase
//    end

    // Controls
    wire audio_en = SW[15];
    wire [2:0] set_octave = SW[14:12];
    wire key_press = SW[0];
    
    wire [3:0] volume_leds;
    wire sec_counter;
    assign LED[15] = sec_counter;
    assign LED[14:12] = set_octave;
    assign LED[4:1] = volume_leds;
    
    wire [2:0] octave_num = set_octave;    
    reg [3:0] volume;
    assign volume_leds = volume;
    initial volume = 4'd0;
    reg btnu_, btnd_; // rising edge detection
    always @(negedge CPU_RESETN or posedge CLK100MHZ) begin
        
        if (!CPU_RESETN) begin
            volume <= 4'd0;
        end
        // vol up
        else if (!btnu_ && BTNU) begin
            volume <= (volume < 4'd15) ? (volume + 1) : volume;
        end
        // vol down
        else if (!btnd_ && BTND) begin
            volume <= (volume > 4'd0) ? (volume - 1) : volume;
        end
        btnu_ <= BTNU;
        btnd_ <= BTND;
    end
        
    wire out_pwm;
    piano_note #(.BASE_CLK_PER_PERIOD(3057805) ) p0 (  // C1
        .clk(CLK100MHZ),
        .resetn(CPU_RESETN),
        .volume(volume),
        .octave(octave_num),
        .key_press(key_press),
        .output_pwm(out_pwm)
    );

    // Audio Jack logic
    assign AUD_PWM = (out_pwm) ? 1'bz : 1'b0;   // that's just how it works
    assign AUD_SD = audio_en;                    // enable
    
    // Show 100 MHz clock is working on led[15]
    reg [32:0] second_counter;
    reg sec_blink;
    assign sec_counter = sec_blink;
    initial sec_blink = 1'b0;
    always @(posedge CLK100MHZ) begin
        if (second_counter == 0) begin
            second_counter <= 32'd50000000;
            sec_blink = ~sec_blink;
        end
        else begin
            second_counter <= second_counter - 1'b1;
        end
    end
    
endmodule



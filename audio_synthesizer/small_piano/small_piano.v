`timescale 1ns / 1ps

module small_piano(
    input clk,
    input [15:0] swt,
    input btnl,
    input btnc,
    input btnr,
    input btnu,
    input btnd,
    input resetn,
    output [15:0] led,
    output AUD_SD,
    output AUD_PWM
);
    localparam NUMNOTES = 12;
    localparam NUMCONCURRENT = 12;
    
    // Controls
    //   Switches: an octave on the keyboard from C:swt[11] to B:swt[0]
    //             octave number on swt[14:12]
    //   Volume: Up (incr), Down (decr)
    //   Pitch: stored on BTNL
    
    wire sw_play_en = swt[15];
    wire [2:0] sw_set_octave = swt[14:12];
    wire [11:0] sw_play_keys = swt[11:0];
    
    wire [2:0] led_volume;
    assign led[15] = led_sec_counter;
    assign led[3:0] = led_volume;
    
//    wire [$clog2(NUMNOTES)-1:0] lowest_note;
//    wire note_off;
//    msb_index_finder #(.WIDTH(NUMNOTES)) m0 (.in(swt[(NUMNOTES-1):0]),
//                                             .msb_index(lowest_note),
//                                             .off(note_off));
//    reg [31:0] stored_notes [NUMCONCURRENT-1:0];
//    reg new_period [NUMCONCURRENT-1:0];
    
//    wire [$clog2(NUMNOTES)-1:0] cur_note;
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
    
    parameter [32*12-1:0] BASE_CLKS_PER_PERIOD = {32'd3057805,  // C
                                               32'd2886184,     // C#
                                               32'd2724194,     // D
                                               32'd2571298,     // D#
                                               32'd2426982,     // E
                                               32'd2290765,     // F
                                               32'd2162195,     // F#
                                               32'd2040840,     // G
                                               32'd1926296,     // G#
                                               32'd1818182,     // A
                                               32'd1716135,     // A#
                                               32'd1619816 };   // B
    
    wire [2:0] octave_num = sw_set_octave;
    
    reg [3:0] volume;
    initial volume = 4'd0;
    assign led_volume = volume;
    reg btnr_, btnc_, btnl_, btnu_, btnd_; // rising edge detection
    always @(negedge resetn or posedge clk) begin
        
        if (!resetn) begin;
            volume <= 4'd0;
        end
//        // 1st note
//        else if (!btnl_ && btnl) begin
//            stored_notes[0] <= (note_off) ? 0 : c1scale[cur_note];
//            new_period[0] <= 1'b1;
//        end
//        // 2nd note
//        else if (!btnc_ && btnc) begin
//            stored_notes[1] <= (note_off) ? 0 : c1scale[cur_note];
//            new_period[1] <= 1'b1;
//        end
//        // 3rd note
//        else if (!btnr_ && btnr) begin
//            stored_notes[2] <= (note_off) ? 0 : c1scale[cur_note];
//            new_period[2] <= 1'b1;
//        end
        // vol up
        else if (!btnu_ && btnu) begin
            volume <= (volume < 4'd15) ? (volume + 1) : volume;
        end
        // vol down
        else if (!btnd_ && btnd) begin
            volume <= (volume > 4'd0) ? (volume - 1) : volume;
        end
        btnr_ <= btnr;
        btnc_ <= btnc;
        btnl_ <= btnl;
        btnu_ <= btnu;
        btnd_ <= btnd;
        
    end

    // Audio Jack logic
    genvar i;
    wire [NUMCONCURRENT-1:0] out_pwm;
    generate
    for (i = 0; i < NUMCONCURRENT; i = i+1) begin
        piano_note #(.BASE_CLK_PER_PERIOD(BASE_CLKS_PER_PERIOD[32*(12-i-1) +: 32])) pN (
            .clk(clk),
            .resetn(resetn),
            .volume(volume),
            .octave(octave_num),
            .key_press(sw_play_keys[NUMCONCURRENT-i-1]),
            .output_pwm(out_pwm[i])
        );
    end
    endgenerate
                
    wire out_pwm_union;
    assign out_pwm_union = |out_pwm;    // bitwise-OR everything

    assign AUD_PWM = (out_pwm_union) ? 1'bz : 1'b0;   // that's just how it works
    assign AUD_SD = sw_play_en;                    // enable
    
    // Show 100 MHz clock is working on led[15]
    reg [32:0] second_counter;
    reg sec_blink;
    assign led_sec_counter = sec_blink;
    initial sec_blink = 1'b0;
    always @(posedge clk) begin
        if (second_counter == 0) begin
            second_counter <= 32'd50000000;
            sec_blink = ~sec_blink;
        end
        else begin
            second_counter <= second_counter - 1'b1;
        end
    end
    
endmodule


module msb_index_finder #(parameter WIDTH = 3) (
    input wire [WIDTH-1:0] in,
    output reg [$clog2(WIDTH)-1:0] msb_index,
    output reg off
);
    reg [$clog2(WIDTH)-1:0] msb_index;
    integer i;
    always @(*) begin
        msb_index = 0; 
        off = 1;
        for (i = WIDTH-1; i >= 0; i = i - 1) begin
            if (in[i]) begin
                msb_index = i;
                off = 0;
            end
        end
    end
endmodule
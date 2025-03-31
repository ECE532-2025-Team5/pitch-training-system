`timescale 1ns / 1ps

module top(
    input CLK100MHZ,
    input CPU_RESETN,
    input PS2_CLK,
    input PS2_DATA,
    input [15:0] SW,
    input BTNU,
    input BTND,
    output AUD_SD,
    output AUD_PWM,
    output [15:0] LED,
    output UART_TXD,
    output [6:0] SEG7_SEG,
    output [7:0] SEG7_AN,
    output SEG7_DP
);
    // Input
    wire play_en = SW[15];
    wire [2:0] octave = SW[14:12];
    
    // Debug Output
    wire led_sec_counter;
    wire [3:0] led_volume;
    wire [11:0] led_key_status;
    assign LED[15] = led_sec_counter;
    assign LED[14:12] = led_volume[3:1];
    assign LED[11:0] = led_key_status;
    
    reg CLK50MHZ=0;        
    always @(posedge CLK100MHZ)begin
        CLK50MHZ<=~CLK50MHZ;
    end

    wire [7:0] keycode;
    wire [7:0] asciicode;
    wire new_key_pressed;
    wire key_released;
    keyboard_ps2 kb0(
        .clk(CLK50MHZ),
        .ps2_clk(PS2_CLK),
        .ps2_data(PS2_DATA),
        .resetn(CPU_RESETN),
        .new_key(new_key_pressed),
        .key_code(keycode),
        .key_ascii(asciicode),
        .key_released(key_released)
    );
    
    // piano keys
    wire [3:0] note_id_temp;
    reg [3:0] note_id;
    kb2piano_octave #(
        .C       (`kb_Z),
        .C_sharp (`kb_S),
        .D       (`kb_X),
        .D_sharp (`kb_D),
        .E       (`kb_C),
        .F       (`kb_V),
        .F_sharp (`kb_G),
        .G       (`kb_B),
        .G_sharp (`kb_H),
        .A       (`kb_N),
        .A_sharp (`kb_J),
        .B       (`kb_M)
    ) kb2poct (
        .keycode(keycode),
        .piano_note(note_id_temp)
    );
                  
    reg prev_key_released;
    always @(posedge CLK100MHZ) begin
        prev_key_released <= 1'b0;
        if (key_released) begin
            prev_key_released <= 1'b1;
        end
    end
    
    always @ (*) begin
        if (!key_released) begin
            note_id <= note_id_temp;
        end
        else if (prev_key_released) begin
            note_id <= 4'h0;
        end
    end

    reg [3:0] piano_pressed;
    reg [7:0] piano_played_note;
    reg [7:0] piano_played_accidental;
    always @ (*) begin
        case(note_id)
            'd1: begin // C
                piano_played_note <= `ascii_C;
                piano_played_accidental <= `ascii_SPACE;
                end
            'd2: begin // C#
                piano_played_note <= `ascii_C;
                piano_played_accidental <= `ascii_SQT;
                end
            'd3: begin // D
                piano_played_note <= `ascii_D;
                piano_played_accidental <= `ascii_SPACE;
                end
            'd4: begin // D#
                piano_played_note <= `ascii_D;
                piano_played_accidental <= `ascii_SQT;
                end
            'd5: begin // E
                piano_played_note <= `ascii_E;
                piano_played_accidental <= `ascii_SPACE;
                end
            'd6: begin // F
                piano_played_note <= `ascii_F;
                piano_played_accidental <= `ascii_SPACE;
                end
            'd7: begin // F#
                piano_played_note <= `ascii_F;
                piano_played_accidental <= `ascii_SQT;
                end
            'd8: begin // G
                piano_played_note <= `ascii_G;
                piano_played_accidental <= `ascii_SPACE;
                end
            'd9: begin // G#
                piano_played_note <= `ascii_G;
                piano_played_accidental <= `ascii_SQT;
                end
            'd10: begin // A
                piano_played_note <= `ascii_A;
                piano_played_accidental <= `ascii_SPACE;
                end
            'd11: begin // A#
                piano_played_note <= `ascii_A;
                piano_played_accidental <= `ascii_SQT;
                end
            'd12: begin // B
                piano_played_note <= `ascii_B;
                piano_played_accidental <= `ascii_SPACE;
                end
            
            default: begin
                piano_played_note <= `ascii_SPACE;
                piano_played_accidental <= `ascii_SPACE;
            end
        endcase
    end
    
    // store key statuses
    reg [12:0] key_status; // index 0 is unused
    assign led_key_status = key_status[12:1];
    initial key_status = 13'h0;
    always @ (posedge CLK100MHZ) begin
        if (note_id == 4'b0) begin
            key_status <= 13'b0;
        end
        else if (new_key_pressed) begin
            key_status[note_id] <= 1'b1;
        end
        else if (key_released) begin
            key_status[note_id] <= 1'b0;
        end
    end

    // store and update 7seg display
    wire seg7en = new_key_pressed | key_released;
    reg [63:0] seg7_reg;
    
    always @ (posedge CLK100MHZ) begin
        if (!CPU_RESETN) begin
            seg7_reg <= 64'h0;
        end
        else if (seg7en) begin
            seg7_reg[8*5 +: 8] <= piano_played_note;
            seg7_reg[8*4 +: 8] <= piano_played_accidental;
        end
    end
    
    seg7x8 sevenSegDisp(
        .clk(CLK100MHZ),
        .resetn(CPU_RESETN),
        .asciix8(seg7_reg),
        .dp(SEG7_DP),
        .seg(SEG7_SEG[6:0]),
        .an(SEG7_AN[7:0])
    );
    
    piano_octave poct(
        .clk(CLK100MHZ),
        .resetn(CPU_RESETN),
        .octave_num(octave),
        .play_en(play_en),
        .piano_keys(key_status[12:1]),
        .vol_up(BTNU),
        .vol_down(BTND),
        .aud_sd(AUD_SD),
        .aud_pwm(AUD_PWM),
        .volume_monitor(led_volume)
    );
    
    // debug blink
    // Show 100 MHz clock is working on led[15]
    reg [32:0] second_counter;
    reg sec_blink;
    assign led_sec_counter = sec_blink;
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
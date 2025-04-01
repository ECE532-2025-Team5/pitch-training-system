`timescale 1ns / 1ps

module piano(
    input CLK100MHZ,
    input CPU_RESETN,
    input PS2_CLK,
    input PS2_DATA,

    input play_en,
    input [2:0] octave,

    input vol_up,
    input vol_down,

    output AUD_SD,
    output AUD_PWM,
    output [15:0] LED,
    output [7:0] kb_ascii,
    output reg [3:0] piano_played_octid
);
    
    // Debug Output
    wire led_sec_counter;
    wire [3:0] led_volume;
    wire [11:0] led_key_status;
    assign LED[15] = led_sec_counter;
    assign LED[14:12] = led_volume[3:1];
//    assign LED[11:0] = led_key_status;
//    assign LED[7:0] = kb_ascii[7:0];
    
    reg CLK50MHZ=0;        
    always @(posedge CLK100MHZ)begin
        CLK50MHZ<=~CLK50MHZ;
    end

    wire [7:0] keycode;
    wire new_key_pressed;
    wire key_released;
    keyboard_ps2 kb0(
        .clk(CLK50MHZ),
        .ps2_clk(PS2_CLK),
        .ps2_data(PS2_DATA),
        .resetn(CPU_RESETN),
        .new_key(new_key_pressed),
        .key_code(keycode),
        .key_ascii(kb_ascii),
        .key_released(key_released)
    );
    
    // piano keys
    wire [3:0] note_id_temp;
    kb2piano_octave #(
        .F       (`kb_Z),
        .F_sharp (`kb_S),
        .G       (`kb_X),
        .G_sharp (`kb_D),
        .A       (`kb_C),
        .A_sharp (`kb_F),
        .B       (`kb_V),
        .C       (`kb_B),
        .C_sharp (`kb_H),
        .D       (`kb_N),
        .D_sharp (`kb_J),
        .E       (`kb_M)
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
            piano_played_octid <= note_id_temp;
        end
        else if (prev_key_released) begin
            piano_played_octid <= 4'h0;
        end
    end
    
    // store key statuses
    reg [12:0] key_status; // index 0 is unused
    assign led_key_status = key_status[12:1];
    initial key_status = 13'h0;
    always @ (posedge CLK100MHZ) begin
        if (piano_played_octid == 4'b0) begin
            key_status <= 13'b0;
        end
        else if (new_key_pressed) begin
            key_status[piano_played_octid] <= 1'b1;
        end
        else if (key_released) begin
            key_status[piano_played_octid] <= 1'b0;
        end
    end
    
    piano_octave poct(
        .clk(CLK100MHZ),
        .resetn(CPU_RESETN),
        .octave_num(octave),
        .play_en(play_en),
        .piano_keys(key_status[12:1]),
        .vol_up(vol_up),
        .vol_down(vol_down),
        .aud_sd(AUD_SD),
        .aud_pwm(AUD_PWM),
        .volume_monitor(led_volume)
    );

    // // debug blink
    // // Show 100 MHz clock is working on led[15]
    // reg [32:0] second_counter;
    // reg sec_blink;
    // assign led_sec_counter = sec_blink;
    // initial sec_blink = 1'b0;
    // always @(posedge CLK100MHZ) begin
    //     if (second_counter == 0) begin
    //         second_counter <= 32'd50000000;
    //         sec_blink = ~sec_blink;
    //     end
    //     else begin
    //         second_counter <= second_counter - 1'b1;
    //     end
    // end

endmodule
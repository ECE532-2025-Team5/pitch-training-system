`timescale 1ns / 1ps

module swctrl_piano (
    // peripherals
    input CLK100MHZ,
    input CPU_RESETN,
    input PS2_CLK,
    input PS2_DATA,
    input [3:0] playen_oct,
    input BTNU,
    input BTND,
    output AUD_SD,
    output AUD_PWM,
    output [15:0] LED,
    output UART_TXD,
    output [6:0] SEG7_SEG,
    output [7:0] SEG7_AN,
    output SEG7_DP,
    
    // interface with AXI_GPIO
    input [31:0] axi_swctrl_piano_i,
    output [10:0] axi_swctrl_piano_o
);

    // Modes
    // # Ear Training [ET]
    //   Functions:
    //   - Play notes
    //      Given N notes indices (microblaze -> module)
    //      Play en (module <- peripheral) (control using rtl logic with kb
    //   - Keyboard user input
    //      user keyboard note index (microblaze <- module)
    //   - Display user's sung note
    //      user sung note index (1) (microblaze -> module)
    //      7seg [override] (module -> peripheral)
    //
    // # Free Play [FP]
    //   Functions:
    //   - User input part of note cmp
    //      Provide played note index (1) (microblaze <- module)
    //   - Display comparison
    //      user sung note index (1) (microblaze -> module)
    //      7seg [override] (module -> peripheral)
    
    // 7 Seg usage
    // [leftmost]
    // 7: user sung note
    // 6: user sung accidental

    // AXI_GPIO inputs [microblaze -> module]
    // bit 0
    wire [1:0] mode_sel;        // 0 Home, 1 Ear Training, 2 Free Play
    wire [1:0] play_note_num;   // microblaze generates chord, max 3 notes
    wire [6:0] play_note_id_0;  // microblaze chord note 0
    wire [6:0] play_note_id_1;  // microblaze chord note 1
    wire [6:0] play_note_id_2;  // microblaze chord note 2
    wire [5:0] sung_note_id;    // user sung note
    wire compare_correct;
    // bit 32
    
    // AXI_GPIO outputs [microblaze <- module]
    // bit 0
    reg [3:0] user_controls;   // 16 controls bits available for keyboard software controls
    wire [6:0] piano_note_id;   // piano note most recently played
    // bit 11

    // encode/decode
    assign {compare_correct, sung_note_id, play_note_id_2, play_note_id_1, play_note_id_0, play_note_num, mode_sel} = axi_swctrl_piano_i;
    assign axi_swctrl_piano_o = {piano_note_id, user_controls};
    
    // Extra peripheral controls
    wire play_en = playen_oct[3];
    wire [2:0] octave = playen_oct[2:0];

    // translation wires
    wire [3:0] piano_note_octid;

/* Mode Select */
  // Le Main Machine De State De Hardware
    reg modesel_freeplay, modesel_eartraining;
    reg [7:0] mode_char1, mode_char0;

    reg [7:0] cmp_char;
    wire [7:0] compare_symbol;

    reg [7:0] microblaze_char1, microblaze_char0;
    reg [7:0] sung_note_note, sung_note_accidental;

    reg [7:0] module_char1, module_char0;
    reg [7:0] piano_played_note, piano_played_accidental;

    always @ (posedge CLK100MHZ) begin
        {mode_char1, mode_char0} <= {`ascii_SPACE, `ascii_SPACE};
        modesel_freeplay <= 1'b0;
        modesel_eartraining <= 1'b0;

        case(mode_sel)
            2'd0: begin // Home Screen
                {mode_char1, mode_char0} <= {`ascii_H, `ascii_S};
                cmp_char <= `ascii_SPACE;
                {microblaze_char1, microblaze_char0} <= {`ascii_SPACE, `ascii_SPACE};
                {module_char1, module_char0} <= {`ascii_SPACE, `ascii_SPACE};
                end

            2'd1: begin // Ear Training
                {mode_char1, mode_char0} <= {`ascii_E, `ascii_T};
                cmp_char <= compare_symbol;
                {microblaze_char1, microblaze_char0} <= {`ascii_QMARK, `ascii_QMARK};
                {module_char1, module_char0} <= {piano_played_note, piano_played_accidental};
                modesel_eartraining <= 1'b1;
                end

            2'd2: begin // Free Play
                {mode_char1, mode_char0} <= {`ascii_F, `ascii_P};
                cmp_char <= compare_symbol;
                {microblaze_char1, microblaze_char0} <= {sung_note_note, sung_note_accidental};
                {module_char1, module_char0} <= {piano_played_note, piano_played_accidental};
                modesel_freeplay <= 1'b1;
                end

            default: begin
                {mode_char1, mode_char0} <= {`ascii_SPACE, `ascii_SPACE};
                cmp_char <= `ascii_SPACE;
                {microblaze_char1, microblaze_char0} <= {`ascii_SPACE, `ascii_SPACE};
                {module_char1, module_char0} <= {`ascii_SPACE, `ascii_SPACE};
                end
        endcase
    end

  // Detect new mode
    reg new_mode;
    reg [1:0] prev_mode;
    always @(posedge CLK100MHZ) begin
        if (mode_sel != prev_mode) begin
            new_mode <= 1'b1;   // Assert change flag
        end else begin
            new_mode <= 1'b0;   // Clear flag next cycle
        end

        prev_mode <= mode_sel; // Update previous data every cycle
    end
    
/* Keyboard User Controls */
  // keyboard to user controls conversion logic
    reg [3:0] prev_ctrl;
    wire [7:0] kbctrl_ascii;
    assign LED[9:2] = kbctrl_ascii; // debug

    localparam  CTRL_NOP = 4'd0,
                CTRL_GOHOME = 4'd1, 
                CTRL_GOEARTRAIN = 4'd2,
                CTRL_GOFREEPLAY = 4'd3,
                CTRL_PLAYCHORD = 4'd4,
                CTRL_PIANOINPUT = 4'd5,
                CTRL_ETENTER = 4'd6;

    always @(posedge CLK100MHZ) begin
        user_controls <= CTRL_NOP;

        if (prev_ctrl == CTRL_NOP) begin    // user controls only changes for 1 cycle
            case(mode_sel)
                2'd0: begin // Home Screen
                    if (kbctrl_ascii == `ascii_1) begin
                        user_controls <= CTRL_GOEARTRAIN;
                    end
                    else if (kbctrl_ascii == `ascii_2) begin
                        user_controls <= CTRL_GOFREEPLAY;
                    end
                    end // case home screen
                    
                2'd1: begin // Ear Training
                    if (kbctrl_ascii == `ascii_Q) begin
                        user_controls <= CTRL_GOHOME;
                    end
                    else if (kbctrl_ascii == `ascii_SPACE) begin
                        user_controls <= CTRL_PLAYCHORD;
                    end
                    else if ((piano_note_octid >= 4'd1) && (piano_note_octid <= 4'd12)) begin
                        user_controls <= CTRL_PIANOINPUT;
                    end
                    else if (kbctrl_ascii == `ascii_ENTER) begin
                        user_controls <= CTRL_ETENTER;
                    end
                    end // case ear training
    
                2'd2: begin // Free Play
                    if (kbctrl_ascii == `ascii_Q) begin
                        user_controls <= CTRL_GOHOME;
                    end
                    else if ((piano_note_octid >= 4'd1) && (piano_note_octid <= 4'd12)) begin
                        user_controls <= CTRL_PIANOINPUT;
                    end
                    else if (kbctrl_ascii == `ascii_ENTER) begin
                        user_controls <= CTRL_ETENTER;
                    end
                    end // case free play
    
                default: begin
                    user_controls <= CTRL_NOP;
                    end
            endcase
        end // prev_ctrl == CTRL_NOP
        
        prev_ctrl <= user_controls;
    end

/* Compare */
//    wire [7:0] compare_symbol = (compare_correct) ? `ascii_O : `ascii_MINUS;
    assign compare_symbol = (compare_correct) ? `ascii_6 : `ascii_MINUS;

/* User Sung Note */
    // convert sung_note spreadsheet_id to octave_id (C, C#, ... B)
    localparam sung_range_offset = 5'd32;   // User singing range is F3 to E4
    wire [3:0] sung_note_octid = sung_note_id - sung_range_offset;

    // detect new sung note
    reg new_sung_note;
    reg [3:0] prev_sung_note;
    always @(posedge CLK100MHZ) begin
        if (sung_note_id != prev_sung_note) begin
            new_sung_note <= 1'b1;   // Assert change flag
        end else begin
            new_sung_note <= 1'b0;   // Clear flag next cycle
        end

        prev_sung_note <= sung_note_id; // Update previous data every cycle
    end

/* Generated Chord Notes */
    // detect new sung note
    reg new_sung_note;
    reg [3:0] prev_sung_note;
    always @(posedge CLK100MHZ) begin
        if (sung_note_id != prev_sung_note) begin
            new_sung_note <= 1'b1;   // Assert change flag
        end else begin
            new_sung_note <= 1'b0;   // Clear flag next cycle
        end

        prev_sung_note <= sung_note_id; // Update previous data every cycle
    end

/* Audio Jack */
    // merge Ear Taining and Free Play audio jack
    wire freeplay_pwm, freeplay_sd;
    wire eartraining_pwm, eartraining_sd;

    wire gated_freeplay_pwm = freeplay_pwm & modesel_freeplay;
    wire gated_eartraining_pwm = eartraining_pwm & modesel_eartraining;

    assign AUD_PWM = (gated_freeplay_pwm | gated_eartraining_pwm) ? 1'b1 : 1'b0;

    assign AUD_SD = freeplay_sd | eartraining_sd;
    assign LED[15] = AUD_SD;
    assign LED[0] = AUD_PWM;    // if no audio out, it should be dark, otherwise faint light

/* Piano */
    // piano_note_id
    localparam first_octave_offset = 4'd8;
    localparam octave_num_keys = 4'd12;
    wire [6:0] note_id;
    assign note_id = (octave-1) * octave_num_keys + piano_note_octid + first_octave_offset;
    assign piano_note_id = (piano_note_octid == 0) ? 7'b0 : note_id;

    // detech new piano played note
    reg new_played_note;
    reg [3:0] prev_played_note;
    always @(posedge CLK100MHZ) begin
        if (piano_note_id != prev_played_note) begin
            new_played_note <= 1'b1;   // Assert change flag
        end else begin
            new_played_note <= 1'b0;   // Clear flag next cycle
        end

        prev_played_note <= piano_note_id; // Update previous data every cycle
    end

    piano piano_inst (
        .CLK100MHZ(CLK100MHZ),
        .CPU_RESETN(CPU_RESETN),
        .PS2_CLK(PS2_CLK),
        .PS2_DATA(PS2_DATA),
        .play_en(play_en),
        .octave(octave),
        .vol_up(BTNU),
        .vol_down(BTND),
        .AUD_SD(freeplay_sd),
        .AUD_PWM(freeplay_pwm),
        .LED({1'b0, LED[14:12], 12'b0}),    // debug
        .kb_ascii(kbctrl_ascii),
        .piano_played_octid(piano_note_octid)
    );

/* Play Generated Chord (Ear Training) */
  // convert play_note spreadsheet_id to octave_id (C, C#, ... B)
    localparam play_range_octave = 2'd3;
    localparam play_range_offset = 6'd32;   // User singing range is F3(33) to E4(44)
    wire [3:0] play_note_octid0 = play_note_id_0 - play_range_offset;
    // wire [3:0] play_note_octid1 = play_note_id_1 - play_range_offset;
    // wire [3:0] play_note_octid2 = play_note_id_2 - play_range_offset;

    wire eartraining_play_chord = play_en;  // debug
        
    reg [31:0] c1scale [12:0];
    always @* begin
        case (play_note_octid0)
            1:  c1scale[1]  = 32'd2290765;   // F1
            2:  c1scale[2]  = 32'd2162195;   // F#1
            3:  c1scale[3]  = 32'd2040840;   // G1
            4:  c1scale[4]  = 32'd1926296;   // G#1
            5:  c1scale[5]  = 32'd1818182;   // A1
            6:  c1scale[6]  = 32'd1716135;   // A#1
            7:  c1scale[7]  = 32'd1619816;   // B1
            8:  c1scale[8]  = 32'd1528903;   // C2
            9:  c1scale[9]  = 32'd1443092;   // C#2
            10: c1scale[10] = 32'd1362097;   // D2
            11: c1scale[11] = 32'd1285649;   // D#2
            12: c1scale[12] = 32'd1213491;   // E2
            default: c1scale[0] = 32'd0;
         endcase
    end
    
    wire [31:0] play_note_base_clks_per_period0 = c1scale[play_note_octid0];

  // Ear Training Volume
    reg [3:0] et_volume;
    initial et_volume = 4'd0;
    
    wire vol_up = BTNU;
    wire vol_down = BTND;
    reg vol_up_, vol_down_; // rising edge detection
    always @(negedge CPU_RESETN or posedge CLK100MHZ) begin
        if (!CPU_RESETN) begin;
            et_volume <= 4'd0;
        end
        else if (!vol_up_ && vol_up) begin
            et_volume <= (et_volume < 4'd15) ? (et_volume + 1) : et_volume;
        end
        else if (!vol_down_ && vol_down) begin
            et_volume <= (et_volume > 4'd0) ? (et_volume - 1) : et_volume;
        end
        
        vol_down_ <= vol_down;
        vol_up_ <= vol_up;
    end

    reg microblaze_note_en;
    always @ (posedge CLK100MHZ) begin
        microblaze_note_en <= 1'b0;
        if (kbctrl_ascii == `ascii_SPACE) begin
            microblaze_note_en <= 1'b1;
        end
    end

  // Get Play Note clks_per_period
    // GENERATED NOTE FREQ_PWM INST BEGIN
        // Set period to 0 when key not pressed
        wire [31:0] play_note_clks_per_period0 = play_note_base_clks_per_period0 >> play_range_octave;
        wire play_note_pwm0;

        // changing period
        reg [31:0] prev_clks_per_period0;
        reg update_period;
        always @(posedge CLK100MHZ) begin
            if (!CPU_RESETN) begin
                update_period <= 1'b0;
                prev_clks_per_period0 <= 32'b0;
            end
            else begin
                update_period <= (play_note_clks_per_period0 != prev_clks_per_period0);
                prev_clks_per_period0 <= play_note_clks_per_period0;
            end
        end

        freq_pwm f0(
            .clk(CLK100MHZ),
            .resetn(CPU_RESETN),
            .new_period(update_period),
            .clks_per_period(play_note_clks_per_period0),
            .volume(et_volume),
            .out_pwm(play_note_pwm0)
        );
    // GENERATED NOTE FREQ_PWM INST END
    
  // Ear Training pwm
    // Only output when key pressed
    wire play_note_pwm_union = play_note_pwm0;
    assign eartraining_pwm = (eartraining_play_chord & microblaze_note_en) ? play_note_pwm_union : 1'b0;
    assign eartraining_sd = play_en;


/* 7 SEG */
    // store and update 7seg display
    wire seg7en = new_played_note | new_sung_note;
    reg [63:0] seg7_reg;

  // 7 seg config, display piano note
    always @ (*) begin
        case(piano_note_octid)
            'd1: begin // F
                piano_played_note <= `ascii_F;
                piano_played_accidental <= `ascii_SPACE;
                end
            'd2: begin // F#
                piano_played_note <= `ascii_F;
                piano_played_accidental <= `ascii_SQT;
                end
            'd3: begin // G
                piano_played_note <= `ascii_G;
                piano_played_accidental <= `ascii_SPACE;
                end
            'd4: begin // G#
                piano_played_note <= `ascii_G;
                piano_played_accidental <= `ascii_SQT;
                end
            'd5: begin // A
                piano_played_note <= `ascii_A;
                piano_played_accidental <= `ascii_SPACE;
                end
            'd6: begin // A#
                piano_played_note <= `ascii_A;
                piano_played_accidental <= `ascii_SQT;
                end
            'd7: begin // B
                piano_played_note <= `ascii_B;
                piano_played_accidental <= `ascii_SPACE;
                end
            'd8: begin // C
                piano_played_note <= `ascii_C;
                piano_played_accidental <= `ascii_SPACE;
                end
            'd9: begin // C#
                piano_played_note <= `ascii_C;
                piano_played_accidental <= `ascii_SQT;
                end
            'd10: begin // D
                piano_played_note <= `ascii_D;
                piano_played_accidental <= `ascii_SPACE;
                end
            'd11: begin // D#
                piano_played_note <= `ascii_D;
                piano_played_accidental <= `ascii_SQT;
                end
            'd12: begin // E
                piano_played_note <= `ascii_E;
                piano_played_accidental <= `ascii_SPACE;
                end
            
            default: begin
                piano_played_note <= `ascii_SPACE;
                piano_played_accidental <= `ascii_SPACE;
            end
        endcase
    end

    // 7 seg config, display sung note
    always @ (*) begin
        case(sung_note_octid)
            'd1: begin // F
                sung_note_note <= `ascii_F;
                sung_note_accidental <= `ascii_SPACE;
                end
            'd2: begin // F#
                sung_note_note <= `ascii_F;
                sung_note_accidental <= `ascii_SQT;
                end
            'd3: begin // G
                sung_note_note <= `ascii_G;
                sung_note_accidental <= `ascii_SPACE;
                end
            'd4: begin // G#
                sung_note_note <= `ascii_G;
                sung_note_accidental <= `ascii_SQT;
                end
            'd5: begin // A
                sung_note_note <= `ascii_A;
                sung_note_accidental <= `ascii_SPACE;
                end
            'd6: begin // A#
                sung_note_note <= `ascii_A;
                sung_note_accidental <= `ascii_SQT;
                end
            'd7: begin // B
                sung_note_note <= `ascii_B;
                sung_note_accidental <= `ascii_SPACE;
                end
            'd8: begin // C
                sung_note_note <= `ascii_C;
                sung_note_accidental <= `ascii_SPACE;
                end
            'd9: begin // C#
                sung_note_note <= `ascii_C;
                sung_note_accidental <= `ascii_SQT;
                end
            'd10: begin // D
                sung_note_note <= `ascii_D;
                sung_note_accidental <= `ascii_SPACE;
                end
            'd11: begin // D#
                sung_note_note <= `ascii_D;
                sung_note_accidental <= `ascii_SQT;
                end
            'd12: begin // E
                sung_note_note <= `ascii_E;
                sung_note_accidental <= `ascii_SPACE;
                end
            
            default: begin
                sung_note_note <= `ascii_SPACE;
                sung_note_accidental <= `ascii_SPACE;
            end
        endcase
    end

  // 7 seg display
    wire seg7en = new_mode | new_sung_note | new_played_note;
    
    always @ (posedge CLK100MHZ) begin
        if (!CPU_RESETN) begin
            seg7_reg <= 64'h0;
        end
        else if (seg7en) begin
            // sung note, from microblaze
            seg7_reg[8*7 +: 8] <= microblaze_char1;
            seg7_reg[8*6 +: 8] <= microblaze_char0;

            // played note, from keyboard
            seg7_reg[8*5 +: 8] <= module_char1;
            seg7_reg[8*4 +: 8] <= module_char0;

            // display comparison
            seg7_reg[8*3 +: 8] <= cmp_char;
                        
            // mode/controls display
            seg7_reg[8*1 +: 8] <= mode_char1;
            seg7_reg[8*0 +: 8] <= mode_char0;
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

endmodule
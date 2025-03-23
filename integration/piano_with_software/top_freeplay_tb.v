`timescale 1ns / 1ps

module top_freeplay_tb (
    // peripherals
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

    /* Testbench Inputs */
    wire [3:0] playen_oct_oct_oct   = SW[15:12];
    wire simulated_cmp              = SW[11];
    wire [3:0] microblaze_sung_note = SW[9:6];
    wire [3:0] generated_note0      = SW[5:2];   // 0 C, 11 B
    wire [1:0] simulated_mode_sel   = SW[1:0];

    // LEDs direcrly used in module

    /* Encode/Decode */
    // AXI_GPIO inputs [microblaze -> module]
    // bit 0
    wire [1:0] mode_sel;        // 0 Home, 1 Ear Training, 2 Free Play
    wire [1:0] play_note_num = 1;   // microblaze generates chord, max 3 notes
    wire [6:0] play_note_id_0;  // microblaze chord note 0
    wire [6:0] play_note_id_1 = 0;  // microblaze chord note 1
    wire [6:0] play_note_id_2 = 0;  // microblaze chord note 2
    wire [5:0] sung_note_id;    // user sung note
    wire compare_correct;
    // bit 32
    
    // AXI_GPIO outputs [microblaze <- module]
    // bit 0
    wire [3:0] user_controls;   // 16 controls bits available for keyboard software controls
    wire [6:0] piano_note_id;   // piano note most recently played
    // bit 11

    // encode/decode
    wire [31:0] axi_swctrl_piano_i;
    wire [10:0] axi_swctrl_piano_o;
    assign axi_swctrl_piano_i = {compare_correct, sung_note_id, play_note_id_2, play_note_id_1, play_note_id_0, play_note_num, mode_sel};
    assign {piano_note_id, user_controls} = axi_swctrl_piano_o;

    /* TEST BENCH */
    assign mode_sel = simulated_mode_sel;
    assign play_note_id_0 = generated_note0 + 5'd27;
    assign sung_note_id = microblaze_sung_note + 5'd28;
    assign compare_correct = simulated_cmp;

    swctrl_piano sp0 (
        // peripherals
        .CLK100MHZ(CLK100MHZ),
        .CPU_RESETN(CPU_RESETN),
        .PS2_CLK(PS2_CLK),
        .PS2_DATA(PS2_DATA),
        .playen_oct(playen_oct_oct_oct),
        .BTNU(BTNU),
        .BTND(BTND),
        .AUD_SD(AUD_SD),
        .AUD_PWM(AUD_PWM),
        .LED(LED),
        .UART_TXD(UART_TXD),
        .SEG7_SEG(SEG7_SEG),
        .SEG7_AN(SEG7_AN),
        .SEG7_DP(SEG7_DP),
        
        // interface with AXI_GPIO
        .axi_swctrl_piano_i(axi_swctrl_piano_i),
        .axi_swctrl_piano_o()
    );

endmodule
//Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
//Date        : Tue Apr  1 03:40:26 2025
//Host        : DESKTOP-QH80AKG running 64-bit major release  (build 9200)
//Command     : generate_target mic_wrapper.bd
//Design      : mic_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module mic_wrapper
   (AUD_PWM,
    AUD_SD,
    BTND,
    BTNU,
    Hsync,
    LED,
    PS2_CLK,
    PS2_DATA,
    SEG7_AN,
    SEG7_DP,
    SEG7_SEG,
    SW,
    Vsync,
    micClk,
    micData,
    micLRSel,
    reset,
    sys_clock,
    usb_uart_rxd,
    usb_uart_txd,
    vgaBlue,
    vgaGreen,
    vgaRed);
  output AUD_PWM;
  output AUD_SD;
  input BTND;
  input BTNU;
  output Hsync;
  output [15:0]LED;
  input PS2_CLK;
  input PS2_DATA;
  output [7:0]SEG7_AN;
  output SEG7_DP;
  output [6:0]SEG7_SEG;
  input [15:0]SW;
  output Vsync;
  output micClk;
  input micData;
  output micLRSel;
  input reset;
  input sys_clock;
  input usb_uart_rxd;
  output usb_uart_txd;
  output [3:0]vgaBlue;
  output [3:0]vgaGreen;
  output [3:0]vgaRed;

  wire AUD_PWM;
  wire AUD_SD;
  wire BTND;
  wire BTNU;
  wire Hsync;
  wire [15:0]LED;
  wire PS2_CLK;
  wire PS2_DATA;
  wire [7:0]SEG7_AN;
  wire SEG7_DP;
  wire [6:0]SEG7_SEG;
  wire [15:0]SW;
  wire Vsync;
  wire micClk;
  wire micData;
  wire micLRSel;
  wire reset;
  wire sys_clock;
  wire usb_uart_rxd;
  wire usb_uart_txd;
  wire [3:0]vgaBlue;
  wire [3:0]vgaGreen;
  wire [3:0]vgaRed;

  mic mic_i
       (.AUD_PWM(AUD_PWM),
        .AUD_SD(AUD_SD),
        .BTND(BTND),
        .BTNU(BTNU),
        .Hsync(Hsync),
        .LED(LED),
        .PS2_CLK(PS2_CLK),
        .PS2_DATA(PS2_DATA),
        .SEG7_AN(SEG7_AN),
        .SEG7_DP(SEG7_DP),
        .SEG7_SEG(SEG7_SEG),
        .SW(SW),
        .Vsync(Vsync),
        .micClk(micClk),
        .micData(micData),
        .micLRSel(micLRSel),
        .reset(reset),
        .sys_clock(sys_clock),
        .usb_uart_rxd(usb_uart_rxd),
        .usb_uart_txd(usb_uart_txd),
        .vgaBlue(vgaBlue),
        .vgaGreen(vgaGreen),
        .vgaRed(vgaRed));
endmodule

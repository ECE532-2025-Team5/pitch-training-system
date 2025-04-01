//Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
//Date        : Tue Apr  1 00:09:55 2025
//Host        : MSI running 64-bit major release  (build 9200)
//Command     : generate_target audioin_fft_top_wrapper.bd
//Design      : audioin_fft_top_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module audioin_fft_top_wrapper
   (Hsync,
    Vsync,
    ck100MHz,
    max_frequency,
    micClk,
    micData,
    micLRSel,
    vgaBlue,
    vgaGreen,
    vgaRed);
  output Hsync;
  output Vsync;
  input ck100MHz;
  output [9:0]max_frequency;
  output micClk;
  input micData;
  output micLRSel;
  output [3:0]vgaBlue;
  output [3:0]vgaGreen;
  output [3:0]vgaRed;

  wire Hsync;
  wire Vsync;
  wire ck100MHz;
  wire [9:0]max_frequency;
  wire micClk;
  wire micData;
  wire micLRSel;
  wire [3:0]vgaBlue;
  wire [3:0]vgaGreen;
  wire [3:0]vgaRed;

  audioin_fft_top audioin_fft_top_i
       (.Hsync(Hsync),
        .Vsync(Vsync),
        .ck100MHz(ck100MHz),
        .max_frequency(max_frequency),
        .micClk(micClk),
        .micData(micData),
        .micLRSel(micLRSel),
        .vgaBlue(vgaBlue),
        .vgaGreen(vgaGreen),
        .vgaRed(vgaRed));
endmodule

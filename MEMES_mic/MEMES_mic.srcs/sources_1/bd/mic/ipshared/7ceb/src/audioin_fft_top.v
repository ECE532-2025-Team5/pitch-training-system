//Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
//Date        : Tue Apr  1 00:09:55 2025
//Host        : MSI running 64-bit major release  (build 9200)
//Command     : generate_target audioin_fft_top.bd
//Design      : audioin_fft_top
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "audioin_fft_top,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=audioin_fft_top,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=8,numReposBlks=8,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=6,numPkgbdBlks=0,bdsource=USER,da_board_cnt=1,synth_mode=OOC_per_IP}" *) (* HW_HANDOFF = "audioin_fft_top.hwdef" *) 
module audioin_fft_top
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

  wire [13:0]FftBlock_0_addrFreq;
  wire [7:0]FftBlock_0_byteFreqSample;
  wire FftBlock_0_flgFreqSampleValid;
  wire [9:0]HarmonicProductSpect_0_max_frequency;
  wire [3:0]ImgCtrl_0_blue;
  wire [3:0]ImgCtrl_0_green;
  wire [3:0]ImgCtrl_0_red;
  wire VgaCtrl_0_HS;
  wire VgaCtrl_0_VS;
  wire [31:0]VgaCtrl_0_adrHor;
  wire [31:0]VgaCtrl_0_adrVer;
  wire VgaCtrl_0_flgActiveVideo;
  wire [7:0]audio_demo_0_data_mic;
  wire audio_demo_0_data_mic_valid;
  wire audio_demo_0_pdm_clk_o;
  wire audio_demo_0_pdm_lrsel_o;
  wire ck100MHz_0_1;
  wire clk_wiz_0_clk_out1;
  wire pdm_data_i_0_1;
  wire prescaller_0_flgStartAcquisition;
  wire [0:0]xlconstant_0_dout;

  assign Hsync = VgaCtrl_0_HS;
  assign Vsync = VgaCtrl_0_VS;
  assign ck100MHz_0_1 = ck100MHz;
  assign max_frequency[9:0] = HarmonicProductSpect_0_max_frequency;
  assign micClk = audio_demo_0_pdm_clk_o;
  assign micLRSel = audio_demo_0_pdm_lrsel_o;
  assign pdm_data_i_0_1 = micData;
  assign vgaBlue[3:0] = ImgCtrl_0_blue;
  assign vgaGreen[3:0] = ImgCtrl_0_green;
  assign vgaRed[3:0] = ImgCtrl_0_red;
  audioin_fft_top_FftBlock_1_0 FftBlock_0
       (.addrFreq(FftBlock_0_addrFreq),
        .btnL(1'b0),
        .byteFreqSample(FftBlock_0_byteFreqSample),
        .ckFreq(1'b0),
        .ckaTime(ck100MHz_0_1),
        .dinaTime(audio_demo_0_data_mic),
        .flgFreqSampleValid(FftBlock_0_flgFreqSampleValid),
        .flgStartAcquisition(prescaller_0_flgStartAcquisition),
        .sw({1'b0,1'b0,1'b0}),
        .weaTime(audio_demo_0_data_mic_valid));
  audioin_fft_top_HarmonicProductSpect_0_0 HarmonicProductSpect_0
       (.addraFreq(FftBlock_0_addrFreq[9:0]),
        .byteFreqSample(FftBlock_0_byteFreqSample),
        .ck100MHz(ck100MHz_0_1),
        .flgFreqSampleValid(FftBlock_0_flgFreqSampleValid),
        .max_frequency(HarmonicProductSpect_0_max_frequency),
        .reset(xlconstant_0_dout));
  audioin_fft_top_ImgCtrl_0_2 ImgCtrl_0
       (.addraFreq(FftBlock_0_addrFreq),
        .adrHor(VgaCtrl_0_adrHor),
        .adrVer(VgaCtrl_0_adrVer),
        .blue(ImgCtrl_0_blue),
        .ck100MHz(ck100MHz_0_1),
        .ckVideo(clk_wiz_0_clk_out1),
        .dinaFreq(FftBlock_0_byteFreqSample),
        .flgActiveVideo(VgaCtrl_0_flgActiveVideo),
        .green(ImgCtrl_0_green),
        .red(ImgCtrl_0_red),
        .weaFreq(FftBlock_0_flgFreqSampleValid));
  audioin_fft_top_VgaCtrl_0_0 VgaCtrl_0
       (.HS(VgaCtrl_0_HS),
        .VS(VgaCtrl_0_VS),
        .adrHor(VgaCtrl_0_adrHor),
        .adrVer(VgaCtrl_0_adrVer),
        .ckVideo(clk_wiz_0_clk_out1),
        .flgActiveVideo(VgaCtrl_0_flgActiveVideo));
  audioin_fft_top_audio_demo_0_0 audio_demo_0
       (.clk_i(ck100MHz_0_1),
        .data_mic(audio_demo_0_data_mic),
        .data_mic_valid(audio_demo_0_data_mic_valid),
        .pdm_clk_o(audio_demo_0_pdm_clk_o),
        .pdm_data_i(pdm_data_i_0_1),
        .pdm_lrsel_o(audio_demo_0_pdm_lrsel_o),
        .rst_i(xlconstant_0_dout));
  audioin_fft_top_clk_wiz_0_0 clk_wiz_0
       (.clk_in1(ck100MHz_0_1),
        .clk_out1(clk_wiz_0_clk_out1),
        .reset(xlconstant_0_dout));
  audioin_fft_top_prescaller_0_0 prescaller_0
       (.ck100MHz(ck100MHz_0_1),
        .flgStartAcquisition(prescaller_0_flgStartAcquisition));
  audioin_fft_top_xlconstant_0_0 xlconstant_0
       (.dout(xlconstant_0_dout));
endmodule

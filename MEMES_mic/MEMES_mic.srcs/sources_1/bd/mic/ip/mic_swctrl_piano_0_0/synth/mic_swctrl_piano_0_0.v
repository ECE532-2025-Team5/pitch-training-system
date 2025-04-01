// (c) Copyright 1995-2025 Xilinx, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
// 
// DO NOT MODIFY THIS FILE.


// IP VLNV: xilinx.com:module_ref:swctrl_piano:1.0
// IP Revision: 1

(* X_CORE_INFO = "swctrl_piano,Vivado 2018.3" *)
(* CHECK_LICENSE_TYPE = "mic_swctrl_piano_0_0,swctrl_piano,{}" *)
(* CORE_GENERATION_INFO = "mic_swctrl_piano_0_0,swctrl_piano,{x_ipProduct=Vivado 2018.3,x_ipVendor=xilinx.com,x_ipLibrary=module_ref,x_ipName=swctrl_piano,x_ipVersion=1.0,x_ipCoreRevision=1,x_ipLanguage=VERILOG,x_ipSimLanguage=MIXED}" *)
(* IP_DEFINITION_SOURCE = "module_ref" *)
(* DowngradeIPIdentifiedWarnings = "yes" *)
module mic_swctrl_piano_0_0 (
  CLK100MHZ,
  CPU_RESETN,
  PS2_CLK,
  PS2_DATA,
  playen_oct,
  BTNU,
  BTND,
  AUD_SD,
  AUD_PWM,
  LED,
  UART_TXD,
  SEG7_SEG,
  SEG7_AN,
  SEG7_DP,
  axi_swctrl_piano_i,
  axi_swctrl_piano_o
);

input wire CLK100MHZ;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CPU_RESETN, POLARITY ACTIVE_LOW, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 CPU_RESETN RST" *)
input wire CPU_RESETN;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME PS2_CLK, FREQ_HZ 100000000, PHASE 0.000, CLK_DOMAIN mic_PS2_CLK, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 PS2_CLK CLK" *)
input wire PS2_CLK;
input wire PS2_DATA;
input wire [3 : 0] playen_oct;
input wire BTNU;
input wire BTND;
output wire AUD_SD;
output wire AUD_PWM;
output wire [15 : 0] LED;
output wire UART_TXD;
output wire [6 : 0] SEG7_SEG;
output wire [7 : 0] SEG7_AN;
output wire SEG7_DP;
input wire [31 : 0] axi_swctrl_piano_i;
output wire [10 : 0] axi_swctrl_piano_o;

  swctrl_piano inst (
    .CLK100MHZ(CLK100MHZ),
    .CPU_RESETN(CPU_RESETN),
    .PS2_CLK(PS2_CLK),
    .PS2_DATA(PS2_DATA),
    .playen_oct(playen_oct),
    .BTNU(BTNU),
    .BTND(BTND),
    .AUD_SD(AUD_SD),
    .AUD_PWM(AUD_PWM),
    .LED(LED),
    .UART_TXD(UART_TXD),
    .SEG7_SEG(SEG7_SEG),
    .SEG7_AN(SEG7_AN),
    .SEG7_DP(SEG7_DP),
    .axi_swctrl_piano_i(axi_swctrl_piano_i),
    .axi_swctrl_piano_o(axi_swctrl_piano_o)
  );
endmodule

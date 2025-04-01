`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/02/21 21:22:49
// Design Name: 
// Module Name: audio_jack
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module audio_jack(
    input unProcessed,
    output audio
    );
    
    assign audio = (unProcessed) ? 1'bz : 1'b0; 
endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/30/2025 04:21:58 PM
// Design Name: 
// Module Name: HarmonicProductSpectrum
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


module HarmonicProductSpect (
    input wire ck100MHz,
    input wire flgFreqSampleValid,
    input wire [9:0] addraFreq,
    input wire [7:0] byteFreqSample,
    input wire reset,
    output wire [9:0] max_frequency
);
    parameter N = 128; // FFT size
    localparam SMOOTHING_FACTOR = 8;
    localparam HYSTERESIS = 5;
    localparam DECAY_FACTOR = 2;

    reg [7:0] max_hps = 0;
    reg [9:0] max_frequency_reg;
    reg [9:0] last_max_freq [0:SMOOTHING_FACTOR-1];  // Last N max values for smoothing
    integer i;
    reg [9:0] smoothed_freq;

    always @(posedge ck100MHz) begin
        if (reset) begin
            max_hps <= 0;
            max_frequency_reg <= 0;
            for (i = 0; i < SMOOTHING_FACTOR; i = i + 1) begin
                last_max_freq[i] <= 0;
            end
            smoothed_freq <= 0;
        end else begin
            if (flgFreqSampleValid) begin
                if (byteFreqSample > max_hps + HYSTERESIS) begin
                    max_hps <= byteFreqSample;
                    max_frequency_reg <= addraFreq;
                end
            end

            if (flgFreqSampleValid && (addraFreq == (N-1))) begin // New frame starts
                // Peak hold with decay
                if (max_hps > DECAY_FACTOR) begin
                    max_hps <= max_hps - DECAY_FACTOR;
                end else begin
                    max_hps <= 0;
                end

                // Shift last values for smoothing
                for (i = 1; i < SMOOTHING_FACTOR; i = i + 1) begin
                    last_max_freq[i-1] <= last_max_freq[i];
                end
                last_max_freq[SMOOTHING_FACTOR-1] <= max_frequency_reg;

                // Compute the smoothed max
                smoothed_freq <= (last_max_freq[0] + last_max_freq[1] + last_max_freq[2] + last_max_freq[3] + last_max_freq[4] + last_max_freq[5] + last_max_freq[6] + last_max_freq[7]) >> 3;
            end
        end
    end

    assign max_frequency = smoothed_freq;  // Output stabilized pitch

endmodule
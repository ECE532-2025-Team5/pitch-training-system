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


module HarmonicProductSpectrum (
    input wire ck100MHz,
    input wire flgFreqSampleValid,
    input wire [9:0] addraFreq,
    input wire [7:0] byteFreqSample,
    input reset,
    output reg [9:0] max_frequency
);
    parameter N = 128; //FFT size
    parameter HARMONICS = 2;
    parameter COUNT = 25_000_000;

    // Power spectrum buffer
    reg [7:0] power_spectrum [0:N-1];
    // Harmonic Product Spectrum buffer
    reg [HARMONICS*8 - 1:0] hps [0:N/HARMONICS-1];
    
    reg [HARMONICS*8 - 1:0] max_hps = 0;
    reg [9:0] max_frequency_reg;
    
    integer i, j;
    reg [25:0] sample_counter = 0;
    reg compute_hps = 0;
    reg full_spectrum = 0;
    
    always @(posedge ck100MHz) begin
        if (reset) begin
            sample_counter <= 0;
            
            for (i = 0; i < N/HARMONICS; i = i + 1) begin
                hps[i] <= 1;
            end
            max_hps <= 0;
            max_frequency_reg <= 0;
        end
        
        if (flgFreqSampleValid && ~full_spectrum) begin
            power_spectrum[addraFreq] <= byteFreqSample;
            if(addraFreq >= N) begin
                full_spectrum <= 1;
            end
        end
 
        if(sample_counter >= COUNT) begin
            compute_hps <= 1;
            sample_counter <= 0;
        end
        else if(~compute_hps) begin
            sample_counter <= sample_counter + 1;
        end

        if(compute_hps && full_spectrum) begin
            max_hps <= 0;
            /*for (i = 1; i < N; i = i + 1) begin
                if(power_spectrum[i] > max_hps) begin
                    max_hps <= power_spectrum[i];
                    max_frequency_reg <= i;
                end
            end*/
            for (i = 1; i < N/HARMONICS; i = i + 1) begin
                hps[i] <= power_spectrum[i];
                for (j = 2; j <= HARMONICS; j = j + 1) begin
                    hps[i] <= hps[i] * power_spectrum[i * j];
                end 
                if (hps[i] > max_hps) begin
                    max_hps <= hps[i];
                    max_frequency_reg <= i;
                end
            end
            max_frequency <= 181;
            compute_hps <= 0;
            full_spectrum <= 0;
        end          
    end
    
    

endmodule


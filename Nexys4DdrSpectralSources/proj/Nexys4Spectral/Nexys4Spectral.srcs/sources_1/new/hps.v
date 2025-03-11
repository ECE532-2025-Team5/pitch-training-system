`timescale 1ns / 1ps

module HarmonicProductSpectrum (
    input wire ck100MHz,
    input wire flgFreqSampleValid,
    input wire [9:0] addraFreq,
    input wire [7:0] byteFreqSample
);
    parameter N = 1024; //FFT size
    parameter HARMONICS = 4;

    // Power spectrum buffer
    reg [31:0] power_spectrum [0:N-1];
    
    // Array of addresses
    reg [9:0] addressArray [0:N-1];

    // Harmonic Product Spectrum buffer
    reg [31:0] hps [0:N/HARMONICS-1];
  
    reg [31:0] max_hps = 0;
    reg [9:0] max_frequency;

    integer i, n;
    
    initial begin
        for (i = 0; i < N/HARMONICS; i = i + 1) begin
            hps[i] = 1;
        end
        i = 0;
    end

    always @(posedge ck100MHz) begin
        if (flgFreqSampleValid) begin
            power_spectrum[i] <= byteFreqSample;
            addressArray[i] <= addraFreq;
            i = i + 1;
        end 
    end
    
    always @(posedge ck100MHz) begin
        // Compute Harmonic Product Spectrum
        for (i = 1; i < N/HARMONICS; i = i + 1) begin
            for (n = 1; n <= HARMONICS; n = n + 1) begin
                hps[i] <= hps[i] * power_spectrum[i * n];
            end 
            if (hps[i] > max_hps) begin
                max_hps <= hps[i];
                max_frequency = addressArray[i];
            end
        end    
        $display("max frequency: %0d", max_frequency);       
    end

endmodule

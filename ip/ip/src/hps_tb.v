`timescale 1ns / 1ps

module hps_tb;

    // Inputs
    reg ck100MHz;
    reg flgFreqSampleValid;
    reg [9:0] addraFreq;
    reg [7:0] byteFreqSample;
    reg reset;

    // Output
    wire [9:0] max_frequency;

    // Instantiate the DUT (Device Under Test)
    HarmonicProductSpect uut (
        .ck100MHz(ck100MHz),
        .flgFreqSampleValid(flgFreqSampleValid),
        .addraFreq(addraFreq),
        .byteFreqSample(byteFreqSample),
        .reset(reset),
        .max_frequency(max_frequency)
    );

    // Clock generation
    always #5 ck100MHz = ~ck100MHz;  // 10 ns period (100MHz)

    integer i, j, peak_freq;

    initial begin
        // Initialize signals
        ck100MHz = 0;
        reset = 1;
        flgFreqSampleValid = 0;
        addraFreq = 0;
        byteFreqSample = 0;

        // Reset sequence
        #20;
        reset = 0;
        #20;

        // Generate 10 groups of FFT-like frames
        for (i = 0; i < 10; i = i + 1) begin
            peak_freq = ($random % 96) + 16; // Peak between 16 and 112 (avoid low-freq noise)

            for (j = 0; j < 128; j = j + 1) begin
                @(posedge ck100MHz);
                flgFreqSampleValid = 1;
                addraFreq = j;

                // Assign high values around the peak frequency
                if (j == peak_freq) begin
                    byteFreqSample = 240; // Peak frequency has the highest magnitude
                end else if (j >= peak_freq - 5 && j <= peak_freq + 5) begin
                    byteFreqSample = 160 + ($random % 32); // Strong nearby frequencies
                end else if (j >= peak_freq - 20 && j <= peak_freq + 20) begin
                    byteFreqSample = 80 + ($random % 32); // Medium nearby frequencies
                end else begin
                    byteFreqSample = $random % 256; // Background noise (low values)
                end
            end
            
            // End of frame
            @(posedge ck100MHz);
            flgFreqSampleValid = 0;
            #50; // Small delay before the next group
        end

        // End simulation
        #100;
        $finish;
    end

    // Monitor changes
    initial begin
        $monitor("Time=%0t, Valid=%b, Addr=%d, Sample=%d, MaxFreq=%d", 
                 $time, flgFreqSampleValid, addraFreq, byteFreqSample, max_frequency);
    end

endmodule

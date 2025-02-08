`timescale 1ns / 1ps

module aud_pwm(
    input clk,
    input [15:0] swt,
    input btnl,
    input btnr,
    input btnu,
    input btnd,
    input resetn,
    output [15:0] led,
    output AUD_SD,
    output AUD_PWM
);
    // Controls
    //   Volume: Up (incr), Down (decr)
    //   Pitch: Left (lower), Right (higher)
    reg [5:0] cur_note;
    initial cur_note = 6'd28;
    reg [3:0] volume;
    initial volume = 4'd0;
    reg set;
    initial set = 1'b0;
    reg btnr_, btnl_, btnu_, btnd_; // rising edge detection
    always @(negedge resetn or posedge clk) begin
        set <= 1'b0;
        if (!resetn) begin
            cur_note <= 6'd28;
            volume <= 4'd0;
        end
        else if (!btnr_ && btnr) begin
            cur_note <= (cur_note < 6'd48) ? (cur_note + 1) : cur_note;
            set <= 1'b1;
        end
        else if (!btnl_ && btnl) begin
            cur_note <= (cur_note > 6'd0) ? (cur_note - 1) : cur_note;
            set <= 1'b1;
        end
        else if (!btnu_ && btnu) begin
            volume <= (volume < 3'd15) ? (volume + 1) : volume;
            set <= 1'b1;
        end
        else if (!btnd_ && btnd) begin
            volume <= (volume > 3'd0) ? (volume - 1) : volume;
            set <= 1'b1;
        end
        btnr_ <= btnr;
        btnl_ <= btnl;
        btnu_ <= btnu;
        btnd_ <= btnd;
    end

    // Note and octave calculation
    reg [31:0] COUNTS_PER_INTERVAL = 32'd191113; // C5, default
    reg [2:0] octave_note;
    reg [2:0] octave_num;
    reg [31:0] c1maj [6:0];
    always @* begin
        octave_note <= (cur_note % 7);
        octave_num <= (cur_note - octave_note) / 7;
        case (octave_note)
            0: c1maj[0] = 32'd3057805;   // C1
            1: c1maj[1] = 32'd2724194;   // D1
            2: c1maj[2] = 32'd2426982;   // E1
            3: c1maj[3] = 32'd2290765;   // F1
            4: c1maj[4] = 32'd2040840;   // G1
            5: c1maj[5] = 32'd1818182;   // A1
            6: c1maj[6] = 32'd1619816;   // B1
         endcase
    end
    
    always @* begin
        // each octave higher is a doubling of frequency
        //    therefore halving of period/samples (right shift)
        COUNTS_PER_INTERVAL <= (c1maj[octave_note] >> octave_num);
    end
    
    // Show note on LEDs
    assign led[3:0] = scale_note[3:0];
    assign led[7:5] = octave_num[2:0];
    assign led[13:8] = cur_note[5:0];

    // Audio Jack logic
    wire out_pwm;
    freq_pwm f0(.clk(clk),
                .resetn(resetn),
                .set(set),
                .clks_per_period(COUNTS_PER_INTERVAL),
                .volume(volume),
                .out_pwm(out_pwm));

    assign AUD_PWM = (out_pwm) ? 1'bz : 1'b0;   // that's just how it works
    assign AUD_SD = swt[15];                    // enable
    
    // Show 100 MHz clock is working on led[15]
    reg [32:0] second_counter;
    reg sec_led;
    assign led[15] = sec_led;
    initial sec_led = 1'b0;
    always @(posedge clk) begin
        if (second_counter == 0) begin
            second_counter <= 32'd50000000;
            sec_led = ~sec_led;
        end
        else begin
            second_counter <= second_counter - 1'b1;
        end
    end
    
endmodule

module freq_pwm(
    input clk,
    input resetn,
    input set,
    input [31:0] clks_per_period,
    input [3:0] volume,
    output reg out_pwm
);
    // Audio Jack logic
    //   clks_per_period: the period
    //       period and freq determines pitch
    //   sample: the portion of "1"
    //       duty cycle (sample/period) determines volumn
    reg [31:0] cur_period;
    reg [31:0] sample;
    reg [31:0] pwm_counter;
    initial pwm_counter = 32'd0;

    
    always @(negedge resetn, posedge set, posedge clk) begin
        if (!resetn) begin
            pwm_counter <= 0;
            sample <= 1;
            cur_period <= 0;
        end
        else if (set) begin
            cur_period <= clks_per_period;
            sample <= (clks_per_period >> (15 - volume));
        end
        else if (pwm_counter >= cur_period-1) begin
            pwm_counter <= 0;
        end
        else begin
            pwm_counter <= pwm_counter + 1'b1;
        end
    end

    always @(posedge clk) begin
	    out_pwm <= (pwm_counter < sample);
    end
    
endmodule
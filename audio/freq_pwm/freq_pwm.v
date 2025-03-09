`timescale 1ns / 1ns

module freq_pwm(
    input clk,
    input resetn,
    input new_period,
    input [31:0] clks_per_period,
    input [3:0] volume,
    output reg out_pwm
);

    reg [31:0] period;
    reg [31:0] sample;
    reg [31:0] pwm_counter;
    initial period  = 32'd0;
    initial sample      = 32'd0;
    initial pwm_counter = 32'd0;
    
    wire [3:0] shift;
    assign shift = 4'd15 - volume;

    always @(negedge resetn, posedge clk) begin
        if (!resetn) begin
            pwm_counter <= 0;
            sample <= 0;
            period <= 0;
        end
        else if (new_period) begin
            period <= clks_per_period;
            sample <= (clks_per_period >> (shift + 1)); // +1 to divide period by 2 for 50% duty cycle
        end
        else if (pwm_counter >= period-1) begin
            pwm_counter <= 0;
            sample <= (period >> (shift + 1)); // update volume
        end
        else begin
            pwm_counter <= pwm_counter + 1'b1;
        end
    end

    always @(posedge clk) begin
        if (period != 0) begin
	       out_pwm <= (pwm_counter < sample);
	    end
    end
    
endmodule

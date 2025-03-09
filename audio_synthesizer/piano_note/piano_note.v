`timescale 1ns / 1ps

module piano_note #(parameter BASE_CLK_PER_PERIOD=3057805) (  // C1
    input clk,
    input resetn,
    input [3:0] volume,
    input [2:0] octave,
    input key_press,
    output output_pwm
);

    // Set period to 0 when key not pressed
    wire [31:0] clks_per_period = BASE_CLK_PER_PERIOD >> octave;
    
    // changing period
    reg [31:0] prev_clks_per_period;
    reg update_period;
    always @(posedge clk) begin
        if (!resetn) begin
            update_period <= 1'b0;
            prev_clks_per_period <= 32'b0;
        end
        else begin
            update_period  <= (clks_per_period != prev_clks_per_period);
            prev_clks_per_period <= clks_per_period;
        end
    end

    // Instantiations
    wire out_pwm;
    freq_pwm f0(
        .clk(clk),
        .resetn(resetn),
        .new_period(update_period),
        .clks_per_period(clks_per_period),
        .volume(volume),
        .out_pwm(out_pwm)
    );
    
    // Only output when key pressed
    assign output_pwm = (key_press) ? out_pwm : 1'b0;

endmodule

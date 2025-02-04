// Here, this controls the DC of a PWM signal connected to a speaker. It generates a square wave
// The PWM only controls the volume of the speaker
// In general, to control the tone of a speaker , you need to modify the frequency (which we can't at run-time)

module pwm_speaker #(
    parameter TPWM = 2000   // Time (in periods of clock) of a period of PWM. It can't be 0 or 1
) (                         // 50 Khz... 500 --> 200 KHz
    input wire resetn,
    input wire clock,
    input wire [7:0] sel,
    output wire oPWM
);

    localparam nTPWM = $clog2(TPWM + 1);
    reg [nTPWM + 7:0] DC_A;
    wire [nTPWM - 1:0] DC;

    always @(posedge clock or negedge resetn) begin
        if (!resetn)
            DC_A <= 0;
        else
            DC_A <= sel * TPWM;
    end

    assign DC = DC_A[nTPWM + 7:8];

    mypwm #(.TPWM(TPWM)) rl (
        .resetn(resetn),
        .clock(clock),
        .DC(DC),        // Number between 0 and TPWM
        .oPWM(oPWM)
    );

endmodule
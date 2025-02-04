module pwm_speaker #(
    parameter TPWM = 2000 // Default 50 KHz
) (
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
        .DC(DC),
        .oPWM(oPWM)
    );

endmodule
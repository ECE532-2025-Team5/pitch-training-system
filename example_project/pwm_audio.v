module pwm_audio (
    input wire resetn,
    input wire clock,
    input wire [2:0] frq,
    input wire SD,
    output wire AUD_PWM,
    output wire AUD_SD
);

    parameter TPWM = 1000; // 100 KHz -> Sinusoidal signal can be of 10 KHz
    
    reg [7:0] sel;
    reg [12:0] tmp;
    wire [12:0] TM;
    wire [7:0] sel_v;
    wire oPWM;

    assign TM = (64 * (1 << frq)) - 1;
    assign sel_v = sel;
    assign AUD_SD = SD;

    always @(posedge clock or negedge resetn) begin
        if (!resetn) begin
            sel <= 0;
            tmp <= 0;
        end else begin
            if (tmp >= TM) begin
                tmp <= 0;
                if (sel == 8'hFF)
                    sel <= 0;
                else
                    sel <= sel + 1;
            end else begin
                tmp <= tmp + 1;
            end
        end
    end

    pwm_speaker #(.TPWM(TPWM)) gi (
        .resetn(resetn),
        .clock(clock),
        .sel(sel_v),
        .oPWM(oPWM)
    );

    assign AUD_PWM = (oPWM) ? 1'bz : 1'b0;
    
endmodule

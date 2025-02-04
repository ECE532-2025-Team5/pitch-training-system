// Here, DC is a number between 0 to TPWM.
// In a higher hierarchy file, you can create a circuit that DC is between 0 and 100% (or 0 to 255).
// If DC = 0 --> oPWM = 0
// If DC = TPWM -> oPWM = 1
//   If DC > TPWM --> oPWM = 1 (this can happen by mistake if TPWM is not a power of 2 minus 1).
// TPWM: Period (in terms of periods of input frequency). If input frequency is 100 MHz, then TPWM = 2000 means 50 KHz

module mypwm #(parameter TPWM = 10) (       // Time (in periods of clock) of a period of PWM. It can't be 0 or 1
    input wire resetn,
    input wire clock,
    input wire [$clog2(TPWM+1)-1:0] DC,     // Number between 0 and TPWM
    output reg oPWM
);

    localparam nDC = $clog2(TPWM+1);
    reg [nDC-1:0] DCq;
    reg [nDC-1:0] Q;    // 0 to TPWM - 1
    reg [1:0] y;
    
    always @(posedge clock or negedge resetn) begin
        if (!resetn) begin
            y <= 2'b00; 
            Q <= 0; 
            DCq <= 0;
        end else begin
            case (y)
                2'b00: begin // S1
                    Q <= 0; 
                    DCq <= DC;
                    y <= 2'b01;
                end
                2'b01: begin // S2
                    if (DCq == 0 || DCq >= TPWM) begin
                        y <= 2'b01; 
                        DCq <= DC;
                    end else begin
                        Q <= Q + 1;
                        y <= (DCq == 1) ? 2'b11 : 2'b10;
                    end
                end
                2'b10: begin // S3
                    Q <= Q + 1;
                    if (Q == DCq - 1)
                        y <= 2'b11;
                end
                2'b11: begin // S4
                    if (Q == TPWM - 1) begin
                        Q <= 0; 
                        DCq <= DC;
                        y <= 2'b01;
                    end else begin
                        Q <= Q + 1;
                    end
                end
            endcase
        end
    end
    
    always @(*) begin
        case (y)
            2'b01: oPWM = (DCq == 0) ? 0 : 1;
            2'b10: oPWM = 1;
            default: oPWM = 0;
        endcase
    end
    
endmodule
module mypwm #(parameter TPWM = 10) (
    input wire resetn,
    input wire clock,
    input wire [$clog2(TPWM+1)-1:0] DC,
    output reg oPWM
);

    localparam nDC = $clog2(TPWM+1);
    reg [nDC-1:0] DCq;
    reg [nDC-1:0] Q;
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
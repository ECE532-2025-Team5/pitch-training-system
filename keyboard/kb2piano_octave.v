`timescale 1ns / 1ps

`include "ps2_to_ascii.v"

module kb2piano_octave #(parameter
    F       = `kb_Z,
    F_sharp = `kb_S,
    G       = `kb_X,
    G_sharp = `kb_D,
    A       = `kb_C,
    A_sharp = `kb_F,
    B       = `kb_V,
    C       = `kb_B,
    C_sharp = `kb_H,
    D       = `kb_N,
    D_sharp = `kb_J,
    E       = `kb_M)
(
    input [7:0] keycode,
    output reg [3:0] piano_note // 0 no note, C:1 to B:12
);
    
    always @ (*) begin        
        case(keycode)
            F: 	        piano_note <= 4'd1;
            F_sharp: 	piano_note <= 4'd2;
            G: 	        piano_note <= 4'd3;
            G_sharp: 	piano_note <= 4'd4;
            A: 	        piano_note <= 4'd5;
            A_sharp: 	piano_note <= 4'd6;
            B: 	        piano_note <= 4'd7;
            C: 	        piano_note <= 4'd8;
            C_sharp: 	piano_note <= 4'd9;
            D: 	        piano_note <= 4'd10;
            D_sharp: 	piano_note <= 4'd11;
            E:      	piano_note <= 4'd12;
            
            default: 	piano_note <= 4'd0;
        endcase
    end
endmodule
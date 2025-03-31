`timescale 1ns / 1ps

`include "ps2_to_ascii.v"

module kb2piano_octave #(parameter
    C       = `kb_Z,
    C_sharp = `kb_S,
    D       = `kb_X,
    D_sharp = `kb_D,
    E       = `kb_C,
    F       = `kb_V,
    F_sharp = `kb_G,
    G       = `kb_B,
    G_sharp = `kb_H,
    A       = `kb_N,
    A_sharp = `kb_J,
    B       = `kb_M)
(
    input [7:0] keycode,
    output reg [3:0] piano_note // 0 no note, C:1 to B:12
);
    
    always @ (*) begin        
        case(keycode)
            C: 	        piano_note <= 4'd1;
            C_sharp: 	piano_note <= 4'd2;
            D: 	        piano_note <= 4'd3;
            D_sharp: 	piano_note <= 4'd4;
            E:      	piano_note <= 4'd5;
            F: 	        piano_note <= 4'd6;
            F_sharp: 	piano_note <= 4'd7;
            G: 	        piano_note <= 4'd8;
            G_sharp: 	piano_note <= 4'd9;
            A: 	        piano_note <= 4'd10;
            A_sharp: 	piano_note <= 4'd11;
            B: 	        piano_note <= 4'd12;
            
            default: 	piano_note <= 4'd0;
        endcase
    end
endmodule
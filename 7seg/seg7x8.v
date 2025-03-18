`timescale 1ns / 1ps

module seg7x8(
    input clk,
    input resetn,
//    input en,
//    input [2:0] seg7id,
//    input [7:0] ascii,
    input [63:0] asciix8,
    output reg dp,
    output reg [6:0] seg,
    output reg [7:0] an
);

    // registering the 8x 7seg displays
    reg [63:0] ascii_reg;
    always @ (posedge clk) begin
        if (!resetn) begin
            ascii_reg <= 64'h0;
        end
//        else if (en) begin
//            case (seg7id)
//                0: ascii_reg[8*0 +: 8] <= ascii;
//                1: ascii_reg[8*1 +: 8] <= ascii;
//                2: ascii_reg[8*2 +: 8] <= ascii;
//                3: ascii_reg[8*3 +: 8] <= ascii;
//                4: ascii_reg[8*4 +: 8] <= ascii;
//                5: ascii_reg[8*5 +: 8] <= ascii;
//                6: ascii_reg[8*6 +: 8] <= ascii;
//                7: ascii_reg[8*7 +: 8] <= ascii;
//                default: ascii_reg[8*0 +: 8] <= 0;
//            endcase
//        end
        else begin
            ascii_reg <= asciix8;
        end
    end

    // Scanning through each 7seg displays one at a time
    // Each 7seg display is on for 1/8-th of the time
    //   but the values change so fast that we perceive them as on
    wire [2:0] s;	 
    reg [19:0] clkdiv;
    wire [7:0] aen;
    assign s = clkdiv[19:17];
    assign aen = 8'b11111111; // all turned off initially

    always @ (posedge clk) begin
        clkdiv <= clkdiv + 1;
    end
    
    always @ (*) begin
        an = 8'b11111111;
        if (aen[s] == 1)
            an[s] = 0;
    end

    // Outputting the current 7seg display
    reg [7:0] ascii_display;
    wire [7:0] dp_seg;

    always @ (posedge clk) begin
        case (s)
            0: ascii_display = ascii_reg[8*0 +: 8];
            1: ascii_display = ascii_reg[8*1 +: 8];
            2: ascii_display = ascii_reg[8*2 +: 8];
            3: ascii_display = ascii_reg[8*3 +: 8];
            4: ascii_display = ascii_reg[8*4 +: 8];
            5: ascii_display = ascii_reg[8*5 +: 8];
            6: ascii_display = ascii_reg[8*6 +: 8];
            7: ascii_display = ascii_reg[8*7 +: 8];
            default: ascii_display = ascii_reg[8*0 +: 8] <= 0;
        endcase
    end

    ascii2hex a2h(
        .ascii(ascii_display),
        .dp_7seg(dp_seg)
    );
    
    always @ (*) begin
        seg <= dp_seg[6:0];
        dp <= dp_seg[7];
    end

endmodule


module ascii2hex (
    input [7:0] ascii,
    output reg [7:0] dp_7seg
);
    // dp_7seg[7:0] <- DP-G-F-E-D-C-B-A
    //       A
    //      ---
    //   F |   | B
    //      ---  G
    //   E |   | C
    //      --- * DP
    //       D

    // ASCII hex values taken from the project below
    // Modifications: inverted bits, added hex key-value

    /*
    *  Project     Segmented LED Display - ASCII Library
    *  @author     David Madison
    *  @link       github.com/dmadison/Segmented-LED-Display-ASCII
    *  @license    MIT - Copyright (c) 2017 David Madison
    */

    always @ (*) begin
        case (ascii)
            'h20: dp_7seg = 8'b11111111; /* (space) */
            'h21: dp_7seg = 8'b01111001; /* ! */
            'h22: dp_7seg = 8'b11011101; /* " */
            'h23: dp_7seg = 8'b10000001; /* # */
            'h24: dp_7seg = 8'b10010010; /* $ */
            'h25: dp_7seg = 8'b00101101; /* % */
            'h26: dp_7seg = 8'b10111001; /* & */
            'h27: dp_7seg = 8'b11011111; /* ' */
            'h28: dp_7seg = 8'b11010110; /* ( */
            'h29: dp_7seg = 8'b11110100; /* ) */
            'h2A: dp_7seg = 8'b11011110; /* * */
            'h2B: dp_7seg = 8'b10001111; /* + */
            'h2C: dp_7seg = 8'b11101111; /* , */
            'h2D: dp_7seg = 8'b10111111; /* - */
            'h2E: dp_7seg = 8'b01111111; /* . */
            'h2F: dp_7seg = 8'b10101101; /* / */
            'h30: dp_7seg = 8'b11000000; /* 0 */
            'h31: dp_7seg = 8'b11111001; /* 1 */
            'h32: dp_7seg = 8'b10100100; /* 2 */
            'h33: dp_7seg = 8'b10110000; /* 3 */
            'h34: dp_7seg = 8'b10011001; /* 4 */
            'h35: dp_7seg = 8'b10010010; /* 5 */
            'h36: dp_7seg = 8'b10000010; /* 6 */
            'h37: dp_7seg = 8'b11111000; /* 7 */
            'h38: dp_7seg = 8'b10000000; /* 8 */
            'h39: dp_7seg = 8'b10010000; /* 9 */
            'h3A: dp_7seg = 8'b11110110; /* : */
            'h3B: dp_7seg = 8'b11110010; /* ; */
            'h3C: dp_7seg = 8'b10011110; /* < */
            'h3D: dp_7seg = 8'b10110111; /* = */
            'h3E: dp_7seg = 8'b10111100; /* > */
            'h3F: dp_7seg = 8'b00101100; /* ? */
            'h40: dp_7seg = 8'b10100000; /* @ */
            'h41: dp_7seg = 8'b10001000; /* A */
            'h42: dp_7seg = 8'b10000011; /* B */
            'h43: dp_7seg = 8'b11000110; /* C */
            'h44: dp_7seg = 8'b10100001; /* D */
            'h45: dp_7seg = 8'b10000110; /* E */
            'h46: dp_7seg = 8'b10001110; /* F */
            'h47: dp_7seg = 8'b11000010; /* G */
            'h48: dp_7seg = 8'b10001001; /* H */
            'h49: dp_7seg = 8'b11001111; /* I */
            'h4A: dp_7seg = 8'b11100001; /* J */
            'h4B: dp_7seg = 8'b10001010; /* K */
            'h4C: dp_7seg = 8'b11000111; /* L */
            'h4D: dp_7seg = 8'b11101010; /* M */
            'h4E: dp_7seg = 8'b11001000; /* N */
            'h4F: dp_7seg = 8'b11000000; /* O */
            'h50: dp_7seg = 8'b10001100; /* P */
            'h51: dp_7seg = 8'b10010100; /* Q */
            'h52: dp_7seg = 8'b11001100; /* R */
            'h53: dp_7seg = 8'b10010010; /* S */
            'h54: dp_7seg = 8'b10000111; /* T */
            'h55: dp_7seg = 8'b11000001; /* U */
            'h56: dp_7seg = 8'b11000001; /* V */
            'h57: dp_7seg = 8'b11010101; /* W */
            'h58: dp_7seg = 8'b10001001; /* X */
            'h59: dp_7seg = 8'b10010001; /* Y */
            'h5A: dp_7seg = 8'b10100100; /* Z */
            'h5B: dp_7seg = 8'b11000110; /* [ */
            'h5C: dp_7seg = 8'b10011011; /* \ */
            'h5D: dp_7seg = 8'b11110000; /* ] */
            'h5E: dp_7seg = 8'b11011100; /* ^ */
            'h5F: dp_7seg = 8'b11110111; /* _ */
            'h60: dp_7seg = 8'b11111101; /* ` */
            'h61: dp_7seg = 8'b10100000; /* a */
            'h62: dp_7seg = 8'b10000011; /* b */
            'h63: dp_7seg = 8'b10100111; /* c */
            'h64: dp_7seg = 8'b10100001; /* d */
            'h65: dp_7seg = 8'b10000100; /* e */
            'h66: dp_7seg = 8'b10001110; /* f */
            'h67: dp_7seg = 8'b10010000; /* g */
            'h68: dp_7seg = 8'b10001011; /* h */
            'h69: dp_7seg = 8'b11101111; /* i */
            'h6A: dp_7seg = 8'b11110011; /* j */
            'h6B: dp_7seg = 8'b10001010; /* k */
            'h6C: dp_7seg = 8'b11001111; /* l */
            'h6D: dp_7seg = 8'b11101011; /* m */
            'h6E: dp_7seg = 8'b10101011; /* n */
            'h6F: dp_7seg = 8'b10100011; /* o */
            'h70: dp_7seg = 8'b10001100; /* p */
            'h71: dp_7seg = 8'b10011000; /* q */
            'h72: dp_7seg = 8'b10101111; /* r */
            'h73: dp_7seg = 8'b10010010; /* s */
            'h74: dp_7seg = 8'b10000111; /* t */
            'h75: dp_7seg = 8'b11100011; /* u */
            'h76: dp_7seg = 8'b11100011; /* v */
            'h77: dp_7seg = 8'b11101011; /* w */
            'h78: dp_7seg = 8'b10001001; /* x */
            'h79: dp_7seg = 8'b10010001; /* y */
            'h7A: dp_7seg = 8'b10100100; /* z */
            'h7B: dp_7seg = 8'b10111001; /* { */
            'h7C: dp_7seg = 8'b11001111; /* | */
            'h7D: dp_7seg = 8'b10001111; /* } */
            'h7E: dp_7seg = 8'b11111110; /* ~ */
            'h7F: dp_7seg = 8'b11111111; /* (del) */
            
            default: dp_7seg = 8'b11111111;
        endcase
    end

endmodule

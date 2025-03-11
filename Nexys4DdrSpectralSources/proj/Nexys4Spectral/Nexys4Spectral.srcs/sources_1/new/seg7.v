`timescale 1ns / 1ps

module bin2bcd(
    input [8:0] binary,
    output reg [11:0] bcd
);
    integer i,j;
    
    always @(binary) begin
        for(i = 0; i <= 11; i = i + 1) bcd[i] = 0;
        bcd[8:0] = binary;
        for(i = 0; i <= 5; i = i + 1)
            for(j = 0; j <= i/3; j = j + 1)
                if(bcd[9-i+4*j -: 4] > 4)
                    bcd[9-i+4*j -: 4] = bcd[9-i+4*j -: 4] + 4'b11;
    end
endmodule

module seg7Ctrl(
    input ck25MHz,
    input [8:0] maxFreq,
    output reg [6:0] seg,
    output reg [2:0] an
    );
    
    reg [11:0] prev_bcd;
    wire [11:0] new_bcd;
    reg [3:0] digit;
    integer digit_num, counter;
    
    bin2bcd conv(.binary(maxFreq), .bcd(new_bcd));
        
    initial begin
        counter = 1;
        digit_num = 0;
        an = 3'b111;
        prev_bcd = new_bcd;
    end
    
    always @(posedge ck25MHz) begin
        counter <= counter + 1;
        if(counter > 125000) begin
            counter <= 0;
            case(digit_num)
                0: begin
                    an = 3'b110;
                    digit = prev_bcd[3:0];
                   end
                1: begin
                    an = 3'b101;
                    digit = prev_bcd[7:4];
                   end
                2: begin
                    an = 3'b011;
                    digit = prev_bcd[11:8];
                   end
                default: begin
                    an = 3'b111;
                    digit = 10;
                end
            endcase
            case(digit)
                0: seg <= 7'b1000000;
                1: seg <= 7'b1111001;
                2: seg <= 7'b0100100;
                3: seg <= 7'b0110000;
                4: seg <= 7'b0011001;
                5: seg <= 7'b0010010;
                6: seg <= 7'b0000010;
                7: seg <= 7'b1111000;
                8: seg <= 7'b0000000;
                9: seg <= 7'b0010000;
                default: seg <= 7'b1111111;
            endcase
            if(digit_num == 2) begin
                prev_bcd <= new_bcd;
                digit_num <= 0;
            end
            else begin
                digit_num <= digit_num + 1;
            end
        end
    end
    
endmodule

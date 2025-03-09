`timescale 1ns / 1ns

module piano_note_tb();
    
    reg clk;
    initial begin
        clk = 0;
        forever begin
            #5 clk = ~clk;
        end
    end
    
    reg resetn;
    reg [3:0] volume;
    reg [2:0] octave;
    reg key_press;
    wire out_pwm;
    initial resetn = 1'b1;
    initial volume = 4'b1111;
                
    piano_note #(.BASE_CLK_PER_PERIOD(63)) p0(  // C1
        .clk(clk),
        .resetn(resetn),
        .volume(volume),
        .octave(octave),
        .key_press(key_press),
        .output_pwm(out_pwm)
    );
                
    initial begin
        volume = 4'b1111;
        octave = 3'd0;
        key_press = 1'b0;
        #20;
        
        // initial reset
        resetn = 1'b0; #3; resetn = 1'b1;
        
        // change octaves
        octave = 3'd1;
        #40;
        
        octave = 3'd2;
        #40;
        
        // Start playing
        key_press = 1'b1;
        #40;
        
        octave = 3'd3;
        #300;
        
        // change volume
        volume = 4'b1101;   // even lower volume (12.5% duty cycle)
        #40;
        
        // Stop playing
        key_press = 1'b0;
        #200;
        $stop;
    end
endmodule

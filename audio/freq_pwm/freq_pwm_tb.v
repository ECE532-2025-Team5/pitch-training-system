`timescale 1ns / 1ns

module freq_pwm_tb();
    
    reg clk;
    initial begin
        clk = 0;
        forever begin
            #5 clk = ~clk;
        end
    end
    
    reg resetn;
    reg new_period;
    reg [31:0] note;
    reg [3:0] volume;
    wire out_pwm;
    initial resetn = 1'b1;
    initial note = 32'h0000000F;
    initial volume = 4'b1111;
    freq_pwm fN(.clk(clk),
                .resetn(resetn),
                .new_period(new_period),
                .clks_per_period(note),
                .volume(volume),
                .out_pwm(out_pwm));
                
    initial begin
        note = 32'h0000000F;
        volume = 4'b1111;
        #20;
        
        // initial reset
        resetn = 1'b0; #10; resetn = 1'b1;
        
        // new note
        note = 32'h0000000F;
        volume = 4'b1111;   // full volume (50% duty cycle)
        new_period = 1'b1; #10; new_period = 1'b0;
        #1000;
        
        // new volume
        volume = 4'b1110;   // lower volume (25% duty cycle)
        #1000;
        
        volume = 4'b1101;   // even lower volume (12.5% duty cycle)
        #1000;
        
        // new note
        note = 32'h0000003F;
        new_period = 1'b1; #10; new_period = 1'b0;
        #1000;
        
        // zero note
        note = 32'h00000000;
        new_period = 1'b1; #10; new_period = 1'b0;
        #1000;
        
        // new note
        note = 32'h0000000F;
        new_period = 1'b1; #10; new_period = 1'b0;
        #1000;
        
        // reset
        resetn = 1'b0; #10; resetn = 1'b1;
        #1000;
        
        // new volume
        volume = 4'b1111;
        new_period = 1'b1; #10; new_period = 1'b0;
        #1000;
    end
endmodule

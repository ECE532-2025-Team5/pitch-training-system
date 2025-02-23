`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Digilent Inc.
// Engineer: Thomas Kappenman
// 
// Create Date: 03/03/2015 09:06:31 PM
// Design Name: 
// Module Name: top
// Project Name: Nexys4DDR Keyboard Demo
// Target Devices: Nexys4DDR
// Tool Versions: 
// Description: This project takes keyboard input from the PS2 port,
//  and outputs the keyboard scan code to the 7 segment display on the board.
//  The scan code is shifted left 2 characters each time a new code is
//  read.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module keyboard_ps2(
    input CLK100MHZ,
    input PS2_CLK,
    input PS2_DATA,
    input CPU_RESETN,
//    output UART_TXD,
    output [6:0] SEG7_SEG,
    output [7:0] SEG7_AN,
    output SEG7_DP
    );
    
    reg CLK50MHZ=0;        
    always @(posedge CLK100MHZ)begin
        CLK50MHZ<=~CLK50MHZ;
    end

    wire [15:0] keycode;
    ps2 kb0(
        .clk(CLK50MHZ),
        .resetn(CPU_RESETN),
        .ps2_clk(PS2_CLK),
        .ps2_data(PS2_DATA),
        .keycode(keycode)
    );
    
    // New Key Detection
    reg [7:0] prev_key_code = 8'b0;  // Stores last pressed keycode
    reg key_released = 1'b1;         // Flag to track if key was released
    reg new_key_pressed;

    wire [7:0] break_code = keycode[15:8];  // Break code part
    wire [7:0] key_code = keycode[7:0];    // Make code part

    always @(posedge CLK50MHZ) begin
        new_key_pressed <= 1'b0; // Default low (ensures 1-cycle pulse)

        if (break_code == 8'hF0) begin
            // Key release detected
            key_released <= 1'b1;
        end
        else if ((key_code != prev_key_code) || key_released) begin
            // New key detected OR same key but was released before
            new_key_pressed <= 1'b1;
            prev_key_code <= key_code;
            key_released <= 1'b0; // Key is now pressed
        end
    end
    
    // PS/2 Code to ASCII Conversion
    wire [7:0] ascii;
    ps2_to_ascii conv0(
        .keycode(key_code),
        .ascii(ascii)
    );

    seg7x8 sevenSegDisp(
        .clk(CLK100MHZ),
        .resetn(CPU_RESETN),
        .en(new_key_pressed),
        .seg7id(3'h7),
        .ascii(ascii),
        .dp(SEG7_DP),
        .seg(SEG7_SEG[6:0]),
        .an(SEG7_AN[7:0])
    );
     
endmodule

//////////////////////////////////////////////////////////////////////////////////
// Author: Jovan Vukic

// Github: https://github.com/jovan-vukic/ps2-keyboard-interface/blob/main/src/simulation/modules/deb.v
//////////////////////////////////////////////////////////////////////////////////

module debouncer #(
    parameter WIDTH = 3
) (
    input  clk,
    input  resetn,
    input  in,
    output out
);

    /* output signal */
    reg out_next;
    reg out_reg; 
    assign out = out_reg;

    /* variables */
    reg [      1:0] ff_next, ff_reg;                                //previous (ff[1]) and current (ff[0]) values of the input
    reg [WIDTH-1:0] cnt_next, cnt_reg;                              //counts up to the 2**WIDTH - 1 at which point the input is stable

    assign in_changed = ff_reg[0] ^ ff_reg[1];                      //the input has changed
    assign in_stable  = (cnt_reg == {WIDTH{1'b1}}) ? 1'b1 : 1'b0;   //the input is stable

    /* sequential logic */
    always @(posedge clk, negedge resetn)
        if(!resetn) begin
            out_reg <= 1'b0;
            ff_reg  <= 2'b00;
            cnt_reg <= {WIDTH{1'b0}};
        end
        else begin
            out_reg <= out_next;
            ff_reg  <= ff_next;
            cnt_reg <= cnt_next;
        end

    /* combinational logic */
    always @(*) begin
        ff_next[0] = in;
        ff_next[1] = ff_reg[0];

        cnt_next = in_changed ? {WIDTH{1'b0}} : (cnt_reg + 1'b1);
        out_next = in_stable ? ff_reg[1] : out_reg;
    end

endmodule


//////////////////////////////////////////////////////////////////////////////////
// Author: Jovan Vukic
// Github: https://github.com/jovan-vukic/ps2-keyboard-interface/blob/main/src/simulation/modules/ps2.v
//
// Note:
//      Modified by Angus Wu to use the Digilent Seg_7_Display logic
//////////////////////////////////////////////////////////////////////////////////
module ps2 (
	input         clk,
	input         resetn,
	input         ps2_clk,
	input         ps2_data, //data sent from the keyboard
    output [15:0] keycode
);

	/* constants */
	localparam DEB_PARAMETER = 3;					//2^3 of the same values are enough for a stable signal

	localparam PARITY_REG_INITIAL_VALUE = 1'b1;			//the initial value for 'parity_reg' variable (odd parity)
	localparam ERROR_REG_INITIAL_VALUE  = 1'b0;			//the initial value for 'error_reg' variable
	localparam ERROR_OCCURED            = 1'b1;			//the value of 'error_reg' if there is an error in a package

	/* main variables */
	reg [10:0] package_reg, package_next;				//stores one whole package (STOP bit, PARITY bit, SCAN_CODE_BYTE[7:0] bits, START bit, respectively)
	reg [15:0] data_reg, data_next;					//stores the lowest two bytes of the scan code
	reg        parity_reg, parity_next;				//stores parity check result
	reg        error_reg, error_next;				//stores package error check result

	reg [3:0] cnt_reg, cnt_next;					//package bit counter (counts from 0 to 10)

	/* additional variables */
	reg ps2_clk_deb_previous_reg, ps2_clk_deb_previous_next;	//used for the ps2_clk_deb falling edge detection
	
	reg f0_flag_reg, f0_flag_next;					//indicates that the F0 byte has arrived
	reg e0_flag_reg, e0_flag_next;					//indicates that the E0 byte has arrived

	/* final state machine */
	localparam STATE_IDLE    = 1'b0;				//package is not being received
	localparam STATE_RECEIVE = 1'b1;				//package is being received

	reg state_reg, state_next;					//stores the current state

	/* displaying 'data_reg' on four 7SEG displays */
    assign keycode[15:0] = data_reg[15:0];

	/* debouncer */
	wire ps2_clk_deb;

	debouncer #(DEB_PARAMETER) deb_inst (
		.resetn(resetn),
		.clk(clk),
		.in(ps2_clk),
		.out(ps2_clk_deb)
	);
	
	/* sequential logic */
	always @ (posedge clk, negedge resetn) begin
		if (!resetn) begin
			package_reg <= 11'b0;
			data_reg    <= 15'b0;
			parity_reg  <= PARITY_REG_INITIAL_VALUE;
			error_reg   <= ERROR_REG_INITIAL_VALUE;

			cnt_reg   <= 4'b0;
			state_reg <= STATE_IDLE;

			ps2_clk_deb_previous_reg <= 1'b0; //the initial value of 'ps2_clk_deb' is 1'b0
			f0_flag_reg              <= 1'b0;
			e0_flag_reg              <= 1'b0;
		end
        else begin
			package_reg <= package_next;
			data_reg    <= data_next;
			parity_reg  <= parity_next;
			error_reg   <= error_next;

			cnt_reg   <= cnt_next;
			state_reg <= state_next;

			ps2_clk_deb_previous_reg <= ps2_clk_deb_previous_next;
			f0_flag_reg              <= f0_flag_next;
			e0_flag_reg              <= e0_flag_next;
		end
	end

	/* combinational logic */
	always @(*) begin
		/* latch prevention*/
		package_next = package_reg;
		data_next    = data_reg;
		parity_next  = parity_reg;
		error_next   = error_reg;

		cnt_next   = cnt_reg;
		state_next = state_reg;

		f0_flag_next = f0_flag_reg;
		e0_flag_next = e0_flag_reg;

		/* implementation logic */
		case (state_reg)
			STATE_IDLE : begin
				if (~ps2_clk_deb && ps2_clk_deb_previous_reg) begin					//falling edge detection
					package_next = { ps2_data, package_reg[10:1] };					//right shift ps2_data (START bit) into the 'package_next' variable

					/* preparation to receive a new package */
					parity_next = PARITY_REG_INITIAL_VALUE;
					error_next  = ERROR_REG_INITIAL_VALUE;

					cnt_next   = 4'd0;								//there are 10 bits left to read
					state_next = STATE_RECEIVE;							//transition to the new state
				end
			end

			STATE_RECEIVE : begin
				if (~ps2_clk_deb && ps2_clk_deb_previous_reg) begin					//falling edge detection
					package_next = { ps2_data, package_reg[10:1] };					//right shift ps2_data

					/* evaluate the final value of 'parity_reg' and 'error_reg' */
					if (cnt_reg <= 4'd7) parity_next = parity_reg ^ ps2_data;			//ps2_data == SCAN_CODE_BYTE[0:7] for cnt_reg == [0:7]
					else if (cnt_reg == 4'd8) begin							//ps2_data == PARITY bit for cnt_reg == 4'd8
						if (parity_reg != ps2_data)	error_next = ERROR_OCCURED;		//there is an error, the PARITY bit does not match
					end else begin									//ps2_data == STOP bit for cnt_reg == 4'd9
						if (package_next[0] != 1'b0 || package_next[10] != 1'b1)		//START bit != 0 or STOP bit != 1
							error_next = ERROR_OCCURED;
					end
					cnt_next = cnt_reg + 4'b1;							//updating the counter
				end

				/* after the new package has been received */
				if (cnt_next == 4'd10 && error_next != ERROR_OCCURED) begin				//MUST use cnt_next and error_next (not cnt_reg and error_reg)
					case (package_next[8:1])
						8'hF0 : f0_flag_next = 1'b1;						//do not insert the F0 byte immediately, just mark that it has arrived
						8'hE0 : e0_flag_next = 1'b1;						//do not insert the E0 byte immediately, just mark that it has arrived

						default : begin
							data_next = { data_reg[7:0], package_next[8:1] };		//by default just insert the next byte of the scan code

							/* improving the 7SEG display fluidity */
							if (data_reg[15:8] == 8'hF0 || data_reg[15:8] == 8'hE0)
								data_next = { 8'b0, package_next[8:1] };
							else if (data_reg[7:0] == package_next[8:1] && data_reg[7:0] != 8'b0)
								data_next = { 8'b0, package_next[8:1] };

							/* insert the marked F0/E0 byte and the one that just arrived */
							if (f0_flag_reg == 1'b1) begin
								data_next    = { 8'hF0, package_next[8:1] };
								f0_flag_next = 1'b0;					//clear the f0_flag
								e0_flag_next = 1'b0;					//necessary due to the situation when we receive E0 F0 respectively (example: [make: E0 14 | break: E0 F0 14])
							end else if (e0_flag_reg == 1'b1) begin
								data_next    = { 8'hE0, package_next[8:1] };
								e0_flag_next = 1'b0;					//clear the e0_flag
								f0_flag_next = 1'b0;
							end
						end
					endcase
				end

				if (cnt_next == 4'd10) state_next = STATE_IDLE;						//return to the idle state
			end
		endcase

		ps2_clk_deb_previous_next = ps2_clk_deb;
	end

endmodule
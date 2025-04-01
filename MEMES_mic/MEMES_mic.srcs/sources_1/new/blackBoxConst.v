`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/17 23:50:20
// Design Name: 
// Module Name: blackBoxConst
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module axi_constant_output #(
    parameter C_M_AXI_ADDR_WIDTH = 32,  // Address width
    parameter C_M_AXI_DATA_WIDTH = 32,  // Data width
    parameter [C_M_AXI_DATA_WIDTH-1:0] CONSTANT_VALUE = 32'hDEADBEEF  // Fixed output value
)(
    input wire  M_AXI_ACLK,        // AXI Clock
    input wire  M_AXI_ARESETN,     // Active low reset

    // Read Address Channel
    input wire  M_AXI_ARVALID,      // Read address valid
    input wire  [C_M_AXI_ADDR_WIDTH-1:0] M_AXI_ARADDR,  // Read address
    output reg  M_AXI_ARREADY,      // Read address ready

    // Read Data Channel
    output reg  M_AXI_RVALID,       // Read valid
    output reg  [C_M_AXI_DATA_WIDTH-1:0] M_AXI_RDATA,  // Read data
    output reg  [1:0] M_AXI_RRESP,  // Read response (OKAY)
    input wire  M_AXI_RREADY        // Read ready
);

// AXI Read FSM States
// Define states using parameters (Verilog syntax)
parameter IDLE = 2'b00;
parameter READ_WAIT = 2'b01;
parameter READ_RESPONSE = 2'b10;

reg [1:0] state;

// FSM Logic
always @(posedge M_AXI_ACLK) begin
    if (!M_AXI_ARESETN) begin
        // Reset state
        state <= IDLE;
        M_AXI_ARREADY <= 0;
        M_AXI_RVALID <= 0;
        M_AXI_RDATA <= 0;
        M_AXI_RRESP <= 2'b00; // OKAY Response
    end else begin
        case (state)
            IDLE: begin
                M_AXI_ARREADY <= 1; // Ready to receive read request
                M_AXI_RVALID <= 0;
                if (M_AXI_ARVALID) begin
                    state <= READ_WAIT;
                    M_AXI_ARREADY <= 0;
                end
            end
            READ_WAIT: begin
                state <= READ_RESPONSE;
            end
            READ_RESPONSE: begin
                M_AXI_RVALID <= 1;
                M_AXI_RDATA <= CONSTANT_VALUE; // Output the constant value
                M_AXI_RRESP <= 2'b00; // OKAY response

                if (M_AXI_RREADY) begin
                    M_AXI_RVALID <= 0;
                    state <= IDLE;
                end
            end
        endcase
    end
end

endmodule


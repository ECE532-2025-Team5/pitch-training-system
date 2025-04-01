module axi_constant_output #(
    parameter C_S_AXI_ADDR_WIDTH = 32,  // Address width
    parameter C_S_AXI_DATA_WIDTH = 32,  // Data width
    parameter [C_S_AXI_DATA_WIDTH-1:0] CONSTANT_VALUE = 32'h12345  // Fixed output value
)(
    input wire  S_AXI_ACLK,        // AXI Clock (slave)
    input wire  S_AXI_ARESETN,     // Active low reset (slave)

    // Read Address Channel (slave)
    input wire  S_AXI_ARVALID,      // Read address valid (slave)
    input wire  [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_ARADDR,  // Read address (slave)
    output reg  S_AXI_ARREADY,      // Read address ready (slave)

    // Read Data Channel (slave)
    output reg  S_AXI_RVALID,       // Read valid (slave)
    output reg  [C_S_AXI_DATA_WIDTH-1:0] S_AXI_RDATA,  // Read data (slave)
    output reg  [1:0] S_AXI_RRESP,  // Read response (OKAY) (slave)
    input wire  S_AXI_RREADY        // Read ready (master to slave)
);

// AXI Read FSM States
parameter IDLE = 2'b00;
parameter READ_WAIT = 2'b01;
parameter READ_RESPONSE = 2'b10;

reg [1:0] state;

// FSM Logic for AXI Slave
always @(posedge S_AXI_ACLK) begin
    if (!S_AXI_ARESETN) begin
        // Reset state and outputs
        state <= IDLE;
        S_AXI_ARREADY <= 0;
        S_AXI_RVALID <= 0;
        S_AXI_RDATA <= 0;
        S_AXI_RRESP <= 2'b00; // OKAY response
    end else begin
        case (state)
            IDLE: begin
                S_AXI_ARREADY <= 1; // Ready to receive read request
                S_AXI_RVALID <= 0;
                if (S_AXI_ARVALID) begin
                    state <= READ_WAIT;
                    S_AXI_ARREADY <= 0;
                end
            end
            READ_WAIT: begin
                state <= READ_RESPONSE;
            end
            READ_RESPONSE: begin
                S_AXI_RVALID <= 1;
                S_AXI_RDATA <= CONSTANT_VALUE; // Output the constant value
                S_AXI_RRESP <= 2'b00; // OKAY response
                if (S_AXI_RREADY) begin
                    S_AXI_RVALID <= 0;
                    state <= IDLE;
                end
            end
        endcase
    end
end

endmodule


`timescale 1 ns / 1 ps

`timescale 1 ns / 1 ps

module perif_constant_p_v1_0_S00_AXI #
(
    // Parameters of Axi Slave Bus Interface S00_AXI
    parameter integer C_S00_AXI_DATA_WIDTH = 32,
    parameter integer C_S00_AXI_ADDR_WIDTH = 4,
    // Constant output value to be read by the master
    parameter [C_S00_AXI_DATA_WIDTH-1:0] CONSTANT_VALUE = 32'h123456
)
(
    // Ports of Axi Slave Bus Interface S00_AXI
    input wire s00_axi_aclk,
    input wire s00_axi_aresetn,
    input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr,
    input wire [2 : 0] s00_axi_awprot,
    input wire s00_axi_awvalid,
    output wire s00_axi_awready,
    input wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata,
    input wire [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb,
    input wire s00_axi_wvalid,
    output wire s00_axi_wready,
    output wire [1 : 0] s00_axi_bresp,
    output wire s00_axi_bvalid,
    input wire s00_axi_bready,
    input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr,
    input wire [2 : 0] s00_axi_arprot,
    input wire s00_axi_arvalid,
    output wire s00_axi_arready,
    output wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata,
    output wire [1 : 0] s00_axi_rresp,
    output wire s00_axi_rvalid,
    input wire s00_axi_rready
);

    // AXI Read FSM States
    parameter IDLE = 2'b00;
    parameter READ_WAIT = 2'b01;
    parameter READ_RESPONSE = 2'b10;
    
    reg [1:0] state;
    reg s00_axi_arready_reg;
    reg s00_axi_rvalid_reg;
    reg [C_S00_AXI_DATA_WIDTH-1:0] s00_axi_rdata_reg;
    reg [1:0] s00_axi_rresp_reg;
    
    // FSM Logic for AXI Slave
    always @(posedge s00_axi_aclk) begin
        if (!s00_axi_aresetn) begin
            // Reset state and outputs
            state <= IDLE;
            s00_axi_arready_reg <= 0;
            s00_axi_rvalid_reg <= 0;
            s00_axi_rdata_reg <= 0;
            s00_axi_rresp_reg <= 2'b00; // OKAY response
        end else begin
            case (state)
                IDLE: begin
                    s00_axi_arready_reg <= 1; // Ready to receive read request
                    s00_axi_rvalid_reg <= 0;
                    if (s00_axi_arvalid) begin
                        state <= READ_WAIT;
                        s00_axi_arready_reg <= 0;
                    end
                end
                READ_WAIT: begin
                    state <= READ_RESPONSE;
                end
                READ_RESPONSE: begin
                    s00_axi_rvalid_reg <= 1;
                    s00_axi_rdata_reg <= CONSTANT_VALUE; // Output the constant value
                    s00_axi_rresp_reg <= 2'b00; // OKAY response
                    if (s00_axi_rready) begin
                        s00_axi_rvalid_reg <= 0;
                        state <= IDLE;
                    end
                end
            endcase
        end
    end
    
    // Assign AXI signals to the internal registers
    assign s00_axi_awready = 1'b0; // Slave doesn't support write address phase in this example
    assign s00_axi_wready = 1'b0;  // Slave doesn't support write data phase in this example
    assign s00_axi_bresp = 2'b00;  // OKAY response (as no write transaction happens)
    assign s00_axi_bvalid = 1'b0;  // No write valid signal since no writes are supported
    
    // Read-related signals for AXI slave interface
    assign s00_axi_arready = s00_axi_arready_reg;
    assign s00_axi_rdata = s00_axi_rdata_reg;
    assign s00_axi_rresp = s00_axi_rresp_reg;
    assign s00_axi_rvalid = s00_axi_rvalid_reg;

endmodule

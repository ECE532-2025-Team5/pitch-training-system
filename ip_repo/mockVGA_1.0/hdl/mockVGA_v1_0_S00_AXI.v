

`timescale 1 ns / 1 ps

module mockVGA_v1_0_S00_AXI #
(
    parameter integer C_S_AXI_DATA_WIDTH = 32,
    parameter integer C_S_AXI_ADDR_WIDTH = 4
)
(
    // AXI Slave Interface
    input wire s_axi_aclk,
    input wire s_axi_aresetn,
    
    // Write Address Channel
    input wire [C_S_AXI_ADDR_WIDTH-1 : 0] s_axi_awaddr,
    input wire s_axi_awvalid,
    output wire s_axi_awready,
    
    // Write Data Channel
    input wire [C_S_AXI_DATA_WIDTH-1 : 0] s_axi_wdata,
    input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] s_axi_wstrb,
    input wire s_axi_wvalid,
    output wire s_axi_wready,
    
    // Write Response Channel
    output wire [1 : 0] s_axi_bresp,
    output wire s_axi_bvalid,
    input wire s_axi_bready,
    
    // Read Address Channel
    input wire [C_S_AXI_ADDR_WIDTH-1 : 0] s_axi_araddr,
    input wire s_axi_arvalid,
    output wire s_axi_arready,
    
    // Read Data Channel
    output wire [C_S_AXI_DATA_WIDTH-1 : 0] s_axi_rdata,
    output wire [1 : 0] s_axi_rresp,
    output wire s_axi_rvalid,
    input wire s_axi_rready
);

    // Internal Registers
    reg [0:0] stored_value;  // Only stores 0 or 1
    reg s_axi_awready_reg, s_axi_wready_reg, s_axi_bvalid_reg;
    reg [1:0] s_axi_bresp_reg;
    reg s_axi_arready_reg, s_axi_rvalid_reg;
    reg [C_S_AXI_DATA_WIDTH-1:0] s_axi_rdata_reg;
    reg [1:0] s_axi_rresp_reg;
    
    // Write FSM
    always @(posedge s_axi_aclk) begin
        if (!s_axi_aresetn) begin
            stored_value <= 1'b0;  // Reset to 0
            s_axi_awready_reg <= 0;
            s_axi_wready_reg <= 0;
            s_axi_bvalid_reg <= 0;
            s_axi_bresp_reg <= 2'b00; // OKAY response
        end else begin
            if (s_axi_awvalid && s_axi_wvalid && !s_axi_bvalid_reg) begin
                stored_value <= s_axi_wdata[0]; // Store only LSB (0 or 1)
                s_axi_awready_reg <= 1;
                s_axi_wready_reg <= 1;
                s_axi_bvalid_reg <= 1;
                s_axi_bresp_reg <= 2'b00; // OKAY response
            end else begin
                s_axi_awready_reg <= 0;
                s_axi_wready_reg <= 0;
            end
            
            if (s_axi_bvalid_reg && s_axi_bready) begin
                s_axi_bvalid_reg <= 0; // Clear response
            end
        end
    end
    
    // Read FSM
    always @(posedge s_axi_aclk) begin
        if (!s_axi_aresetn) begin
            s_axi_arready_reg <= 0;
            s_axi_rvalid_reg <= 0;
            s_axi_rdata_reg <= 0;
            s_axi_rresp_reg <= 2'b00; // OKAY response
        end else begin
            if (s_axi_arvalid && !s_axi_rvalid_reg) begin
                s_axi_arready_reg <= 1;
                s_axi_rdata_reg <= {31'b0, stored_value}; // Return 0 or 1
                s_axi_rresp_reg <= 2'b00; // OKAY response
                s_axi_rvalid_reg <= 1;
            end else begin
                s_axi_arready_reg <= 0;
            end
    
            if (s_axi_rvalid_reg && s_axi_rready) begin
                s_axi_rvalid_reg <= 0; // Clear response
            end
        end
    end
    
    // Assign Output Signals
    assign s_axi_awready = s_axi_awready_reg;
    assign s_axi_wready = s_axi_wready_reg;
    assign s_axi_bresp = s_axi_bresp_reg;
    assign s_axi_bvalid = s_axi_bvalid_reg;
    assign s_axi_arready = s_axi_arready_reg;
    assign s_axi_rdata = s_axi_rdata_reg;
    assign s_axi_rresp = s_axi_rresp_reg;
    assign s_axi_rvalid = s_axi_rvalid_reg;

endmodule

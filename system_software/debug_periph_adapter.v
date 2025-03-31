`timescale 1ns / 1ps

module debug_periph_adapter (
    input [15:0] SW,
    output [3:0] sw_15_12,
    output [11:0] sw_11_0
);

    assign {sw_15_12, sw_11_0} = SW;

endmodule
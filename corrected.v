module microphone(
   input      clk,
   input      rst,
   input      sd_sw,   // a switch to control the amplifier
   
   // Port to microphone
   output reg MIC_CLK,
   input      MIC_DATA,
   output reg MIC_LR_SEL,
   
   // Port to mono audio output
   output reg AUD_PWM,
   output reg AUD_SD
);
reg audio;
// Generate 2.5MHz to MIC_CLK, and rising edge detection
reg [7:0] MIC_CLK_count;
reg       MIC_CLK_d;
wire      MIC_CLK_posedge;
always @(posedge clk or posedge rst) begin
    if(rst) begin
        MIC_CLK <= 1'b0;
        MIC_CLK_count <= 8'd0;
    end
    else if(MIC_CLK_count < 8'd19) begin
        MIC_CLK_count <= MIC_CLK_count + 8'd1;
    end
    else begin
        MIC_CLK <= ~MIC_CLK;
        MIC_CLK_count <= 8'd0;
    end
end

always @(posedge clk) begin
    MIC_CLK_d <= MIC_CLK;
end
assign MIC_CLK_posedge = ({MIC_CLK_d, MIC_CLK}==2'b01) ? 1'b1 : 1'b0;

//20 counters that outputs PDM to PWM counting alternatively to output at a frequency of 5.12 us 
//while PDM full count finished at 51.2 us
reg [7:0] PDM_counter;
always @(posedge clk or posedge rst) begin
    if(rst) begin
        PDM_counter <= 8'd0;
    end
    else if(MIC_CLK_posedge) begin
        if(PDM_counter == 8'd127) begin
            PDM_counter <= 8'd0;
        end
        else begin
            PDM_counter <= PDM_counter + 8'd1;
        end
    end
end

wire [7:0] PWM1_ouput,PWM2_ouput,PWM3_ouput,PWM4_ouput,PWM5_ouput,PWM6_ouput;
wire [7:0] PWM7_ouput,PWM8_ouput,PWM9_ouput,PWM10_ouput;
wire [7:0] PWM11_ouput,PWM12_ouput,PWM13_ouput,PWM14_ouput,PWM15_ouput,PWM16_ouput;
wire [7:0] PWM17_ouput,PWM18_ouput,PWM19_ouput,PWM20_ouput;
    
    TenPWMcounters firstTen (    
    .clk(clk),
    .mic_clk_pos(MIC_CLK_posedge),
    .reset(rst),
    .threshold1(8'd0),
    .threshold2(8'd6),
    .threshold3(8'd12),
    .threshold4(8'd19),
    .threshold5(8'd25),
    .threshold6(8'd32),
    .threshold7(8'd38),
    .threshold8(8'd44),
    .threshold9(8'd51),
    .threshold10(8'd57),
    .PDM_counter(PDM_counter),
    .mic_data(MIC_DATA),
    .result1(PWM1_ouput),
    .result2(PWM2_ouput),
    .result3(PWM3_ouput),
    .result4(PWM4_ouput),
    .result5(PWM5_ouput),
    .result6(PWM6_ouput),
    .result7(PWM7_ouput),
    .result8(PWM8_ouput),
    .result9(PWM9_ouput),
    .result10(PWM10_ouput)
    );
    
TenPWMcounters secondTen (    
    .clk(clk),
    .mic_clk_pos(MIC_CLK_posedge),
    .reset(rst),
    .threshold1(8'd64),
    .threshold2(8'd70),
    .threshold3(8'd76),
    .threshold4(8'd83),
    .threshold5(8'd89),
    .threshold6(8'd96),
    .threshold7(8'd102),
    .threshold8(8'd108),
    .threshold9(8'd115),
    .threshold10(8'd121),
    .PDM_counter(PDM_counter),
    .mic_data(MIC_DATA),
    .result1(PWM11_ouput),
    .result2(PWM12_ouput),
    .result3(PWM13_ouput),
    .result4(PWM14_ouput),
    .result5(PWM15_ouput),
    .result6(PWM16_ouput),
    .result7(PWM17_ouput),
    .result8(PWM18_ouput),
    .result9(PWM19_ouput),
    .result10(PWM20_ouput)
    );

    reg [15:0] PWM_count;
    reg [15:0] PWM_duty;
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            PWM_count <= 16'd0;
            PWM_duty <= 16'h0;
            MIC_LR_SEL <= 1'b0;
        end
        else begin
            PWM_count <= (PWM_count == 16'd5119) ? 16'd0 : PWM_count + 16'd1; //5120 sample mic points
            case(PWM_count)
            16'd0    : begin PWM_duty <= PWM1_ouput << 2; end
            16'd240  : begin PWM_duty <= PWM2_ouput <<2; end
            16'd480 : begin PWM_duty <= PWM3_ouput <<2; end
            16'd760 : begin PWM_duty <= PWM4_ouput <<2; end
            16'd1000 : begin PWM_duty <= PWM5_ouput <<2; end
            16'd1280 : begin PWM_duty <= PWM6_ouput <<2; end
            16'd1520 : begin PWM_duty <= PWM7_ouput <<2; end
            16'd1760 : begin PWM_duty <=PWM8_ouput <<2; end
            16'd2040 : begin PWM_duty <= PWM9_ouput <<2; end
            16'd2280 : begin PWM_duty <= PWM10_ouput <<2; end
            16'd2560 : begin PWM_duty <= PWM11_ouput << 2; end
            16'd2800 : begin PWM_duty <= PWM12_ouput <<2; end
            16'd3040 : begin PWM_duty <= PWM13_ouput <<2; end
            16'd3320 : begin PWM_duty <= PWM14_ouput <<2; end
            16'd3560 : begin PWM_duty <= PWM15_ouput <<2; end
            16'd3840 : begin PWM_duty <= PWM16_ouput <<2; end
            16'd4080 : begin PWM_duty <= PWM17_ouput <<2; end
            16'd4320 : begin PWM_duty <= PWM18_ouput <<2; end
            16'd4600 : begin PWM_duty <= PWM19_ouput <<2; end
            16'd4840 : begin PWM_duty <=PWM20_ouput <<2; end
            endcase
        MIC_LR_SEL <= 1'b0;
        end
    end
    
    reg [15:0] PWM_sample;
    always @(posedge clk or posedge rst) begin
    if(rst) begin
        PWM_sample <= 16'd0;
    end
    else if(PWM_sample < 16'd512) begin
        PWM_sample <= PWM_sample + 16'd1;
    end
    else begin
        PWM_sample <= 16'd0;
    end
end

    always @(posedge clk or posedge rst) begin
    if(rst) begin
        audio <= 1'b0;
    end
    else begin
        if(PWM_sample<PWM_duty) begin
            audio <= 1'b1;
        end
        else begin
            audio <= 1'b0;
        end
    end
end
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            AUD_SD <= 1'b0;
            AUD_PWM <= 1'b0;
        end
        else begin
            AUD_SD <= sd_sw;
            AUD_PWM <= (audio) ? 1'bz : 1'b0;
        end
    end

endmodule    
    
module PWMcounter(
    input clk,
    input mic_clk_pos,
    input reset,
    input [7:0] threshold,
    input [7:0] PDM_counter,
    input mic_data,
    output reg [7:0] result
    );
    
    always @(posedge clk or posedge reset) begin //clk inclusion in case 
    //reset pressed when mic clk did not detect
        if (reset) begin 
            result <= 0;
        end
        else if(mic_clk_pos && PDM_counter == threshold) begin
            result <= mic_data;
        end
        else begin
            result <= (mic_data) ? result + 1 : result;
        end
    end
endmodule

module TenPWMcounters(
    input clk,
    input mic_clk_pos,
    input reset,
    input [7:0] threshold1,
    input [7:0] threshold2,
    input [7:0] threshold3,
    input [7:0] threshold4,
    input [7:0] threshold5,
    input [7:0] threshold6,
    input [7:0] threshold7,
    input [7:0] threshold8,
    input [7:0] threshold9,
    input [7:0] threshold10,
    input [7:0] PDM_counter,
    input mic_data,
    output wire [7:0] result1,
    output wire [7:0] result2,
    output wire [7:0] result3,
    output wire [7:0] result4,
    output wire [7:0] result5,
    output wire [7:0] result6,
    output wire [7:0] result7,
    output wire [7:0] result8,
    output wire [7:0] result9,
    output wire [7:0] result10
    );
    PWMcounter PWM1 (
    .clk(clk),
    .mic_clk_pos(mic_clk_pos),
    .reset(reset),
    .threshold(threshold1),
    .PDM_counter(PDM_counter),
    .mic_data(mic_data),
    .result(result1));
    
    PWMcounter PWM2 (
    .clk(clk),
    .mic_clk_pos(mic_clk_pos),
    .reset(reset),
    .threshold(threshold2),
    .PDM_counter(PDM_counter),
    .mic_data(mic_data),
    .result(result2));
    
    PWMcounter PWM3 (
    .clk(clk),
    .mic_clk_pos(mic_clk_pos),
    .reset(reset),
    .threshold(threshold3),
    .PDM_counter(PDM_counter),
    .mic_data(mic_data),
    .result(result3));
    
     PWMcounter PWM4 (
    .clk(clk),
    .mic_clk_pos(mic_clk_pos),
    .reset(reset),
    .threshold(threshold4),
    .PDM_counter(PDM_counter),
    .mic_data(mic_data),
    .result(result4));
    
    PWMcounter PWM5 (
    .clk(clk),
    .mic_clk_pos(mic_clk_pos),
    .reset(reset),
    .threshold(threshold5),
    .PDM_counter(PDM_counter),
    .mic_data(mic_data),
    .result(result5));
    
    PWMcounter PWM6 (
    .clk(clk),
    .mic_clk_pos(mic_clk_pos),
    .reset(reset),
    .threshold(threshold6),
    .PDM_counter(PDM_counter),
    .mic_data(mic_data),
    .result(result6));
    
    PWMcounter PWM7 (
    .clk(clk),
    .mic_clk_pos(mic_clk_pos),
    .reset(reset),
    .threshold(threshold7),
    .PDM_counter(PDM_counter),
    .mic_data(mic_data),
    .result(result7));
    
    PWMcounter PWM8 (
    .clk(clk),
    .mic_clk_pos(mic_clk_pos),
    .reset(reset),
    .threshold(threshold8),
    .PDM_counter(PDM_counter),
    .mic_data(mic_data),
    .result(result8));
    
    PWMcounter PWM9 (
    .clk(clk),
    .mic_clk_pos(mic_clk_pos),
    .reset(reset),
    .threshold(threshold9),
    .PDM_counter(PDM_counter),
    .mic_data(mic_data),
    .result(result9));
    
    PWMcounter PWM10 (
    .clk(clk),
    .mic_clk_pos(mic_clk_pos),
    .reset(reset),
    .threshold(threshold10),
    .PDM_counter(PDM_counter),
    .mic_data(mic_data),
    .result(result10));
endmodule


`default_nettype none

module spi_peripheral (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       sclk,
    input  wire       copi,
    input  wire       ncs,
    output reg  [7:0] en_reg_out_7_0,
    output reg  [7:0] en_reg_out_15_8,
    output reg  [7:0] en_reg_pwm_7_0,
    output reg  [7:0] en_reg_pwm_15_8,
    output reg  [7:0] pwm_duty_cycle
);

    localparam MAX_ADDRESS = 7'h04;

    // Synchronizers
    reg [2:0] sclk_sync;
    reg [2:0] ncs_sync;
    reg [1:0] copi_sync;

    always @(posedge clk  or negedge rst_n) begin
        if (!rst_n) begin
            sclk_sync <= 3'b000;
            ncs_sync <= 3'b111;
            copi_sync <= 2'b00;
        end else begin
            sclk_sync <= {sclk_sync[1:0], sclk};
            ncs_sync  <= {ncs_sync[1:0],  ncs};
            copi_sync <= {copi_sync[0],   copi};
        end
    end

    //Edge detection
    wire sclk_rise = (sclk_sync[2:1] == 2'b01);
    wire ncs_fall  = (ncs_sync[2:1] == 2'b10);
    wire ncs_rise  = (ncs_sync[2:1] == 2'b01);

    //Collect/Write bits
    reg [15:0] shift;
    reg [4:0]  bit_count;   

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            shift           <= 16'd0;
            bit_count       <= 5'd0;
            en_reg_out_7_0  <= 8'h00;
            en_reg_out_15_8 <= 8'h00;
            en_reg_pwm_7_0  <= 8'h00;
            en_reg_pwm_15_8 <= 8'h00;
            pwm_duty_cycle  <= 8'h00;
        end else if (ncs_fall) begin
            bit_count <= 5'd0;
            shift     <= 16'd0;
        end else if (sclk_rise && ncs_sync[1] == 1'b0) begin
            shift <= {shift[14:0], copi_sync[1]};
            bit_count <= bit_count + 1;
        end else if (ncs_rise && bit_count == 5'd16 && shift[15] == 1'b1 && shift[14:8] <= MAX_ADDRESS) begin
            case (shift[14:8])
                7'h00: en_reg_out_7_0  <= shift[7:0];
                7'h01: en_reg_out_15_8 <= shift[7:0];
                7'h02: en_reg_pwm_7_0  <= shift[7:0];
                7'h03: en_reg_pwm_15_8 <= shift[7:0];
                7'h04: pwm_duty_cycle <= shift[7:0];
                default: ;
            endcase
        end    
    end

endmodule
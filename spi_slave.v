module spi_slave(
    input  wire       spi_clk,
    input  wire       spi_cs,      
    input  wire       spi_mosi,
    output reg [7:0]  rx_data, 
    output reg        rx_valid 
);

    reg [2:0] bit_cnt;
    reg [7:0] shift_reg;

    always @(posedge spi_clk or posedge spi_cs) begin
        if (spi_cs) begin               
            bit_cnt  <= 3'd7;
            rx_valid <= 1'b0;
        end else 
            begin
             shift_reg[bit_cnt] <= spi_mosi;

            if (bit_cnt == 3'd0) begin
                rx_data  <= {shift_reg[7:1], spi_mosi};
                rx_valid <= 1'b1;
                bit_cnt  <= 3'd7;
            end else begin
                rx_valid <= 1'b0;
                bit_cnt  <= bit_cnt - 1;
            end
        end
    end

endmodule
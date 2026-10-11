`timescale 1ns / 1ps
module spi_top ( input wire clk, input wire rst_n, input wire [7:0] parallel_data, input wire data_valid, output wire [7:0] received_data, output wire received_valid );
wire spi_cs; 
wire spi_clk; 
wire spi_mosi; 
  spi_master u_master ( .clk(clk), .rst_n(rst_n), .parallel_data(parallel_data), .data_valid(data_valid), .spi_cs(spi_cs), .spi_clk(spi_clk), .spi_mosi(spi_mosi) ); 
   spi_slave u_slave ( .spi_clk(spi_clk), .spi_cs(spi_cs), .spi_mosi(spi_mosi), .rx_data(received_data), .rx_valid(received_valid) );
 endmodule
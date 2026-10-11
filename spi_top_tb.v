`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.10.2026 19:47:35
// Design Name: 
// Module Name: spi_top_tb
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


module spi_top_tb;

    reg clk, rst_n;
    reg [7:0] parallel_data;
    reg data_valid;
    wire [7:0] received_data;
    wire received_valid;

    spi_top dut (
        .clk(clk), .rst_n(rst_n),
        .parallel_data(parallel_data),
        .data_valid(data_valid),
        .received_data(received_data),
        .received_valid(received_valid)
    );

    always #5 clk = ~clk;

    initial begin
        clk          = 0;
        rst_n        = 0;
        data_valid   = 0;
        parallel_data = 8'h00;

        #20 rst_n = 1;
        #20;

        parallel_data = 8'hAA;  
        data_valid    = 1;
        #10 data_valid = 0;

   
        wait(received_valid);
        #10; 

        $display("Sent Data     = %h", 8'hAA);
        $display("Received Data = %h", received_data);

        if (received_data == 8'hAA)
            $display(" PASS");
        else
            $display(" FAIL - mismatch!");

        #100 $finish;
    end

endmodule
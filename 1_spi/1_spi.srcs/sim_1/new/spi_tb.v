`timescale 1ns / 1ns

module spi_tb();
reg clk;
reg reset_n;
reg en;
wire out;
wire busy;
wire done;
wire cs;
reg [3:0]tx_data;
wire[3:0]rx_data;
wire MOSI;
reg MISO;
parameter copl = 0;
parameter cpha = 1;
spi_diver
#(
    .COPL(copl),
    .CPHA(cpha)
)
spi
(
        .i_sys_clk(clk)                                 ,
        .i_reset_n(reset_n)                             ,
        .tx_data(tx_data)                                    ,
        .rx_data(rx_data)                               ,
        .spi_en(en)                                     ,
        .spi_busy(busy)                                   ,
        .spi_done(done)                                   ,

        .CS(cs)                                        ,                         
        .MOSI(MOSI)                                       ,
        .MISO(MISO)                                         ,
        .SCK(out)   
);

initial clk = 1;
always #10 clk = !clk;
initial begin
reset_n = 0;
tx_data = {4'b1111};
MISO = 1;
#201;
reset_n = 1;
en = 1;
#200;
en = 0;
#2000_000;
tx_data = {4'b1010};
en = 1;
#200;
en = 0;
end



endmodule

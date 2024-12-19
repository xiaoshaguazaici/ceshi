`timescale 1ns / 1ns

module spi_tb();
reg clk;
reg reset_n;
reg en;
wire out;
wire busy;
wire done;
wire cs;
reg [48:0]tx_data;
wire[48:0]rx_data;
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
tx_data = {8'h06,1'b0,8'h02,24'h000000,8'h00};
MISO = 1;
#201;
reset_n = 1;
en = 1;
#200;
en = 0;

end



endmodule

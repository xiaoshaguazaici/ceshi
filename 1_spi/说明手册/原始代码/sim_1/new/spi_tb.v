`timescale 1ns / 1ns

module spi_tb();
reg clk;
reg reset_n;
reg en;
wire out;
wire busy;
wire done;
wire cs;
reg [7:0]tx_data;
wire[7:0]rx_data;
wire MOSI;
reg MISO;
parameter copl = 0;
spi_diver
#(
    .COPL(copl)
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
tx_data = 8'b10101010;
MISO = 1;
#201;
reset_n = 1;
en = 1;
#200;
en = 0;

end



endmodule

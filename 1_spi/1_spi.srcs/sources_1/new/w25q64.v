module w25q64(
    input key,
    input sys_clk,
    input reset_n,
    
    output CS,
    output SCK,
    output MOSI
    );
wire reset_flag;
key_filter key_filter(
    .clk(sys_clk),
    .reset_n(reset_n),
    .in(key),
    .out(),
    //???????????§Û????????????????????¦Ë
    .press_flag(),
    .reset_flag(reset_flag)
);
parameter COPL = 0;
reg [48:0]data = {8'h06,1'b0,8'h02,24'h000000,8'h01};
spi_diver
#(
    .COPL(COPL)
)
spi(
        .i_sys_clk(sys_clk)                                 ,
        .i_reset_n(reset_n)                                 ,
        
        .tx_data(data)             ,
        .rx_data()         ,
        .spi_en(reset_flag)                                    ,
        .spi_busy()                             ,
        .spi_done()                             ,

        .CS(CS)                                   ,                     
        .MOSI(MOSI)                                 ,
        .MISO()                                     ,
        .SCK(SCK)    
);
endmodule

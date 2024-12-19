`timescale 1ns / 1ns

module w25q64_tb();
reg key;
reg sys_clk;
reg reset_n;
wire CS;
wire SCK;
wire MOSI;
w25q64 w25q64(
    .key(key),
    .sys_clk(sys_clk),
    .reset_n(reset_n),
    
    .CS(CS),
    .SCK(SCK),
    .MOSI(MOSI)
);
initial sys_clk = 1;
always #10 sys_clk = !sys_clk;
initial begin
reset_n = 0;
#200;
reset_n = 1;
key = 1;
#201;
key = 0;
#200_000_000;
key = 1;
end
endmodule

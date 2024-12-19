//????

module key_filter#(
    parameter time_delay = 1000_000,
    parameter free = 0,
    parameter p_filter = 1,
    parameter press = 2,
    parameter r_filter = 3
)
(
    input clk,
    input reset_n,
    input in,
    output reg out,
    //???????????§Û????????????????????¦Ë
    output reg press_flag,
    output reg reset_flag
    );
//?????????????????????
reg [1:0]key_in;
always @(posedge clk) begin
    key_in <={key_in[0],in};
end
//??????????????
wire posedge_in;
wire negedge_in;

assign posedge_in = (key_in == 2'b01);   //?????¦Ë?????¦Ë?????????
assign negedge_in = (key_in == 2'b10);


//§Õ?????
reg[1:0]status;
        //??????????? 100*1000*10
    reg[19:0]cnt;

always @(posedge clk or negedge reset_n) begin
    if(!reset_n)begin
        out <= 1;
        cnt <= 0;
        status <= free;
        press_flag <= 0;
        reset_flag <= 0;

    end
    else begin
        case (status)

            free:begin
                reset_flag <= 0;
                if(negedge_in)
                    status <= p_filter;
                else
                    status <= free;
            end 
            p_filter:begin
                if(cnt == time_delay-1)begin
                    press_flag <= 1;
                    out <= 0;//////////////////////////////
                    status <= press;
                    cnt <= 0;
                end
                else if(cnt<time_delay-1 & posedge_in)begin
                    status <= free;
                    cnt <= 0;
                end
                else
                    cnt <= cnt+1;

            end
            press:begin
                press_flag <= 0;
                if(posedge_in)
                    status <= r_filter;
                else
                    status <= press;
            end 
            r_filter:begin
                 if(cnt == time_delay-1)begin
                    reset_flag <= 1;
                    out <= 1;////////////////////////////////
                    status <= free;
                    cnt <= 0;
                end
                else if(cnt<time_delay-1 & negedge_in)begin
                    status <= press;
                    cnt <= 0;
                end
                else
                    cnt <= cnt+1;               

            end 



            default: status <=free;
        endcase
    end

    
end


endmodule

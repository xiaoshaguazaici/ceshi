module spi_diver#(
        parameter TX_DATA_WIDTH = 49                     ,
        parameter RX_DATA_wIDTH = 49                     ,
        parameter COPL          = 0                     ,
        parameter CPHA          = 0
)(

        input i_sys_clk                                 ,
        input i_reset_n                                 ,
        
        input [TX_DATA_WIDTH -1 : 0]tx_data             ,
        output reg[RX_DATA_wIDTH -1 : 0]rx_data         ,
        input spi_en                                    ,
        output reg spi_busy                             ,
        output reg spi_done                             ,

        output reg CS                                   ,                     
        output reg MOSI                                 ,
        input  MISO                                     ,
        output SCK     
);


parameter clk_now = 50_000_000;
parameter clk_use = 50_0000;
localparam DIV_CNT_MAX = clk_now/clk_use;

reg [1:0] en_check;
wire en_process;
reg start_en;

reg [TX_DATA_WIDTH -1 : 0] tx_data_tem;

reg [19:0]div_cnt;
reg ro_SCK;

reg [1:0]EDGE;//01为第一个 ，10为第二个

reg [5:0]data_cnt;

reg [RX_DATA_wIDTH -1 : 0] rx_data_tem;


//0 en的识别 （一次使能跳变）
        always @(posedge i_sys_clk or negedge i_reset_n) begin
                if(!i_reset_n)
                        en_check <= 2'b0;
                else
                        en_check <={en_check[0],spi_en};
        end 
        assign en_process = en_check[1];

        always @(posedge i_sys_clk , negedge i_reset_n) begin
                if(!i_reset_n)
                        start_en <= 'd0;
                else if(en_process)
                        start_en <= 'd1;
                else
                        start_en <= 'd0;
        end

//1 数据缓存
        always @(posedge i_sys_clk , negedge i_reset_n) begin
                if(!i_reset_n)
                        tx_data_tem <= 'd0;
                else if(en_process)
                        tx_data_tem <= tx_data;
                else if(EDGE == 'd2 && data_cnt == TX_DATA_WIDTH -1)
                        tx_data_tem <= 'd0;
                else
                        tx_data_tem <= tx_data_tem;  
        end
//2 busy done cs 信号的提前给出（运行要靠这几个逻辑）
        ///busy信号
        always @(posedge i_sys_clk , negedge i_reset_n) begin
                if(!i_reset_n)
                        spi_busy <= 'd0;
                else if(start_en)
                        spi_busy <= 'd1;
                else if(EDGE == 'd2 && data_cnt == TX_DATA_WIDTH -1)
                        spi_busy <= 'd0;
                else
                        spi_busy <= spi_busy;
        end
        ///CS信号
        always @(posedge i_sys_clk , negedge i_reset_n) begin
                if(!i_reset_n)
                        CS <= 'd1;
                else if(start_en)
                        CS <= 'd0;
                //-----------------------------------------前8帧数据        
                else if(EDGE == 'd2 && data_cnt == 8 -1)
                        CS <= 'd1;
                else if(EDGE == 'd2 && data_cnt == 9 -1)
                        CS <= 'd0;
                //-----------------------------------------
                else if(EDGE == 'd2 && data_cnt == TX_DATA_WIDTH -1)
                        CS <= 'd1;
                else
                        CS <= CS;
        end 
        ///done信号
        always @(posedge i_sys_clk , negedge i_reset_n) begin
                if(!i_reset_n)
                        spi_done <= 'd0;
                else if(EDGE == 'd2 && data_cnt == TX_DATA_WIDTH -1)
                        spi_done <= 'd1;
                else
                        spi_done <= 'd0;
                
        end        

//3 分频器
        always @(posedge i_sys_clk , negedge i_reset_n) begin
                if(!i_reset_n)
                        div_cnt <= 'd0;
                else if(spi_busy)begin
                        if(div_cnt == DIV_CNT_MAX - 1)
                                div_cnt <= 'd0;
                        else if(EDGE == 'd2 && data_cnt == TX_DATA_WIDTH -1)//结束计数也要清零
                                div_cnt <= 'd0;
                        else
                                div_cnt <= div_cnt + 1;
                end
                else
                        div_cnt <= 'd0;

        end

//4 SCK生成
        always @(posedge i_sys_clk , negedge i_reset_n) begin
                if(!i_reset_n)
                        ro_SCK <= 0;
                else if(div_cnt < DIV_CNT_MAX/2)
                        ro_SCK <= 0;
                else
                        ro_SCK <= 1;
        end
        //CPOL的使用
        assign SCK = (COPL == 0)?(ro_SCK):(!ro_SCK);

//5 上升沿和下降沿时刻提前提取
         always @(posedge i_sys_clk , negedge i_reset_n) begin
                if(!i_reset_n)
                        EDGE <= 'd0;
                else if(div_cnt == DIV_CNT_MAX/2 - 1)
                        EDGE <= 'd1;
                else if(div_cnt == DIV_CNT_MAX - 1)
                        EDGE <= 'd2;
                else
                        EDGE <= 'd0;
                
        end       

//6 数据计数器data_cnt
        always @(posedge i_sys_clk , negedge i_reset_n) begin
                if(!i_reset_n)
                        data_cnt <= 'd0;
                else if(EDGE == 'd2)begin
                        if(data_cnt == TX_DATA_WIDTH -1)
                                data_cnt <= 'd0; 
                        else
                                data_cnt <= data_cnt + 1;                              
                end
                else
                        data_cnt <= data_cnt;
        end

      
//7 线性序列机 mosi 与miso
        ///mosi
        always @(posedge i_sys_clk , negedge i_reset_n) begin
                if(!i_reset_n)
                        MOSI <= 1'b0;
                else if(CPHA == 0)begin
                        if(start_en )
                                MOSI <= tx_data_tem[TX_DATA_WIDTH -1];  
                        else if(spi_busy && EDGE == 'd2)begin
                                if(EDGE == 'd2 && data_cnt == TX_DATA_WIDTH -1)
                                        MOSI <= 1'b0;
                                else
                                        MOSI <= tx_data_tem[TX_DATA_WIDTH -2-data_cnt]; 
                        end
                        else
                                MOSI <= MOSI;                
                end
                else if(CPHA == 1)begin
                        if(start_en )
                                MOSI <= 'd0;  
                        else if(spi_busy && EDGE == 'd1)begin
                                if(EDGE == 'd1 && data_cnt == TX_DATA_WIDTH -1)
                                        MOSI <= 1'b0;
                                else
                                        MOSI <= tx_data_tem[TX_DATA_WIDTH - 1 -data_cnt]; 
                        end
                        else
                                MOSI <= MOSI;   
                end



        end
        ///miso
        always @(posedge i_sys_clk , negedge i_reset_n) begin
                if(!i_reset_n)
                        rx_data_tem <= 'd0;
                else if(CPHA == 0)begin
                        if(spi_busy && EDGE == 'd1)
                                rx_data_tem[RX_DATA_wIDTH - 1 - data_cnt] <= MISO;
                        else if(EDGE == 'd2 && data_cnt == TX_DATA_WIDTH -1)
                                rx_data_tem <= 'd0;
                        else
                                rx_data_tem <= rx_data_tem;
                end
                else if(CPHA == 1)begin
                        if(spi_busy && EDGE == 'd2)
                                rx_data_tem[RX_DATA_wIDTH - 1 - data_cnt] <= MISO;
                        else if(EDGE == 'd2 && data_cnt == TX_DATA_WIDTH -1)
                                rx_data_tem <= 'd0;
                        else
                                rx_data_tem <= rx_data_tem;                        
                end

                
        end
        ///收数据缓存
        always @(posedge i_sys_clk , negedge i_reset_n) begin
                if(!i_reset_n)
                        rx_data <= 'd0;
                else if(EDGE == 'd2 && data_cnt == TX_DATA_WIDTH -1)
                        rx_data <= rx_data_tem;
                else
                        rx_data <= rx_data;
                
        end                

endmodule

/*
        always @(posedge i_sys_clk , negedge i_reset_n) begin
                if(!i_reset_n)
                        ;
                else if()
                        ;
                else if()

                else
                
        end
*/
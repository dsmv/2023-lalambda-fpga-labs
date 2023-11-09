
`default_nettype none 

module uart_mic
#(
    parameter               is_simulation=0
)
(
  
    input   wire            clk,
    input   wire            reset_p,

    input   wire [23:0]     data,
    input   wire            data_we,

    input   wire [23:0]     threshold_low,
    input   wire [23:0]     threshold_high,

    input   wire            uart_empty,
    input   wire            uart_full,
    input   wire            uart_done,
    output  reg             uart_tx_data_we,
    output  reg [7:0]       uart_tx_data

);

logic [4:0]     stp;
logic [11:0]    index_wr;

logic [3:0]     n_stp;
logic [10:0]    n_index_wr;
logic [3:0]     n_vsync_cnt;

logic           rstp;

logic           fifo_rstp;
logic           fifo_we;
logic           fifo_rd;
logic [23:0]    fifo_data_w;
logic [23:0]    fifo_data_r;
logic           fifo_empty;
logic           fifo_full; 
logic [11:0]    rd_cnt;
logic           start_wr;

logic [23:0]    data_z;
logic           data_we_z;

fifo_simple 
#(
    .FIFO_DEPTH         ( 2048 ),
    .FIFO_DATA_WIDTH    (   24  )
)
fifo
(
  .clk              (   clk         ),
  .clk_enable       (   1           ),
  .reset            (   fifo_rstp   ),

  .write            (   fifo_we     ),
  .read             (   fifo_rd     ),

  .write_data       (   fifo_data_w ),
  .read_data        (   fifo_data_r ),

  .empty            (   fifo_empty  ),
  .full             (   fifo_full   )
);

always_ff @(posedge clk) begin
    
    rstp <= #1 reset_p;

    if( data_we )
        data_z  <= #1 data;

    data_we_z <= #1 data_we;

    fifo_data_w <= #1 data_z;
    fifo_we <= #1 data_we_z & start_wr;


    // if( rstp ) begin
    //     stp <= #1 '0;
    //     index_wr <= #1 '0;
    //     rd_cnt <= #1 '0;
    // end else begin
    //     stp <= #1 n_stp;
    //     index_wr <= #1 n_index_wr;
    //     rd_cnt <= #1 n_rd_cnt;
    // end

    case( stp ) 

        0: begin
            fifo_rstp <= #1 1;
            rd_cnt <= #1 0;
            stp <= #1 1;
            start_wr <= #1 0;
            uart_tx_data_we <= #1 0;
            fifo_rd <= #1 0;

        end

        1: begin
            fifo_rstp <= #1 0;
            if( $signed(data_z)<$signed(threshold_low) )
                stp <= #1 2;
        end

        2: begin
            
            if( $signed(data_z)>$signed(threshold_high) ) begin
                stp <= #1 3;
                start_wr <= #1 1;
            end 
        end

        // синхробайт 0
        3: begin 
            uart_tx_data <= #1 16'hAA;
            if( uart_empty )
                stp <= #1 4;
        end

        4: begin
            uart_tx_data_we <= #1 1;
            stp <= #1 5;
        end

        5: begin
            uart_tx_data_we <= #1 0;
            stp <= #1 6;
        end

 
        // синхробайт 1
        6: begin 
            uart_tx_data <= #1 16'hBB;
            if( uart_empty )
                stp <= #1 7;
        end

        7: begin
            uart_tx_data_we <= #1 1;
            stp <= #1 8;
        end

        8: begin
            uart_tx_data_we <= #1 0;
            stp <= #1 9;
        end

        // синхробайт 2
        9: begin 
            uart_tx_data <= #1 16'hCC;
            if( uart_empty )
                stp <= #1 10;
        end

        10: begin
            uart_tx_data_we <= #1 1;
            stp <= #1 11;
        end

        11: begin
            uart_tx_data_we <= #1 0;
            if( ~fifo_empty )
                stp <= #1 12;
        end
        

        12: begin
            uart_tx_data <= #1 fifo_data_r[7:0];
            if( uart_empty )
                stp <= #1 13;
        end

        13: begin
            uart_tx_data_we <= #1 1;
            stp <= #1 14;
            rd_cnt <= #1 rd_cnt + 1;
        end

        14: begin
            uart_tx_data_we <= #1 0;
            uart_tx_data <= #1 fifo_data_r[15:8];
            if( uart_empty )
                stp <= #1 15;
        end

        15: begin
            uart_tx_data_we <= #1 1;
            stp <= #1 16;
        end
        
        16: begin
            uart_tx_data_we <= #1 0;
            uart_tx_data <= #1 fifo_data_r[23:16];
            if( uart_empty )
                stp <= #1 17;
        end

        17: begin
            uart_tx_data_we <= #1 1;
            stp <= #1 18;
            fifo_rd <= #1 1;
        end

        18: begin
            uart_tx_data_we <= #1 0;
            fifo_rd <= #1 0;
            if( ~rd_cnt[11] && ~fifo_empty )
                stp <= #1 12;
            
            if( rd_cnt[11] )
                stp <= #1 19;
            
        end



        19: begin
            fifo_rstp <= #1 1;
            if( uart_done )
                stp <= #1 0;
        end
    endcase

    if( rstp )
        stp <= #1 0;
end



endmodule

`default_nettype wire
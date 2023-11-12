
`default_nettype none 

module top
#(
    parameter               is_simulation=0
)
(
  
    input   wire            clk,
    input   wire            reset_p,

    input   wire [3:0]      key_sw_p,           // key_sw_p[0]: 1 - reset cpu
                                                // key_sw_p[1]: 1 - отображение A0, 0 - отображение PC counter
                                                

    output  wire [15:0]     display_number,     // [15:12] - p0_reg_hex
                                                // [11:8]  - credit_counter
                                                // [7:4]   - p1_reg_hex
    output  wire [3:0]      led_p,


    output  wire            hsync,
    output  wire            vsync,
    output  wire [2:0]      rgb,

    output  wire [3:0]      vgaext_r,
    output  wire [3:0]      vgaext_g,
    output  wire [3:0]      vgaext_b,
    output  wire            vgaext_hsync,
    output  wire            vgaext_vsync,

    inout   wire [13:0]     gpio,

    input   wire        uart_rxd,
    output  wire        uart_txd    
    
); 

logic                           rstp;
logic   [3:0]                   key_sw_p_z1;
logic   [3:0]                   key_sw_p_z2;

logic   [3:0]                   osc_vga_r;
logic   [3:0]                   osc_vga_g;
logic   [3:0]                   osc_vga_b;
logic   [3:0]                   osc_state;


logic         cks_mode;                                  /* sync mode                    */
logic         clkp;                                      /* main peripheral clock        */
logic         ld_wdata;                                  /* write tx data register       */
logic         rd_rdata;                                  /* read rx data register        */
logic         s_reset;                                   /* synchronous reset            */
//logic         ser_rxd;                                   /* receive data input           */
logic   [7:0] tx_wdata;                                  /* write data bus               */
logic  [11:0] div_rate;                                  /* serial baud rate divider     */

logic        bufr_done;                                 /* serial tx done sending       */
logic        bufr_empty;                                /* serial tx buffer empty       */
logic        bufr_full;                                 /* serial rx buffer full        */
logic        bufr_ovr;                                  /* serial rx buffer overrun     */
logic        ser_clk;                                   /* serial clk output (cks)      */
//logic        ser_txd;                                   /* transmit data output         */
logic  [7:0] rx_rdata;                                  /* receive data buffer          */

always @(posedge clk) begin
    rstp <= #1 reset_p | key_sw_p[0];
    //p0_reset_n <= #1 ~rstp;

    key_sw_p_z1 <= #1 key_sw_p;
    key_sw_p_z2 <= #1 key_sw_p_z1;
end 



localparam  X_WIDTH = 11,
            Y_WIDTH = 10,
            CLK_MHZ = 50;

wire display_on;

// wire [X_WIDTH - 1:0] x;
// wire [Y_WIDTH - 1:0] y;

logic [11:0]    color;
logic [11:0]    color_q;

logic [X_WIDTH - 1:0] pixel_x;
logic [Y_WIDTH - 1:0] pixel_y;

logic [X_WIDTH - 1:0] pixel_x_q;
logic [X_WIDTH - 1:0] pixel_x_q2;

logic [11:0]                    video_r_addr;
logic [7:0]                     video_r_data;
logic [11:0]                    video_w_addr;
logic [7:0]                     video_w_data;
logic                           video_w_valid;
logic                           video_reset_done;

assign { vgaext_r, vgaext_g, vgaext_b } = color_q;

//always @(posedge clk) color_q <= #1 color;

vga
# (
    .N_MIXER_PIPE_STAGES ( 2 ),
    .HPOS_WIDTH ( X_WIDTH      ),
    .VPOS_WIDTH ( Y_WIDTH      ),

    // Horizontal constants

    //.H_DISPLAY           ( 1024  ),  // Horizontal display width
    .H_DISPLAY           ( 1024  ),  // Horizontal display width
    .H_FRONT             (   24  ),  // Horizontal right border (front porch)
    .H_SYNC              (  136  ),  // Horizontal sync width
    .H_BACK              (  160  ),  // Horizontal left border (back porch)

    // Vertical constants

    .V_DISPLAY           (  768  ),  // Vertical display height
    .V_BOTTOM            (  29   ),  // Vertical bottom border
    .V_SYNC              (  6    ),  // Vertical sync # lines
    .V_TOP               (  3    ),  // Vertical top border
    
    .CLK_MHZ                (  65  ),   // Clock frequency (50 or 100 MHz)
    .VGA_CLOCK              (  65  )  // Pixel clock of VGA in MHz    
    
)
i_vga
(
    .clk        (   clk        ),
    .reset      (   rstp       ),
    .hsync      (   vgaext_hsync    ),
    .vsync      (   vgaext_vsync    ),
    .display_on (   display_on      ),
    .hpos       (   pixel_x         ),
    .vpos       (   pixel_y         )
);

assign hsync = vgaext_hsync;
assign vsync = vgaext_vsync;
assign rgb[0] = vgaext_b[3];
assign rgb[1] = vgaext_g[3];
assign rgb[2] = vgaext_r[3];

logic [7:0]         index; // Character Index
logic [2:0]         sub_index; // Y position in character
logic [7:0]         bitmap_out;        // 8 bit horizontal slice of character

text_rom    text_rom
  (
   .clock           (       clk         ), // Clock
   .index           (       index       ), // Character Index
   .sub_index       (       sub_index   ), // Y position in character

   .bitmap_out      (       bitmap_out  )         // 8 bit horizontal slice of character
   );

// assign index = (pixel_y[9:4]=='d16 && pixel_x[9:4]=='d32) ? 8'h32 : 0;
assign sub_index = pixel_y[3:1];

always @(posedge clk) begin
 
    pixel_x_q  <= #1 pixel_x;
    pixel_x_q2 <= #1 pixel_x_q;

    if( pixel_y>15 && pixel_x>15 && pixel_x<(1024-16) && pixel_y<(768-16))
        //color_q <= display_on & (bitmap_out[pixel_x_q2[3:1]]) ? 12'h0F0 : 0;
        color_q <= { osc_vga_r, osc_vga_g, osc_vga_b };
    else
        color_q <= '0;

end

assign video_r_addr = { pixel_y[9:4], pixel_x[9:4] };
assign index = video_r_data;

video_memory
#(
    //.INIT_VALUE                  ( 8'h41 )
    .INIT_VALUE                  ( 8'h20 )
) video_memory
(
    .clk                (       clk     ),
    .reset_p            (       rstp    ),
    .reset_done         (       video_reset_done ),
    .r_addr             (       video_r_addr     ),
    .r_data             (       video_r_data    ),
    .w_addr             (       video_w_addr    ),
    .w_data             (       video_w_data    ),
    .w_valid            (       video_w_valid   )
);

logic [3:0]     stp;

logic [15:0][7:0]  str_data = " Hello, world!  ";


always @(posedge clk) begin
    case( stp )
    0: begin
        video_w_addr <= #1 'h40;
        video_w_data <= #1 8'h30;
        video_w_valid=1;
        stp <= #1 1;
    end

    1: begin

        if( video_w_data == 8'h39 )
            video_w_data <= #1 8'h30;
        else
            video_w_data <= #1 video_w_data + 1;
        
        if( video_w_addr==('h40+63) ) begin

            video_w_addr <= #1 'h40*46;
            video_w_data <= #1 8'h41;
            stp <= #1 2;
        end else begin
            video_w_addr <= #1 video_w_addr + 1;    
        end

    end

    2: begin
        
        if( video_w_addr==('h40*46+63) ) begin
            video_w_addr <= #1 'h40*16;
            video_w_data <= #1 str_data[15];
            stp <= #1 3;
        end else begin
            video_w_addr <= #1 video_w_addr + 1;    
        end


        // if( video_w_data == 8'h39 )
        //     video_w_data <= #1 8'h30;
        // else
        //     video_w_data <= #1 video_w_data + 1;
        video_w_data <= #1 video_w_data + 1;
    end

    3: begin
        
        if( video_w_addr[4] ) begin
            video_w_valid=0;
            stp <= #1 4;
        end else begin
            video_w_addr <= #1 video_w_addr + 1;    
        end

        video_w_data <= #1 str_data[15-video_w_addr[3:0]];
    end


    4: begin
        video_w_valid=0;
    end

    endcase

    if( rstp || ~video_reset_done )
        stp <= #1 '0;

end


wire [23:0] value_24;
wire [15:0] value = value_24 [23:8];
logic       value_we;

// inmp441_mic_i2s_receiver i_microphone
// (
//     .clk   ( clk       ),
//     .reset ( rstp      ),
//     .lr    ( gpio  [5] ),
//     .ws    ( gpio  [3] ),
//     .sck   ( gpio  [1] ),
//     .sd    ( gpio  [0] ),
//     .value      ( value_24  ),
//     .value_we   ( value_we  )
// );

inmp441_mic_spi_receiver_65m  i_microphone
(
    .clk    (   clk     ),
    .reset  (   rstp    ),
    .cs     (   gpio  [3]   ),
    .sck    (   gpio  [1]   ),
    .sdo    (   gpio  [0]   ),
    .value  (   value_24    ),
    .value_we   ( value_we  )    

);

assign gpio  [5] = 0;

osc_mic 
#(
    .is_simulation   ( is_simulation )
)
osc_mic
(
  
    .clk            (   clk         ),
    .reset_p        (   rstp        ),

    .data           (   value       ),
    .data_we        (   value_we    ),

    .threshold      (   16'h0010    ),


    .x              (   pixel_x     ),
    .y              (   pixel_y     ),
    .vga_r          (   osc_vga_r   ),
    .vga_g          (   osc_vga_g   ),
    .vga_b          (   osc_vga_b   ),
    .vsync          (   vgaext_vsync    ),
    .state          (   osc_state   )
);


logic [15:0]    value_r;

assign display_number[3:0] = osc_state;
assign display_number[15:4] = value_r[15:4];

always_ff @(posedge clk)
    if( ~key_sw_p[1]) value_r = value;


assign div_rate = 12'd35;
assign cks_mode = 0;

serial_top  serial 
(
    .cks_mode       (   cks_mode    ),
    .clkp           (   clk         ),
    .ld_wdata       (   ld_wdata    ),
    .rd_rdata       (   rd_rdata    ),
    .s_reset        (   rstp        ),
    .ser_rxd        (   uart_rxd     ),
    .tx_wdata       (   tx_wdata    ),
    .div_rate       (   div_rate    ),
    .bufr_done      (   bufr_done   ),
    .bufr_empty     (   bufr_empty  ),
    .bufr_full      (   bufr_full   ),
    .bufr_ovr       (   bufr_ovr    ),
    .ser_clk        (   ser_clk     ),
    .ser_txd        (   uart_txd     ),
    .rx_rdata       (   rx_rdata    )
);

logic [23:0]     threshold_low;
logic [23:0]     threshold_high;

assign threshold_low    = -24'd1000;
assign threshold_high   = 24'd1000;

// assign threshold_low    = 24'd100;
// assign threshold_high   = 24'd200;

uart_mic
#(
    .is_simulation      (   is_simulation   )
)
uart_mic
(
  
    .clk                    (   clk         ),
    .reset_p                (   reset_p     ),

    .data                   (   value_24    ),
    .data_we                (   value_we    ),

    .threshold_low          (   threshold_low   ),
    .threshold_high         (   threshold_high  ),

    .uart_empty             (   bufr_empty  ),
    .uart_full              (   bufr_full   ),
    .uart_tx_data_we        (   ld_wdata    ),
    .uart_tx_data           (   tx_wdata    ),
    .uart_done              (   bufr_done   )

);


assign led_p[0] = uart_txd;

endmodule



`default_nettype wire
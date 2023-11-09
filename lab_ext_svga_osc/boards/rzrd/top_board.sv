
`default_nettype none 

module top_board
# (
    parameter clk_mhz = 50
)
(
    input   wire        clk,
    input   wire        reset_n,
    
    input   wire [3:0]  key_sw,
    output  wire [3:0]  led,

    output  wire [7:0]  abcdefgh,
    output  wire [3:0]  digit,

    output  wire        buzzer,

    output  wire        hsync,
    output  wire        vsync,
    output  wire [2:0]  rgb,

    output  wire [3:0]  vgaext_r,
    output  wire [3:0]  vgaext_g,
    output  wire [3:0]  vgaext_b,
    output  wire        vgaext_hsync,
    output  wire        vgaext_vsync,

    inout   wire [13:0]     gpio,

    input   wire        uart_rxd,
    output  wire        uart_txd    

);

//assign led       = key_sw;
//assign abcdefgh  = { key_sw, key_sw };
//assign digit     = 4'b0;
assign buzzer       = 1'b0;
// assign  hsync       = 0;
// assign  vsync       = 0;
// assign  rgb         = '0;

 logic              reset_p;
 logic [10:0]       transaction_cnt;
 logic              step_error;
 logic              flag_ok;
 logic              flag_error;

 logic              interface_rstp;
 logic [15:0]       display_number;

 logic [3:0]        key_sw_z;

 logic [3:0]        key_sw_p;

 logic [3:0]        led_p;

 logic              cpu_clk;
 logic              locked;
 
sync_and_debounce 
#(
    .w          (   4   ),
    .depth      (   8   )
)
sync_and_debounce 
(   
    .clk            (       clk           ),
    .reset          (       interface_rstp  ),
    .sw_in          (       key_sw          ),
    .sw_out         (       key_sw_z        )
);

 seven_segment_4_digits display
 (
     .clock         (       clk             ),
     .reset         (       interface_rstp    ),
     .number        (       display_number  ),
 
     .abcdefgh      (       abcdefgh        ),
     .digit         (       digit           )
 );

always @(posedge clk) interface_rstp <= #1 ~reset_n;

always @(posedge clk) reset_p <= #1 ~reset_n;

top top
(
    .clk            (       cpu_clk         ),
    //.clk            (       clk         ),
    .reset_p        (       reset_p         ),
    .key_sw_p       (       key_sw_p        ),
    .display_number (       display_number  ),
    .led_p          (       led_p           ),
    
    .hsync          (       hsync           ),
    .vsync          (       vsync           ),
    .rgb            (       rgb             ),

    .vgaext_r       (       vgaext_r        ),
    .vgaext_g       (       vgaext_g        ),
    .vgaext_b       (       vgaext_b        ),
    .vgaext_hsync   (       vgaext_hsync    ),
    .vgaext_vsync   (       vgaext_vsync    ),
    .gpio           (       gpio            ),

    .uart_rxd       (       uart_rxd        ),
    .uart_txd       (       uart_txd        )
);

assign key_sw_p     = ~ key_sw_z;
assign led          = ~led_p;

pll50_65 pll
(
	.areset     (   interface_rstp  ),
	.inclk0     (   clk             ),
	.c0         (   cpu_clk         ),
    .locked     (   locked          )
);



endmodule

`default_nettype wire
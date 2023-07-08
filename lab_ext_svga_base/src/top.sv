
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

    output  wire [3:0]  vgaext_r,
    output  wire [3:0]  vgaext_g,
    output  wire [3:0]  vgaext_b,
    output  wire        vgaext_hsync,
    output  wire        vgaext_vsync    
    
); 

logic                           rstp;
logic   [3:0]                   key_sw_p_z1;
logic   [3:0]                   key_sw_p_z2;





always @(posedge clk) begin
    rstp <= #1 reset_p | key_sw_p[0];
    //p0_reset_n <= #1 ~rstp;

    key_sw_p_z1 <= #1 key_sw_p;
    key_sw_p_z2 <= #1 key_sw_p_z1;
end 



localparam  X_WIDTH = 10,
            Y_WIDTH = 10,
            CLK_MHZ = 50;

wire display_on;

wire [X_WIDTH - 1:0] x;
wire [Y_WIDTH - 1:0] y;

logic [11:0]    color;

assign { vgaext_r, vgaext_g, vgaext_b } = color;

vga
# (
    .HPOS_WIDTH ( X_WIDTH      ),
    .VPOS_WIDTH ( Y_WIDTH      ),

    .CLK_MHZ    ( CLK_MHZ      )
)
i_vga
(
    .clk        (   clk        ),
    .reset      (   rstp       ),
    .hsync      (   vgaext_hsync      ),
    .vsync      (   vgaext_vsync      ),
    .display_on (   display_on ),
    .hpos       (   x          ),
    .vpos       (   y          )
);

// typedef enum bit [11:0]
// {
//   black  = 12'b000000000000,
//   cyan   = 12'b000011111111,
//   red    = 12'b111100000000,
//   yellow = 12'b111111110000,
//   white  = 12'b111111111111

//   // TODO: Add other colors
// }
// rgb_t;

// always_comb
// begin
//   // Circle

//   if (~ display_on)
//     color = black;
//   else if (x ** 2 + y ** 2 < 100 ** 2)
//     color = red;
//   else if (x > 200 & y > 200 & x < 300 & y < 400)
//     color = yellow;
//   else if (key_sw_p[1] == 1'b1 & (x - 600) ** 2 + (y - 200) ** 2 < 70 ** 2)
//     color = white;
//   else
//     color = cyan;

//   // TODO: Add other figures
// end

// always_comb
// begin
//   // Circle

//   if (~ display_on ) begin
//     color = '0;
//   end else begin
//     // case( x/212 )
//     // 0: color = { x[6:3], 4'h0, 4'h0 };
//     // 1: color = { 4'h0,   x[6:3], 4'h0 };
//     // 2: color = { 4'h0,   4'h0,   x[6:3]  };
//     // default: color = '0;
//     // endcase

//     case( x/212 )
//     0:color = { y[7:6], x[9:8], 4'h0, 4'h0 };
//     1:color = { 4'h0, y[7:6], x[9:8], 4'h0 };
//     2:color = { 4'h0, 4'h0, y[7:6], x[9:8], y[7:6]  };
//     default: color = '0;
//     endcase

    
    
//   end
// end
//   // TODO: Add other figures
// end


mem_bram
#(
    .WIDTH      (   12       ),
    .DEPTH      (   640*480  )
)
mem_bram    
    (   input wire                      i_wclk,
        input wire                      i_wr,
        input wire [$clog2(DEPTH)-1:0]  i_wr_addr,
        
        input wire                      i_rclk,
        input wire                      i_rd,
        input wire [$clog2(DEPTH)-1:0]  i_rd_addr,
        
        input wire                      i_bram_en,
        input wire [WIDTH-1:0]          i_bram_data,
        output reg [WIDTH-1:0]          o_bram_data      
    );

endmodule

`default_nettype wire
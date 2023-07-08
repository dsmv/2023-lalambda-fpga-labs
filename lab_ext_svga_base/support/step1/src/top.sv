
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
    output  wire            vgaext_vsync    
    
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



localparam  X_WIDTH = 11,
            Y_WIDTH = 10,
            CLK_MHZ = 50;

wire display_on;

wire [X_WIDTH - 1:0] x;
wire [Y_WIDTH - 1:0] y;

logic [11:0]    color;
logic [11:0]    color_q;

assign { vgaext_r, vgaext_g, vgaext_b } = color_q;

always @(posedge clk) color_q <= #1 color;

vga
# (
    .N_MIXER_PIPE_STAGES ( 1 ),
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
    .hsync      (   vgaext_hsync      ),
    .vsync      (   vgaext_vsync      ),
    .display_on (   display_on ),
    .hpos       (   x          ),
    .vpos       (   y          )
);

assign hsync = vgaext_hsync;
assign vsync = vgaext_vsync;
assign rgb[0] = vgaext_b[3];
assign rgb[1] = vgaext_g[3];
assign rgb[2] = vgaext_r[3];

typedef enum bit [11:0]
{
  black  = 12'b000000000000,
  cyan   = 12'b000011111111,
  red    = 12'b111100000000,
  yellow = 12'b111111110000,
  white  = 12'b111111111111

  // TODO: Add other colors
}
rgb_t;

always_comb
begin
//  Circle

//  if (~ display_on || x<1 || y<5 || x>1022 || y>766 )
  if( ~display_on || y<3  )
    color = '0;//black;
  else if (x ** 2 + y ** 2 < 100 ** 2)
    color = 12'b111100000000; //red;
  else if (x > 200 & y > 200 & x < 300 & y < 400)
    color = 12'b111111110000; //yellow;
  //else if (key_sw_p[1] == 1'b1 & (x - 600) ** 2 + (y - 200) ** 2 < 70 ** 2)

  else if(key_sw_p == 4'b0010 & (x - 600) ** 2 + (y - 200) ** 2 < 70 ** 2)
    color = 12'b111111111111; //white;
  else
    color = 12'b000011111111; //cyan;

  // TODO: Add other figures
end

// always_comb
// begin

//   if (~ display_on || y<3 ) begin
//     color = '0;
//   end else begin
//     case( x/300 )
//     0: color = { x[6:3], 4'h0, 4'h0 };
//     1: color = { 4'h0,   x[6:3], 4'h0 };
//     2: color = { 4'h0,   4'h0,   x[6:3]  };
//     default: color = '0;
//     endcase

//     // case( x/300 )
//     // 0:color = { y[7:6], x[9:8], 4'h0, 4'h0 };
//     // 1:color = { 4'h0, y[7:6], x[9:8], 4'h0 };
//     // 2:color = { 4'h0, 4'h0, y[7:6], x[9:8], y[7:6]  };
//     // default: color = '0;
//     // endcase

    
    
//    end
// // end
// //   // TODO: Add other figures
// end




endmodule

`default_nettype wire
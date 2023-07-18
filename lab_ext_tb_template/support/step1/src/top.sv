
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
    output  wire [3:0]      led_p
    
); 

logic                           rstp;
logic   [3:0]                   key_sw_p_z1;
logic   [3:0]                   key_sw_p_z2;



logic [15:0]    n_display_number;

always @(posedge clk) begin
    rstp <= #1 reset_p | key_sw_p[0];

    key_sw_p_z1 <= #1 key_sw_p;
    key_sw_p_z2 <= #1 key_sw_p_z1;
end 

initial begin

    n_display_number = 0;

    // @(posedge clk iff reset_p)   // don't work in Icarus
    for( int ii=0; ~reset_p ; ii++ ) begin
        @(posedge clk);
    end


    for( int ii=0; ii<16; ii++ ) begin

        #1000;
        n_display_number[3:0]++;
        
    end
end

assign display_number = n_display_number;
endmodule

`default_nettype wire
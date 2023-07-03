
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



logic                           p0_reset_n;
logic   [31:0]                  p0_vcu_reg_control;             //! control register for video control unit (vcu)  
logic                           p0_vcu_reg_control_we;          //! 1 - new data in the vcu_reg_control
logic   [31:0]                  p0_vcu_reg_wdata;               //! data register for video control unit (vcu)
logic                           p0_vcu_reg_wdata_we;            //! 1 - new data in the vcu_reg_wdata
logic   [31:0]                  p0_vcu_reg_rdata;               //! input data 
logic   [ 4:0]                  p0_regAddr;                     // debug access reg address
logic   [31:0]                  p0_regData;                     // debug access reg data
logic   [31:0]                  p0_imAddr;
logic   [31:0]                  p0_imData;
logic   [3:0]                   p0_reg_hex;
logic   [7:0]                   p0_reg_status;

logic   [27:0]                  tick_counter;


always @(posedge clk) begin
    rstp <= #1 reset_p | key_sw_p[0];
    p0_reset_n <= #1 ~rstp;

    key_sw_p_z1 <= #1 key_sw_p;
    key_sw_p_z2 <= #1 key_sw_p_z1;
end 

sm_rom 
#(
        .SIZE               (       128             ),
        .PROG_NAME          (   "p0_program.hex"    )
) p0_rom
(
    .a                      (       p0_imAddr       ), 
    .rd                     (       p0_imData       )
);

// sm_rom_p0
// #(
//         .SIZE               (       128             )
// ) p0_rom
// (
//     .a                      (       p0_imAddr       ), 
//     .rd                     (       p0_imData       )
// );


sr_cpu_vc  p0_sm_cpu_vc
(
    .clk                    (       clk                     ),    // clock
    .rst_n                  (       p0_reset_n              ),    // reset
    .regAddr                (       p0_regAddr              ),    // debug access reg address
    .regData                (       p0_regData              ),    // debug access reg data
    .imAddr                 (       p0_imAddr               ),
    .imData                 (       p0_imData               ),

    .vcu_reg_control        (       p0_vcu_reg_control      ),   // control register for video control unit (vcu)
    .vcu_reg_control_we     (       p0_vcu_reg_control_we   ),   // 1 - new data in the vcu_reg-control
    .vcu_reg_wdata          (       p0_vcu_reg_wdata        ),   // данные на запись
    .vcu_reg_wdata_we       (       p0_vcu_reg_wdata_we     ),   // 1 - запись данных
    .vcu_reg_rdata          (       p0_vcu_reg_rdata        )    // данные для чтения
);

assign p0_regAddr = (key_sw_p[1]) ? 5'b01010 : 5'b00000;  // кнопка 1 нажата -  p0_regData = регистр A0, не нажата - p0_regData = PC counter

assign display_number[15:8] = p0_regData[7:0];          // вывод регистра A0 или PC counter
assign display_number[7:0]  = p0_vcu_reg_wdata[7:0];    // вывод регистра T5

assign p0_vcu_reg_rdata[0] = tick_counter[27];
assign p0_vcu_reg_rdata[31:1] = '0;

always_ff @(posedge clk) begin
    if( rstp || p0_vcu_reg_wdata_we )
        tick_counter <= #1 (is_simulation) ? 28'h10 : 28'h2FAF080;
    else if( ~tick_counter[27] )
        tick_counter <= #1 tick_counter - 1;

end

assign led_p = display_number[3:0];

endmodule

`default_nettype wire
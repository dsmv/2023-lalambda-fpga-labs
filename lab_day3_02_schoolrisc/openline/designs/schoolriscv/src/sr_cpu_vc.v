/*
 * schoolRISCV - small RISC-V CPU 
 *
 * originally based on Sarah L. Harris MIPS CPU 
 *                   & schoolMIPS project
 * 
 * Copyright(c) 2017-2020 Stanislav Zhelnio 
 *                        Aleksandr Romanov 
 *
 *
 *
 *          t5  vcu_data        write and read from external component
 *          t6  vcu_control     write to external, read from internal register
 *
 */ 

`include "sr_cpu.vh"



module sr_cpu_vc
(
    input           clk,        // clock
    input           rst_n,      // reset
    input   [ 4:0]  regAddr,    // debug access reg address
    output  [31:0]  regData,    // debug access reg data
    output  [31:0]  imAddr,     // instruction memory address
    input   [31:0]  imData,     // instruction memory data

    output  reg [31:0]  vcu_reg_control,    // control register for video control unit (vcu)  
    output  reg         vcu_reg_control_we, // 1 - new data in the vcu_reg_control
    output  reg [31:0]  vcu_reg_wdata,      // data register for video control unit (vcu)
    output  reg         vcu_reg_wdata_we,   // 1 - new data in the vcu_reg_wdata
    input   [31:0]      vcu_reg_rdata       // input data 
);
    //control wires
    wire        aluZero;
    wire        pcSrc;
    wire        regWrite;
    wire        aluSrc;
    wire        wdSrc;
    wire  [2:0] aluControl;

    //instruction decode wires
    wire [ 6:0] cmdOp;
    wire [ 4:0] rd;
    wire [ 2:0] cmdF3;
    wire [ 4:0] rs1;
    wire [ 4:0] rs2;
    wire [ 6:0] cmdF7;
    wire [31:0] immI;
    wire [31:0] immB;
    wire [31:0] immU;

    //program counter
    wire [31:0] pc;
    wire [31:0] pcBranch = pc + immB;
    wire [31:0] pcPlus4  = pc + 4;
    wire [31:0] pcNext   = pcSrc ? pcBranch : pcPlus4;
    sm_register r_pc(clk ,rst_n, pcNext, pc);

    //program memory access
    assign imAddr = pc >> 2;
    wire [31:0] instr = imData;

    //instruction decode
    sr_decode id (
        .instr      ( instr        ),
        .cmdOp      ( cmdOp        ),
        .rd         ( rd           ),
        .cmdF3      ( cmdF3        ),
        .rs1        ( rs1          ),
        .rs2        ( rs2          ),
        .cmdF7      ( cmdF7        ),
        .immI       ( immI         ),
        .immB       ( immB         ),
        .immU       ( immU         ) 
    );

    //register file
    wire [31:0] rd0;
    wire [31:0] rd1;
    wire [31:0] rd2;
    wire [31:0] wd3;

    sm_register_file_vc rf (
        .clk        ( clk          ),
        .a0         ( regAddr      ),
        .a1         ( rs1          ),
        .a2         ( rs2          ),
        .a3         ( rd           ),
        .rd0        ( rd0          ),
        .rd1        ( rd1          ),
        .rd2        ( rd2          ),
        .wd3        ( wd3          ),
        .we3        ( regWrite     ),
        .vcu_reg_rdata ( vcu_reg_rdata )
    );

    //debug register access
    assign regData = (regAddr != 0) ? rd0 : pc;

    // VCU register
    always @(posedge clk) begin
        if( ~rst_n )
            vcu_reg_control <= 0;
        else if( regWrite & rd==5'b11111 )
            vcu_reg_control <= wd3;
            
        if( rd==5'b11111 )
            vcu_reg_control_we <= regWrite;
        else
            vcu_reg_control_we <= 0;

        if( ~rst_n )
            vcu_reg_wdata <= 0;
        else if( regWrite & rd==5'b11110 )
            vcu_reg_wdata <= wd3;
            
        if( rd==5'b11110 )
            vcu_reg_wdata_we <= regWrite;
        else
            vcu_reg_wdata_we <= 0;

    end

    //alu
    wire [31:0] srcB = aluSrc ? immI : rd2;
    wire [31:0] aluResult;

    sr_alu alu (
        .srcA       ( rd1          ),
        .srcB       ( srcB         ),
        .oper       ( aluControl   ),
        .zero       ( aluZero      ),
        .result     ( aluResult    ) 
    );

    assign wd3 = wdSrc ? immU : aluResult;

    //control
    sr_control sm_control (
        .cmdOp      ( cmdOp        ),
        .cmdF3      ( cmdF3        ),
        .cmdF7      ( cmdF7        ),
        .aluZero    ( aluZero      ),
        .pcSrc      ( pcSrc        ),
        .regWrite   ( regWrite     ),
        .aluSrc     ( aluSrc       ),
        .wdSrc      ( wdSrc        ),
        .aluControl ( aluControl   ) 
    );

endmodule




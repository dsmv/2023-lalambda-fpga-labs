module tb;

    logic           clk;
    logic           reset_n;
    logic [3:0]     key_sw;
    wire  [13:0]    gpio;
    //logic           sd;

    localparam integer freq_100_C  = 26163,
               freq_100_Cs = 27718,
               freq_100_D  = 29366,
               freq_100_Ds = 31113,
               freq_100_E  = 32963,
               freq_100_F  = 34923,
               freq_100_Fs = 36999,
               freq_100_G  = 39200,
               freq_100_Gs = 41530,
               freq_100_A  = 44000,
               freq_100_As = 46616,
               freq_100_B  = 49388;

    localparam int     s_freq_100[5]= { freq_100_C, freq_100_D, freq_100_Ds, freq_100_E, freq_100_F };

    

    localparam int       s_time_ms[5]= { 1, 45, 90, 135, 180 };

    localparam int       s_ampl[5]= { 30000, 20000, 31000, 22000, 26000 };

    localparam int       s_cnt=5;

    top
    # (
        .clk_mhz (50)
    )
    i_top
    (
        .clk     ( clk     ),
        .reset_n ( reset_n ),
        .key_sw  ( key_sw  ),
        .gpio    ( gpio    )
    );


    sim_inn441 
    #(
        .s_freq_100     (   s_freq_100    ),
        .s_time_ms      (   s_time_ms     ),
        .s_ampl         (   s_ampl        ),
        .s_cnt          (   s_cnt         )
    )
    sim_inn441
    (
        .sck            (   gpio[6]   ),    //! частота получения данных Fws * 64
        .ws             (   gpio[0]   ),     //! частота дискретизации АЦП
        .lr             (   0         ),
        .sdo            (   gpio[4]   )
    );    

    initial
    begin
        clk = 1'b0;

        forever
            # 10 clk = ~ clk;
    end

    initial
    begin
        reset_n <= 1'bx;
        repeat (2) @ (posedge clk);
        reset_n <= 1'b0;
        repeat (2) @ (posedge clk);
        reset_n <= 1'b1;
    end

    initial
    begin
        `ifdef __ICARUS__
            $dumpvars;
        `endif

        key_sw <= 4'b0;

        @ (posedge reset_n);

        // repeat (1000)
        // begin
        //     @ (posedge clk);

        //     key_sw <= $urandom ();
        // end

        #250000000; // delay for 250 ms

        `ifdef MODEL_TECH  // Mentor ModelSim and Questa
            $stop;
        `else
            $finish;
        `endif
    end

endmodule

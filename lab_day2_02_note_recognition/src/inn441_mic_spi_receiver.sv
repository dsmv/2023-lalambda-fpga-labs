module inn441_mic_spi_receiver
(
    input             clk,
    input             reset,
    output            cs,
    output            sck,
    input             sdo,
    output logic [15:0] value
);

    logic [ 9:0] cnt;
    logic [31:0] shift;

    always_ff @ (posedge clk or posedge reset)
    begin
        if (reset)
            cnt <= 8'b100;
        else
            cnt <= cnt + 8'b1;
    end

    assign sck = ~ cnt [3];
    assign cs  =   cnt [9];

    wire sample_bit = ( cs == 1'b0 && cnt [3:0] == 4'b1111 );
    wire value_done = ( cnt [9:0] == 8'b0 );

    always_ff @ (posedge clk or posedge reset)
    begin
        if (reset)
        begin
            shift <= 32'h0000;
            value <= 16'h0000;
        end
        else if (sample_bit)
        begin
            shift <= (shift << 1) | sdo;
        end
        else if (value_done)
        begin
            //value[15:0] <= shift[30:7];
            value[15:0] <= shift[30:15];
        end
    end

endmodule

// Code your testbench here
// or browse Examples


module tb
();
  
initial begin
  $dumpfile("dump.vcd");
  $dumpvars(5);
end
  
//   string	test_name[3:0]=
//   {
//    "test_3", 
//    "test_2", 
//    "test_1", 
//    "test_0" 
//   };
string	test_name[3:0];
int fd;
int args;

task test_finish;
  		input int 	    test_id;
  		input string	test_name;
        input int		result;
begin

    fd = $fopen( "global.txt", "a" );

    $display("");
    $display("");

    if( 1==result ) begin
        $fdisplay( fd, "test_id=%-5d test_name: %15s         TEST_PASSED", 
        test_id, test_name );
        $display(      "test_id=%-5d test_name: %15s         TEST_PASSED", 
        test_id, test_name );
    end else begin
        $fdisplay( fd, "test_id=%-5d test_name: %15s         TEST_FAILED *******", 
        test_id, test_name );
        $display(      "test_id=%-5d test_name: %15s         TEST_FAILED *******", 
        test_id, test_name );
    end

    $fclose( fd );

    $display("");
    $display("");

    $finish();
end endtask  
  
int 	        test_id=0;

logic           clk=0;
logic           reset_p;

logic [3:0]      key_sw_p;      
                                
                                

logic [15:0]     display_number;    
logic [3:0]      ar_display_number[4];
                                    
                                    
logic [3:0]      led_p;

logic            test_passed=0;
logic            test_stop=0;
logic            test_timeout=0;

always #5 clk = ~clk;

top #( .is_simulation(1) ) uut( .* );

assign ar_display_number[0] = display_number[3:0];
assign ar_display_number[1] = display_number[7:4];
assign ar_display_number[2] = display_number[11:8];
assign ar_display_number[3] = display_number[15:12];

// Main process  
initial begin  

    args=-1;

    test_name[0] = "test_0";
    test_name[1] = "test_1";
    test_name[2] = "test_2";
    test_name[3] = "test_3";

    
    if( $value$plusargs( "test_id=%0d", args )) begin
        if( args>=0 && args<2 )
        test_id = args;

        $display( "args=%d  test_id=%d", args, test_id );

    end

  $display("Hello, world! test_id=%d  name: %s  ", test_id, test_name[test_id]);

  reset_p <= #1 1;

  #200;

  @(posedge clk);
  
  reset_p <= #1 0;
  
  //@(posedge clk iff test_stop | test_timeout );
  for( int ii=0; ~(test_stop || test_timeout)  ; ii++ ) begin
    @(posedge clk);
  end


  #200;

  //test_finish( test_id, test_name[test_id], test_passed, display_number[7:4] );
  test_finish( test_id, test_name[test_id], test_passed );

end

initial begin
    #40000;
    $display();
    $display( "***************************  TIMEMOUT  ****************************"  );
    $display();
    test_timeout = 1;
end

initial begin

    test_init();

    @(negedge reset_p );

    case( test_id )
        0: begin
            // some action for test_id==0
            fork
                test_seq_p0();    
                test_seq_p1();    
                test_seq_p2();    
            join_any
           
            if( display_number[3:0]==4'b1111 )  
                test_passed = 1;
        end

        // 1: begin
        //     // some action for test_id==1
        // end

        1: begin
            #500;
            if( display_number[3:0]==4'b0110 )  
                test_passed = 1;

        end

    endcase    

    test_stop = 1;
end
  
task test_init;
    key_sw_p <= '0;
endtask

// Иммитация нажатия на кнопку 1
task test_seq_p0;

    for( int loop=1;  loop<1000; loop++ ) begin

        key_sw_p[1] <= 1;    
        #500;
        key_sw_p[1] <= 0;    
        #500;

    end

endtask

// Иммитация нажатия на кнопку 2
task test_seq_p1;

    for( int loop=1;  loop<1000; loop++ ) begin        

        key_sw_p[2] <= 1;    
        #500;
        key_sw_p[2] <= 0;    
        #800;

    end


endtask


// Контроль вывода на семисегментный индикатолра
task test_seq_p2;

    for( int ii=0; ii<16; ii++ ) begin
        //@(posedge clk iff display_number[3:0]==ii ); // ожидание вывода очередной цифры на младшую цифру индикатора
        for( int kk=0; display_number[3:0]!=ii; kk++ )
            @(posedge clk);
    end

endtask


endmodule
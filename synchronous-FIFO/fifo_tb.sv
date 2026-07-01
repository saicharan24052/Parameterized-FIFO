`timescale 1ns/1ps

module fifo_tb;

    parameter DATA_WIDTH = 32;
    parameter DEPTH      = 28;
    
     int wr_depth, rd_depth;
    int p = 0;
    //--------------------------------------------------
    // DUT Signals
    //--------------------------------------------------
    logic clk;
    logic rst_n;

    logic w_en;
    logic r_en;

    logic [DATA_WIDTH-1:0] data_in;
    logic [DATA_WIDTH-1:0] data_out;

    logic full;
    logic empty;

    //--------------------------------------------------
    // Scoreboard
    //--------------------------------------------------
    logic [DATA_WIDTH-1:0] exp_q[$];
    logic [DATA_WIDTH-1:0] expected_data;

	int j,k,l,m;
	int count;
	bit ctrl, ctrl_r;
    //--------------------------------------------------
    // DUT
    //--------------------------------------------------
    fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(data_in),
        .data_out(data_out),
        .w_en(w_en),
        .r_en(r_en),
        .full(full),
        .empty(empty)
    );
    
    
      initial clk = 0;
    always #5 clk = ~clk;
      
    task reset();
        rst_n   = 0;
        w_en    = 0;
        r_en    = 0;
        data_in = '0;
        count	= 0;
    	
		repeat(2) @(posedge clk);

        rst_n = 1;

        @(posedge clk);

        if(empty)
            $display($time," RESET PASS");
        else
            $error($time," RESET FAILED");
    
    endtask
    
    task write(bit a, int data);
    	@(posedge clk);
    	if(full) begin
    		$display("FIFO FULL");
    	end 
    	else begin
    	    @(negedge clk);   		
       		if(a) begin
   		        w_en	= 1;
   		        count	= count + 1;
   		        data_in	= count;
 		        
    		end
    		else begin
   		        w_en	= 1;
   		        data_in	= data; 		        
    		end
		end
	  //  $display($time, " INSIDE MAIN WRITE: FULL = %d, EMPTY = %d, w_en = %d, data = %0d\n", full, empty, w_en, data_in);
	
	endtask 
 
 
   	
	task write_drv(bit a);
	@(posedge clk);
   //	 $display($time, " INSIDE WRITE DRIVER: FULL = %d, EMPTY = %d, w_en = %d, data = %0d\n", full, empty, w_en, data_in);
		if(w_en && !full) begin
	   		if(a) begin
		  		exp_q.push_back(data_in);
		  		//$display($time, "queue is %p after push back the count", exp_q);
		  	end
	   		else
				exp_q.push_back(data_in);
		end 			
    endtask
 
 
 
   
    task read;
    	@(posedge clk);
    	if(empty) begin
    		$display("FIFO EMPTY");
    		return;
    	end
    	@(negedge clk); 
    	r_en	= 1;
	    
    endtask
    
    task read_mon();
    	@(posedge clk);
    	if(r_en && !empty)  begin
    		expected_data = exp_q.pop_front();
    		  //	$display($time, "	queue is %p in read mon", exp_q);
    		#2; 
    		if(expected_data == data_out)
    			$display("DATA MATCH");
       		else
    			$display($time,"DATA NOT MATCH : out = %d not equal to exp = %d",data_out, expected_data );
        
      end
    endtask
    
    initial forever read_mon();
    initial forever write_drv(1);
  /*
    initial begin
    	$monitor($time, "	After NBA Update queue is %p \n\n\n", exp_q);
 		
    end
    
    always begin
       @(posedge clk);
        $display($time, "	Before NBA Update FULL = %d, EMPTY = %d, DATA = %0d", full, empty,data_in);
        $display($time, "	Before NBA Update queue is %p \n\n\n", exp_q);
    end  
    */  
    initial
    begin
    	
    	reset();
    		
    	for(int i = 0; i<DEPTH; i++) begin
  		    write(1,0);
  		   p = p+1;
  		   end
  		 	@(negedge clk);   
  	   //	$display($time,"WRITE IS COMPLETED");    
  		w_en = 0;
  		
    	for(int j = 0; j<DEPTH; j++)
  		    read;
  		r_en = 0;
  		
  		fork
  		begin
  			for(int l = 0; l< 700; l++) begin
  				write(1,0);
  				assert(std::randomize(ctrl) with {ctrl dist {1 := 4, 0 := 6};});    //1 : w_en = 0;
  				if(ctrl || full) begin
  					@(negedge clk);
  					w_en = 0;
  				end
  			end
  		end
  		
  		begin
  			for(int m = 0; m< 600; m++) begin
  				read;
  			   assert(std::randomize(ctrl_r) with {ctrl_r dist {1 := 3, 0 := 9};});    //1 : r_en = 0;
  				if(ctrl_r || empty) begin
  					@(negedge clk);
  					r_en = 0;
  				end	
  			end	
  		end
  		
  		join 	
  		
  	 $stop;		  
    end
    
  
    
    
endmodule    
    
       

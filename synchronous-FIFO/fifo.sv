module fifo #(
	parameter DEPTH = 16,
	parameter DATA_WIDTH = 32
)(	input	logic clk,
	input	logic rst_n,
	input	logic [DATA_WIDTH-1:0] data_in,
	input	logic w_en,
	input	logic r_en,
	output	logic full,
	output	logic empty, 
	//output	logic almost_full,
	//output	logic almost_empty,
	output	logic [DATA_WIDTH-1:0] data_out
);

	localparam ADD_WIDTH = $clog2(DEPTH);
	
	logic [ADD_WIDTH-1:0] w_ptr, r_ptr;
	logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];
	logic loop_w, loop_r;
	
	
	
	always_ff @(posedge clk) begin
		if(!rst_n) begin
			w_ptr	<= 1'b0;		
			loop_w	<= 1'b0;
		end
		else begin		
			if(w_en && !full) begin
		   		mem[w_ptr]	<= data_in;	
		   		w_ptr		<= (w_ptr == (DEPTH-1))	? 0 : (w_ptr + 1); 
				loop_w		<= (w_ptr == (DEPTH-1))	? (loop_w ^ 1'b1) : loop_w;			
	    	end
	       	else
	    	mem[w_ptr]	<= mem[w_ptr];
	    end		
	end
	
	
	always_ff @(posedge clk) begin
		if(!rst_n) begin
	  		r_ptr	<= 1'b0;
			loop_r	<= 1'b0;	
		end
		else begin
			if(r_en && !empty) begin
		  		data_out	<= mem[r_ptr];	
	  	   		r_ptr		<= (r_ptr == (DEPTH-1))	? 0 : (r_ptr + 1);
		   		loop_r		<= (r_ptr == (DEPTH-1))	? (loop_r ^ 1'b1) : loop_r;			
	    	end
	  		else
	       	data_out	<= data_out;		
		end	
	end	

assign full		= ((loop_w != loop_r) && (w_ptr == r_ptr)) ? 1 : 0; // hold your writing budd  
assign empty	= ((loop_w == loop_r) && (w_ptr == r_ptr)) ? 1 : 0; // hold your reading budd 
endmodule               

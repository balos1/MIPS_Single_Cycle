/*
    Cody Balos
	EPCE 173 - Computer Organization and Architecture
	Spring 2017
	University of the Pacific
*/

`define NUM_ENTRIES 64
`define NUM_SETS    2
`define TAGMSB      31
`define TAGLSB      8
`define TAGSIZE     `TAGMSB-`TAGLSB
`define INDEXMSB    7
`define INDEXLSB	2
`define INDEXSIZE  `INDEXMSB-`INDEXLSB

/*
    Module: cache

	A 128 word, 1 word block, 2-way, set-assocative cache with write-through write policy.

    Parameters:
        clk - The system clock signal.
        reset - Asynchronous system reset signal.
        MemRead - (CPU->Cache) Is asserted when CPU wants to read.
		MemReadReady - (Memory->Cache) This signal indicates when the data from memory is available to read.
        MemWrite - (CPU->Cache) Is asserted when CPU wants to write. 
        MemWriteDone - (Memory->Cache) Is asserted when the memory write is completed.
        memAddr - (CPU->Cache) The address of data memory to read or write.
        memReadData - (Memory->Cache) Data from data memory.
        cacheWriteData - (Memory->Cache) The data to write into the cache.
		cacheReadData[out] - (Cache->CPU) The data from the cache entry.
		MemHit[out] - (Cache->CPU) Is asserted if there was a cache hit. 
		MemReadDone[out] - (Cache->CPU) Is asserted when a data read is completed.
        MemWriteReady[out] - (Cache->Memory) Is asserted if the processor is writing to memory.
		Stall[out] - (Cache->CPU) Tells the CPU to wait if asserted.
*/
module cache(input logic clk, reset, MemRead, MemReadReady, MemWrite, MemWriteDone,
			 input logic [31:0] memAddr, memReadData, cacheWriteData,
			 output logic [31:0] cacheReadData,
			 output logic MemHit, MemReadDone, MemWriteReady, Stall);
	
	// Variables used for performing analysis
	int misscount;
	int readcount;
	int writecount;
	always_ff @(posedge reset) begin
		misscount = 0;
		readcount = 0;
		writecount = 0;
	end

	// 64 entries, 2-set, set-associative cache
	logic valid_vec[`NUM_ENTRIES-1:0][`NUM_SETS-1:0];
	logic [`TAGSIZE:0] tag_vec[`NUM_ENTRIES-1:0][`NUM_SETS-1:0];
	logic [31:0] data_vec[`NUM_ENTRIES-1:0][`NUM_SETS-1:0];

	// LRU tracking bit. If it is 0, then least recently used set 
	logic LRU[`NUM_ENTRIES-1:0];

	// Parts of the memory address.
	logic [`TAGSIZE:0] tag;
	logic [`INDEXSIZE:0] index;
	assign tag = memAddr[`TAGMSB:`TAGLSB];
	assign index = memAddr[`INDEXMSB:`INDEXLSB];
	assign Stall = (MemRead&(~(MemHit|MemReadDone))) | (MemWrite&(MemWriteReady|(~MemWriteDone)));
	
	always_comb
	begin		
		if (MemRead && valid_vec[index][0] && tag_vec[index][0] == tag) begin
			MemHit = 1;
			cacheReadData = data_vec[index][0];
		end
		else if (MemRead && valid_vec[index][1] && tag_vec[index][1] == tag) begin
			MemHit = 1;
			cacheReadData = data_vec[index][1];
		end
		else begin
			MemHit = 0;
			cacheReadData = 32'b0;
		end
	end

	always_ff @(posedge clk or posedge reset)
	begin
		if (reset) begin
			MemReadDone <= 0;
			MemWriteReady <= 0;
			for(int i = 0; i < `NUM_ENTRIES; i = i+1) begin
				LRU[i] = 0;
				for (int j = 0; j < `NUM_SETS; j = j+1) begin
					// Initialize the cache to all zeros.
					valid_vec[i][j] <= 0;
					tag_vec[i][j] <= 0;
					data_vec[i][j] <= 0;
				end
			end
		end
		else if (MemRead) begin
			if (valid_vec[index][0] && tag_vec[index][0] == tag) begin
				$display("cache read hit, set %b", 1'b0);
				// $display("memAddr = 0x%h\t tag = 0x%h\t index = %dd", memAddr, tag, index);
				LRU[index] <= 1;
				MemReadDone <= 0;
			end
			else if (valid_vec[index][1] && tag_vec[index][1] == tag) begin
				$display("cache read hit, set %b", 1'b1);
				// $display("memAddr = 0x%h\t tag = 0x%h\t index = %dd", memAddr, tag, index);
				LRU[index] <= 0;
				MemReadDone <= 0;
			end
			else begin
				// update the cache once memory controller responds with data
				if (MemReadReady) begin
					$display("cache read miss");
					// $display("memAddr = 0x%h\t tag = 0x%h\t index = %dd\n", memAddr, tag, index);
					valid_vec[index][LRU[index]] <= 1;
					tag_vec[index][LRU[index]] <= tag;
					data_vec[index][LRU[index]] <= memReadData;
					MemReadDone <= 1;
					LRU[index] <= LRU[index]^1;
				end
			end
		end
		else if (MemWrite) begin
			if (valid_vec[index][0] && tag_vec[index][0] == tag) begin
				$display("cache write hit, set %b", 1'b0);
				// $display("memAddr = 0x%h\t tag = 0x%h\t index = %dd", memAddr, tag, index);
				LRU[index] <= 1;
				MemWriteReady <= 0;
			end
			else if (valid_vec[index][1] && tag_vec[index][1] == tag) begin
				$display("cache write hit, set %b", 1'b1);
				// $display("memAddr = 0x%h\t tag = 0x%h\t index = %dd", memAddr, tag, index);
				LRU[index] <= 0;
				MemWriteReady <= 0;
			end
			else begin
				MemWriteReady <= 1;
				if (MemWriteDone) begin
					$display("cache write miss");
					// $display("memAddr = 0x%h\t tag = 0x%h\t index = %dd\n", memAddr, tag, index);
					valid_vec[index][LRU[index]] <= 1;
					tag_vec[index][LRU[index]] <= tag;
					data_vec[index][LRU[index]] <= cacheWriteData;
					LRU[index] <= LRU[index]^1;
				end
			end
		end
		else begin
			MemReadDone <= 0;
			MemWriteReady <= 0;
		end
	end

	// Keep count of misses/reads/writes for analysis.
	always_ff @(posedge MemReadDone or MemWriteReady)
	begin
		if(!reset)
			misscount = misscount + 1;
	end

	always_ff @(posedge MemRead)
	begin
		if (MemRead)
			readcount = readcount + 1;
	end

	always_ff @(posedge MemWrite)
	begin
		if(MemWrite)
			writecount = writecount + 1;
	end
endmodule
/***************************************
 * Testbench for Beta: Lab 5
 *   Memory: Read
 *
 * Elizabeth Basha
 * Spring 2014
 */
 
 module testBeta5_read();
 
		// Define parameters when calling from do file
        parameter testFileName;
        parameter numTests;
		parameter testType;
		parameter CYCLE_TIME=32'd10;
        
        // Signal declarations
		logic clk = 1'b0;
        logic reset = 1'b1;
		logic irq = 1'b0;
		logic [31:0] id, memReadData = 32'd0, ia, memAddr, memWriteData;
		logic MemWrite, MemRead, MemReadReady = 1'b0, MemReadDone, MemHit;
		logic [31:0] memReadDataValue;
           
        logic [3:0] cntlIn;
		logic [31:0] iaExpected, memAddrExpected, newMemAddrExpected, incMemAddr;
                
		logic MemWriteExpected, MemReadExpected;
		logic [67:0] testVector[800:0];
        int i = 32'd0;
		logic checkOutputs;
        
        // Module under test declaration
        beta dutBeta(.clk(clk),.reset(reset),.irq(irq),.id(id),.memReadData(memReadData),.ia(ia),.memAddr(memAddr),.memWriteData(memWriteData),.MemWrite(MemWrite),.MemRead(MemRead),.MemReadReady(MemReadReady),.MemReadDone(MemReadDone),.MemHit(MemHit));
        
		// Create instruction memory
		imem5 dutImem(.clk(clk),.ia(ia),.id(id));
		
		// Create data memory
		dmem5 dutDmem(.clk(clk),.memAddr(memAddr),.memWriteData(memWriteData),.memReadData(memReadDataValue),.MemWrite(MemWrite),.MemRead(MemRead));
		
		// Generate clock signal
		always #(CYCLE_TIME) clk = ~clk;
		
        // Test
        initial
        begin         
           // Read test file
           $readmemh(testFileName, testVector);
        end
        
		// Code to deal with inputs and handshaking
		always @(posedge clk)
		begin
			// Assign signals and check for results
			if(i<numTests)
			begin
				{cntlIn, iaExpected, memAddrExpected} = testVector[i];

				// Set signals
				irq = cntlIn[3];
				reset = cntlIn[2];
				MemReadExpected = cntlIn[1];
				MemWriteExpected = cntlIn[0];
				
				// Delays due to data memory
				if(MemReadExpected)
				begin
					#1; // small delay due to simulation
					if(!MemHit)
					begin
						// Random delay between 2 and 10
						repeat($urandom_range(2,10)) @(posedge clk);
						
						// Once "memory ready," set value and set signal
						@(negedge clk);
						memReadData = memReadDataValue;
						MemReadReady = 1'b1;
						
						// Wait for Beta to complete read
						while(!MemReadDone)
							#1 memReadData = memReadDataValue;;
						
						// Release ready
						@(negedge clk);
						MemReadReady = 1'b0;
					end
				end
								
				// Increment i
				i=i+32'd1;
				
			end else begin
				// If all done, exit cleanly
				$display("Test Successful!\n");
				$stop;
			end				
		end
		
		// Code to check outputs
		assign checkOutputs = (~MemReadExpected & ~MemWriteExpected) | (MemHit & ~MemReadReady) | (~MemReadReady & MemReadDone);
		assign newMemAddrExpected = memAddrExpected;
		
		always @(negedge clk)
		begin
			if(checkOutputs)	
			begin
				// Wait until almost end of cycle
				#(CYCLE_TIME-3)
				
				// Check result
				if((ia!==iaExpected) || (memAddr!==newMemAddrExpected) || (MemWrite!==MemWriteExpected) || (MemRead!==MemReadExpected))
				begin
					$display("Error at simulation time = %0t\n",$time);
					$display("Expected ia = %h\t memAddr = %h",iaExpected, memAddrExpected);
					$display("Got      ia = %h\t memAddr = %h\n", ia, memAddr);
					$display("Expected MemWrite = %h\t MemRead = %h",MemWriteExpected, MemReadExpected);
					$display("Got      MemWrite = %h\t MemRead = %h\n", MemWrite, MemRead);
					$stop;
				end
			end
		end
		
 endmodule
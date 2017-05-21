# Script to run testbench

# Check for valid parameter
set readTestTypes {READ RMULTI}
set writeTestTypes {WB WBMULTI WT WTMULTI}
if {[lsearch $readTestTypes $1] >= 0 || [lsearch $writeTestTypes $1] >= 0} {
	# Valid input
	# Compile Beta
	vlog -reportprogress 300 -work work bool.sv
	vlog -reportprogress 300 -work work arith.sv
	vlog -reportprogress 300 -work work comp.sv
	vlog -reportprogress 300 -work work shift.sv
	vlog -reportprogress 300 -work work alu.sv
	vlog -reportprogress 300 -work work pc.sv
	vlog -reportprogress 300 -work work -suppress 7061 regfile.sv
	vlog -reportprogress 300 -work work ctl.sv
	vlog -reportprogress 300 -work work main.sv
			
	### ADD YOUR DESIGN FILES HERE FOR COMPILATION ###
	vlog -reportprogress 300 -work work branch.sv
	vlog -reportprogress 300 -work work jump.sv
	vlog -reportprogress 300 -work work cache.sv

	# Compile Testbench
	vlog -sv -reportprogress 300 -work work tests/imem5.sv
	vlog -sv -reportprogress 300 -work work tests/dmem5.sv

	# Check if read or read/write
	if {[lsearch $readTestTypes $1] >= 0} {
		# Simulate
		vlog -sv -reportprogress 300 -work work tests/testBeta5_read.sv
		vsim -t 1ps -L work -voptargs="+acc" -gtestFileName="tests/lab5test.txt" -gnumTests=81 -gtestType=$1 testBeta5_read

	} else {
		# Simulate
		vlog -sv -reportprogress 300 -work work tests/testBeta5_write.sv
		vsim -t 1ps -L work -voptargs="+acc" -gtestFileName="tests/lab5test.txt" -gnumTests=81 -gtestType=$1 testBeta5_write
	
	}
	
	do tests/opRadix.txt
	do tests/funcRadix.txt
	do tests/regRadix.txt

	# Add waves
	add wave -label Clk clk
	add wave -label Reset reset
	add wave -label IRQ irq
	add wave -radix hex -label IA ia
	add wave -radix hex -label ID id
	add wave -radix OP_LABELS -label OpCode {id[31:26]}
	add wave -radix FUNC_LABELS -label Funct {id[5:0]}
	add wave -radix REG_LABELS -label Rs {id[25:21]}
	add wave -radix REG_LABELS -label Rt {id[20:16]}
	add wave -radix REG_LABELS -label Rd {id[15:11]}
	add wave -radix hex -label MemToReg dutBeta/MemToReg
	add wave -radix hex -label MemAddr memAddr
	add wave -radix hex -label MemReadData memReadData
	add wave -label MemWrite MemWrite
	add wave -radix hex -label MemWriteData memWriteData
	add wave -radix hex -label cacheWriteData dutBeta/xcache/cacheWriteData
	add wave -radix hex -label MemWriteReady MemWriteReady
	add wave -radix hex -label MemWriteDone MemWriteDone
	add wave -label MemRead MemRead
	add wave -radix hex -label MemReadReady MemReadReady
	add wave -radix hex -label MemReadDone MemReadDone
	add wave -radix hex -label MemHit MemHit
	add wave -radix hex -label Stall dutBeta/Stall
	add wave -radix dec -label misscount dutBeta/xcache/misscount
	add wave -radix dec -label readcount dutBeta/xcache/readcount
	add wave -radix dec -label writecount dutBeta/xcache/writecount
	add wave -radix dec -label instrcount dutBeta/xpc/instrcount
	
	#### Add your debug signals here ####

	# Plot signal values
	view structure
	view signals
	run -a
	
} else {
	puts -nonewline {Error in calling test.  Make sure you use a valid test type (case matters):  }
	puts $testTypes
}
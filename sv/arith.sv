/*
	Cody Balos
	EPCE 173 - Computer Organization and Architecture
	Spring 2017
	University of the Pacific

	alu.sv: arithmetic module for ALU
*/


module arith(input logic [1:0] ALUOp,
	         input logic [31:0] A, B, 
	         output logic [31:0] arithout,
	         output logic z, v, n); // zero, overflow, and negative flags
	
	logic carry; // carry-out of add/sub operations 

	// determine arithout in here
	always_comb begin
		if (ALUOp[0] == 1'b0)
		begin // ADD
			// sign extend each operand 1-bit before adding for overflow checking
			{carry, arithout} = {A[31], A} + {B[31], B}; 
		end
		else 
		begin // SUB
			logic [31:0] B2C; // 2C of B
			B2C = ~B + 1'b1;
			// sign extend each operand 1-bit before adding for overflow checking
			{carry, arithout} = {A[31], A} + {B2C[31], B2C};
		end
	end
	
	// determine z,v,n in here
	always_comb begin
		z = ~|arithout;   // zero flag
		v = ({carry, arithout[31]} == 2'b01 || {carry, arithout[31]} == 2'b10); // overflow flag
		n = arithout[31]; // negative flag
	end
endmodule

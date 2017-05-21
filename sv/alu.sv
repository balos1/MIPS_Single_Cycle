/*
	Cody Balos
	EPCE 173 - Computer Organization and Architecture
	Spring 2017
	University of the Pacific
	
	32-bit ALU module which has the following operations:

	+------------+------------------------+---------------------------+
	| ALUOp[4:0] |       Operation        |   Output Value Y[31:0]    |
	+------------+------------------------+---------------------------+
	| 5'b00000   | 32-bit add             | Y = A + B                 |
	| 5'b00001   | 32 bit subtract        | Y = A - B                 |
	| 5'b00101   | CMPEQ                  | Y = (A == B)              |
	| 5'b00111   | CMPLT                  | Y = (A < B)               |
	| 5'b01101   | CMPLE                  | Y = (A <= B)              |
	| 5'b01000   | Shift left logical     | Y = A << B                |
	| 5'b01001   | Shift right logical    | Y = A >> B                |
	| 5'b01011   | Shift right arithmetic | Y = signed'A >>> signed'B |
	| 5'b11010   | Pass through           | Y = A                     |
	| 5'b11000   | AND                    | Y = A & B                 |
	| 5'b10001   | NOR                    | Y = ~(A | B)              |
	| 5'b11110   | OR                     | Y = A | B                 |
	| 5'b11001   | XNOR                   | Y = ~(A ^ B)              |
	| 5'b10110   | XOR                    | Y = A ^ B                 |
	+------------+------------------------+---------------------------+
*/

module alu(input logic [31:0] A, B, // operands
		   input logic [4:0] ALUOp, // ALU operation code
		   output logic [31:0] Y,   // result of operation
		   output logic z, v, n);   // zero, overflow, and negative flags
		   
	// Signal declarations
	logic [31:0] boolout, shiftout, arithout, compout;
	
	// Modules declarations
	bool xbool(ALUOp[3:0], A, B, boolout);
	arith xarith(ALUOp[1:0], A, B, arithout, z, v, n);
	comp xcomp(ALUOp[3], ALUOp[1], z, v, n, compout);
	shift xshift(ALUOp[1:0], A, B, shiftout);

	// Decide what connections to make based on ALUOp.
	always_comb begin
		if (ALUOp[4] == 1'b0) begin
			case (ALUOp[3:0])
				4'b0000: Y = arithout;
				4'b0001: Y = arithout;
				4'b0101: Y = compout;
				4'b0111: Y = compout;
				4'b1101: Y = compout;
				4'b1000: Y = shiftout;
				4'b1001: Y = shiftout;
				4'b1011: Y = shiftout;
				default: Y = 32'd0;
			endcase
		end
		else begin
			Y = boolout;
		end
	end
endmodule

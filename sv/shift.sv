/*
	Cody Balos
	EPCE 173 - Computer Organization and Architecture
	Spring 2017
	University of the Pacific

	shift.sv: shift module for ALU
*/
module shift(input logic [1:0] ALUOp,
			 input logic [31:0] A, B,
             output logic [31:0] shiftout);

    always_comb begin
        if (ALUOp == 2'b00)      // sll
            shiftout = A << B;  
        else if (ALUOp == 2'b01) // slr
            shiftout = A >> B;
        else if (ALUOp == 2'b11) // sra
            shiftout = signed'(A) >>> signed'(B);
        else // 2'b10 is undefined
            shiftout = 32'd0;
    end

endmodule
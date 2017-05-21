/*
	Cody Balos
	EPCE 173 - Computer Organization and Architecture
	Spring 2017
	University of the Pacific

	comp.sv: comparison module for ALU
*/

module comp(input logic ALUOp3,
            input logic ALUOp1,
            input logic z, v, n, // zero, overflow, and negative flags
            output logic [31:0] compout);

    always_comb begin
        if (ALUOp3 == 1'b1) // CMPLE (A <= B)
            // If equal than obviously the result of A - B is zero.
            // If the result is negative, and there was no overflow than it A < B. However, if the was result 
            // was positive, it A < B if overflow occured. Therefore, we must check this case too.
            compout = z == 1 || (n == 1 && v == 0) || (n == 0 && v == 1);
        else if (ALUOp1 == 1'b1) // CMPLT (A < B)
            // If the result is negative, and there was no overflow than it A < B. However, if the was result 
            // was positive, it A < B if overflow occured. Therefore, we must check this case too.
            compout = (n == 1 && v == 0) || (n == 0 && v == 1);
        else // CMPEQ (A == B)
             // If equal than obviously the result of A - B is zero.
            compout = z == 1;
    end

endmodule
/*
	Cody Balos
	EPCE 173 - Computer Organization and Architecture
	Spring 2017
	University of the Pacific

	bool.sv: boolean module for ALU
*/

module bool(input logic [3:0] ALUOp,
			input logic [31:0] A, B,
            output logic [31:0] boolout);

    always_comb begin
        if (ALUOp == 4'b1010)
            boolout = A;
        else if (ALUOp == 4'b1000)
            boolout = A & B;
        else if (ALUOp == 4'b0001)
            boolout = ~(A | B);
        else if (ALUOp == 4'b1110)
            boolout = A | B;
        else if (ALUOp == 4'b1001)
            boolout = ~(A ^ B);
        else if (ALUOp == 4'b0110)
            boolout = A ^ B;
        else 
            boolout = 32'd0;
    end

endmodule

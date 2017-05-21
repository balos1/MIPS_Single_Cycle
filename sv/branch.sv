/*
    Cody Balos
	EPCE 173 - Computer Organization and Architecture
	Spring 2017
	University of the Pacific
*/

`define BEQ 6'b000100
`define BNE 6'b000101

/*
    Module: branch

    The branch module for the single-cyle MIPS processor. It determines if a branch is taken or not taken, and 
    calculates the proper next instruction address. Currently, the module supports only BEQ and BNE.

    Parameters:
       opCode - The opCode for the current instruction.
       PCp4 - PC+4.
       Branch - Should a branch even be examined? It must be 1 if a branch should be examined.
       ALUz - The ALU 'zero' flag. When it is 1, then A == B.
       branchImm - The word-aligned offset to the instruction which we would branch to.
       branchAddr[out] - The address of the next instruction. 
*/
module branch(input logic [5:0] opCode,
              input logic [31:0] PCp4,
              input logic Branch, ALUz,
              input logic [15:0] branchImm,
              output logic [31:0] branchAddr);

    always_comb
    begin
        if (Branch) begin
            if ((opCode == `BEQ && ALUz) || (opCode == `BNE && !ALUz))
                branchAddr = ({{16{branchImm[15]}}, branchImm} << 2) + PCp4;
            else 
                branchAddr = PCp4;
        end
        else begin
            branchAddr = PCp4;
        end
    end

endmodule
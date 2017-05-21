/*
    Cody Balos
	EPCE 173 - Computer Organization and Architecture
	Spring 2017
	University of the Pacific
*/

`define JUMP_BRANCH 2'b00
`define JUMP_IMM    2'b01
`define JUMP_RA     2'b10

/*
    Module: jump

    The jump module for the single-cycle MIPS processor. It support MIPS instructions J, JAL, and JR.

    Parameters:
       superbit - The MSB of the instruction address, it indicates if the processor is running in supervisor mode or user mode.
       Jump - Determines what value to load into the PC next.
       offset - The offset to the instruction to jump to.
       PCp4 - The current instruction address + 4.
       radata - Read data 1 from the regfile.
       branchAddr - The word-aligned offset to the instruction which we would branch to.
       jumpAddr[out] - The address of the instruction to jump to. 
*/
module jump(input logic superbit,
            input logic [1:0] Jump,
            input logic [25:0] offset,
            input logic [31:0] PCp4, radata, branchAddr,
            output logic [31:0] jumpAddr);

    always_comb
    begin
        case(Jump)
            `JUMP_BRANCH: jumpAddr = {superbit, branchAddr[30:0]};
            `JUMP_IMM: jumpAddr = {superbit, {PCp4[31:28], {offset, 2'b0}}[30:0]};
            `JUMP_RA: 
                if (superbit == 1 && radata[31] == 0)
                    jumpAddr = radata;
                else
                    jumpAddr = {superbit, radata[30:0]};
        endcase
    end

endmodule
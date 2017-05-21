/*
    Cody Balos
	EPCE 173 - Computer Organization and Architecture
	Spring 2017
	University of the Pacific
*/

// Constant memory locations
`define RESET 32'h80000000
`define ILLOP 32'h80000004  // Illegal opcode handler address
`define XADR  32'h80000008  // Interrupt handler memory address

// Supervisor modes
`define SUPERBIT  31
`define USER       0
`define SUPERVISOR 1

// Mux Signals
`define PCSEL_DEFAULT 2'b00
`define PCSEL_IR      2'b01
`define PCSEL_ILLOP   2'b10


/*
    Module: pc

    A Program Counter module for a single cycle MIPS processor. Includes an active-high, asynchronous RESET that resets
    the system by setting PC=0x80000000. When it is not resetting it will increment the PC by 4 bytes, or it will
    follow a jump/branch.

    Parameters:
        clk - A clock signal which triggers PC increment on the rising-edge.
        reset - Asynchronous signal which resets the PC to 0x0 when high.
        Stall - Is asserted if processor needs to stall.    
        PCSel - It determines if the PC should be loaded with the value from the jump module/mux or an address of an exception handler.
        jumpAddr - The address of the next instruction to fetch IF not reset.
        PCp4[out] - It is the current instruction address plus four, i.e. the address of the next instruction.
        ia[out] - The next instruction address that will be fetched.
*/
module pc(input logic clk, reset, Stall,
          input logic [1:0] PCSel,
          input logic [31:0] jumpAddr,
          output logic [31:0] PCp4,
          output logic [31:0] ia);
        
    int instrcount; // Used for analysis of processor.

    always_ff @(posedge clk or posedge reset)
    begin
        if (reset) begin
            ia <= `RESET;
            instrcount = 1;
        end 
        else if (Stall) begin
            ia <= ia;
        end
        else if (PCSel == `PCSEL_IR) begin
            ia <= `XADR;
        end 
        else if (PCSel == `PCSEL_ILLOP) begin
            ia <= `ILLOP;
        end 
        else begin
            ia <= jumpAddr;
            instrcount = instrcount + 1;
        end 
    end

    always_comb
    begin
        PCp4 = ia + 4'h4;
    end

endmodule
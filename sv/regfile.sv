/*
    Cody Balos
	EPCE 173 - Computer Organization and Architecture
	Spring 2017
	University of the Pacific
*/

// Special registers and their index.
`define ZERO 5'h0
`define XP   5'h1
`define RA   5'h1F

`define REGDST_RD 2'b00
`define REGDST_RT 2'b01
`define REGDST_RA 2'b10
`define REGDST_XP 2'b11

/*
    Module: regfile

    Regfile is 3-port memory (2 read ports, 1 write port).

    Parameters:
        clk - A clock signal which triggers PC increment on the rising-edge.
        RegWrite - Control signal which must be asserted during a rising clock edge to write wdata to the specific reg.
        RegDest - Control signal which determines which register to write to.
        ra - Read register 1 address.
        rb - Read register 2 address. Can also be used as the destination/write register if RegDst is 1.
        rc - Default destination/write register.
        wdata - The data to write.
        radata[out] - Read data 1.
        rbdata[out] - Read data 2.
*/
module regfile(input logic clk, RegWrite, 
               input logic [1:0] RegDst,
               input logic [4:0] ra, rb, rc,
               input logic [31:0] wdata,
               output logic [31:0] radata, rbdata);

// 32, 32-bit registers.
logic [31:0] registers[31:0];

// Initialize all the registers to 0.
initial begin
    for (int i = 0; i < 32; ++i)
        registers[i] = 32'h0;
end

// Read regardless of clock.
always_comb
begin
    radata = registers[ra];
    rbdata = registers[rb];
end

// Write on rising edge of clock only.
always_ff @(posedge clk)
begin
    if (RegWrite) begin
        // Never allow the zero registers to be overwritten.
        if (RegDst == `REGDST_RD && rc != `ZERO)
            registers[rc] <= wdata;
        else if (RegDst == `REGDST_RT && rb != `ZERO)
            registers[rb] <= wdata;
        else if (RegDst == `REGDST_RA)
            registers[`RA] <= wdata;
        else if (RegDst == `REGDST_XP) begin
            registers[`XP] <= wdata;
        end
    end
end

endmodule
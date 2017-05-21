/*
    Cody Balos
	EPCE 173 - Computer Organization and Architecture
	Spring 2017
	University of the Pacific
*/

////////////////////// Supervisor modes /////////////////////////////
`define SUPERBIT 31
`define USER 0
`define SUPERVISOR 1

///////////////////// CONTROL SIGNAL VALUES ///////////////////////
`define ALUSRC1_RD1  0
`define ALUSRC1_PCP4 1
`define ALUSRC1_PC   2

`define ALUSRC2_RB    2'b00
`define ALUSRC2_SIMM  2'b01
`define ALUSRC2_SHAMT 2'b10
`define ALUSRC2_ZIMM  2'b11

`define MEM2REG_ALUOUT 0
`define MEM2REG_RDATA  1

/*
    Module: main

    Beta version of a single cycle MIPS processor which supports most instructions except branches and jumps.
      
                Supported operations
    +-----------+-----------+-------------+------+
    |  OPCODE   |   FUNCT   | Instruction | Type |
    +-----------+-----------+-------------+------+
    | 6'b000000 | 6'b000000 | SLL         | R    |
    | 6'b000000 | 6'b000010 | SRL         | R    |
    | 6'b000000 | 6'b000011 | SRA         | R    |
    | 6'b000000 | 6'b001000 | JR          | R    |
    | 6'b000000 | 6'b100000 | ADD         | R    |
    | 6'b000000 | 6'b100010 | SUB         | R    |
    | 6'b000000 | 6'b100110 | XOR         | R    |
    | 6'b000000 | 6'b100100 | AND         | R    |
    | 6'b000000 | 6'b100101 | OR          | R    |
    | 6'b000000 | 6'b100111 | NOR         | R    |
    | 6'b000000 | 6'b101010 | SLT         | R    |
    | 6'b000010 | XXXXXXXXX | J           | J    |
    | 6'b000011 | XXXXXXXXX | JAL         | J    |
    | 6'b000100 | XXXXXXXXX | BEQ         | I    |
    | 6'b000101 | XXXXXXXXX | BNE         | I    |
    | 6'b001000 | XXXXXXXXX | ADDI        | I    |
    | 6'b001100 | XXXXXXXXX | ANDI        | I    |
    | 6'b001101 | XXXXXXXXX | ORI         | I    |
    | 6'b001110 | XXXXXXXXX | XORI        | I    |
    | 6'b100011 | XXXXXXXXX | LW          | I    |
    | 6'b101011 | XXXXXXXXX | SW          | I    |
    +-----------+-----------+-------------+------+

    Parameters:
        clk - The system clock signal.
        reset - Asynchronous system reset signal.
        irq - The interrupt-request signal. When this signal is 1 and in “user mode”, an interrupt should occur.
		MemReadReady - In the case of a cache miss, this signal indicates when the data from memory is available to read.
        MemWriteDone - Is asserted when the memory write is completed.
        id - The instruction to execute (comes from instruction memory).
        memReadData - Data from data memory.
        ia[out] - The address of the next instruction to execute.
        memAddr[out] - The address of data memory to read or write.
        memWriteData[out] - The data to write into data memory.
        MemRead[out] - Is asserted to enable reading from data memory.
        MemWrite[out] - Is asserted to enable writing to data memory. 
		MemReadDone[out] - Is asserted when a data read is completed.
		MemHit[out] - Is asserted if there was a cache hit. 
        MemWriteReady[out] - Is asserted if the processor is writing to memory.
*/
module beta(input logic clk, reset, irq, MemReadReady, MemWriteDone,
            input logic [31:0] id, memReadData,
            output logic [31:0] ia, memAddr, memWriteData,
            output logic MemRead, MemWrite, MemReadDone, MemHit, MemWriteReady);

    // intermediate control signal declarations
    logic RegWrite, MemToReg, ALUz, ALUv, ALUn, Branch, Stall;
    logic [1:0] ALUSrc1, ALUSrc2, RegDst, Jump, PCSel;
    logic [4:0] ALUOp;

    // intermediate data signal declarations
    logic [31:0] radata, rbdata, regWriteData, ALUA, ALUB, ALUout, branchAddr, PCp4, jumpAddr;
    logic [31:0] cacheReadData;

    // module declarations
    pc xpc(.clk(clk), .reset(reset), .Stall(Stall), .PCSel(PCSel), .jumpAddr(jumpAddr), .PCp4(PCp4), .ia(ia));
    
    ctl xctl(.reset(reset), .irq(irq), .superbit(ia[`SUPERBIT]), .opCode(id[31:26]), .funct(id[5:0]), 
			 .RegWrite(RegWrite), .Branch(Branch), .MemWrite(MemWrite), .MemRead(MemRead), .MemToReg(MemToReg), 
             .ALUSrc1(ALUSrc1), .ALUSrc2(ALUSrc2), .RegDst(RegDst), .Jump(Jump), .PCSel(PCSel), .ALUOp(ALUOp));
    
    regfile xregfile(.clk(clk), .RegWrite(RegWrite), .RegDst(RegDst), .ra(id[25:21]), 
                     .rb(id[20:16]), .rc(id[15:11]), .wdata(regWriteData), .radata(radata),
                     .rbdata(rbdata));
   
    alu xalu(.A(ALUA), .B(ALUB), .ALUOp(ALUOp), .Y(ALUout), .z(ALUz), .v(ALUv), .n(ALUn));

    branch xbranch(.opCode(id[31:26]), .PCp4(PCp4), .Branch(Branch), .ALUz(ALUz), .branchImm(id[15:0]),
                   .branchAddr(branchAddr));

    jump xjump(.superbit(ia[`SUPERBIT]), .Jump(Jump), .offset(id[25:0]), .PCp4(PCp4), .radata(radata), 
               .branchAddr(branchAddr), .jumpAddr(jumpAddr));
			   
	cache xcache(.clk(clk), .reset(reset), .MemRead(MemRead), .MemReadReady(MemReadReady), .MemWrite(MemWrite), 
                 .MemWriteDone(MemWriteDone), .memAddr(memAddr), .memReadData(memReadData),
                 .cacheWriteData(memWriteData), .cacheReadData(cacheReadData), .MemHit(MemHit), 
                 .MemReadDone(MemReadDone), .MemWriteReady(MemWriteReady), .Stall(Stall));

    // Logic that is not handled in submodules.
    // I.e. the muxes and sign ext./zero-pad blocks in the diagram that we didnt take care of in any submodule.
    always_comb begin
        // ALUSrc1 mux: decides between PC+4 and register ra data.
        case (ALUSrc1)
            `ALUSRC1_RD1: ALUA = radata;
            `ALUSRC1_PCP4: ALUA = {ia[`SUPERBIT], PCp4[30:0]};
            `ALUSRC1_PC: ALUA = ia; 
        endcase;

        // ALUSrc2 mux: decides between register rb data and sign-extend/zero-pad logic outputs
        case (ALUSrc2)
            `ALUSRC2_RB: ALUB = rbdata;
            `ALUSRC2_SIMM: ALUB = {{16{id[15]}}, id[15:0]}; // sign-extension of 16-bit immediate
            `ALUSRC2_SHAMT: ALUB = {27'b0, id[10:6]}; // zero-pad 5-bit SHAMT
            `ALUSRC2_ZIMM: ALUB = {16'b0, id[15:0]}; // zero-pad logical I-types
        endcase;

        // MemToReg mux
        case(MemToReg)
            `MEM2REG_ALUOUT: regWriteData = ALUout;
            `MEM2REG_RDATA: regWriteData = cacheReadData;
        endcase
        
        // Constant connections
        memAddr = ALUout;
        memWriteData = rbdata;
    end
endmodule
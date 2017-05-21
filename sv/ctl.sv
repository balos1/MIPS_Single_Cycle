/*
    Cody Balos
	EPCE 173 - Computer Organization and Architecture
	Spring 2017
	University of the Pacific
*/

///////////////////// CONTROL SIGNAL VALUES ///////////////////////
`define ALUSRC1_RD1  0
`define ALUSRC1_PCP4 1
`define ALUSRC1_PC   2

`define ALUSRC2_RB    2'b00
`define ALUSRC2_SIMM  2'b01
`define ALUSRC2_SHAMT 2'b10
`define ALUSRC2_ZIMM  2'b11

`define BRANCH_NT 0
`define BRANCH_T  1

`define JUMP_BRANCH 2'b00
`define JUMP_IMM    2'b01
`define JUMP_RA     2'b10

`define MEM2REG_ALUOUT 0
`define MEM2REG_RDATA  1

`define PCSEL_DEFAULT 2'b00
`define PCSEL_IR      2'b01
`define PCSEL_ILLOP   2'b10

`define REGDST_RD 2'b00
`define REGDST_RT 2'b01
`define REGDST_RA 2'b10
`define REGDST_XP 2'b11

/*
    Module: ctl

    A control module for a single cycle MIPS processor. It is responsible for generating the correct control signals
    within the processor. 

    Parameters:
        reset - Sets all write enables to 0.
        irq - The interrupt-request signal. When this signal is 1 and in “user mode”, an interrupt should occur.
        superbit - Indicates if the processors is running in supervisor mode (when 1) or user mode (when 0).
        opCode - The instruction opCode.
        funct - The function code for R-Type instructions.
        RegWrite[out] - If asserted during a rising clock edge, it will allow the regfile to be written to.
        Branch[out] - Indicates if an instruction is a branch or not.
        MemWrite[out] - If asserted during a rising clock edge, it will allow the D-mem to be written to.
        MemRead[out] - If asserted it will allow the D-mem to be read from.
        MemToReg[out] - Determines if the output from D-mem or the ALU is used for write back.
        ALUSrc1[out] - Determines which data to use as the first ALU input.
        ALUSrc2[out] - Determines which data to use as the second ALU input.
        RegDst[out] - Determines which register (rb, rc or $ra) to use as the destination register.
        Jump[out] - Determines what value to load into the PC next.
        PCSel[out] - Determines if the PC should choose jumpAddr, interrupt start, or illop start.
        ALUOp[out] - The ALU operation code.
*/
module ctl(input logic reset, irq, superbit,
           input logic [5:0] opCode,
           input logic [5:0] funct,
           output logic RegWrite, Branch, MemWrite, MemRead, MemToReg,
           output logic [1:0] ALUSrc1, ALUSrc2, RegDst, Jump, PCSel,
           output logic [4:0] ALUOp);

    always_comb
    begin
        if (reset) begin
            RegDst = `REGDST_RD;
            ALUSrc1 = `ALUSRC1_RD1;
            ALUSrc2 = `ALUSRC2_RB;
            RegWrite = 0;
            MemWrite = 0;
            MemRead = 0;
            MemToReg = `MEM2REG_ALUOUT;
            Branch = `BRANCH_NT;
            Jump = `JUMP_BRANCH;
            ALUOp = 5'h0;
            PCSel = `PCSEL_DEFAULT;
        end 
        else if (irq && !superbit) begin
            RegDst = `REGDST_XP;
            RegWrite = 1;
            ALUSrc1 = `ALUSRC1_PCP4;
            ALUSrc2 = `ALUSRC2_RB;
            ALUOp = 5'b11010;
            MemWrite = 0;
            MemRead = 0;
            MemToReg = `MEM2REG_ALUOUT;
            Branch = `BRANCH_NT;
            Jump = `JUMP_BRANCH;
            PCSel = `PCSEL_IR;
        end
        else begin
            case (opCode)
                6'h0: begin // RTYPE
                    case(funct)
                        6'b000000: begin // SLL
                            RegDst = `REGDST_RD;
                            ALUSrc1 = `ALUSRC1_RD1;
                            ALUSrc2 = `ALUSRC2_SHAMT;
                            RegWrite = 1;
                            MemWrite = 0;
                            MemRead = 0;
                            MemToReg = `MEM2REG_ALUOUT;
                            Branch = `BRANCH_NT;
                            Jump = `JUMP_BRANCH;
                            ALUOp = 5'b01000;
                            PCSel = `PCSEL_DEFAULT;
                        end
                        6'b000010: begin // SRL
                            RegDst = `REGDST_RD;
                            ALUSrc1 = `ALUSRC1_RD1;
                            ALUSrc2 = `ALUSRC2_SHAMT;
                            RegWrite = 1;
                            MemWrite = 0;
                            MemRead = 0;
                            MemToReg = `MEM2REG_ALUOUT;
                            Branch = `BRANCH_NT;
                            Jump = `JUMP_BRANCH;
                            ALUOp = 5'b01001;
                            PCSel = `PCSEL_DEFAULT;
                        end
                        6'b000011: begin // SRA
                            RegDst = `REGDST_RD;
                            ALUSrc1 = `ALUSRC1_RD1;
                            ALUSrc2 = `ALUSRC2_SHAMT;
                            RegWrite = 1;
                            MemWrite = 0;
                            MemRead = 0;
                            MemToReg = `MEM2REG_ALUOUT;
                            Branch = `BRANCH_NT;
                            Jump = `JUMP_BRANCH;
                            ALUOp = 5'b01011;
                            PCSel = `PCSEL_DEFAULT;
                        end
                        6'b001000: begin // JR
                            RegDst = `REGDST_RD;
                            ALUSrc1 = `ALUSRC1_RD1;
                            ALUSrc2 = `ALUSRC2_RB;
                            RegWrite = 0;
                            MemWrite = 0;
                            MemRead = 0;
                            MemToReg = `MEM2REG_ALUOUT;
                            Branch = `BRANCH_NT;
                            Jump = `JUMP_RA;
                            ALUOp = 5'b00000;
                            PCSel = `PCSEL_DEFAULT;
                        end
                        6'b100000: begin // ADD
                            RegDst = `REGDST_RD;
                            ALUSrc1 = `ALUSRC1_RD1;
                            ALUSrc2 = `ALUSRC2_RB;
                            RegWrite = 1;
                            MemWrite = 0;
                            MemRead = 0;
                            MemToReg = `MEM2REG_ALUOUT;
                            Branch = `BRANCH_NT;
                            Jump = `JUMP_BRANCH;
                            ALUOp = 5'b00;
                            PCSel = `PCSEL_DEFAULT;
                        end
                        6'b100010: begin // SUB
                            RegDst = `REGDST_RD;
                            ALUSrc1 = `ALUSRC1_RD1;
                            ALUSrc2 = `ALUSRC2_RB;
                            RegWrite = 1;
                            MemWrite = 0;
                            MemRead = 0;
                            MemToReg = `MEM2REG_ALUOUT;
                            Branch = `BRANCH_NT;
                            Jump = `JUMP_BRANCH;
                            ALUOp = 5'b00001;
                            PCSel = `PCSEL_DEFAULT;
                        end
                        6'b100100: begin // AND
                            RegDst = `REGDST_RD;
                            ALUSrc1 = `ALUSRC1_RD1;
                            ALUSrc2 = `ALUSRC2_RB;
                            RegWrite = 1;
                            MemWrite = 0;
                            MemRead = 0;
                            MemToReg = `MEM2REG_ALUOUT;
                            Branch = `BRANCH_NT;
                            Jump = `JUMP_BRANCH;
                            ALUOp = 5'b11000;
                            PCSel = `PCSEL_DEFAULT;
                        end
                        6'b100101: begin // OR
                            RegDst = `REGDST_RD;
                            ALUSrc1 = `ALUSRC1_RD1;
                            ALUSrc2 = `ALUSRC2_RB;
                            RegWrite = 1;
                            MemWrite = 0;
                            MemRead = 0;
                            MemToReg = `MEM2REG_ALUOUT;
                            Branch = `BRANCH_NT;
                            Jump = `JUMP_BRANCH;
                            ALUOp = 5'b11110;
                            PCSel = `PCSEL_DEFAULT;
                        end
                        6'b100110: begin // XOR
                            RegDst = `REGDST_RD;
                            ALUSrc1 = `ALUSRC1_RD1;
                            ALUSrc2 = `ALUSRC2_RB;
                            RegWrite = 1;
                            MemWrite = 0;
                            MemRead = 0;
                            MemToReg = `MEM2REG_ALUOUT;
                            Branch = `BRANCH_NT;
                            Jump = `JUMP_BRANCH;
                            ALUOp = 5'b10110;
                            PCSel = `PCSEL_DEFAULT;
                        end
                        6'b100111: begin // NOR
                            RegDst = `REGDST_RD;
                            ALUSrc1 = `ALUSRC1_RD1;
                            ALUSrc2 = `ALUSRC2_RB;
                            RegWrite = 1;
                            MemWrite = 0;
                            MemRead = 0;
                            MemToReg = `MEM2REG_ALUOUT;
                            Branch = `BRANCH_NT;
                            Jump = `JUMP_BRANCH;
                            ALUOp = 5'b10001;
                            PCSel = `PCSEL_DEFAULT;
                        end
                        6'b101010: begin // SLT
                            RegDst = `REGDST_RD;
                            ALUSrc1 = `ALUSRC1_RD1;
                            ALUSrc2 = `ALUSRC2_RB;
                            RegWrite = 1;
                            MemWrite = 0;
                            MemRead = 0;
                            MemToReg = `MEM2REG_ALUOUT;
                            Branch = `BRANCH_NT;
                            Jump = `JUMP_BRANCH;
                            ALUOp = 5'b00111;
                            PCSel = `PCSEL_DEFAULT;
                        end
                        default: begin // ILLOP
                            RegDst = `REGDST_XP;
                            RegWrite = 1;
                            ALUSrc1 = `ALUSRC1_PCP4;
                            ALUSrc2 = `ALUSRC2_RB;
                            ALUOp = 5'b11010;
                            MemWrite = 0;
                            MemRead = 0;
                            MemToReg = `MEM2REG_ALUOUT;
                            Branch = `BRANCH_NT;
                            Jump = `JUMP_BRANCH;
                            PCSel = `PCSEL_ILLOP;
                        end
                    endcase
                end
                6'b000010: begin // J
                    RegDst = `REGDST_RD;
                    ALUSrc1 = `ALUSRC1_RD1;
                    ALUSrc2 = `ALUSRC2_RB;
                    RegWrite = 0;
                    MemWrite = 0;
                    MemRead = 0;
                    MemToReg = `MEM2REG_ALUOUT;
                    Branch = `BRANCH_NT;
                    Jump = `JUMP_IMM;
                    ALUOp = 5'b00000;
                    PCSel = `PCSEL_DEFAULT;
                end
                6'b000011: begin // JAL
                    RegDst = `REGDST_RA;
                    ALUSrc1 = 1;      // PC+4 will pass through ALU
                    ALUSrc2 = `ALUSRC2_RB;
                    RegWrite = 1;     // write PC+4 to $ra
                    MemWrite = 0;
                    MemRead = 0;
                    MemToReg = `MEM2REG_ALUOUT;
                    Branch = `BRANCH_NT;
                    Jump = `JUMP_IMM;
                    ALUOp = 5'b11010; // pass-through ALU
                    PCSel = `PCSEL_DEFAULT;
                end
                6'b000100: begin // BEQ
                    RegDst = `REGDST_RD;
                    ALUSrc1 = `ALUSRC1_RD1;
                    ALUSrc2 = `ALUSRC2_RB;
                    RegWrite = 0;
                    MemWrite = 0;
                    MemRead = 0;
                    MemToReg = `MEM2REG_ALUOUT;
                    Branch = `BRANCH_T;
                    Jump = `JUMP_BRANCH;
                    ALUOp = 5'b00001; // subtract
                    PCSel = `PCSEL_DEFAULT;
                end
                6'b000101: begin // BNE
                    RegDst = `REGDST_RD;
                    ALUSrc1 = `ALUSRC1_RD1;
                    ALUSrc2 = `ALUSRC2_RB;
                    RegWrite = 0;
                    MemWrite = 0;
                    MemRead = 0;
                    MemToReg = `MEM2REG_ALUOUT;
                    Branch = `BRANCH_T;
                    Jump = `JUMP_BRANCH;
                    ALUOp = 5'b00001; // subtract
                    PCSel = `PCSEL_DEFAULT;
                end
                6'b001000: begin // ADDI
                    RegDst = `REGDST_RT;
                    ALUSrc1 = `ALUSRC1_RD1;
                    ALUSrc2 = `ALUSRC2_SIMM;
                    RegWrite = 1;
                    MemWrite = 0;
                    MemRead = 0;
                    MemToReg = `MEM2REG_ALUOUT;
                    Branch = `BRANCH_NT;
                    Jump = `JUMP_BRANCH;
                    ALUOp = 5'b00;
                    PCSel = `PCSEL_DEFAULT;
                end
                6'b001100: begin // ANDI
                    RegDst = `REGDST_RT;
                    ALUSrc1 = `ALUSRC1_RD1;
                    ALUSrc2 = `ALUSRC2_ZIMM;
                    RegWrite = 1;
                    MemWrite = 0;
                    MemRead = 0;
                    MemToReg = `MEM2REG_ALUOUT;
                    Branch = `BRANCH_NT;
                    Jump = `JUMP_BRANCH;
                    ALUOp = 5'b11000;
                    PCSel = `PCSEL_DEFAULT;
                end
                6'b001101: begin // ORI
                    RegDst = `REGDST_RT;
                    ALUSrc1 = `ALUSRC1_RD1;
                    ALUSrc2 = `ALUSRC2_ZIMM;
                    RegWrite = 1;
                    MemWrite = 0;
                    MemRead = 0;
                    MemToReg = `MEM2REG_ALUOUT;
                    Branch = `BRANCH_NT;
                    Jump = `JUMP_BRANCH;
                    ALUOp = 5'b11110;
                    PCSel = `PCSEL_DEFAULT;
                end
                6'b001110: begin // XORI
                    RegDst = `REGDST_RT;
                    ALUSrc1 = `ALUSRC1_RD1;
                    ALUSrc2 = `ALUSRC2_ZIMM;
                    RegWrite = 1;
                    MemWrite = 0;
                    MemRead = 0;
                    MemToReg = `MEM2REG_ALUOUT;
                    Branch = `BRANCH_NT;
                    Jump = `JUMP_BRANCH;
                    ALUOp = 5'b10110;
                    PCSel = `PCSEL_DEFAULT;
                end
                6'b100011: begin // LW
                    RegDst = `REGDST_RT;
                    ALUSrc1 = `ALUSRC1_RD1;
                    ALUSrc2 = `ALUSRC2_SIMM;
                    RegWrite = 1;
                    MemWrite = 0;
                    MemRead = 1;
                    MemToReg = `MEM2REG_RDATA;
                    Jump = `JUMP_BRANCH;
                    ALUOp = 5'b00;
                    PCSel = `PCSEL_DEFAULT;
                end
                6'b101011: begin // SW
                    RegDst = `REGDST_RD;
                    ALUSrc1 = `ALUSRC1_RD1;
                    ALUSrc2 = `ALUSRC2_SIMM;
                    RegWrite = 0;
                    MemWrite = 1;
                    MemRead = 0;
                    MemToReg = `MEM2REG_ALUOUT;
                    Branch = `BRANCH_NT;
                    Jump = `JUMP_BRANCH;
                    ALUOp = 5'b00;
                    PCSel = `PCSEL_DEFAULT;
                end
                default: begin // ILLOP
                    RegDst = `REGDST_XP;
                    RegWrite = 1;
                    ALUSrc1 = `ALUSRC1_PCP4;
                    ALUSrc2 = `ALUSRC2_RB;
                    ALUOp = 5'b11010;
                    MemWrite = 0;
                    MemRead = 0;
                    MemToReg = `MEM2REG_ALUOUT;
                    Branch = `BRANCH_NT;
                    Jump = `JUMP_BRANCH;
                    PCSel = `PCSEL_ILLOP;
                end
            endcase
        end
    end

endmodule
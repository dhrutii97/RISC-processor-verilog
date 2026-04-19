// ============================================================
//  processor.v
//  Top-level RISCprocessor module
//  CSE302 Course Project - Five-cycle Non-pipelined RISC
//
//  Five Phases: IF(T0) / ID(T1) / EX(T2) / MEM(T3) / WB(T4)
//
//  Datapath MUXes inside this file:
//  1. Operand2 MUX    : RS2  vs IMMDATA          → ALU Operand2
//  2. WB MUX          : ALUout/SRAMout/StackOut/INportOut → RegFile Datain
//  3. Stack Datain MUX: ALUout(PUSH) / ALUout2(UMULT) / PC(CALL)
//  4. SRAM Addr MUX   : ADDR(direct) / XP(indirect)
//  5. PC Address MUX  : ADDR(jumps) / StackOut(RET)
// ============================================================

module RISCprocessor(
    input  wire        clk,
    input  wire        Reset,
    input  wire [7:0]  InpExtWorld1,
    input  wire [7:0]  InpExtWorld2,
    input  wire [7:0]  InpExtWorld3,
    input  wire [7:0]  InpExtWorld4,
    output wire [7:0]  OutExtWorld1,
    output wire [7:0]  OutExtWorld2,
    output wire [7:0]  OutExtWorld3,
    output wire [7:0]  OutExtWorld4
);

// ============================================================
// SECTION 1: Internal wires
// ============================================================

    // Timing
    wire T0, T1, T2, T3, T4;

    // Program Counter
    wire [11:0] PC;
    wire [11:0] PC_addr_in;   // address fed to PC (jump target or stack for RET)

    // Instruction Memory outputs
    wire [31:0] InstDataout;
    wire [7:0]  Opcode;
    wire [3:0]  Destin;
    wire [3:0]  Source1;
    wire [3:0]  Source2;
    wire [3:0]  Source3;
    wire [11:0] ADDR;
    wire [7:0]  ImmData;
    wire [3:0]  ADDR4;

    // Control signals
    wire PCenable, InstRead, PCupdate;
    wire SRAMRead, SRAMWrite;
    wire StackRead, StackWrite;
    wire ALUSave, ZflagSave, CflagSave;
    wire INportRead, OUTportWrite;
    wire RegFileRead, RegFileWrite;

    // Flags
    wire ZFlag, CFlag;

    // Register File
    wire [7:0] RS1_data;   // Dataout1 = RS1
    wire [7:0] RS2_data;   // Dataout2 = RS2
    wire [7:0] RS3_data;   // Dataout3 = RS3 (for STOREI)
    wire [7:0] WB_data;    // data written back to RegFile

    // ALU
    wire [7:0] ALUout;
    wire [7:0] ALUout2;    // high byte for UMULT
    wire [7:0] Operand2;   // muxed: RS2 or IMMDATA

    // SRAM
    wire [7:0]  SRAMout;
    wire [11:0] SRAM_addr; // muxed: ADDR or XP

    // Stack
    wire [7:0] StackOut;
    wire [7:0] Stack_datain; // muxed: ALUout(PUSH)/ALUout2(UMULT)/PC_low(CALL)

    // INport
    wire [7:0] INportOut;

// ============================================================
// SECTION 2: Module Instantiations
// ============================================================

    // --- Timing Generator ---
    TimingGen timegen(
        .clk(clk), .Rst(Reset),
        .T0(T0), .T1(T1), .T2(T2), .T3(T3), .T4(T4)
    );

    // --- Program Counter ---
    // PC address input: ADDR for jumps, StackOut (zero-extended) for RET
    // RET pops an 8-bit value from stack → zero-extend to 12 bits
    assign PC_addr_in = (Opcode == 8'h24) ? {4'b0000, StackOut} : ADDR;

    ProgCounter pc(
        .clk(clk), .Rst(Reset),
        .PCenable(PCenable),
        .PCupdate(PCupdate),
        .Address(PC_addr_in),
        .PC(PC)
    );

    // --- Instruction Memory ---
    InstMEM4096 imem(
        .clk(clk), .Rst(Reset),
        .Address(PC),
        .InstRead(InstRead),
        .Dataout(InstDataout),
        .Opcode(Opcode),
        .Destin(Destin),
        .Source1(Source1),
        .Source2(Source2),
        .Source3(Source3),
        .ADDR(ADDR),
        .ImmData(ImmData),
        .ADDR4(ADDR4)
    );

    // --- Control Logic ---
    ControlLogic ctrl(
        .clk(clk), .Rst(Reset),
        .T0(T0), .T1(T1), .T2(T2), .T3(T3), .T4(T4),
        .ZFlag(ZFlag), .CFlag(CFlag),
        .Opcode(Opcode),
        .PCenable(PCenable),
        .InstRead(InstRead),
        .PCupdate(PCupdate),
        .SRAMRead(SRAMRead),
        .SRAMWrite(SRAMWrite),
        .StackRead(StackRead),
        .StackWrite(StackWrite),
        .ALUSave(ALUSave),
        .ZflagSave(ZflagSave),
        .CflagSave(CflagSave),
        .INportRead(INportRead),
        .OUTportWrite(OUTportWrite),
        .RegFileRead(RegFileRead),
        .RegFileWrite(RegFileWrite)
    );

    // --- Register File ---
    RegisterFile regfile(
        .clk(clk), .Rst(Reset),
        .RegFileRead(RegFileRead),
        .RegFileWrite(RegFileWrite),
        .Datain(WB_data),
        .Source1(Source1),
        .Source2(Source2),
        .Source3(Source3),
        .Destin(Destin),
        .Dataout1(RS1_data),
        .Dataout2(RS2_data),
        .Dataout3(RS3_data)
    );

// ============================================================
// MUX 1: Operand2 selection (before ALU)
// RS2 for register ops, IMMDATA for immediate ops
// ============================================================
    // Immediate instructions:
    // 02H ADDI, 05H SUBI, 0AH ANDI, 0CH ORI, 0EH EXORI,
    // 08H CMPI, 11H MOVI
    wire op2_is_imm;
    assign op2_is_imm = (Opcode == 8'h02) || (Opcode == 8'h05) ||
                        (Opcode == 8'h08) || (Opcode == 8'h0A) ||
                        (Opcode == 8'h0C) || (Opcode == 8'h0E) ||
                        (Opcode == 8'h11);

    assign Operand2 = op2_is_imm ? ImmData : RS2_data;

    // --- ALU ---
    ALU8 alu(
        .clk(clk), .Rst(Reset),
        .Operand1(RS1_data),
        .Operand2(Operand2),
        .Opcode(Opcode),
        .ALUSave(ALUSave),
        .ZflagSave(ZflagSave),
        .CflagSave(CflagSave),
        .ZFlag(ZFlag),
        .CFlag(CFlag),
        .ALUout(ALUout),
        .ALUout2(ALUout2)
    );

// ============================================================
// MUX 2: SRAM Address selection
// ADDR for LOAD/STORE, XP = {RS1[3:0], RS2[7:0]} for LOADI/STOREI
// ============================================================
    wire [11:0] XP;
    assign XP = {RS1_data[3:0], RS2_data[7:0]};

    wire sram_use_xp;
    assign sram_use_xp = (Opcode == 8'h15) || (Opcode == 8'h17);

    assign SRAM_addr = sram_use_xp ? XP : ADDR;

    // --- SRAM4096 (Data Memory) ---
    // STORE: writes RS1_data (passed through ALUout from ALU case 16/17)
    // STOREI: writes RS3_data directly
    wire [7:0] SRAM_datain;
    assign SRAM_datain = (Opcode == 8'h17) ? RS3_data : ALUout;

    SRAM4096 sram(
        .clk(clk), .Rst(Reset),
        .Address(SRAM_addr),
        .SRAMRead(SRAMRead),
        .SRAMWrite(SRAMWrite),
        .Datain(SRAM_datain),
        .Dataout(SRAMout)
    );

// ============================================================
// MUX 3: Stack Datain selection
// PUSH     → ALUout (= RS1 passed through ALU)
// UMULT    → ALUout2 (high byte)
// CALL     → PC[7:0] (return address, low 8 bits)
//            Note: PC is 12-bit; stack is 8-bit
//            Upper 4 bits of PC are lost (limitation of 8-bit stack)
//            For full support, two pushes would be needed — 
//            keeping simple per project scope
// ============================================================
    assign Stack_datain =
        (Opcode == 8'h27) ? ALUout2   :   // UMULT high byte
        (Opcode == 8'h23) ? PC[7:0]   :   // CALL: push return addr
                            ALUout     ;   // PUSH (default)

    // --- Stack ---
    Stack256 stack(
        .clk(clk), .Rst(Reset),
        .StackRead(StackRead),
        .StackWrite(StackWrite),
        .Datain(Stack_datain),
        .Dataout(StackOut)
    );

    // --- INport ---
    INport inport(
        .clk(clk), .Rst(Reset),
        .INportRead(INportRead),
        .InpExtWorld1(InpExtWorld1),
        .InpExtWorld2(InpExtWorld2),
        .InpExtWorld3(InpExtWorld3),
        .InpExtWorld4(InpExtWorld4),
        .Address(ADDR4),
        .Dataout(INportOut)
    );

    // --- OUTport ---
    OUTport outport(
        .clk(clk), .Rst(Reset),
        .Address(ADDR4),
        .Datain(ALUout),       // RS1 passed through ALU for OUT
        .OUTportWrite(OUTportWrite),
        .OutExtWorld1(OutExtWorld1),
        .OutExtWorld2(OutExtWorld2),
        .OutExtWorld3(OutExtWorld3),
        .OutExtWorld4(OutExtWorld4)
    );

// ============================================================
// MUX 4: Write Back data selection → RegFile Datain
// ALUout   → all ALU instructions
// SRAMout  → LOAD, LOADI
// StackOut → POP
// INportOut→ IN
// ============================================================
    assign WB_data =
        ((Opcode == 8'h14) || (Opcode == 8'h15)) ? SRAMout   :
        (Opcode == 8'h26)                         ? StackOut  :
        (Opcode == 8'h28)                         ? INportOut :
                                                    ALUout    ;

endmodule

// ============================================================
//  testbench.v  —  Self-checking testbench for RISCprocessor
//  5-stage non-pipelined RISC (IF/ID/EX/MEM/WB)
//
//  Simulation command (Icarus Verilog):
//    iverilog -o sim testbench.v subcomponents.v processor.v
//    vvp sim
//
//  program.mem must be in the working directory (loaded by
//  InstMEM4096 via $readmemb).
//
// ============================================================
//  Test program (program.mem)  –  instruction encoding summary
// ============================================================
//  Format: [31:24]=Opcode | [23:20]=Destin | [19:16]=Src1
//          [15:12]=Src2   | [11:0]=ADDR    | [7:0]=ImmData
//
//  Addr  | Assembly               | Expected effect
//  ------+------------------------+------------------------------
//  0x000 | MOVI  R0, 10           | R0 = 10
//  0x001 | MOVI  R1, 20           | R1 = 20
//  0x002 | ADD   R2, R0, R1       | R2 = 30, ALUout=30
//  0x003 | STORE R2, 0x050        | mem[0x050]=30  (ALUout=30
//        |                        |  retained from ADD; ALUSave
//        |                        |  is NOT asserted for STORE
//        |                        |  in ControlLogic — place
//        |                        |  STORE immediately after the
//        |                        |  instruction that produced
//        |                        |  the data to be stored)
//  0x004 | LOAD  R6, 0x050        | R6 = mem[0x050] = 30
//  0x005 | ADDI  R3, R2, 5        | R3 = 35
//  0x006 | SUB   R4, R1, R0       | R4 = 10
//  0x007 | MOVI  R5, 0            | R5 = 0
//  0x008 | CMP   R0, R5           | 10-0≠0 → Z=0, C=1
//  0x009 | JZ    0x00B            | Z=0 → NOT taken; fall-thru
//  0x00A | JMP   0x00C            | unconditional; skip 0x00B
//  0x00B | MOVI  R0, 0xFF         | ** SKIPPED by JMP **
//  0x00C | NOP                    | landing pad
//  0x00D-0x013 | NOP (padding)    |
//
//  Expected final register file:
//    R0=10  R1=20  R2=30  R3=35  R4=10  R5=0  R6=30
//  Expected flags after CMP R0,R5:
//    ZFlag=0  CFlag=1
// ============================================================

`timescale 1ns/1ps

module testbench;

// ----------------------------------------------------------------
// DUT ports
// ----------------------------------------------------------------
reg        clk;
reg        Reset;
reg  [7:0] InpExtWorld1, InpExtWorld2, InpExtWorld3, InpExtWorld4;
wire [7:0] OutExtWorld1, OutExtWorld2, OutExtWorld3, OutExtWorld4;

// ----------------------------------------------------------------
// Device under test
// ----------------------------------------------------------------
RISCprocessor uut (
    .clk          (clk),
    .Reset        (Reset),
    .InpExtWorld1 (InpExtWorld1),
    .InpExtWorld2 (InpExtWorld2),
    .InpExtWorld3 (InpExtWorld3),
    .InpExtWorld4 (InpExtWorld4),
    .OutExtWorld1 (OutExtWorld1),
    .OutExtWorld2 (OutExtWorld2),
    .OutExtWorld3 (OutExtWorld3),
    .OutExtWorld4 (OutExtWorld4)
);

// ----------------------------------------------------------------
// Clock  (10 ns period = 100 MHz)
// ----------------------------------------------------------------
initial clk = 0;
always  #5 clk = ~clk;

// ----------------------------------------------------------------
// Pass / Fail counters
// ----------------------------------------------------------------
integer pass_cnt;
integer fail_cnt;

// ----------------------------------------------------------------
// Task: compare an 8-bit value and report PASS/FAIL
// ----------------------------------------------------------------
task check8;
    input [7:0]   actual;
    input [7:0]   expected;
    input [127:0] label;
    begin
        if (actual === expected) begin
            $display("  PASS  %-14s = %0d", label, actual);
            pass_cnt = pass_cnt + 1;
        end else begin
            $display("  FAIL  %-14s = %0d  (expected %0d)",
                      label, actual, expected);
            fail_cnt = fail_cnt + 1;
        end
    end
endtask

// ----------------------------------------------------------------
// Task: compare a 1-bit flag
// ----------------------------------------------------------------
task check1;
    input         actual;
    input         expected;
    input [127:0] label;
    begin
        if (actual === expected) begin
            $display("  PASS  %-14s = %b", label, actual);
            pass_cnt = pass_cnt + 1;
        end else begin
            $display("  FAIL  %-14s = %b  (expected %b)",
                      label, actual, expected);
            fail_cnt = fail_cnt + 1;
        end
    end
endtask

// ----------------------------------------------------------------
// Task: dump CPU state (register file + key signals)
// ----------------------------------------------------------------
task dump_state;
    begin
        $display("");
        $display("  PC      = 0x%03X", uut.PC);
        $display("  Opcode  = 0x%02X", uut.Opcode);
        $display("  ZFlag   = %b   CFlag = %b", uut.ZFlag, uut.CFlag);
        $display("  TimingRing = T4T3T2T1T0 = %b%b%b%b%b",
                  uut.timegen.T4, uut.timegen.T3, uut.timegen.T2,
                  uut.timegen.T1, uut.timegen.T0);
        $display("");
        $display("  R0 =%4d  R1 =%4d  R2 =%4d  R3 =%4d",
                  uut.regfile.d0,  uut.regfile.d1,
                  uut.regfile.d2,  uut.regfile.d3);
        $display("  R4 =%4d  R5 =%4d  R6 =%4d  R7 =%4d",
                  uut.regfile.d4,  uut.regfile.d5,
                  uut.regfile.d6,  uut.regfile.d7);
        $display("  R8 =%4d  R9 =%4d  R10=%4d  R11=%4d",
                  uut.regfile.d8,  uut.regfile.d9,
                  uut.regfile.d10, uut.regfile.d11);
        $display("  R12=%4d  R13=%4d  R14=%4d  R15=%4d",
                  uut.regfile.d12, uut.regfile.d13,
                  uut.regfile.d14, uut.regfile.d15);
        $display("");
        $display("  SRAM[0x050] = %0d", uut.sram.datamemlarge[12'h050]);
        $display("");
    end
endtask

// ----------------------------------------------------------------
// Main stimulus
// ----------------------------------------------------------------
initial begin
    // -- Waveform capture --
    $dumpfile("testbench.vcd");
    $dumpvars(0, testbench);

    // -- Initialise --
    pass_cnt     = 0;
    fail_cnt     = 0;
    // Port inputs available if IN instructions are added later
    InpExtWorld1 = 8'h42;   // 66
    InpExtWorld2 = 8'h07;   //  7
    InpExtWorld3 = 8'h00;
    InpExtWorld4 = 8'h00;

    // -- Reset sequence --
    Reset = 1;
    repeat(4) @(posedge clk);
    #1;                         // de-assert between edges
    Reset = 0;

    $display("============================================================");
    $display("  RISCprocessor Testbench  (reset released at t=%0t ns)", $time);
    $display("============================================================");

    // -- Wait for all 13 instructions to complete --
    // Timing breakdown after reset de-asserts:
    //   5 cycles: T1→T4→T0 pipeline drain of the reset NOP
    //   13 * 5 = 65 instruction cycles
    //   + 10 cycles safety margin
    //   = 80 cycles total
    repeat(80) @(posedge clk);

    // -- Display final CPU state --
    $display("--- CPU state after program execution ---");
    dump_state();

    // ---- Self-checking assertions ----
    $display("--- Assertions ---");

    // Immediate loads
    check8(uut.regfile.d0,  8'd10,  "R0 (MOVI 10)");
    check8(uut.regfile.d1,  8'd20,  "R1 (MOVI 20)");

    // Arithmetic
    check8(uut.regfile.d2,  8'd30,  "R2 (ADD)");
    check8(uut.regfile.d3,  8'd35,  "R3 (ADDI)");
    check8(uut.regfile.d4,  8'd10,  "R4 (SUB)");
    check8(uut.regfile.d5,  8'd0,   "R5 (MOVI 0)");

    // STORE / LOAD round-trip through SRAM
    check8(uut.sram.datamemlarge[12'h050], 8'd30, "SRAM[0x050]");
    check8(uut.regfile.d6,  8'd30,  "R6 (LOAD)");

    // Flags after CMP R0, R5  (10 - 0 → result=10, Z=0, carry-out=1)
    check1(uut.ZFlag, 1'b0, "ZFlag (CMP)");
    check1(uut.CFlag, 1'b1, "CFlag (CMP)");

    // JZ not-taken: execution fell through to addr 0x00A
    // JMP taken: addr 0x00B (MOVI R0,0xFF) was skipped → R0 still 10
    check8(uut.regfile.d0,  8'd10,  "R0 (JZ+JMP)");

    if (uut.regfile.d0 === 8'd10) begin
        $display("  PASS  JMP skip       (MOVI R0,0xFF at 0x00B not executed)");
        pass_cnt = pass_cnt + 1;
    end else begin
        $display("  FAIL  JMP skip       R0=%0d (expected 10; JMP not taken?)",
                  uut.regfile.d0);
        fail_cnt = fail_cnt + 1;
    end

    // ---- Summary ----
    $display("");
    $display("============================================================");
    if (fail_cnt == 0)
        $display("  ALL TESTS PASSED  (%0d / %0d)", pass_cnt, pass_cnt);
    else
        $display("  %0d PASSED  |  %0d FAILED", pass_cnt, fail_cnt);
    $display("============================================================");
    $display("");

    $finish;
end

// ----------------------------------------------------------------
// Monitor output ports (fires only when a port changes value)
// ----------------------------------------------------------------
initial begin
    $monitor("  [t=%6t ns]  OUT1=%0d  OUT2=%0d  OUT3=%0d  OUT4=%0d",
              $time,
              OutExtWorld1, OutExtWorld2, OutExtWorld3, OutExtWorld4);
end

endmodule
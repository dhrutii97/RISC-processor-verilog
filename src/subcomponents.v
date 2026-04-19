//8bit Reg with SyncL
module eightbitReg_withLoad(clk, Datain, Rst, L, Dataout);
  input clk, L, Rst;
  input [7:0] Datain;
  output reg [7:0] Dataout;
  
  wire [7:0] Y;
  
  assign Y = (L==1'b1) ? Datain : Dataout;
  
  always @(posedge clk)
    begin
      if (Rst==1'b1)
        Dataout <= 8'b0000_0000;
      else 
        Dataout <= Y;
    end
endmodule

//4to16 Decoder for destination selection of register file (structural modelling)
module decoder1bit_4to16_withE(A,E,D);
  //A = input(dest of reg)
  input [3:0] A;
  input E; //E=enable(Reg_W)
  output wire [15:0] D;
  
  and (D[0], E, ~A[3], ~A[2], ~A[1], ~A[0]); //0000
  and (D[1], E, ~A[3], ~A[2], ~A[1], A[0]); //0001
  and (D[2], E, ~A[3], ~A[2], A[1], ~A[0]); //0010
  and (D[3], E, ~A[3], ~A[2], A[1], A[0]); //0011
  and (D[4], E, ~A[3], A[2], ~A[1], ~A[0]); //0100
  and (D[5], E, ~A[3], A[2], ~A[1], A[0]); //0101
  and (D[6], E, ~A[3], A[2], A[1], ~A[0]); //0110
  and (D[7], E, ~A[3], A[2], A[1], A[0]); //0111
  and (D[8], E, A[3], ~A[2], ~A[1], ~A[0]); //1000
  and (D[9], E, A[3], ~A[2], ~A[1], A[0]); //1001
  and (D[10], E, A[3], ~A[2], A[1], ~A[0]); //1010
  and (D[11], E, A[3], ~A[2], A[1], A[0]); //1011
  and (D[12], E, A[3], A[2], ~A[1], ~A[0]); //1100
  and (D[13], E, A[3], A[2], ~A[1], A[0]); //1101
  and (D[14], E, A[3], A[2], A[1], ~A[0]); //1110
  and (D[15], E, A[3], A[2], A[1], A[0]); //1111
  
endmodule

//4to1 mux 8 bit (data flow modelling)
module Mux4to1_8bit(I0,I1,I2,I3,S,Y);
  input [7:0] I0,I1,I2,I3;
  input [1:0] S;
  output wire [7:0] Y;

  assign Y = (S==2'b00)? I0 :
             (S==2'b01)? I1 :
             (S==2'b10)? I2 :
    		 (S==2'b11)? I3 :
    		 8'b0000_0000;
endmodule


//16to1 8 bit Mux for source selection of dataout of reg file (structural)
module Mux16to1_8bit(I0,I1,I2,I3,I4,I5,I6,I7,I8,I9,I10,I11,I12,I13,I14,I15,S,Y);
  
  input [7:0] I0,I1,I2,I3,I4,I5,I6,I7,
              I8,I9,I10,I11,I12,I13,I14,I15;
  input [3:0] S;
  output wire [7:0] Y;

  wire [7:0] W0, W1, W2, W3;

  Mux4to1_8bit M0(I0, I1, I2, I3, S[1:0], W0);
  Mux4to1_8bit M1(I4, I5, I6, I7, S[1:0], W1);
  Mux4to1_8bit M2(I8, I9, I10, I11, S[1:0], W2);
  Mux4to1_8bit M3(I12, I13, I14, I15, S[1:0], W3);


  Mux4to1_8bit M4(W0, W1, W2, W3, S[3:2], Y);

endmodule


module RegisterFile(clk, Rst, RegFileRead, RegFileWrite, 
                    Datain, Source1, Source2, Source3, Destin, 
                    Dataout1, Dataout2, Dataout3);
  
  input clk, Rst, RegFileRead, RegFileWrite;
  input [7:0] Datain;
  input [3:0] Source1, Source2, Source3, Destin;
  
  output wire [7:0] Dataout1;
  output wire [7:0] Dataout2;
  output wire [7:0] Dataout3;
  
  wire [15:0] L;
  
  //desination choice selection decoder
  decoder1bit_4to16_withE dinst(Destin,RegFileWrite,L);
  
  wire [7:0] d0;
  wire [7:0] d1;
  wire [7:0] d2;
  wire [7:0] d3;
  wire [7:0] d4;
  wire [7:0] d5;
  wire [7:0] d6;
  wire [7:0] d7;
  wire [7:0] d8;
  wire [7:0] d9;
  wire [7:0] d10;
  wire [7:0] d11;
  wire [7:0] d12;
  wire [7:0] d13;
  wire [7:0] d14;
  wire [7:0] d15;
  
  //16 reg instances
  eightbitReg_withLoad reginst0(clk, Datain, Rst, L[0], d0);
  eightbitReg_withLoad reginst1(clk, Datain, Rst, L[1], d1);
  eightbitReg_withLoad reginst2(clk, Datain, Rst, L[2], d2);
  eightbitReg_withLoad reginst3(clk, Datain, Rst, L[3], d3);
  eightbitReg_withLoad reginst4(clk, Datain, Rst, L[4], d4);
  eightbitReg_withLoad reginst5(clk, Datain, Rst, L[5], d5);
  eightbitReg_withLoad reginst6(clk, Datain, Rst, L[6], d6);
  eightbitReg_withLoad reginst7(clk, Datain, Rst, L[7], d7);
  eightbitReg_withLoad reginst8(clk, Datain, Rst, L[8], d8);
  eightbitReg_withLoad reginst9(clk, Datain, Rst, L[9], d9);
  eightbitReg_withLoad reginst10(clk, Datain, Rst, L[10], d10);
  eightbitReg_withLoad reginst11(clk, Datain, Rst, L[11], d11);
  eightbitReg_withLoad reginst12(clk, Datain, Rst, L[12], d12);
  eightbitReg_withLoad reginst13(clk, Datain, Rst, L[13], d13);
  eightbitReg_withLoad reginst14(clk, Datain, Rst, L[14], d14);
  eightbitReg_withLoad reginst15(clk, Datain, Rst, L[15], d15);
  
  wire[7:0] Y1, Y2, Y3;
  
  //dataout choice selection muxes
  Mux16to1_8bit muxinst1(d0,d1,d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14,d15,Source1,Y1);
  
  Mux16to1_8bit muxinst2(d0,d1,d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14,d15,Source2,Y2);
  
  Mux16to1_8bit muxinst3(d0,d1,d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14,d15,Source3,Y3);
  
  //last 3 FFs for sunchronous read
  eightbitReg_withLoad regR1(clk, Y1, Rst, RegFileRead, Dataout1);
  
  eightbitReg_withLoad regR2(clk, Y2, Rst, RegFileRead, Dataout2);
  
  eightbitReg_withLoad regR3(clk, Y3, Rst, RegFileRead, Dataout3);
  
endmodule

//12 bit adder for Program Counter
module adder_12bit (a, b, cin, sum, cout);
  input[11:0] a,b;
  input cin;  
  output wire [11:0] sum;
  output wire cout;     
  assign {cout, sum} = a + b + cin;
endmodule


//2to1 12 bit mux for PC
module Mux2to1_12bit(I0, I1, S, Y);
  input [11:0] I0, I1;
  input S;
  output wire [11:0] Y;
  assign Y = (S == 1'b0) ? I0 : I1;
endmodule


//12 bit FF
module twelvebitReg_withLoad(clk, Datain, Rst, L, Dataout);
  input clk, L, Rst;
  input [11:0] Datain;
  output reg [11:0] Dataout;
  
  wire [11:0] Y;
  
  assign Y = (L==1'b1) ? Datain : Dataout;
  
  always @(posedge clk)
    begin
      if (Rst==1'b1)
        Dataout <= 12'b0000_0000_0000;
      else 
        Dataout <= Y;
    end
endmodule

module ProgCounter(clk, Rst, PCenable, PCupdate, Address, PC);
  input clk, Rst, PCenable, PCupdate;
  input [11:0] Address;
  output wire [11:0] PC;
  
  wire [11:0] Y;
  Mux2to1_12bit pcmux1(12'b0000_0000_0000, 12'b0000_0000_0001, PCenable, Y);
  
  wire [11:0] sum;
  wire cout;
  adder_12bit addpc1(PC, Y, 1'b0, sum, cout);
  
  wire [11:0] D;
  Mux2to1_12bit pcmux2(sum, Address, PCupdate, D);
  
  twelvebitReg_withLoad PCff(clk, D, Rst, 1'b1, PC);
  
endmodule

module INport(clk, Rst, INportRead, InpExtWorld1, InpExtWorld2, InpExtWorld3, InpExtWorld4, Address, Dataout);
  input clk, Rst, INportRead;
  input [7:0] InpExtWorld1, InpExtWorld2, InpExtWorld3, InpExtWorld4;
  input [3:0] Address;
  
  output wire [7:0] Dataout;
  
  wire [7:0] d0, d1, d2, d3;
  
  eightbitReg_withLoad inff1(clk, InpExtWorld1, Rst, 1'b1, d0);
  eightbitReg_withLoad inff2(clk, InpExtWorld2, Rst, 1'b1, d1);
  eightbitReg_withLoad inff3(clk, InpExtWorld3, Rst, 1'b1, d2);
  eightbitReg_withLoad inff4(clk, InpExtWorld4, Rst, 1'b1, d3);
  
  wire [7:0] Y;
  Mux4to1_8bit inmux(d0,d1,d2,d3,Address[1:0],Y);
  
  eightbitReg_withLoad inportff(clk, Y, Rst, INportRead, Dataout);
  
endmodule

module OUTport(clk, Rst, Address, Datain, OUTportWrite, OutExtWorld1, OutExtWorld2, OutExtWorld3, OutExtWorld4);
  
  input clk, Rst, OUTportWrite;
  input [3:0] Address;
  input [7:0] Datain;

  output wire [7:0] OutExtWorld1, OutExtWorld2, OutExtWorld3, OutExtWorld4;
  
  wire L0, L1, L2, L3;
  
  //comparing and ANDing
  assign L0 = OUTportWrite & (Address == 4'b1000);
  assign L1 = OUTportWrite & (Address == 4'b1001);
  assign L2 = OUTportWrite & (Address == 4'b1010);
  assign L3 = OUTportWrite & (Address == 4'b1011);
  
  eightbitReg_withLoad outreg1(clk, Datain, Rst, L0, OutExtWorld1);
  eightbitReg_withLoad outreg2(clk, Datain, Rst, L1, OutExtWorld2);
  eightbitReg_withLoad outreg3(clk, Datain, Rst, L2, OutExtWorld3);
  eightbitReg_withLoad outreg4(clk, Datain, Rst, L3, OutExtWorld4);

endmodule

//Timing Generator T0 to T4
module TimingGen(clk, Rst, T0, T1, T2, T3, T4);
  input clk,Rst;
  output wire T0, T1, T2, T3, T4;
  
  reg [4:0] ring;
  
  always @(posedge clk)
    begin
      if (Rst==1'b1)
        ring <= 5'b00001;
      else
        ring <= {ring[3:0], ring[4]};
    end
  
  assign {T4,T3,T2,T1,T0} = ring;
endmodule

//Instruction Memory
module InstMEM4096(clk, Rst, Address, InstRead, Dataout, Opcode, Destin, Source1, Source2, Source3, ADDR, ImmData, ADDR4);
  input clk, Rst, InstRead;
  input [11:0] Address;
  
  output wire [31:0] Dataout;
  output wire [7:0] Opcode;
  output wire [3:0] Destin;
  output wire [3:0] Source1;
  output wire [3:0] Source2;
  output wire [3:0] Source3;
  output wire [11:0] ADDR;
  output wire [7:0] ImmData;
  output wire [3:0] ADDR4;
  
  reg [31:0] instmemory [0:4095];
  reg [31:0] instruction;
  
  //reading instruction set from program.mem fileS
  initial begin
    $readmemb("program.mem", instmemory);
  end
    
  
  always @(posedge clk)
    begin
      if(Rst==1'b1)
        instruction <= 32'b0;
      else if(InstRead == 1'b1)
        instruction <= instmemory[Address];
    end
  
  assign Dataout = instruction;
  assign Opcode = instruction[31:24];
  assign Destin = instruction[23:20];
  assign Source1 = instruction[19:16];
  assign Source2 = instruction[15:12];
  assign Source3 = instruction[3:0];
  assign ADDR = instruction[11:0];
  assign ImmData = instruction[7:0];
  assign ADDR4 = instruction[3:0];
  
endmodule

//Small Data Memory (256 words - 8 bits each), Address = 8 bits
module SRAM256(clk, Rst, Address, SRAMRead, SRAMWrite, Datain, Dataout);
  input clk, Rst, SRAMRead, SRAMWrite;
  input [7:0] Address;
  input [7:0] Datain;
  output wire [7:0] Dataout;
  
  reg [7:0] datamemsmall [0:255];
  reg [7:0] data_reg;
  
  //Write
  always @(posedge clk)
    begin
      if(SRAMWrite == 1'b1)
        datamemsmall[Address] <= Datain;
    end
  
  //Read
  always @(posedge clk)
    begin
      if(Rst == 1'b1)
        data_reg <= 8'b0;
      else if(SRAMRead == 1'b1)
        data_reg <= datamemsmall[Address];
    end
  assign Dataout = data_reg;
  
endmodule

//Bigger Data memory (4096 words, 8 bits) Address = 12 bits
module SRAM4096(clk, Rst, Address, SRAMRead, SRAMWrite, Datain, Dataout);
  input clk, Rst, SRAMRead, SRAMWrite;
  input [11:0] Address;
  input [7:0] Datain;
  output wire [7:0] Dataout;
  
  reg [7:0] datamemlarge [0:4095];
  reg [7:0] data_reg;
  
  //Write
  always @(posedge clk)
    begin
      if(SRAMWrite == 1'b1)
        datamemlarge[Address] <= Datain;
    end
  
  //Read
  always @(posedge clk)
    begin
      if(Rst == 1'b1)
        data_reg <= 8'b0;
      else if(SRAMRead == 1'b1)
        data_reg <= datamemlarge[Address];
    end
  assign Dataout = data_reg;
  
endmodule

//IncDec
module IncDec(RS1, mode, RD);
  input [7:0] RS1;
  input mode;
  output wire [7:0] RD;
  
  wire [7:0] B;
  
  //XOR with 1 for 1s complement if valid
  assign B = 8'b0000_0001 ^ {8{mode}};
  
  assign RD = RS1 + B + mode;
endmodule

//Stack
module Stack256(clk, Rst, StackRead, StackWrite, Datain, Dataout);
  input clk, Rst, StackRead, StackWrite;
  input [7:0] Datain;
  output wire [7:0] Dataout;
  
  wire [7:0] SP, SP_plus, SP_minus;
  
  //Increment, Decrememnt
  IncDec plus(SP, 1'b0, SP_plus);
  IncDec minus(SP, 1'b1, SP_minus);
  
  //SP update mux
  wire [1:0] sel_sp;
  
  assign sel_sp =
    (Rst)  			? 2'b11:
    (StackWrite) 	? 2'b01:
    (StackRead) 	? 2'b10:
  					  2'b00;
  
  wire [7:0] SP_next;
  Mux4to1_8bit spupdate(SP,SP_plus,SP_minus,8'b0000_0000,sel_sp,SP_next);
  
  //SP register
  eightbitReg_withLoad spreg(clk, SP_next,Rst, 1'b1, SP);
  
  //Address selection mux
  wire [1:0] sel_addr;
  
  assign sel_addr =
    (StackRead) 	? 2'b01 :
    (StackWrite) 	? 2'b00 :
    				  2'b00;
  
  wire [7:0] Address;
  Mux4to1_8bit addrsel(SP,SP_minus,SP,SP,sel_addr,Address);
  
  SRAM256 stackmem(clk, Rst, Address, StackRead, StackWrite, Datain, Dataout);
  
endmodule

module ALU8(clk, Rst, Operand1, Operand2, Opcode, ALUSave, ZflagSave, CflagSave, ZFlag, CFlag, ALUout, ALUout2);
  input clk, Rst, ALUSave, ZflagSave, CflagSave;
  input [7:0] Operand1, Operand2, Opcode;
  output reg ZFlag, CFlag;
  output reg [7:0] ALUout, ALUout2;
  
  //Adder inputs
  reg [7:0] addA, addB;
  reg addCin;
  wire [8:0] addResult; //9 bit adder {cout, sum}
  
  assign addResult = {1'b0, addA} + {1'b0, addB} + {8'b0, addCin};
  
  wire [15:0] multResult;
  assign multResult = Operand1 * Operand2;
  
  reg [7:0] result, result_high;
  reg carry_out;
  
  always @(*) begin
    result = 8'b0;
	result_high = 8'b0;
  	carry_out = 1'b0;
    
    addA = 8'b0;
	addB = 8'b0;
	addCin = 1'b0;
    
    case(Opcode)
      //NOP
      8'h00:begin
        result = 8'b0;
        carry_out = 1'b0;
      end
      
      //ADD Rs1 + Rs2
      8'h01: begin
        addA = Operand1;
        addB = Operand2;
        addCin = 1'b0;
        result = addResult[7:0];
        carry_out = addResult[8];
      end
      
      //ADDI RS1 + IMM
      8'h02: begin
        addA = Operand1;
        addB = Operand2; //Imm
        addCin = 1'b0;
        result = addResult[7:0];
        carry_out = addResult[8];
      end
      
      //ADDC Rs1 + Rs2 + C
      8'h03: begin
        addA = Operand1;
        addB = Operand2;
        addCin = CFlag;
        result = addResult[7:0];
        carry_out = addResult[8];
      end
      
      //SUB RS! + (1'scompof RS2) + 1
      8'h04: begin
        addA = Operand1;
        addB = ~Operand2;
        addCin = 1'b1;
        result = addResult[7:0];
        carry_out = addResult[8];
      end
      
      //SUBI RS1 + 1s comp of Imm + 1
      8'h05: begin
        addA = Operand1;
        addB = ~Operand2; //imm inverted
        addCin = 1'b1;
        result = addResult[7:0];
        carry_out = addResult[8];
      end
      
      //SUBC RS1 + 1s comp of RS2 + C
      8'h06: begin
        addA = Operand1;
        addB = ~Operand2;
        addCin = CFlag;
        result = addResult[7:0];
        carry_out = addResult[8];
      end
      
      //CMP
      8'h07: begin
        addA = Operand1;
        addB = ~Operand2;
        addCin = 1'b1;
        result = addResult[7:0];
        carry_out = addResult[8];
      end
      
      //CMPI
      8'h08: begin
        addA = Operand1;
        addB = ~Operand2; //imm inverted
        addCin = 1'b1;
        result = addResult[7:0];
        carry_out = addResult[8];
      end
      
      //AND
      8'h09: begin
        result = Operand1 & Operand2;
        carry_out = 1'b0;
      end
      
      //ANDI
      8'h0A: begin
        result = Operand1 & Operand2; //imm
        carry_out = 1'b0;
      end
      
      //OR
      8'h0B: begin
        result = Operand1 | Operand2;
        carry_out = 1'b0;
      end
      
      //ORI
      8'h0C: begin
        result = Operand1 | Operand2; //imm
        carry_out = 1'b0;
      end
      
      //ExOR
      8'h0D: begin
        result = Operand1 ^ Operand2;
        carry_out = 1'b0;
      end
      
      //ExORI
      8'h0E: begin
        result = Operand1 ^ Operand2; //imm
        carry_out = 1'b0;
      end
      
      //INC
      8'h0F: begin
        addA = Operand1;
        addB = 8'h01;
        addCin = 1'b0;
        result = addResult[7:0];
        carry_out = addResult[8];
      end
      
      //DEC
      8'h10: begin
        addA = Operand1;
        addB = ~(8'h01); //8'hFE
        addCin = 1'b1;
        result = addResult[7:0];
        carry_out = addResult[8];
      end
      
      //MOVI: RD <- IMMDATA (Operand2 carries IMMDATA)
      //No ALU arithmetic; just pass IMMDATA through
      8'h11: begin
        result = Operand2; //imm
        carry_out = 1'b0;
      end
      
      //MOV RD <- RS1
      8'h12: begin
        result = Operand1;
        carry_out = 1'b0;
      end
      
      //MOVF RD <- {C, 6'b00000, Z}
      8'h13: begin
        result = {CFlag, 6'b000000, ZFlag};
        carry_out = 1'b0;
      end
      
      //LOAD/LOADI (pass through)
      8'h14, 8'h15: begin
        result = Operand1;
        carry_out = 1'b0;
      end
      
      //STORE/STOREI
      8'h16, 8'h17: begin
        result = Operand1;
        carry_out = 1'b0;
      end
      
      //LRS: Logical Shift Right
      //RD = {1'b0, RS1[7:1]},  C = RS1[0]
      8'h18: begin
        result = {1'b0, Operand1[7:1]};
        carry_out = Operand1[0];
      end
      
      //ARS: Arithemetic Shift Right
      // RD = {RS1[7], RS1[7:1]},  C = RS1[0]
      8'h19: begin
        result = {Operand1[7], Operand1[7:1]};
        carry_out = Operand1[0];
      end
      
      //LLS: Logical SHift Left
      // RD = {RS1[6:0], 1'b0},  C = RS1[7]
      8'h1A: begin
        result =  {Operand1[6:0], 1'b0};
        carry_out = Operand1[7];
      end
      
      //ROTR:Rotate Right
      // RD = {RS1[0], RS1[7:1]},  C = RS1[0]
      8'h1B: begin
        result = {Operand1[0], Operand1[7:1]};
        carry_out = Operand1[0];
      end
      
      //ROTL: Rotate Left
      // RD = {RS1[6:0], RS1[7]},  C = RS1[7]
      8'h1C: begin
        result = {Operand1[6:0], Operand1[7]};
        carry_out = Operand1[7];
      end
      
      //ROTRC: Rotate Right through Carry
      // {C, RD} = {RS1[0], C, RS1[7:1]},  C = RS1[0]
      8'h1D: begin
        result = {CFlag, Operand1[7:1]};
        carry_out = Operand1[0];
      end
      
      //ROTLC: Rotate Left through Carry
      //{C, RD} = {RS1[7:0], C},  C = RS1[7]
      8'h1E:begin
        result = {Operand1[6:0], CFlag};
        carry_out = Operand1[7];
      end
      
      //JMP to RET
      // Jump address selection done outside ALU (in PC logic).
      // ALU produces no meaningful result; pass zero.
      8'h1F, 8'h20, 8'h21, 8'h22, 8'h23, 8'h24, 8'h2A: begin
        result = 8'b0;
        carry_out = 1'b0;
      end
      
      //PUSH/POP
      // Data routing to/from Stack handled in MEM stage outside ALU.
      // Pass RS1 through so datapath can forward to Stack data-in.
      8'h25:begin
        result = Operand1;
        carry_out = 1'b0;
      end
      
      8'h26: begin
        result = 8'b0;
        carry_out = 1'b0;
      end
      
      //UMULT: unsigned 8x8 multiply
      // Low byte  -> ALUout  (written to RD in WB)
      // High byte -> ALUout2 (written to Stack in MEM stage)
      8'h27: begin
        result = multResult[7:0];
        result_high = multResult[15:8];
        carry_out = 1'b0;
      end
      
      //INport
      // Port read data is muxed in WB stage, outside ALU.
      // Pass zero from ALU.
      8'h28: begin
        result = 8'b0;
        carry_out = 1'b0;
      end
      
      //OUTport
      // Pass RS1 so OUTport can sample it in MEM stage.
      8'h29: begin
        result = Operand1;
        carry_out = 1'b0;
      end
      
      //default
      default:begin
        result = 8'b0;
        carry_out = 1'b0;
      end
    endcase
  end
  
  wire zero_comb = (result==8'b0);
  
  always @(posedge clk)
    begin
      if(Rst) begin
        ALUout <= 8'b0;
        ALUout2 <= 8'b0;
        ZFlag <= 1'b0;
        CFlag <= 1'b0;
      end
      else begin
        if(ALUSave) begin
          ALUout <= result;
          ALUout2 <= result_high; //non zero only for umult
        end
        
        if(ZflagSave)
          ZFlag <= zero_comb;
        
        if(CflagSave)
          CFlag <= carry_out;
      end
    end
endmodule

module ControlLogic(clk, Rst, T0, T1, T2, T3, T4, ZFlag,CFlag, Opcode, PCenable, InstRead, PCupdate, SRAMRead, SRAMWrite, StackRead, StackWrite, ALUSave, ZflagSave, CflagSave, INportRead, OUTportWrite, RegFileRead, RegFileWrite);
  
  input clk, Rst, T0, T1, T2, T3, T4, ZFlag, CFlag;
  input [7:0] Opcode;
  
  output wire PCenable, InstRead, PCupdate, SRAMRead, SRAMWrite, StackRead, StackWrite, ALUSave, ZflagSave, CflagSave, INportRead, OUTportWrite, RegFileRead, RegFileWrite;
  
  assign PCenable  = T0;
  assign InstRead  = T0;
  
  assign PCupdate = T4 & (
        (Opcode == 8'h2A)                   ||
        (Opcode == 8'h1F && ZFlag == 1'b1)  ||
        (Opcode == 8'h20 && ZFlag == 1'b0)  ||
        (Opcode == 8'h21 && CFlag == 1'b1)  ||
        (Opcode == 8'h22 && CFlag == 1'b0)  ||
        (Opcode == 8'h23)                   ||
        (Opcode == 8'h24)
    );

    assign SRAMWrite = T3 & (Opcode == 8'h16 || Opcode == 8'h17);
    assign SRAMRead  = T3 & (Opcode == 8'h14 || Opcode == 8'h15);

    assign RegFileRead = T1 & (
        Opcode != 8'h00 && Opcode != 8'h11 &&
        Opcode != 8'h1F && Opcode != 8'h20 &&
        Opcode != 8'h21 && Opcode != 8'h22 && Opcode != 8'h2A
    );

    assign RegFileWrite = T4 & (
        Opcode == 8'h01 || Opcode == 8'h02 || Opcode == 8'h03 ||
        Opcode == 8'h04 || Opcode == 8'h05 || Opcode == 8'h06 ||
        Opcode == 8'h09 || Opcode == 8'h0A || Opcode == 8'h0B ||
        Opcode == 8'h0C || Opcode == 8'h0D || Opcode == 8'h0E ||
        Opcode == 8'h0F || Opcode == 8'h10 || Opcode == 8'h11 ||
        Opcode == 8'h12 || Opcode == 8'h13 || Opcode == 8'h14 ||
        Opcode == 8'h15 || Opcode == 8'h18 || Opcode == 8'h19 ||
        Opcode == 8'h1A || Opcode == 8'h1B || Opcode == 8'h1C ||
        Opcode == 8'h1D || Opcode == 8'h1E || Opcode == 8'h26 ||
        Opcode == 8'h27 || Opcode == 8'h28
    );

    assign ALUSave = T2 & (
        Opcode == 8'h01 || Opcode == 8'h02 || Opcode == 8'h03 ||
        Opcode == 8'h04 || Opcode == 8'h05 || Opcode == 8'h06 ||
        Opcode == 8'h07 || Opcode == 8'h08 || Opcode == 8'h09 ||
        Opcode == 8'h0A || Opcode == 8'h0B || Opcode == 8'h0C ||
        Opcode == 8'h0D || Opcode == 8'h0E || Opcode == 8'h0F ||
        Opcode == 8'h10 || Opcode == 8'h11 || Opcode == 8'h12 ||
        Opcode == 8'h13 || Opcode == 8'h18 || Opcode == 8'h19 ||
        Opcode == 8'h1A || Opcode == 8'h1B || Opcode == 8'h1C ||
        Opcode == 8'h1D || Opcode == 8'h1E || Opcode == 8'h25 ||
        Opcode == 8'h27 || Opcode == 8'h29
    );

    assign ZflagSave = T2 & (
        Opcode == 8'h01 || Opcode == 8'h02 || Opcode == 8'h03 ||
        Opcode == 8'h04 || Opcode == 8'h05 || Opcode == 8'h06 ||
        Opcode == 8'h07 || Opcode == 8'h08 || Opcode == 8'h09 ||
        Opcode == 8'h0A || Opcode == 8'h0B || Opcode == 8'h0C ||
        Opcode == 8'h0D || Opcode == 8'h0E || Opcode == 8'h0F ||
        Opcode == 8'h10 || Opcode == 8'h18 || Opcode == 8'h19 ||
        Opcode == 8'h1A || Opcode == 8'h1B || Opcode == 8'h1C ||
        Opcode == 8'h1D || Opcode == 8'h1E
    );

    assign CflagSave = T2 & (
        Opcode == 8'h01 || Opcode == 8'h02 || Opcode == 8'h03 ||
        Opcode == 8'h04 || Opcode == 8'h05 || Opcode == 8'h06 ||
        Opcode == 8'h07 || Opcode == 8'h08 || Opcode == 8'h18 ||
        Opcode == 8'h19 || Opcode == 8'h1A || Opcode == 8'h1B ||
        Opcode == 8'h1C || Opcode == 8'h1D || Opcode == 8'h1E
    );

    assign StackWrite = T3 & (Opcode == 8'h25 || Opcode == 8'h27 || Opcode == 8'h23);
    assign StackRead   = T3 & (Opcode == 8'h26 || Opcode == 8'h24);
    assign OUTportWrite = T3 & (Opcode == 8'h29);
    assign INportRead  = T3 & (Opcode == 8'h28);

endmodule
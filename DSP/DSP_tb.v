module DSP_tb();
parameter A0REG = 0;
parameter A1REG = 1;
parameter B0REG = 0;
parameter B1REG = 1;
parameter CREG = 1;
parameter DREG = 1;
parameter MREG = 1;
parameter PREG = 1;
parameter CARRYINREG = 1;
parameter CARRYOUTREG = 1;
parameter OPMODEREG = 1;
parameter CARRYINSEL = "OPMODE5";
parameter B_INPUT = "DIRECT";
parameter RSTTYPE = "SYNC";

reg [17:0] A, B, D, BCIN;
reg [47:0] C, PCIN;
reg [7:0] OPMODE;
reg CARRYIN, CLK;
reg RSTA, RSTB, RSTC, RSTD, RSTP, RSTM, RSTOPMODE, RSTCARRYIN;
reg CEA, CEB, CEC, CED, CEP, CEM, CEOPMODE, CECARRYIN;
wire [17:0] BCOUT;
wire [47:0] PCOUT, P;
wire [35:0] M;
wire CARRYOUT, CARRYOUTF;

DSP DUT (
        .A(A), .B(B), .D(D), .BCIN(BCIN), .C(C), .PCIN(PCIN), 
        .CARRYIN(CARRYIN), .CLK(CLK), .OPMODE(OPMODE),
        .RSTA(RSTA), .RSTB(RSTB), .RSTC(RSTC), .RSTD(RSTD), 
        .RSTCARRYIN(RSTCARRYIN), .RSTP(RSTP), .RSTM(RSTM), 
        .RSTOPMODE(RSTOPMODE), .CEA(CEA), .CEB(CEB), .CEC(CEC),
        .CED(CED), .CEM(CEM), .CEOPMODE(CEOPMODE), .CEP(CEP), 
        .CECARRYIN(CECARRYIN), .BCOUT(BCOUT), .PCOUT(PCOUT), 
        .P(P), .M(M), .CARRYOUT(CARRYOUT), .CARRYOUTF(CARRYOUTF)
    );

initial begin
	CLK = 0;
	forever
	#1 CLK = ~CLK;
end

initial begin
	A = 0; B = 0; C = 0; D = 0;
	BCIN = 0; PCIN = 0; CARRYIN = 0;
	CEA = 0; CEB = 0; CEC = 0; CECARRYIN = 0;
	CED = 0; CEM = 0; CEOPMODE = 0; CEP = 0;
	RSTA = 0; RSTB = 0; RSTC = 0; RSTD = 0; RSTP = 0; 
	RSTM = 0; RSTCARRYIN = 0; RSTOPMODE = 0;
	repeat (4) @(negedge CLK);

	RSTA = 1; RSTB = 1; RSTC = 1; RSTD = 1; RSTP = 1; 
	RSTM = 1; RSTCARRYIN = 1; RSTOPMODE = 1;
	repeat (4) @(negedge CLK);

	RSTA = 0; RSTB = 0; RSTC = 0; RSTD = 0; RSTP = 0; 
	RSTM = 0; RSTCARRYIN = 0; RSTOPMODE = 0;
	
	CEA = 1; CEB = 1; CEC = 1; CECARRYIN = 1;
	CED = 1; CEM = 1; CEOPMODE = 1; CEP = 1;
	
	// Test Case 1: Pre-adder & Post-adder
	A = 22; B = 17; C = 7; D = 5;
	PCIN = 10;
	OPMODE = 8'b0001_0101;
	repeat (4) @(negedge CLK); //12
	if (P != ((D + B) * A + PCIN)) $stop;

	// Test Case 2: Pre-adder & Post-subtractor
	A = 1; B = 1; C = 1; D = 1;
	PCIN = 2;
	OPMODE = 8'b1001_0101;
	repeat (4) @(negedge CLK); //-8
	if (P != ((D + B) * A - PCIN)) $stop;

	// Test Case 3: Pre-subtractor & Post-adder
	A = 5; B = 3; C = 1; D = 6;
	PCIN = 10;
	OPMODE = 8'b0101_0101;
	repeat (4) @(negedge CLK); //10
	if (P != ((D - B) * A + PCIN)) $stop;

	// Test Case 4: Pre-subtractor & Post-subtractor
	A = 1; B = 5; C = 3; D = 6;
	PCIN = 1;
	OPMODE = 8'b1101_0101;
	repeat (4) @(negedge CLK); //-10
	if (P != ((D - B) * A - PCIN)) $stop;

	// Test Case 5: Pre-adder & Post-adder with B bypass 
	A = 1; B = 7; C = 2; D = 3;
	PCIN = 5;
	OPMODE = 8'b0000_0101;
	repeat(4) @(negedge CLK); //10
	if (P != ((B * A + PCIN))) $stop;

	// Test Case 6: Pre-adder & Post-adder + OPMODE[5] Carry
	A = 5; B = 20; C = 13; D = 9;
	PCIN = 4;
	OPMODE = 8'b0011_0101;
	repeat(4) @(negedge CLK); //13
	if (P != ((D + B) * A + PCIN + OPMODE[5])) $stop;

	// Test Case 7: Concatenation & Z_out = 0
	A = 4; B = 11; C = 6; D = 1;
	OPMODE = 8'b0000_0011;
	repeat(4) @(negedge CLK);
	if (P != {D[11:0], A[17:0], B[17:0]}) $stop;

	// Test Case 8: X_out = 0 & Zout = C
	A = 10; B = 1; C = 8; D = 5;
	OPMODE = 8'b0000_1100;
	repeat(4) @(negedge CLK);
	if (P != C) $stop;

	$stop;
end
endmodule
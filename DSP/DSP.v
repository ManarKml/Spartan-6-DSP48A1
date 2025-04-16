module DSP #(
	parameter A0REG = 0,
	parameter A1REG = 1,
	parameter B0REG = 0,
	parameter B1REG = 1,
	parameter CREG = 1,
	parameter DREG = 1,
	parameter MREG = 1,
	parameter PREG = 1,
	parameter CARRYINREG = 1,
	parameter CARRYOUTREG = 1,
	parameter OPMODEREG = 1,
	parameter CARRYINSEL = "OPMODE5",
	parameter B_INPUT = "DIRECT",
	parameter RSTTYPE = "SYNC"
	) (
	input [17:0] A, B, D, BCIN,
	input [47:0] C, PCIN,
	input [7:0] OPMODE,
	input CARRYIN, CLK,
	input RSTA, RSTB, RSTC, RSTD, RSTP, RSTM, RSTOPMODE, RSTCARRYIN,
	input CEA, CEB, CEC, CED, CEP, CEM, CEOPMODE, CECARRYIN,
	output [17:0] BCOUT,
	output [47:0] PCOUT, P,
	output [35:0] M,
	output CARRYOUT, CARRYOUTF
	);

wire [17:0] A_Reg0, A_Reg1, B_Reg0, B_Reg1, D_Reg;
wire [47:0] C_Reg;
wire [7:0] OPMODE_Reg;

wire [17:0] B0Reg_in;
assign B0Reg_in = (B_INPUT == "DIRECT")? B :
				  (B_INPUT == "CASCADE")? BCIN : 0;

wire [17:0] Pre_out;
assign Pre_out = (OPMODE_Reg[6])? D_Reg - B_Reg0 : D_Reg + B_Reg0;
	
wire [17:0] B1Reg_in;
assign B1Reg_in = (OPMODE_Reg[4])? Pre_out : B_Reg0;
assign BCOUT = B_Reg1;

wire [35:0] M_Reg;
wire [35:0] Mult_out;
assign Mult_out = A_Reg1 * B_Reg1;
assign M = M_Reg;

reg [47:0] X_out;
// Case 1 inside always block

reg [47:0] Z_out;
// Case 2 inside always block
	
wire CYI_Reg;
assign CYI_Reg = (CARRYINSEL == "OPMODE5")? OPMODE_Reg[5] : 
				 (CARRYINSEL == "CARRYIN")? CARRYIN : 0; 
wire CIN;
wire [47:0] Post_out;
wire COUT;
assign {COUT, Post_out} = (OPMODE_Reg[7])? Z_out - (X_out + CIN) : Z_out + X_out + CIN;

assign CARRYOUTF = CARRYOUT;
assign PCOUT = P;


FF_MUX #(.N(18), .SEL(A0REG), .RSTTYPE(RSTTYPE)) A_REG0 (A, CLK, RSTA, CEA, A_Reg0);
FF_MUX #(.N(18), .SEL(A1REG), .RSTTYPE(RSTTYPE)) A_REG1 (A_Reg0, CLK, RSTA, CEA, A_Reg1);
FF_MUX #(.N(48), .SEL(CREG), .RSTTYPE(RSTTYPE)) C_REG (C, CLK, RSTC, CEC, C_Reg);
FF_MUX #(.N(18), .SEL(DREG), .RSTTYPE(RSTTYPE)) D_REG (D, CLK, RSTD, CED, D_Reg);
FF_MUX #(.N(8), .SEL(OPMODEREG), .RSTTYPE(RSTTYPE)) OPMODE_REG (OPMODE, CLK, RSTOPMODE, CEOPMODE, OPMODE_Reg);
FF_MUX #(.N(18), .SEL(B0REG), .RSTTYPE(RSTTYPE)) B_REG0 (B0Reg_in, CLK, RSTB, CEB, B_Reg0);
FF_MUX #(.N(18), .SEL(B1REG), .RSTTYPE(RSTTYPE)) B_REG1 (B1Reg_in, CLK, RSTB, CEB, B_Reg1);
FF_MUX #(.N(36), .SEL(MREG), .RSTTYPE(RSTTYPE)) M_REG (Mult_out, CLK, RSTM, CEM, M_Reg);
FF_MUX #(.N(1), .SEL(CARRYINREG), .RSTTYPE(RSTTYPE)) CYI_REG (CYI_Reg, CLK, RSTCARRYIN, CECARRYIN, CIN);
FF_MUX #(.N(1), .SEL(CARRYOUTREG), .RSTTYPE(RSTTYPE)) CYO_REG (COUT, CLK, RSTCARRYIN, CECARRYIN, CARRYOUT);
FF_MUX #(.N(48), .SEL(PREG), .RSTTYPE(RSTTYPE)) P_REG (Post_out, CLK, RSTP, CEP, P);


always @(*) begin
	case (OPMODE_Reg[1:0])
		0: X_out = 0;
		1: X_out = {12'b0, Mult_out};
		2: X_out = P; 
		default: X_out = {D_Reg[11:0], A_Reg1[17:0], B_Reg1[17:0]};
	endcase
end

always @(*) begin
	case (OPMODE_Reg[3:2])
		0: Z_out = 0;
		1: Z_out = PCIN;
		2: Z_out = P; 
		default: Z_out = C_Reg;
	endcase
end

endmodule
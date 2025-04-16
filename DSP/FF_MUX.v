module FF_MUX(A, clk, rst, EN, Y);
parameter N = 1;
parameter SEL = 0;
parameter RSTTYPE = "SYNC";
input EN;
input clk, rst;
input [N-1:0] A;
output [N-1:0] Y;

reg [N-1:0] Y_FF;

assign Y = (SEL)? Y_FF : A;

generate
	if (RSTTYPE == "SYNC") begin
		always @(posedge clk) begin
			if (rst) begin
				Y_FF <= 0;
			end
			else if(EN) begin
				Y_FF <= A;
			end
		end
	end
	else begin
		always @(posedge clk or posedge rst) begin
			if (rst) begin
				Y_FF <= 0;
			end
			else if(EN) begin
				Y_FF <= A;
			end
		end
	end
endgenerate
endmodule
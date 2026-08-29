module top_mem_fpga (
    input  wire        clock,    
    input  wire        reset,    
    output wire [15:0] led      
);

    // ---------------------------------------------------------
    // 1. Clock Enable Generation (1 Hz)
    // ---------------------------------------------------------
    wire clk_en;

    clock_divider #(
        .DIVISOR(100_000_000)   // assumes a 100 MHz system clock -> 1 Hz toggle
    ) u_clk_div (
        .clk    (clock),
        .reset  (reset),
        .clk_en (clk_en)
    );

    // ---------------------------------------------------------
    // Program Counter
    // ---------------------------------------------------------
    reg [31:0] pc;
    always @(posedge clock or posedge reset) begin
        if (reset)
            pc <= 0;
        else if (clk_en)
            pc <= pc + 4;      // word-aligned, byte address
    end

    // ---------------------------------------------------------
    // Memory Instantiations
    // ---------------------------------------------------------
    wire [31:0] instr_out;

	// TODO-TOP-MEM-1: Instantiate IMEM
    instr_mem u_imem (
        .clk   (clock),
        .pc    (pc),
        .instr (instr_out)
    );

    assign led = ~instr_out[15:0];

endmodule

//======================================================
// Clock Divider (clock enable generator)
//======================================================
module clock_divider #(
	parameter DIVISOR = 100_000_000
)(
	input  wire clk,
	input  wire reset,
	output reg  clk_en
);

	  reg [26:0] counter;

	always @(posedge clk) begin
    	if (reset) begin
        	counter <= 0;
        	clk_en  <= 1'b0;
    	end else if (counter == DIVISOR / 2 - 1) begin
        	counter <= 0;
        	clk_en  <= 1'b1;   // one-cycle pulse
    	end else begin
        	counter <= counter + 1;
        	clk_en  <= 1'b0;
    	end
	end

endmodule
// Copyright (C) 2017-2018, Gisselquist Technology, LLC
// See LICENSE for more details.
`default_nettype	none
module	busyctr(i_clk, i_reset, i_start_signal, o_busy);
	parameter	[15:0]	MAX_AMOUNT = 22;
	input	wire	i_clk, i_reset;
	input	wire	i_start_signal;
	output	reg	o_busy;

	reg	[15:0]	counter;

	initial	counter = 0;
	always @(posedge i_clk)
		if (i_reset)
			counter <= 0;
		else if ((i_start_signal)&&(counter == 0))
			counter <= MAX_AMOUNT-1'b1;
		else if (counter != 0)
			counter <= counter - 1'b1;

	always @(*)
		o_busy <= (counter != 0);

`ifdef	FORMAL

    reg f_past_valid = 0;
    always @(posedge i_clk) 
        f_past_valid <= 1;

    //	1. Assume that once raised, i_start_signal will remain high until it
    //		is both high and the counter is no longer busy.
    //		Following (i_start_signal)&&(!o_busy), i_start_signal is no
    //		longer constrained--until it is raised again.
    always @(posedge i_clk) begin
        if(f_past_valid && $past(i_start_signal) && o_busy)
            assume(i_start_signal);
    end

    // #1, To Prove:
    //	2. o_busy will *always* be true any time the counter is non-zero.
    //	3. If the counter is non-zero, it should always be counting down
    always @(posedge i_clk) begin
        assume(!i_reset);
        if(counter)
            assert(o_busy);
        if(counter && f_past_valid && counter != MAX_AMOUNT - 1)
            assert(counter == $past(counter) - 1);
    end

`endif
endmodule

`default_nettype none
//------------------------------------------------------------------------------
// Delay signal
//------------------------------------------------------------------------------
module delay #(
    parameter p_width = 24,
    parameter p_delay = 5
) (
    input   wire                     i_clk,
    input   wire    [p_width - 1:0]  i_data,
    output  wire    [p_width - 1:0]  o_data
);

    genvar i;
    generate
        if (p_delay == 1) begin
            reg     [p_width - 1:0]     d_data  = {p_width{1'b0}};
            always @(posedge i_clk)
                d_data <= i_data;
            assign o_data = d_data;
        end else begin
            reg     [p_width - 1:0]     d_data  [1: p_delay];
            integer j;
            initial
                for (j = 1; j <= p_delay; j = j + 1)
                    d_data[j] = {p_width{1'b0}};
            always @(posedge i_clk)
                d_data[1] <= i_data;
            for (i = 1; i < p_delay; i = i + 1) begin
                always @(posedge i_clk)
                    d_data[i + 1] <= d_data[i];
            end
            assign o_data = d_data[p_delay];
        end
    endgenerate

endmodule
`default_nettype wire

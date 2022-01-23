`default_nettype none
//------------------------------------------------------------------------------
// 有効期間カウンタ
//------------------------------------------------------------------------------
module hv_counter2 #(
    parameter integer
        p_hcnt = 11,    // 水平カウンタのbit数
        p_vcnt = 11,    // 垂直カウンタのbit数
        p_hpos = 0,     // 水平カウンタをリセットするx座標
        p_vpos = 0      // 垂直カウンタをリセットするy座標
) (
    input   wire                  i_xres,   // Synchronous Reset (Low Active)
    input   wire                  i_clk,    // Pixel Clock
    input   wire                  i0_de,    // Data Enable
    input   wire                  i0_hclr,  // 水平カウントパルス
    input   wire  [p_hcnt - 1: 0] i0_hcnt,  // 水平カウンタ
    input   wire  [p_vcnt - 1: 0] i0_vcnt,  // 垂直カウンタ
    output  wire  [p_hcnt - 1: 0] o1_hcnt,
    output  wire  [p_vcnt - 1: 0] o1_vcnt
);

    //--------------------------------------------------------------------------
    // 指定座標からカウントを始める水平カウンタ
    // ブランキング期間中は値を保持
    //--------------------------------------------------------------------------
    reg     [p_hcnt - 1: 0] d1_hcnt;
    always @(posedge i_clk)
        if (!i_xres)
            d1_hcnt <= 0;
        else if (i0_hcnt == p_hpos)
            d1_hcnt <= 0;
        else if (i0_de == 1)
            d1_hcnt <= d1_hcnt + {{p_hcnt - 1{1'b0}}, 1'b1};
    assign o1_hcnt = d1_hcnt;

    //--------------------------------------------------------------------------
    // 指定座標からカウントを始める垂直カウンタ
    // ブランキング期間中は値を保持
    //--------------------------------------------------------------------------
    reg     [p_vcnt - 1: 0] d1_vcnt;
    always @(posedge i_clk)
        if (!i_xres)
            d1_vcnt <= 0;
        else if (i0_vcnt == p_vpos)
            d1_vcnt <= 0;
        else if (i0_hclr == 1)
            d1_vcnt <= d1_vcnt + {{p_vcnt - 1{1'b0}}, 1'b1};
    assign o1_vcnt = d1_vcnt;

endmodule
`default_nettype wire

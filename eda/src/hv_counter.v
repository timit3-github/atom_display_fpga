`default_nettype none
//------------------------------------------------------------------------------
// 有効期間カウンタ
//------------------------------------------------------------------------------
module hv_counter #(
    parameter integer
        p_hcnt = 11,    // 水平カウンタのbit数
        p_vcnt = 11     // 垂直カウンタのbit数
) (
    input   wire                  i_xres,   // Synchronous Reset (Low Active)
    input   wire                  i_clk,    // Pixel Clock
    input   wire                  i0_de,    // Data Enable
    input   wire                  i0_hs,    // HSync
    input   wire                  i0_vs,    // VSync
    output  wire                  o1_vclr,  // 垂直カウントパルス
    output  wire  [p_hcnt - 1: 0] o2_hcnt,  // 水平カウンタ
    output  wire  [p_vcnt - 1: 0] o2_vcnt,  // 垂直カウンタ
    // 遅延信号出力
    output  wire                  o2_hclr,
    output  wire                  o2_vclr,
    output  wire  [p_hcnt - 1: 0] o3_hcnt,
    output  wire  [p_vcnt - 1: 0] o3_vcnt,
    output  wire                  o2_de,
    output  wire                  o5_de,
    output  wire                  o5_hs,
    output  wire                  o5_vs,
    output  wire                  o3_de,
    output  wire                  o6_de,
    output  wire                  o6_hs,
    output  wire                  o6_vs
);

    //--------------------------------------------------------------------------
    // 同期信号の遅延
    //--------------------------------------------------------------------------
    reg     [6:1]   d_de;
    reg     [6:1]   d_hs;
    reg     [6:1]   d_vs;
    always @(posedge i_clk)
        if (!i_xres) begin
            d_de[6:1] <= 0;
            d_hs[6:1] <= 0;
            d_vs[6:1] <= 0;
        end else begin
            d_de[6:1] <= {d_de[5:1], i0_de};
            d_hs[6:1] <= {d_hs[5:1], i0_hs};
            d_vs[6:1] <= {d_vs[5:1], i0_vs};
        end
    assign o2_de = d_de[2];
    assign o5_de = d_de[5];
    assign o5_hs = d_hs[5];
    assign o5_vs = d_vs[5];
    assign o3_de = d_de[3];
    assign o6_de = d_de[6];
    assign o6_hs = d_hs[6];
    assign o6_vs = d_vs[6];

    //--------------------------------------------------------------------------
    // de信号の立ち上がりエッジを検出
    //--------------------------------------------------------------------------

    reg             d1_hclr;
    always @(posedge i_clk)
        if (!i_xres)
            d1_hclr <= 0;
        else
            d1_hclr <= ({d_de[1], i0_de} == 2'b01) ? 1 : 0;

    //--------------------------------------------------------------------------
    // 垂直帰線期間(のvsの任意のエッジ)でlow、フレームの先頭画素でhighへ変化
    //--------------------------------------------------------------------------

    reg             d1_vdisp;
    always @(posedge i_clk)
        if (!i_xres)
            d1_vdisp <= 0;
        else if (i0_de == 1)
            d1_vdisp <= 1;
        else if (d_vs[1] != i0_vs)
            d1_vdisp <= 0;
        else
            d1_vdisp <= d1_vdisp;

    //--------------------------------------------------------------------------
    // フレームの最初のde信号の立ち上がりエッジを検出
    //--------------------------------------------------------------------------

    reg             d1_vclr;
    always @(posedge i_clk)
        if (!i_xres)
            d1_vclr <= 0;
        else if (({d_de[1], i0_de} == 2'b01) && (d1_vdisp == 0))
            d1_vclr <= 1;
        else
            d1_vclr <= 0;
    assign o1_vclr = d1_vclr;

    //--------------------------------------------------------------------------
    // 水平カウンタ
    // ブランキング期間中は値を保持
    //--------------------------------------------------------------------------
    reg     [p_hcnt - 1: 0] d2_hcnt;
    always @(posedge i_clk)
        if (!i_xres)
            d2_hcnt <= 0;
        else if (d1_hclr == 1)
            d2_hcnt <= 0;
        else if (d_de[1] == 1)
            d2_hcnt <= d2_hcnt + {{p_hcnt - 1{1'b0}}, 1'b1};
    assign o2_hcnt = d2_hcnt;

    //--------------------------------------------------------------------------
    // 垂直カウンタ
    // ブランキング期間中は値を保持
    //--------------------------------------------------------------------------
    reg     [p_vcnt - 1: 0] d2_vcnt;
    always @(posedge i_clk)
        if (!i_xres)
            d2_vcnt <= 0;
        else if (d1_vclr == 1)
            d2_vcnt <= 0;
        else if (d1_hclr == 1)
            d2_vcnt <= d2_vcnt + {{p_vcnt - 1{1'b0}}, 1'b1};
    assign o2_vcnt = d2_vcnt;

    reg             d2_hclr;
    reg             d2_vclr;
    reg     [p_hcnt - 1: 0] d3_hcnt;
    reg     [p_vcnt - 1: 0] d3_vcnt;
    always @(posedge i_clk)
        if (!i_xres) begin
            d2_hclr <= 0;
            d2_vclr <= 0;
            d3_hcnt <= 0;
            d3_vcnt <= 0;
        end else begin
            d2_hclr <= d1_hclr;
            d2_vclr <= d1_vclr;
            d3_hcnt <= d2_hcnt;
            d3_vcnt <= d2_vcnt;
        end
    assign o2_hclr = d2_hclr;
    assign o2_vclr = d2_vclr;
    assign o3_hcnt = d3_hcnt;
    assign o3_vcnt = d3_vcnt;


endmodule
`default_nettype wire

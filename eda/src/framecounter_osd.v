`default_nettype none
//------------------------------------------------------------------------------
// 画面左上32x16の領域へ4桁のフレームカウンタを表示
//------------------------------------------------------------------------------
module framecounter_osd #(
    parameter integer
        p_hpos = 0,     // フレームカウンタの表示x座標
        p_vpos = 0,     // フレームカウンタの表示y座標
        p_hcnt = 11,    // 水平カウンタのbit数
        p_vcnt = 11     // 垂直カウンタのbit数
) (
    input   wire            i_clk,
    input   wire            i_xres,
    input   wire            i_en,
    input   wire    [23:0]  i_bgr,
    input   wire            i0_vs,
    input   wire            i0_hs,
    input   wire            i0_de,
    input   wire    [23:0]  i0_data,
    output  wire            o6_vs,
    output  wire            o6_hs,
    output  wire            o6_de,
    output  wire    [23:0]  o6_data
);

    //--------------------------------------------------------------------------
    // 有効期間カウンタ
    //--------------------------------------------------------------------------

    // ラインの先頭ピクセルで1クロックだけhigh
    wire            s2_hclr;
    // フレームの先頭ピクセルで1クロックだけhigh
    wire            s2_vclr;
    // 水平&垂直カウンタ (Binary)
    wire    [p_hcnt-1:0]  s2_hcnt;
    wire    [p_vcnt-1:0]  s2_vcnt;
    wire            s3_de;
    wire            s6_de;
    wire            s6_hs;
    wire            s6_vs;
    hv_counter #(
        .p_hcnt     (p_hcnt),
        .p_vcnt     (p_vcnt)
    ) u_hv_counter (
        .i_xres     (i_xres),
        .i_clk      (i_clk),
        .i0_de      (i0_de),
        .i0_hs      (i0_hs),
        .i0_vs      (i0_vs),
        .o1_vclr    (),
        .o2_hcnt    (s2_hcnt),
        .o2_vcnt    (s2_vcnt),
        .o2_de      (),
        .o5_de      (),
        .o5_hs      (),
        .o5_vs      (),
        .o2_hclr    (s2_hclr),
        .o2_vclr    (s2_vclr),
        .o3_hcnt    (),
        .o3_vcnt    (),
        .o3_de      (s3_de),
        .o6_de      (s6_de),
        .o6_hs      (s6_hs),
        .o6_vs      (s6_vs)
    );
    wire    [p_hcnt-1:0]  s3_hcnt;
    wire    [p_vcnt-1:0]  s3_vcnt;
    hv_counter2 #(
        .p_hpos     (p_hpos),
        .p_vpos     (p_vpos),
        .p_hcnt     (p_hcnt),
        .p_vcnt     (p_vcnt)
    ) u_hv_counter2 (
        .i_xres     (i_xres),
        .i_clk      (i_clk),
        .i0_de      (i0_de),
        .i0_hclr    (s2_hclr),
        .i0_hcnt    (s2_hcnt),
        .i0_vcnt    (s2_vcnt),
        .o1_hcnt    (s3_hcnt),
        .o1_vcnt    (s3_vcnt)
    );

    //--------------------------------------------------------------------------
    // 読み出しアドレス生成
    //--------------------------------------------------------------------------

    // フレームカウンタ (Decimal)
    reg [3:0]  d3_fcnt_dec0;    // 一
    reg [3:0]  d3_fcnt_dec1;    // 十
    reg [3:0]  d3_fcnt_dec2;    // 百
    reg [3:0]  d3_fcnt_dec3;    // 千
    // ROM選択信号
    reg [3:0]  d4_numsel;
    // ROM読み出し用アドレス
    reg [6:0]  d4_rd_addr;
    always @(posedge i_clk) begin
        if( !i_xres ) begin
            d3_fcnt_dec0 <= 0;
            d3_fcnt_dec1 <= 0;
            d3_fcnt_dec2 <= 0;
            d3_fcnt_dec3 <= 0;
            d4_numsel <= 4'hF;
            d4_rd_addr <= 0;
        end else begin
            if(s2_vclr) begin
                if(d3_fcnt_dec0 == 4'd9) begin
                    d3_fcnt_dec0 <= 0;
                    if(d3_fcnt_dec1 == 4'd9) begin
                        d3_fcnt_dec1 <= 0;
                        if(d3_fcnt_dec2 == 4'd9) begin
                            d3_fcnt_dec2 <= 0;
                            if(d3_fcnt_dec3 == 4'd9)
                                d3_fcnt_dec3 <= 0;
                            else
                                d3_fcnt_dec3 <=  d3_fcnt_dec3 + 4'd1;
                        end else begin
                            d3_fcnt_dec2 <=  d3_fcnt_dec2 + 4'd1;
                        end
                    end else begin
                        d3_fcnt_dec1 <=  d3_fcnt_dec1 + 4'd1;
                    end
                end else begin
                    d3_fcnt_dec0 <=  d3_fcnt_dec0 + 4'd1;
                end
            end
            if(s3_de == 1'b1 && s3_hcnt < 8 && s3_vcnt < 16)
                d4_numsel <= d3_fcnt_dec3;
            else if(s3_de == 1'b1 && s3_hcnt < 16 && s3_vcnt < 16)
                d4_numsel <= d3_fcnt_dec2;
            else if(s3_de == 1'b1 && s3_hcnt < 24 && s3_vcnt < 16)
                d4_numsel <= d3_fcnt_dec1;
            else if(s3_de == 1'b1 && s3_hcnt < 32 && s3_vcnt < 16)
                d4_numsel <= d3_fcnt_dec0;
            else
                d4_numsel <= 4'hF; // アドレスによらず非表示
            d4_rd_addr <= {s3_vcnt[3:0], s3_hcnt[2:0]};
        end
    end
    wire    [23:0]  s6_data;
    delay #(
        .p_width    (24),
        .p_delay    (6)
    ) delay_i (
        .i_clk  (i_clk),
        .i_data (i0_data),
        .o_data (s6_data)
    );

    //--------------------------------------------------------------------------
    // ROM読み出し
    //--------------------------------------------------------------------------

    wire s6_replace;
    number_rom number_rom_i (
        .i_clk   (i_clk),
        .i0_num  (d4_numsel),
        .i0_addr (d4_rd_addr),
        .o2_data (s6_replace)
    );

    assign o6_data = (i_en && s6_replace) ? i_bgr : s6_data;
    assign o6_de = s6_de;
    assign o6_hs = s6_hs;
    assign o6_vs = s6_vs;

endmodule
`default_nettype wire

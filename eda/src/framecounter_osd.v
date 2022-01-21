`default_nettype none
//------------------------------------------------------------------------------
// 画面左上32x16の領域へ4桁のフレームカウンタを表示
//------------------------------------------------------------------------------
module framecounter_osd (
    input   wire            i_clk,
    input   wire            i_xres,
    input   wire            i_en,
    input   wire    [23:0]  i_bgr,
    input   wire            i0_vs,
    input   wire            i0_hs,
    input   wire            i0_de,
    input   wire    [23:0]  i0_data,
    output  wire            o5_vs,
    output  wire            o5_hs,
    output  wire            o5_de,
    output  wire    [23:0]  o5_data
);

    //--------------------------------------------------------------------------
    // 有効期間カウンタ
    //--------------------------------------------------------------------------

    // フレームの先頭ピクセルで1クロックだけhigh
    wire            s1_vclr;
    // 水平&垂直カウンタ (Binary)
    wire    [10:0]  s2_hcnt;    // 0 to 2,047
    wire    [10:0]  s2_vcnt;    // 0 to 2,047
    wire            s2_de;
    wire            s5_de;
    wire            s5_hs;
    wire            s5_vs;
    hv_counter #(
        .p_hcnt     (11),
        .p_vcnt     (11)
    ) u_hv_counter (
        .i_xres     (i_xres),
        .i_clk      (i_clk),
        .i0_de      (i0_de),
        .i0_hs      (i0_hs),
        .i0_vs      (i0_vs),
        .o1_vclr    (s1_vclr),
        .o2_hcnt    (s2_hcnt),
        .o2_vcnt    (s2_vcnt),
        .o2_de      (s2_de),
        .o5_de      (s5_de),
        .o5_hs      (s5_hs),
        .o5_vs      (s5_vs)
    );

    //--------------------------------------------------------------------------
    // 読み出しアドレス生成
    //--------------------------------------------------------------------------

    // フレームカウンタ (Decimal)
    reg [3:0]  d2_fcnt_dec0;    // 一
    reg [3:0]  d2_fcnt_dec1;    // 十
    reg [3:0]  d2_fcnt_dec2;    // 百
    reg [3:0]  d2_fcnt_dec3;    // 千
    // ROM選択信号
    reg [3:0]  d3_numsel;
    // ROM読み出し用アドレス
    reg [6:0]  d3_rd_addr;
    always @(posedge i_clk) begin
        if( !i_xres ) begin
            d2_fcnt_dec0 <= 0;
            d2_fcnt_dec1 <= 0;
            d2_fcnt_dec2 <= 0;
            d2_fcnt_dec3 <= 0;
            d3_numsel <= 4'hF;
            d3_rd_addr <= 0;
        end else begin
            if(s1_vclr) begin
                if(d2_fcnt_dec0 == 4'd9) begin
                    d2_fcnt_dec0 <= 0;
                    if(d2_fcnt_dec1 == 4'd9) begin
                        d2_fcnt_dec1 <= 0;
                        if(d2_fcnt_dec2 == 4'd9) begin
                            d2_fcnt_dec2 <= 0;
                            if(d2_fcnt_dec3 == 4'd9)
                                d2_fcnt_dec3 <= 0;
                            else
                                d2_fcnt_dec3 <=  d2_fcnt_dec3 + 4'd1;
                        end else begin
                            d2_fcnt_dec2 <=  d2_fcnt_dec2 + 4'd1;
                        end
                    end else begin
                        d2_fcnt_dec1 <=  d2_fcnt_dec1 + 4'd1;
                    end
                end else begin
                    d2_fcnt_dec0 <=  d2_fcnt_dec0 + 4'd1;
                end
            end
            if(s2_de == 1'b1 && s2_hcnt < 11'd8 && s2_vcnt < 11'd16)
                d3_numsel <= d2_fcnt_dec3;
            else if(s2_de == 1'b1 && s2_hcnt < 11'd16 && s2_vcnt < 11'd16)
                d3_numsel <= d2_fcnt_dec2;
            else if(s2_de == 1'b1 && s2_hcnt < 11'd24 && s2_vcnt < 11'd16)
                d3_numsel <= d2_fcnt_dec1;
            else if(s2_de == 1'b1 && s2_hcnt < 11'd32 && s2_vcnt < 11'd16)
                d3_numsel <= d2_fcnt_dec0;
            else
                d3_numsel <= 4'hF; // アドレスによらず非表示
            d3_rd_addr <= {s2_vcnt[3:0], s2_hcnt[2:0]};
        end
    end
    wire    [23:0]  s5_data;
    delay #(
        .p_width    (24),
        .p_delay    (5)
    ) delay_i (
        .i_clk  (i_clk),
        .i_data (i0_data),
        .o_data (s5_data)
    );

    //--------------------------------------------------------------------------
    // ROM読み出し
    //--------------------------------------------------------------------------

    wire s5_replace;
    number_rom number_rom_i (
        .i_clk   (i_clk),
        .i0_num  (d3_numsel),
        .i0_addr (d3_rd_addr),
        .o2_data (s5_replace)
    );

    assign o5_data = (i_en && s5_replace) ? i_bgr : s5_data;
    assign o5_de = s5_de;
    assign o5_hs = s5_hs;
    assign o5_vs = s5_vs;

endmodule
`default_nettype wire

`default_nettype none
//------------------------------------------------------------------------------
// 8x16 pixel number ROM
//------------------------------------------------------------------------------
/*
                                                                                                    
                                                                                                    
     11         1        111     111111       11     11111      1111     111111     1111       11   
    1111       11       11111        11       11     11        11  11        11    11  11     1  1  
   11  11     111      11  11       11       111     11        11  11        11    11  11    11  11 
   11  11      11          11       11       111     1111      11           11     11  11    11  11 
   11  11      11          11      111      11 1     11111     11111        11      1111     11  11 
   11  11      11         11         11     11 1         11    11  11       11      1111     11  11 
   11  11      11         11         11    11  1         11    11  11      11      11  11     11111 
   11  11      11        11          11    111111        11    11  11      11      11  11        11 
   11  11      11       11           11       11         11    11  11      11      11  11    11  11 
    1111       11      11        11  11       11     11  11    11  11     11       11  11    11  11 
     11        11      111111     1111        11      1111      1111      11        1111      1111  
                                                                                                    
                                                                                                    
                                                                                                    
*/
module number_rom (
    input   wire            i_clk,
    input   wire    [3:0]   i0_num,     // 0-9選択
    input   wire    [6:0]   i0_addr,    // 8x16のROM読み出しアドレス
    output  wire            o2_data     // 0:thru 1:valid
);
// )/* synthesis syn_romstyle = "block_rom" */;
    reg [127:0] d1_number_data = 0;
    reg [6:0] d1_addr = 0;
    always @(posedge i_clk) begin
        case (i0_num[3:0])
            4'd0 : d1_number_data <= 128'h000000183C666666666666663C180000;
            4'd1 : d1_number_data <= 128'h00000018181818181818181C18100000;
            4'd2 : d1_number_data <= 128'h0000007E060C1830306060667C380000;
            4'd3 : d1_number_data <= 128'h0000003C6660606060383030607E0000;
            4'd4 : d1_number_data <= 128'h0000003030307E262C2C383830300000;
            4'd5 : d1_number_data <= 128'h0000003C66606060603E1E06063E0000;
            4'd6 : d1_number_data <= 128'h0000003C66666666663E0666663C0000;
            4'd7 : d1_number_data <= 128'h0000000C0C18181830303060607E0000;
            4'd8 : d1_number_data <= 128'h0000003C666666663C3C6666663C0000;
            4'd9 : d1_number_data <= 128'h0000003C6666607C6666666624180000;
            default : d1_number_data <= 128'd0;
        endcase
        d1_addr <= i0_addr;
    end

    reg       d2_data = 0;
    always @(posedge i_clk) begin
        d2_data <= d1_number_data[d1_addr];
    end
    assign o2_data = d2_data;

endmodule
`default_nettype wire

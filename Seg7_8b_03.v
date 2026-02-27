module seg7_8b_03(
    input  wire        clk,
    input  wire        rst,
    input  wire [31:0] data,
    output reg         a, b, c, d, e, f, g, h, // 段选（这一位应该亮哪些段）
    output reg [7:0]   ds // 数码管位选（哪一位被点亮）
);

    reg [2:0]  cnt_scan; 
    reg [12:0] cnt_div;
    reg        clk_scan;

	 // 5kHz
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt_div <= 13'd0;
            clk_scan <= 1'b0;
        end else if (cnt_div >= 13'd4999) begin
            cnt_div <= 13'd0;
            clk_scan <= ~clk_scan;
        end else begin
            cnt_div <= cnt_div + 1'b1;
        end
    end

// 扫描计数器：决定当前点亮哪一位
// cnt_scan在0-7中循环
// clk_scan = 5kHz，每次can_scan+1，说明8位需要1.6ms，人眼看不出来
    always @(posedge clk_scan or posedge rst) begin
        if (rst) begin
            cnt_scan <= 3'd0;
        end else begin
            cnt_scan <= cnt_scan + 1'b1;
        end
    end


// ds + 取出当前位的BCD数字 + 消零控制

    reg [3:0]  data_seg; // 保存 “当前正在扫描的这一位数码管” 对应的BCD数字
    reg        seg_en; 	// 1:正常显示, 0:灭灯

    always @(posedge clk_scan or posedge rst) begin
    // 敏感信号是 clk_scan！位选、取数、消零逻辑同步
         if (rst) begin
            ds <= 8'b1111_1111; // 所有数码管都不被选中
            data_seg <= 4'd0;   // 当前显示数字清零
            seg_en <= 1'b0;    // 不显示任何位
        end else begin
            case (cnt_scan)  // 判断当前扫描的是第几位数码管
                // bit 7
                3'd0: begin 
					 ds <= 8'b1111_1110;	
                    data_seg <= data[31:28];
                    // 前n位不为0，则显示（置1）；否则灭灯
                    seg_en <= (data[31:28] != 4'h0); 
                end

                // bit 6
                3'd1: begin 
                    ds <= 8'b0111_1111;
                    data_seg <= data[27:24];
                    seg_en <= (data[31:24] != 8'h00);
                end

                // bit 5
                3'd2: begin 
                    ds <= 8'b1011_1111;
                    data_seg <= data[23:20];
                    seg_en <= (data[31:20] != 12'h000);
                end

                // bit 4
                3'd3: begin 
                    ds <= 8'b1101_1111;
                    data_seg <= data[19:16];
                    seg_en <= (data[31:16] != 16'h0000);
                end

                // bit 3
                3'd4: begin 
                    ds <= 8'b1110_1111;
                    data_seg <= data[15:12];
                    seg_en <= (data[31:12] != 20'h00000);
                end

                // bit 2
                3'd5: begin 
                    ds <= 8'b1111_0111;
                    data_seg <= data[11:8];
                    seg_en <= (data[31:8] != 24'h000000);
                end

                // bit 1
                3'd6: begin 
                    ds <= 8'b1111_1011;
                    data_seg <= data[7:4];
                    seg_en <= (data[31:4] != 28'h0000000);
                end

                // bit 0位
                3'd7: begin 
                    ds <= 8'b1111_1101; 
                    data_seg <= data[3:0];
                    // 最低位始终显示，即使是0
                    seg_en <= 1'b1;   //最低位永远显示
                end
            endcase
        end
    end


// 段码生成
// ds 切换 和 段码变化 在同一时刻发生

    always @(posedge clk_scan or posedge rst) begin
        if (rst) begin
            {a, b, c, d, e, f, g, h} <= 8'b00000000;  // 所有段线关闭
        end else begin
				// 灭灯
            if (seg_en == 1'b0) begin
                {a, b, c, d, e, f, g, h} <= 8'b00000000; // 如果当前位被判定为“应当消隐”
            end else begin
                case(data_seg)
                    4'b0000: {a, b, c, d, e, f, g, h} <= 8'b11111100; // 0
                    4'b0001: {a, b, c, d, e, f, g, h} <= 8'b01100000; // 1
                    4'b0010: {a, b, c, d, e, f, g, h} <= 8'b11011010; // 2
                    4'b0011: {a, b, c, d, e, f, g, h} <= 8'b11110010; // 3
                    4'b0100: {a, b, c, d, e, f, g, h} <= 8'b01100110; // 4
                    4'b0101: {a, b, c, d, e, f, g, h} <= 8'b10110110; // 5
                    4'b0110: {a, b, c, d, e, f, g, h} <= 8'b10111110; // 6
                    4'b0111: {a, b, c, d, e, f, g, h} <= 8'b11100000; // 7
                    4'b1000: {a, b, c, d, e, f, g, h} <= 8'b11111110; // 8
                    4'b1001: {a, b, c, d, e, f, g, h} <= 8'b11110110; // 9

                    default: {a, b, c, d, e, f, g, h} <= 8'b00000000;
                endcase
            end
        end
    end

endmodule
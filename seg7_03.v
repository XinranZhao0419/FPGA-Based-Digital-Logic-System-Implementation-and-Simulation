module seg7_03(
    input  wire        clk,
    input  wire        rst,
    input  wire [31:0] data,
    output reg         a, b, c, d, e, f, g, h,
    output reg [7:0]   ds
);

    reg [2:0]  cnt_scan; 
    reg [3:0]  data_seg;
    reg [12:0] cnt_div;
    reg        clk_scan;
    reg        seg_en; 	// 1:正常显示, 0:灭灯

	 //不加分频有频闪
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

	
    always @(posedge clk_scan or posedge rst) begin
        if (rst) begin
            cnt_scan <= 3'd0;
        end else begin
            cnt_scan <= cnt_scan + 1'b1;
        end
    end

    always @(posedge clk_scan or posedge rst) begin
        if (rst) begin
            ds <= 8'b1111_1111;
            data_seg <= 4'd0;
            seg_en <= 1'b0;
        end else begin
            case (cnt_scan)
                // bit 7
                3'd0: begin 
					 ds <= 8'b1111_1110;	// 与物理位置不对应
                    data_seg <= data[31:28];
                    // 前n位不为0，则显示；否则灭灯
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
                    seg_en <= 1'b1; 
                end
            endcase
        end
    end


    always @(posedge clk_scan or posedge rst) begin
        if (rst) begin
            {a, b, c, d, e, f, g, h} <= 8'b00000000;
        end else begin
				// 灭灯
            if (seg_en == 1'b0) begin
                {a, b, c, d, e, f, g, h} <= 8'b00000000; 
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
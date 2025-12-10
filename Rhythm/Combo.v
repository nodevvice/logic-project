module ComboCounter (
    input  wire       i_Clk,
    input  wire       i_Rst,
    input  wire       i_Hit,   // 성공 1클럭
    input  wire       i_Miss,  // 미스 1클럭

    output reg  [6:0] o_Combo  // 0 ~ 99
);

    localparam [6:0] MAX_COMBO = 7'd99;

    always @(posedge i_Clk or posedge i_Rst) begin
        if (i_Rst) begin
            o_Combo <= 7'd0;
        end else begin
            // Miss가 들어오면 콤보 바로 0
            if (i_Miss) begin
                o_Combo <= 7'd0;
            end 
            // Hit면 콤보 +1 (최대 99에서 멈춤)
            else if (i_Hit) begin
                if (o_Combo < MAX_COMBO)
                    o_Combo <= o_Combo + 7'd1;
                else
                    o_Combo <= o_Combo;
            end
        end
    end

endmodule

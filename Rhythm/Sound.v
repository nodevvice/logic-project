module Sound (
    input  wire       i_Clk,
    input  wire       i_Rst_n,
    input  wire [1:0] i_Sound_Cmd,
    output reg        o_Piezo
);

    // Tone divisors are half-period counts for 50MHz clock
    localparam [15:0] TONE_DIV_PERF = 16'd12_500;  // ~2kHz
    localparam [15:0] TONE_DIV_GOOD = 16'd16_667;  // ~1.5kHz
    localparam [15:0] TONE_DIV_MISS = 16'd62_500;  // ~400Hz

    localparam [23:0] DUR_PERF = 24'd6_000_000;  // ~120ms
    localparam [23:0] DUR_GOOD = 24'd4_500_000;  // ~90ms
    localparam [23:0] DUR_MISS = 24'd8_000_000;  // ~160ms

    reg        r_active;
    reg [15:0] r_tone_max;
    reg [15:0] r_tone_cnt;
    reg [23:0] r_dur_max;
    reg [23:0] r_dur_cnt;

    always @(posedge i_Clk or negedge i_Rst_n) begin
        if (!i_Rst_n) begin
            r_active   <= 1'b0;
            r_tone_max <= 16'd0;
            r_tone_cnt <= 16'd0;
            r_dur_max  <= 24'd0;
            r_dur_cnt  <= 24'd0;
            o_Piezo    <= 1'b0;
        end else begin
            if (i_Sound_Cmd != 2'd0) begin
                r_active   <= 1'b1;
                r_tone_cnt <= 16'd0;
                r_dur_cnt  <= 24'd0;

                case (i_Sound_Cmd)
                    2'd1: begin r_tone_max <= TONE_DIV_PERF; r_dur_max <= DUR_PERF; end
                    2'd2: begin r_tone_max <= TONE_DIV_GOOD; r_dur_max <= DUR_GOOD; end
                    2'd3: begin r_tone_max <= TONE_DIV_MISS; r_dur_max <= DUR_MISS; end
                    default: begin r_tone_max <= 16'd0; r_dur_max <= 24'd0; end
                endcase

                o_Piezo <= 1'b0;
            end else if (r_active) begin
                if (r_dur_cnt >= r_dur_max) begin
                    r_active   <= 1'b0;
                    o_Piezo    <= 1'b0;
                end else begin
                    r_dur_cnt <= r_dur_cnt + 1'b1;

                    if (r_tone_max != 16'd0) begin
                        if (r_tone_cnt >= r_tone_max) begin
                            r_tone_cnt <= 16'd0;
                            o_Piezo    <= ~o_Piezo;
                        end else begin
                            r_tone_cnt <= r_tone_cnt + 1'b1;
                        end
                    end else begin
                        o_Piezo <= 1'b0;
                    end
                end
            end else begin
                o_Piezo <= 1'b0;
            end
        end
    end

endmodule

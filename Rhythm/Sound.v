module Sound (
    input  wire       i_Clk,        // 50MHz Clock
    input  wire       i_Rst_n,
    input  wire [1:0] i_Sound_Cmd,  // 0:None, 1:Perf, 2:Good, 3:Miss
    output reg        o_Piezo
);

    // ==========================================
    // 1. Parameter Definition (50MHz 기준)
    // ==========================================
    // Perfect: 6옥타브 도 -> 6옥타브 솔 (띠링~)
    localparam [17:0] TONE_DIV_PERF_1 = 18'd23_878;  // 1047Hz
    localparam [17:0] TONE_DIV_PERF_2 = 18'd15_944;  // 1568Hz

    // Good: 5옥타브 도 (띵)
    localparam [17:0] TONE_DIV_GOOD   = 18'd47_801;  // 523Hz
    
    // Miss: 3옥타브 솔 (웅/툭) - 값이 커서 18비트 필요
    localparam [17:0] TONE_DIV_MISS   = 18'd62_500; // 196Hz

    // Duration (재생 시간)
    localparam [23:0] DUR_PERF = 24'd6_000_000;  // ~120ms (0.12초)
    localparam [23:0] DUR_GOOD = 24'd4_500_000;  // ~90ms
    localparam [23:0] DUR_MISS = 24'd8_000_000;  // ~160ms

    // ==========================================
    // 2. Registers
    // ==========================================
    reg        r_active;       // 현재 소리 재생 중인지 여부
    reg [1:0]  r_current_cmd;  // 현재 재생 중인 소리 타입 저장
    
    // **중요**: Miss의 낮은 주파수를 담기 위해 [17:0]으로 확장
    reg [17:0] r_tone_max;     
    reg [17:0] r_tone_cnt;
    
    reg [23:0] r_dur_max;
    reg [23:0] r_dur_cnt;

    // ==========================================
    // 3. Logic
    // ==========================================
    always @(posedge i_Clk or negedge i_Rst_n) begin
        if (!i_Rst_n) begin
            r_active      <= 1'b0;
            r_current_cmd <= 2'd0;
            r_tone_max    <= 18'd0;
            r_tone_cnt    <= 18'd0;
            r_dur_max     <= 24'd0;
            r_dur_cnt     <= 24'd0;
            o_Piezo       <= 1'b0;
        end else begin
            // ----------------------------------
            // A. 새로운 사운드 명령이 들어왔을 때 (Start)
            // ----------------------------------
            if (i_Sound_Cmd != 2'd0) begin
                r_active      <= 1'b1;
                r_current_cmd <= i_Sound_Cmd; // 무슨 소리인지 저장
                r_tone_cnt    <= 18'd0;
                r_dur_cnt     <= 24'd0;
                o_Piezo       <= 1'b0;

                // 지속 시간 설정
                case (i_Sound_Cmd)
                    2'd1: r_dur_max <= DUR_PERF; // Perfect
                    2'd2: r_dur_max <= DUR_GOOD; // Good
                    2'd3: r_dur_max <= DUR_MISS; // Miss
                    default: r_dur_max <= 24'd0;
                endcase
            end 
            // ----------------------------------
            // B. 소리 재생 중 (Playing)
            // ----------------------------------
            else if (r_active) begin
                // B-1. 지속 시간 종료 체크
                if (r_dur_cnt >= r_dur_max) begin
                    r_active <= 1'b0;
                    o_Piezo  <= 1'b0;
                end else begin
                    r_dur_cnt <= r_dur_cnt + 1'b1;

                    // B-2. 실시간 주파수(Tone) 설정
                    // Perfect일 때는 시간에 따라 음을 변경 (띠 -> 링)
                    if (r_current_cmd == 2'd1) begin
                        if (r_dur_cnt < (DUR_PERF / 2)) 
                            r_tone_max <= TONE_DIV_PERF_1; // 앞부분 (도)
                        else 
                            r_tone_max <= TONE_DIV_PERF_2; // 뒷부분 (솔)
                    end
                    else if (r_current_cmd == 2'd2) begin
                        r_tone_max <= TONE_DIV_GOOD;
                    end
                    else if (r_current_cmd == 2'd3) begin
                        r_tone_max <= TONE_DIV_MISS;
                    end

                    // B-3. PWM 생성 (Buzzer Toggle)
                    if (r_tone_max != 18'd0) begin
                        if (r_tone_cnt >= r_tone_max) begin
                            r_tone_cnt <= 18'd0;
                            o_Piezo    <= ~o_Piezo; // 핀 토글
                        end else begin
                            r_tone_cnt <= r_tone_cnt + 1'b1;
                        end
                    end
                end
            end 
            // ----------------------------------
            // C. 대기 상태 (Idle)
            // ----------------------------------
            else begin
                o_Piezo <= 1'b0;
                // 다음 입력을 위해 상태 초기화가 필요하다면 여기에 추가
            end
        end
    end

endmodule
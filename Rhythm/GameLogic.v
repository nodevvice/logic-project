module GameLogic (
    // ==========================================
    // 1. 시스템 입력
    // ==========================================
    input  wire        i_Clk,        // 50MHz Main Clock
    input  wire        i_Rst,      // [수정됨] Active Low Reset (0일 때 리셋)
    
    // ==========================================
    // 2. 외부 제어 및 설정
    // ==========================================
    input  wire [3:0]  i_Pulse,      // 필터링된 버튼 입력
    input  wire [7:0]  i_Rand_Val,   // LFSR 난수
    
    input  wire [1:0]  i_Speed_Opt,  // 배속 설정
    input  wire        i_View_Mode,  // 결과 확인 모드
    input  wire        i_Start_Btn,  // 게임 시작 버튼

    // ==========================================
    // 3. 게임 출력
    // ==========================================
    output reg  [63:0] o_Map_Data,   // 도트 매트릭스 화면
    output reg  [15:0] o_Score,      // 점수
    output reg  [7:0]  o_Combo,      // 콤보
    output reg  [9:0]  o_HP,         // HP (LED)
    output reg  [1:0]  o_Sound_Cmd   // 사운드 명령
);

    // ==========================================
    // 4. 상수 및 파라미터
    // ==========================================
    localparam S_IDLE     = 2'd0;
    localparam S_PLAY     = 2'd1;
    localparam S_GAMEOVER = 2'd2;

    localparam SPEED_BASE_1X = 32'd25_000_000; 
    localparam SPEED_LIMIT   = 32'd5_000_000;
    localparam SPEED_STEP    = 32'd100_000;

    // ==========================================
    // 5. 내부 레지스터
    // ==========================================
    reg [1:0]  r_State;
    reg [31:0] r_Wait_Cnt;
    reg [15:0] r_Score;
    reg [15:0] r_HighScore; 
    reg [7:0]  r_Combo;
    reg [9:0]  r_HP;
    reg [63:0] r_Map;
    reg [31:0] r_Speed_Cnt;
    reg [31:0] r_Speed_Max;

    // 임시 변수
    reg [7:0] v_New_Row;

    // ==========================================
    // 6. 메인 로직 (Active Low 적용)
    // ==========================================
    
    // [수정됨] negedge i_Rst 사용 (Falling Edge 감지)
    always @(posedge i_Clk or negedge i_Rst) begin
        
        // [수정됨] 0일 때 리셋 동작
        if (!i_Rst) begin
            r_State     <= S_IDLE;
            r_Score     <= 0;
            r_Combo     <= 0;
            r_HP        <= 10'b11_1111_1111;
            r_Map       <= 64'd0;
            r_Speed_Cnt <= 0;
            r_Speed_Max <= SPEED_BASE_1X;
            o_Sound_Cmd <= 2'd0;
            // r_HighScore는 초기화하지 않음 (유지)
        end
        else begin
            // ------------------------------------------------
            // 리셋이 아닐 때 (Normal Operation)
            // ------------------------------------------------
            o_Sound_Cmd <= 2'd0; // 사운드 Pulse 초기화

            case (r_State)
                S_IDLE: begin
                    // 배속 설정 (스위치)
                    case (i_Speed_Opt)
                        2'b00: r_Speed_Max <= SPEED_BASE_1X;
                        2'b01: r_Speed_Max <= SPEED_BASE_1X >> 1;
                        2'b10: r_Speed_Max <= SPEED_BASE_1X >> 2;
                        default: r_Speed_Max <= SPEED_BASE_1X;
                    endcase

                    if (i_Start_Btn) begin
                        r_Score <= 0;
                        r_Combo <= 0;
                        r_HP    <= 10'b11_1111_1111;
                        r_Map   <= 64'd0;
                        r_State <= S_PLAY;
                    end
                end

                S_PLAY: begin
                    // (1) 게임 오버 체크
                    if (r_HP == 10'd0) begin
                        r_State <= S_GAMEOVER;
                        r_Wait_Cnt <= 0;
                        if (r_Score > r_HighScore) r_HighScore <= r_Score;
                    end
                    else begin
                        // (2) 버튼 입력 판정 (Sub-tick & 점진적 가속)
                        
                        // Lane 0
                        if (i_Pulse[0]) begin
                            if (r_Map[1:0] != 2'b00) begin
                                if (r_Speed_Cnt > (r_Speed_Max >> 2) && r_Speed_Cnt < (r_Speed_Max - (r_Speed_Max >> 2))) begin
                                    r_Score <= r_Score + 10; o_Sound_Cmd <= 2'd1;
                                end else begin
                                    r_Score <= r_Score + 5; o_Sound_Cmd <= 2'd2;
                                end
                                r_Combo <= r_Combo + 1;
                                r_Map[1:0] <= 2'b00; // 노트 삭제
                                if (r_Speed_Max > SPEED_LIMIT) r_Speed_Max <= r_Speed_Max - SPEED_STEP;
                            end else begin
                                r_HP <= {r_HP[8:0], 1'b0}; r_Combo <= 0; o_Sound_Cmd <= 2'd3;
                            end
                        end
                        
                        // Lane 1
                        if (i_Pulse[1]) begin
                            if (r_Map[3:2] != 2'b00) begin
                                if (r_Speed_Cnt > (r_Speed_Max >> 2) && r_Speed_Cnt < (r_Speed_Max - (r_Speed_Max >> 2))) begin
                                    r_Score <= r_Score + 10; o_Sound_Cmd <= 2'd1;
                                end else begin
                                    r_Score <= r_Score + 5; o_Sound_Cmd <= 2'd2;
                                end
                                r_Combo <= r_Combo + 1;
                                r_Map[3:2] <= 2'b00;
                                if (r_Speed_Max > SPEED_LIMIT) r_Speed_Max <= r_Speed_Max - SPEED_STEP;
                            end else begin
                                r_HP <= {r_HP[8:0], 1'b0}; r_Combo <= 0; o_Sound_Cmd <= 2'd3;
                            end
                        end

                        // Lane 2
                        if (i_Pulse[2]) begin
                            if (r_Map[5:4] != 2'b00) begin
                                if (r_Speed_Cnt > (r_Speed_Max >> 2) && r_Speed_Cnt < (r_Speed_Max - (r_Speed_Max >> 2))) begin
                                    r_Score <= r_Score + 10; o_Sound_Cmd <= 2'd1;
                                end else begin
                                    r_Score <= r_Score + 5; o_Sound_Cmd <= 2'd2;
                                end
                                r_Combo <= r_Combo + 1;
                                r_Map[5:4] <= 2'b00;
                                if (r_Speed_Max > SPEED_LIMIT) r_Speed_Max <= r_Speed_Max - SPEED_STEP;
                            end else begin
                                r_HP <= {r_HP[8:0], 1'b0}; r_Combo <= 0; o_Sound_Cmd <= 2'd3;
                            end
                        end

                        // Lane 3
                        if (i_Pulse[3]) begin
                            if (r_Map[7:6] != 2'b00) begin
                                if (r_Speed_Cnt > (r_Speed_Max >> 2) && r_Speed_Cnt < (r_Speed_Max - (r_Speed_Max >> 2))) begin
                                    r_Score <= r_Score + 10; o_Sound_Cmd <= 2'd1;
                                end else begin
                                    r_Score <= r_Score + 5; o_Sound_Cmd <= 2'd2;
                                end
                                r_Combo <= r_Combo + 1;
                                r_Map[7:6] <= 2'b00;
                                if (r_Speed_Max > SPEED_LIMIT) r_Speed_Max <= r_Speed_Max - SPEED_STEP;
                            end else begin
                                r_HP <= {r_HP[8:0], 1'b0}; r_Combo <= 0; o_Sound_Cmd <= 2'd3;
                            end
                        end

                        // (3) 노트 이동 및 생성 (Timer Tick)
                        if (r_Speed_Cnt < r_Speed_Max) begin
                            r_Speed_Cnt <= r_Speed_Cnt + 1;
                        end
                        else begin
                            r_Speed_Cnt <= 0;

                            // Miss 체크 (Row 0에 남은 노트)
                            if (r_Map[7:0] != 8'd0) begin
                                r_HP <= {r_HP[8:0], 1'b0}; 
                                r_Combo <= 0;
                                o_Sound_Cmd <= 2'd3;
                            end

                            // 노트 생성
                            if (i_Rand_Val[3:0] > 4'd7) begin
                                v_New_Row[7:6] = i_Rand_Val[7] ? 2'b11 : 2'b00;
                                v_New_Row[5:4] = i_Rand_Val[6] ? 2'b11 : 2'b00;
                                v_New_Row[3:2] = i_Rand_Val[5] ? 2'b11 : 2'b00;
                                v_New_Row[1:0] = i_Rand_Val[4] ? 2'b11 : 2'b00;
                            end else begin
                                v_New_Row = 8'd0;
                            end

                            // 전체 Shift
                            r_Map <= {v_New_Row, r_Map[63:8]};
                        end
                    end
                end

                S_GAMEOVER: begin
                    if (r_Wait_Cnt < 32'd150_000_000) r_Wait_Cnt <= r_Wait_Cnt + 1;
                    else r_State <= S_IDLE;
                end
            endcase
        end
    end

    // 출력 연결
    always @(*) begin
        o_Map_Data = r_Map;
        o_HP = r_HP;
        o_Combo = r_Combo;
        if (i_View_Mode) o_Score = r_HighScore;
        else             o_Score = r_Score;
    end

endmodule
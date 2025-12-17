module GameLogic (
    // ==========================================
    // 1. 시스템 입력
    // ==========================================
    input  wire        i_Clk,        // 50MHz
    input  wire        i_Rst,        // Active Low Reset
    
    // ==========================================
    // 2. 외부 제어
    // ==========================================
    input  wire [3:0]  i_Pulse,      // 버튼 펄스
    input  wire [7:0]  i_Rand_Val,   // 난수
    input  wire [1:0]  i_Speed_Opt,  // 속도 조절
    input  wire        i_View_Mode,  // 점수 보기 모드
    input  wire        i_Start_Btn,  // 시작 버튼

    // ==========================================
    // 3. 게임 출력
    // ==========================================
    output reg  [63:0] o_Map_Data,   // Dot Matrix 출력
    output reg  [15:0] o_Score,
    output reg  [7:0]  o_Combo,
    output reg  [9:0]  o_HP,
    output reg  [1:0]  o_Sound_Cmd   // 0:Mute, 1:Perfect, 2:Good, 3:Miss
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
    reg [15:0] r_Score, r_HighScore; 
    reg [7:0]  r_Combo, r_HighCombo;
    reg [9:0]  r_HP;
    reg [63:0] r_Map;       // 실제 맵 레지스터
    reg [31:0] r_Speed_Cnt;
    reg [31:0] r_Speed_Max;

    // [수정] 로직 처리를 위한 임시 변수 (Blocking Assignment용)
    reg [63:0] v_Map_Temp; 
    reg [7:0]  v_New_Row;

    // ==========================================
    // 6. 메인 로직
    // ==========================================
    always @(posedge i_Clk or negedge i_Rst) begin
        if (!i_Rst) begin
            r_State     <= S_IDLE;
            r_Score     <= 0;
            r_Combo     <= 0;
            r_HP        <= 10'b11_1111_1111; // HP Full
            r_Map       <= 64'd0;
            r_Speed_Cnt <= 0;
            r_Speed_Max <= SPEED_BASE_1X;
            o_Sound_Cmd <= 2'd0;
            // r_HighScore는 리셋 시 유지 (일반적으로)
        end
        else begin
            // 기본값
            o_Sound_Cmd <= 2'd0; 

            case (r_State)
                // ------------------------------------
                // IDLE 상태
                // ------------------------------------
                S_IDLE: begin
                    // 속도 설정
                    case (i_Speed_Opt)
                        2'b00: r_Speed_Max <= SPEED_BASE_1X;
                        2'b01: r_Speed_Max <= SPEED_BASE_1X >> 1; // 2배속
                        2'b10: r_Speed_Max <= SPEED_BASE_1X >> 2; // 4배속
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

                // ------------------------------------
                // PLAY 상태
                // ------------------------------------
                S_PLAY: begin
                    // (0) 임시 변수에 현재 맵 복사
                    v_Map_Temp = r_Map;

                    // (1) 게임 오버 체크
                    if (r_HP == 10'd0) begin
                        r_State    <= S_GAMEOVER;
                        r_Wait_Cnt <= 0;
                        if (r_Score > r_HighScore) r_HighScore <= r_Score;
                    end
                    else begin
                        // (2) 버튼 입력 판정 (v_Map_Temp를 수정)
                        
                        // Lane 0
                        if (i_Pulse[3]) begin
                            if (v_Map_Temp[1:0] != 2'b00) begin // 노트가 있으면
                                // 판정 로직 (타이밍)
                                if (r_Speed_Cnt > (r_Speed_Max >> 2) && r_Speed_Cnt < (r_Speed_Max - (r_Speed_Max >> 2))) begin
                                    r_Score <= r_Score + 10; o_Sound_Cmd <= 2'd1; // Perfect
                                end else begin
                                    r_Score <= r_Score + 5;  o_Sound_Cmd <= 2'd2; // Good
                                end
                                r_Combo <= r_Combo + 1;

                                if (r_Combo + 1 > r_HighCombo) begin
                                    r_HighCombo <= r_Combo + 1;
                                end
                                v_Map_Temp[1:0] = 2'b00; // [중요] 임시 변수에서 삭제
                                
                                // 속도 증가 (난이도 상승)
                                if (r_Speed_Max > SPEED_LIMIT) r_Speed_Max <= r_Speed_Max - SPEED_STEP;
                            end else begin
                                // 헛침 (Miss)
                                r_HP <= {r_HP[8:0], 1'b0}; r_Combo <= 0; o_Sound_Cmd <= 2'd3;
                            end
                        end

                        // Lane 1
                        if (i_Pulse[2]) begin
                            if (v_Map_Temp[3:2] != 2'b00) begin
                                if (r_Speed_Cnt > (r_Speed_Max >> 2) && r_Speed_Cnt < (r_Speed_Max - (r_Speed_Max >> 2))) begin
                                    r_Score <= r_Score + 10; o_Sound_Cmd <= 2'd1;
                                end else begin
                                    r_Score <= r_Score + 5;  o_Sound_Cmd <= 2'd2;
                                end
                                r_Combo <= r_Combo + 1;
                                v_Map_Temp[3:2] = 2'b00;
                                if (r_Speed_Max > SPEED_LIMIT) r_Speed_Max <= r_Speed_Max - SPEED_STEP;
                            end else begin
                                r_HP <= {r_HP[8:0], 1'b0}; r_Combo <= 0; o_Sound_Cmd <= 2'd3;
                            end
                        end

                        // Lane 2
                        if (i_Pulse[1]) begin
                            if (v_Map_Temp[5:4] != 2'b00) begin
                                if (r_Speed_Cnt > (r_Speed_Max >> 2) && r_Speed_Cnt < (r_Speed_Max - (r_Speed_Max >> 2))) begin
                                    r_Score <= r_Score + 10; o_Sound_Cmd <= 2'd1;
                                end else begin
                                    r_Score <= r_Score + 5;  o_Sound_Cmd <= 2'd2;
                                end
                                r_Combo <= r_Combo + 1;
                                v_Map_Temp[5:4] = 2'b00;
                                if (r_Speed_Max > SPEED_LIMIT) r_Speed_Max <= r_Speed_Max - SPEED_STEP;
                            end else begin
                                r_HP <= {r_HP[8:0], 1'b0}; r_Combo <= 0; o_Sound_Cmd <= 2'd3;
                            end
                        end

                        // Lane 3
                        if (i_Pulse[0]) begin
                            if (v_Map_Temp[7:6] != 2'b00) begin
                                if (r_Speed_Cnt > (r_Speed_Max >> 2) && r_Speed_Cnt < (r_Speed_Max - (r_Speed_Max >> 2))) begin
                                    r_Score <= r_Score + 10; o_Sound_Cmd <= 2'd1;
                                end else begin
                                    r_Score <= r_Score + 5;  o_Sound_Cmd <= 2'd2;
                                end
                                r_Combo <= r_Combo + 1;
                                v_Map_Temp[7:6] = 2'b00;
                                if (r_Speed_Max > SPEED_LIMIT) r_Speed_Max <= r_Speed_Max - SPEED_STEP;
                            end else begin
                                r_HP <= {r_HP[8:0], 1'b0}; r_Combo <= 0; o_Sound_Cmd <= 2'd3;
                            end
                        end

                        // (3) 노트 이동 및 생성 (Timer Tick)
                        if (r_Speed_Cnt < r_Speed_Max) begin
                            r_Speed_Cnt <= r_Speed_Cnt + 1;
                            r_Map       <= v_Map_Temp; // 이동 안 함, 버튼 처리 결과만 반영
                        end
                        else begin
                            r_Speed_Cnt <= 0;

                            // 바닥에 닿은 노트 체크 (Miss) - 이동하기 전 v_Map_Temp 기준
                            if (v_Map_Temp[7:0] != 8'd0) begin
                                r_HP    <= {r_HP[8:0], 1'b0}; 
                                r_Combo <= 0;
                                o_Sound_Cmd <= 2'd3;
                            end

                            // 새 노트 패턴 생성
                            v_New_Row = 8'd0; // 초기화
                            if (i_Rand_Val[3:0] > 4'd7) begin // 확률
                                v_New_Row[7:6] = i_Rand_Val[7] ? 2'b11 : 2'b00;
                                v_New_Row[5:4] = i_Rand_Val[6] ? 2'b11 : 2'b00;
                                v_New_Row[3:2] = i_Rand_Val[5] ? 2'b11 : 2'b00;
                                v_New_Row[1:0] = i_Rand_Val[4] ? 2'b11 : 2'b00;
                            end

                            // [중요] v_Map_Temp(버튼 처리된 맵)를 Shift 해서 r_Map에 저장
                            r_Map <= {v_New_Row, v_Map_Temp[63:8]};
                        end
                    end
                end

                // ------------------------------------
                // GAMEOVER 상태
                // ------------------------------------
                S_GAMEOVER: begin
                    if (r_Wait_Cnt < 32'd150_000_000) // 약 3초 대기
                        r_Wait_Cnt <= r_Wait_Cnt + 1;
                    else 
                        r_State <= S_IDLE;
                end
            endcase
        end
    end

    // 출력 연결
    always @(*) begin
        o_Map_Data = r_Map;
        o_HP       = r_HP;

        // [수정] 보기 모드(SW[2])에 따라 점수와 콤보를 세트로 보여줌
        if (i_View_Mode) begin
            o_Score = r_HighScore;  // 최고 점수
            o_Combo = r_HighCombo;  // 최고 콤보
        end else begin
            o_Score = r_Score;      // 현재 점수
            o_Combo = r_Combo;      // 현재 콤보
        end
    end

endmodule
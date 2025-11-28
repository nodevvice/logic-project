0~3 난수생성 - 도트매트릭스
켜져있는게 없으면 저장해서 내려오기

판정선 닿을때 어떻게 판정할것인지
타이밍별로 점수 책정

시간 지날때마다 떨어지는 속도 증가 - 클락 조절  
DM_fdone 받아서 게임속도를 계산  


최고기록 저장 FND 표시

슬라이드 스위치로 옵션 선택(최고기록 뜨게 뭐 이런…)

| register  | bits |
| ------------- | ------------- |
|  note  | 8 (4개정도) |
| DM_Data  |    |
| state |    |
| score |    |
| combo |    |
| hp    | 10 |



    reg [7:0] note_matrix [0:7]; // 8x8 노트 배열 (Row 0~7)
    reg [13:0] score;            // 현재 점수
    reg [13:0] best_score;       // 최고 기록
    reg [9:0] hp;                // 체력 (LED)
    reg [7:0] combo;             // 콤보
    // --- 난수 생성 (LFSR) --
    reg [15:0] lfsr;
    wire [1:0] rand_col = lfsr[1:0]; // 0~3 사이 난수 추출

    // --- 속도 조절 & 타이밍 ---
    reg [31:0] frame_cnt;        // DM_fdone 횟수 카운트
    reg [31:0] speed_limit;      // 현재 속도 (이 값이 작을수록 빠름)
    reg [31:0] game_time;        // 게임 진행 시간 (속도 증가용)
    
    // --- 버튼 엣지 검출 ---
    reg [3:0] btn_prev;
    wire [3:0] btn_pos_edge = i_Push & ~btn_prev; // 버튼 누른 순간(Rising Edge)

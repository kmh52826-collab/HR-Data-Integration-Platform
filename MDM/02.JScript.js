/**
 * @description HR Master Code Management Logic
 * 이 스크립트는 인사 마스터 코드의 카테고리와 상세 항목을 관리하기 위한 UI 로직을 포함합니다.
 * 메인 카테고리(Category)를 선택하면 해당되는 상세 코드(Detail)가 하단 그리드에 필터링되어 표시됩니다.
 */

// 그리드 및 데이터 제어 객체 정의
var mainGrid = Matrix.getObject("DataGrid");        // 상위 카테고리 정보 그리드
var detailGrid = Matrix.getObject("DataGrid1");     // 하위 상세 코드 정보 그리드
var subCodeParam = Matrix.getObject("VS_SUBCODE");  // 하위 그리드 조회를 위한 파라미터 변수
var userLabel = Matrix.getObject("LB_사번");         // 사용자 정보를 표시할 레이블

/*****************************************
 * 페이지 로드 완료 시 실행
 * - 초기 데이터 로딩 및 사용자 세션 정보 설정
 *****************************************/
var OnLoadComplete = function(sender, args) {
    // 페이지 진입 시 상위 카테고리 데이터를 서버로부터 조회합니다.
    Matrix.doRefresh("mainGrid"); 
    
    // 현재 접속한 사용자의 ID를 레이블에 바인딩합니다. (Audit Trail 용도)
    userLabel.Text = Matrix.GetUserInfo().UserCode;
};

/*****************************************
 * 버튼 컨트롤 클릭 이벤트 핸들러
 * - 조회(Search), 저장(Save), 추가(Add) 등의 공통 로직 처리
 *****************************************/
var OnButtonClick = function(sender, args) {

    // 1. 데이터 조회 (Search)
    if (args.Id == "btn_MainSearch") {
        Matrix.doRefresh("mainGrid");
    } 
    
    // 2. 상위 그리드 데이터 저장 (Save)
    else if (args.Id == "btn_MainSave") {
        if (mainGrid.IsModified()) {
            // 변경된 데이터가 있을 경우 서버의 업데이트 플랜(Process)을 실행합니다.
            Matrix.ExecutePlan("PROCESS_SAVE_MAIN", "", function(p) {
                if (p.Success == false) {
                    Matrix.Alert(p.Message);
                    return;
                }
                mainGrid.ClearRowState(); // 저장 성공 시 변경 상태 초기화
                Matrix.Information("저장이 완료되었습니다.", "Information");
                Matrix.doRefresh("mainGrid");
            });
        } else {
            alert("수정된 내용이 없습니다.");
        }
    }

    // 3. 하위 상세 그리드 데이터 저장 (Save)
    else if (args.Id == "btn_DetailSave") {
        if (detailGrid.IsModified()) {
            Matrix.ExecutePlan("PROCESS_SAVE_DETAIL", "", function(p) {
                if (p.Success == false) {
                    Matrix.Alert(p.Message);
                    return;
                }
                detailGrid.ClearRowState();
                Matrix.Information("저장이 완료되었습니다.", "Information");
                Matrix.doRefresh("detailGrid");
            });
        } else {
            alert("수정된 내용이 없습니다.");
        }
    }

    // 4. 행 추가 (Add)
    else if (args.Id == "btn_MainAdd") {
        mainGrid.AppendRow(); // 상위 그리드에 신규 행 생성
    } 
    else if (args.Id == "btn_DetailAdd") {
        detailGrid.AppendRow(); // 하위 그리드에 신규 행 생성
    }

    // 5. 행 삭제 (Delete)
    else if (args.Id == "btn_DetailDelete") {
        Matrix.Confirm("선택하신 레코드들을 삭제하시겠습니까?", "삭제 확인", function(isOk) {
            if (isOk) {
                detailGrid.RemoveRow(); // 선택된 하위 그리드 행 삭제
            }
        });
    }
};

/*****************************************
 * 그리드 셀 클릭 이벤트 핸들러
 * - 메인 그리드에서 특정 행을 클릭하면 하위 상세 정보를 동적으로 로드합니다.
 * - 메인 그리드의 설정값(VALUE1~10)에 따라 하위 그리드의 헤더 명칭을 동적으로 변경합니다.
 *****************************************/
var OnCellClick = function(sender, args) {
    // 'DetailCode' 컬럼을 클릭했을 때만 하위 상세 정보를 연동합니다.
    if (args.Field.Caption == "DetailCode") {
        if (args.Id == "mainGrid") {
            
            // 클릭된 행의 DetailCode 값을 하위 그리드 조회 파라미터에 할당
            subCodeParam.Text = args.Row.GetCell("DetailCode").Value;
            Matrix.doRefresh("detailGrid"); // 파라미터 기반으로 하위 그리드 리프레시

            /**
             * [Dynamic Header Mapping]
             * 상위 코드 정의에 설정된 가변 속성값(VALUE1~10)을 하위 그리드의 컬럼 헤더(Caption)로 적용합니다.
             * 이를 통해 코드별로 서로 다른 속성 이름을 동적으로 UI에 반영할 수 있습니다.
             */
            for (var i = 1; i <= 10; i++) {
                var metaValue = args.Row.GetValue("VALUE" + i);
                
                // 상위 카테고리에 정의된 컬럼명이 있으면 해당 명칭을 사용하고, 없으면 기본 필드명을 유지합니다.
                if (metaValue != "" && metaValue != null) {
                    detailGrid.GetField("VALUE" + i).Caption = metaValue;
                } else {
                    // 데이터가 없는 경우 메인 그리드의 기본 캡션을 복사하여 일관성을 유지합니다.
                    detailGrid.GetField("VALUE" + i).Caption = mainGrid.GetField("VALUE" + i).Caption;
                }
            }
            
            // 변경된 UI 레이아웃(헤더 명칭)을 그리드에 반영합니다.
            detailGrid.Update();
        }
    }
};

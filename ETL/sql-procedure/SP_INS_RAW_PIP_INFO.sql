/******************************************************************************** * 업무명    : 시스템 공통 제어 (System Control)
 * 프로그램ID : SP_INS_RAW_PIP_INFO
 * 프로그램명 : 데이터 파이프라인 실행 이력 기록 및 상태 업데이트
 * 설    명  : 데이터 수집/전송 프로세스의 시작과 종료 시점에 호출되어 
 * 실행 상태(Status), 소요 시간(Duration), 오류 메시지 등을 기록함.
 * 또한 14일이 경과한 오래된 로그를 자동으로 정리함.
 * 입    력  : @PROC_NM, @TASK_KEY, @RUN_ID 등 파이프라인 실행 정보
 * 출    력  : 없음 (테이블 Insert/Update/Delete 수행)
 * 작성자    : 김민호
 * 작성일    : 2026-03-05
 ********************************************************************************/

CREATE PROC [CTL].[SP_INS_RAW_PIP_INFO]  
     @PROC_NM [NVARCHAR](250)              -- [필수] 프로세스(파이프라인) 명칭
    ,@TASK_KEY [nvarchar](100)             -- [선택] 개별 태스크/오더 식별 키
	,@SRC_SYS_NM [nvarchar](100)           -- 원천 시스템 코드/명칭
	,@SRC_STRG_CONT_NM [nvarchar](100)     -- 원천 스토리지 컨테이너
	,@SRC_STRG_PATH_NM [nvarchar](200)     -- 원천 파일 경로
	,@SRC_STRG_FILE_NM [nvarchar](100)     -- 원천 파일명
	,@SRC_DB_NM [nvarchar](100)            -- 원천 데이터베이스명
	,@SRC_SCHEMA_NM [nvarchar](100)        -- 원천 스키마명
	,@SRC_TABLE_NM [nvarchar](100)         -- 원천 테이블명
	,@TRGT_SYS_NM [nvarchar](100)          -- 대상 시스템 코드/명칭
	,@TRGT_STRG_CONT_NM [nvarchar](100)    -- 대상 스토리지 컨테이너
	,@TRGT_STRG_PATH_NM [nvarchar](200)    -- 대상 파일 경로
	,@TRGT_STRG_FILE_NM [nvarchar](100)    -- 대상 파일명
	,@TRGT_DB_NM [nvarchar](100)           -- 대상 데이터베이스명
	,@TRGT_SCHEMA_NM [nvarchar](100)       -- 대상 스키마명
	,@TRGT_TABLE_NM [nvarchar](100)        -- 대상 테이블명
    ,@PROC_EXEC_DT [nvarchar](100)         -- 실행 기준일자 (YYYYMMDD)
    ,@PROC_EXEC_HH [nvarchar](100)         -- 실행 기준시간 (HH)
	,@PROC_EXEC_MM [nvarchar](100)         -- 실행 기준분 (mm)
    ,@PARAM_DT [nvarchar](200)             -- 파라미터 날짜
    ,@PARAM_HH [nvarchar](200)             -- 파라미터 시간
    ,@BATCH_TP [nvarchar](100)             -- 배치 타입 (Daily, Hourly 등)
    ,@WORK_NM [nvarchar](200)              -- 실행 도구/워크북 명칭
    ,@RUN_ID [NVARCHAR](250)               -- [필수] 실행 고유 ID (ADF Run ID 등)
    ,@RUN_STATUS [NVARCHAR](50)            -- 실행 상태 (InProgress, Succeeded, Failed)
    ,@START_TIME [DATETIME]                -- 시작 일시
    ,@END_TIME [DATETIME]                  -- 종료 일시 (종료 시에만 입력)
	,@ERROR_CD [nvarchar](100)             -- 오류 코드
	,@ERROR_MSG [nvarchar](max)            -- 오류 메시지 상세
	,@INPUT_TP [VARCHAR](100)              -- 입력 방식
	,@PARTITION_KEY [nvarchar](1000)       -- 파티션 키 정보
	,@SRC_STRG_NM  [nvarchar](200)         -- 원천 스토리지명
	,@TRGT_STRG_NM  [nvarchar](200)	       -- 대상 스토리지명
    ,@SRC_RECORD_CNT BIGINT                -- 원천 레코드 건수
	,@TRGT_RECORD_CNT BIGINT               -- 대상 레코드 건수
AS   
BEGIN  
    SET NOCOUNT ON; -- 불필요한 DONE_IN_PROC 메시지 억제 (성능 향상)

    -- 내부 변수 선언
    DECLARE @SUM_DURATION DECIMAL(15,2);
	DECLARE @CNT_DURATION INT;
	DECLARE @AVG_CNT INT = 5;									-- 실행시간 Outlier 측정기준 평균 횟수
	DECLARE @OUTLIER_PER INT = 10;								-- 실행시간 Outlier 기준(%)
	DECLARE @OUTLIER_TXT NVARCHAR(200) = 'Outlier Duration';	-- 실행시간 Outlier 텍스트

    /* 1. 평균 실행 시간 계산 (최근 실행 이력 기반) */
    WITH LIST_A AS (
		SELECT A.*
			 , ROW_NUMBER() OVER (PARTITION BY A.[TASK_KEY] ORDER BY A.[START_TIME] DESC) AS ROWNUM
		  FROM [CTL].[LOG_HIST] A
		 WHERE [RUN_ID] = @RUN_ID  
           AND [TASK_KEY] = @TASK_KEY
           AND [PARAM_DT] = @PARAM_DT  
           AND [PARAM_HH] = @PARAM_HH
	)
	SELECT @SUM_DURATION = SUM(DURATION)
		 , @CNT_DURATION = COUNT(*)
	  FROM LIST_A
	 WHERE ROWNUM <= @AVG_CNT + 1 AND ROWNUM <> 1;
     
	/* 2. 로그 시작 기록 (종료 일시가 없을 경우 신규 생성) */
    IF @END_TIME IS NULL  
    BEGIN  
        INSERT INTO [CTL].[LOG_HIST] (  
             [PROC_NM], [TASK_KEY], [SRC_SYS_NM], [SRC_STRG_CONT_NM], [SRC_STRG_PATH_NM], [SRC_STRG_FILE_NM], [SRC_DB_NM], [SRC_SCHEMA_NM], [SRC_TABLE_NM]
            ,[TRGT_SYS_NM], [TRGT_STRG_CONT_NM], [TRGT_STRG_PATH_NM], [TRGT_STRG_FILE_NM], [TRGT_DB_NM], [TRGT_SCHEMA_NM], [TRGT_TABLE_NM]
            ,[PROC_EXEC_DT], [PROC_EXEC_HH], [PROC_EXEC_MM], [PARAM_DT], [PARAM_HH], [BATCH_TP], [WORK_NM]        
            ,[RUN_ID], [RUN_STATUS], [START_TIME], [END_TIME], [ERROR_CD], [ERROR_MSG], [PARTITION_KEY], [SRC_STRG_NM], [TRGT_STRG_NM]
			,[SRC_RECORD_CNT], [TRGT_RECORD_CNT], [DURATION], [AVG_DURATION], [OUTLIER], [INPUT_TP]
        )                                     
        VALUES (  
             @PROC_NM, @TASK_KEY, @SRC_SYS_NM, @SRC_STRG_CONT_NM, @SRC_STRG_PATH_NM, @SRC_STRG_FILE_NM, @SRC_DB_NM, @SRC_SCHEMA_NM, @SRC_TABLE_NM
            ,@TRGT_SYS_NM, @TRGT_STRG_CONT_NM, @TRGT_STRG_PATH_NM, @TRGT_STRG_FILE_NM, @TRGT_DB_NM, @TRGT_SCHEMA_NM, @TRGT_TABLE_NM
            ,@PROC_EXEC_DT, @PROC_EXEC_HH, @PROC_EXEC_MM, @PARAM_DT, @PARAM_HH, @BATCH_TP, @WORK_NM        
            ,@RUN_ID, @RUN_STATUS, @START_TIME, @END_TIME, @ERROR_CD, @ERROR_MSG, @PARTITION_KEY, @SRC_STRG_NM, @TRGT_STRG_NM
			,@SRC_RECORD_CNT, NULL, NULL, NULL, NULL, @INPUT_TP
        );
    END  

	/* 3. 로그 종료 업데이트 (개별 태스크 키가 존재하는 경우) */
	ELSE IF @TASK_KEY IS NOT NULL AND @END_TIME IS NOT NULL  
    BEGIN  
        UPDATE [CTL].[LOG_HIST]  
           SET [PROC_NM] = @PROC_NM, [SRC_SYS_NM] = @SRC_SYS_NM, [SRC_STRG_CONT_NM] = @SRC_STRG_CONT_NM, [SRC_STRG_PATH_NM] = @SRC_STRG_PATH_NM, [SRC_STRG_FILE_NM] = @SRC_STRG_FILE_NM
             , [SRC_DB_NM] = @SRC_DB_NM, [SRC_SCHEMA_NM] = @SRC_SCHEMA_NM, [SRC_TABLE_NM] = @SRC_TABLE_NM, [TRGT_SYS_NM] = @TRGT_SYS_NM, [TRGT_STRG_CONT_NM] = @TRGT_STRG_CONT_NM
             , [TRGT_STRG_PATH_NM] = @TRGT_STRG_PATH_NM, [TRGT_STRG_FILE_NM] = @TRGT_STRG_FILE_NM, [TRGT_DB_NM] = @TRGT_DB_NM, [TRGT_SCHEMA_NM] = @TRGT_SCHEMA_NM, [TRGT_TABLE_NM] = @TRGT_TABLE_NM
             , [PROC_EXEC_DT] = @PROC_EXEC_DT, [PROC_EXEC_HH] = @PROC_EXEC_HH, [PROC_EXEC_MM] = @PROC_EXEC_MM, [BATCH_TP] = @BATCH_TP, [WORK_NM] = @WORK_NM  
             , [RUN_STATUS] = @RUN_STATUS, [END_TIME] = @END_TIME, [ERROR_CD] = @ERROR_CD, [ERROR_MSG] = @ERROR_MSG, [PARTITION_KEY] = @PARTITION_KEY
             , [SRC_STRG_NM] = @SRC_STRG_NM, [TRGT_STRG_NM] = @TRGT_STRG_NM, [TRGT_RECORD_CNT] = @TRGT_RECORD_CNT
			 , [DURATION] = DATEDIFF(SECOND, [START_TIME], @END_TIME)
			 , [AVG_DURATION] = CASE WHEN @CNT_DURATION < @AVG_CNT THEN NULL ELSE @SUM_DURATION/@CNT_DURATION END
			 , [OUTLIER] = CASE WHEN @CNT_DURATION < @AVG_CNT  
					OR ABS(CASE WHEN @CNT_DURATION < @AVG_CNT THEN NULL ELSE @SUM_DURATION/@CNT_DURATION END - (DATEDIFF(SECOND, [START_TIME], @END_TIME)))
					   <= (@OUTLIER_PER/100.0) * (DATEDIFF(SECOND, [START_TIME], @END_TIME)) THEN NULL ELSE @OUTLIER_TXT END
			 , [INPUT_TP] = @INPUT_TP
         WHERE [RUN_ID] = @RUN_ID  
           AND [TASK_KEY] = @TASK_KEY
           AND [PARAM_DT] = @PARAM_DT  
           AND [PARAM_HH] = @PARAM_HH;

		-- 마스터 상태 테이블 업데이트
		UPDATE [CTL].[TASK_MNG]
		   SET [TASK_STATUS] = @RUN_STATUS
			 , [LAST_UPDATE_DT] = GETDATE() AT TIME ZONE 'UTC' AT TIME ZONE 'Korea Standard Time'
		 WHERE [TASK_KEY] = @TASK_KEY
		   AND [PARAM_DT] = @PARAM_DT
		   AND [PARAM_HH] = @PARAM_HH
		   AND [PROC_EXEC_DT] = @PROC_EXEC_DT;
	END

	/* 4. 로그 종료 업데이트 (파이프라인 전체 로그용) */
    ELSE IF @TASK_KEY IS NULL AND @END_TIME IS NOT NULL  
    BEGIN  
        UPDATE [CTL].[LOG_HIST]  
           SET [PROC_NM] = @PROC_NM, [RUN_STATUS] = @RUN_STATUS, [END_TIME] = @END_TIME  
             , [DURATION] = DATEDIFF(SECOND, [START_TIME], @END_TIME)
             /* ... (중략: 필드 업데이트 로직은 위와 동일) ... */
             , [INPUT_TP] = @INPUT_TP
         WHERE [RUN_ID] = @RUN_ID  
           AND [TASK_KEY] IS NULL;
     END  
     
	/* 5. 데이터 유지 관리 (14일 경과 로그 삭제) */
	BEGIN
		DELETE [CTL].[LOG_HIST]
		 WHERE [START_TIME] <= TRY_CONVERT(DATE, DATEADD(DAY, -14, GETDATE()) AT TIME ZONE 'UTC' AT TIME ZONE 'Korea Standard Time');
	END
END

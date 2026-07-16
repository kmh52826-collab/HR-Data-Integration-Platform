/********************************************************************************
 * Business Area        : System Control
 * Program ID           : SP_INS_RAW_PIP_INFO
 * Program Name         : Record Data Pipeline Execution History and Update Status
 * Description          : Called at the start and end of data collection/transmission
 * processes to record execution status, duration, error messages, etc.
 * Also automatically cleans up logs older than 14 days.
 * Input                : Pipeline execution info such as @PROC_NM, @TASK_KEY, @RUN_ID, etc.
 * Output               : None (Performs Table Insert/Update/Delete)
 * Author               : Minho Kim
 * Date                 : 2026-03-05
 ********************************************************************************/

CREATE PROC [CTL].[SP_INS_RAW_PIP_INFO]  
     @PROC_NM [NVARCHAR](250)              -- [Required] Process (Pipeline) Name
    ,@TASK_KEY [nvarchar](100)             -- [Optional] Individual Task/Order Identification Key
	,@SRC_SYS_NM [nvarchar](100)           -- Source System Code/Name
	,@SRC_STRG_CONT_NM [nvarchar](100)     -- Source Storage Container
	,@SRC_STRG_PATH_NM [nvarchar](200)     -- Source File Path
	,@SRC_STRG_FILE_NM [nvarchar](100)     -- Source File Name
	,@SRC_DB_NM [nvarchar](100)            -- Source Database Name
	,@SRC_SCHEMA_NM [nvarchar](100)        -- Source Schema Name
	,@SRC_TABLE_NM [nvarchar](100)         -- Source Table Name
	,@TRGT_SYS_NM [nvarchar](100)          -- Target System Code/Name
	,@TRGT_STRG_CONT_NM [nvarchar](100)    -- Target Storage Container
	,@TRGT_STRG_PATH_NM [nvarchar](200)    -- Target File Path
	,@TRGT_STRG_FILE_NM [nvarchar](100)    -- Target File Name
	,@TRGT_DB_NM [nvarchar](100)           -- Target Database Name
	,@TRGT_SCHEMA_NM [nvarchar](100)       -- Target Schema Name
	,@TRGT_TABLE_NM [nvarchar](100)        -- Target Table Name
    ,@PROC_EXEC_DT [nvarchar](100)         -- Execution Reference Date (YYYYMMDD)
    ,@PROC_EXEC_HH [nvarchar](100)         -- Execution Reference Hour (HH)
	,@PROC_EXEC_MM [nvarchar](100)         -- Execution Reference Minute (mm)
    ,@PARAM_DT [nvarchar](200)             -- Parameter Date
    ,@PARAM_HH [nvarchar](200)             -- Parameter Hour
    ,@BATCH_TP [nvarchar](100)             -- Batch Type (Daily, Hourly, etc.)
    ,@WORK_NM [nvarchar](200)              -- Execution Tool/Workbook Name
    ,@RUN_ID [NVARCHAR](250)               -- [Required] Execution Unique ID (ADF Run ID, etc.)
    ,@RUN_STATUS [NVARCHAR](50)            -- Execution Status (InProgress, Succeeded, Failed)
    ,@START_TIME [DATETIME]                -- Start Date/Time
    ,@END_TIME [DATETIME]                  -- End Date/Time (Input only upon completion)
	,@ERROR_CD [nvarchar](100)             -- Error Code
	,@ERROR_MSG [nvarchar](max)            -- Error Message Details
	,@INPUT_TP [VARCHAR](100)              -- Input Type
	,@PARTITION_KEY [nvarchar](1000)       -- Partition Key Information
	,@SRC_STRG_NM  [nvarchar](200)         -- Source Storage Name
	,@TRGT_STRG_NM  [nvarchar](200)	       -- Target Storage Name
    ,@SRC_RECORD_CNT BIGINT                -- Source Record Count
	,@TRGT_RECORD_CNT BIGINT               -- Target Record Count
AS   
BEGIN  
    SET NOCOUNT ON; -- Suppress unnecessary DONE_IN_PROC messages (Improves performance)

    -- Internal Variable Declaration
    DECLARE @SUM_DURATION DECIMAL(15,2);
	DECLARE @CNT_DURATION INT;
	DECLARE @AVG_CNT INT = 5;									-- Average count threshold for execution time Outlier measurement
	DECLARE @OUTLIER_PER INT = 10;								-- Execution time Outlier threshold (%)
	DECLARE @OUTLIER_TXT NVARCHAR(200) = 'Outlier Duration';	-- Execution time Outlier text

    /* 1. Calculate Average Execution Time (Based on recent execution history) */
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
     
	/* 2. Record Log Start (Create new record if end date/time is null) */
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

	/* 3. Update Log End (If individual Task Key exists) */
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

		-- Update Master Status Table
		UPDATE [CTL].[TASK_MNG]
		   SET [TASK_STATUS] = @RUN_STATUS
			 , [LAST_UPDATE_DT] = GETDATE() AT TIME ZONE 'UTC' AT TIME ZONE 'Korea Standard Time'
		 WHERE [TASK_KEY] = @TASK_KEY
		   AND [PARAM_DT] = @PARAM_DT
		   AND [PARAM_HH] = @PARAM_HH
		   AND [PROC_EXEC_DT] = @PROC_EXEC_DT;
	END

	/* 4. Update Log End (For pipeline-wide logs) */
    ELSE IF @TASK_KEY IS NULL AND @END_TIME IS NOT NULL  
    BEGIN  
        UPDATE [CTL].[LOG_HIST]  
           SET [PROC_NM] = @PROC_NM, [SRC_SYS_NM] = @SRC_SYS_NM, [SRC_STRG_CONT_NM] = @SRC_STRG_CONT_NM, [SRC_STRG_PATH_NM] = @SRC_STRG_PATH_NM, [SRC_STRG_FILE_NM] = @SRC_STRG_FILE_NM
             , [SRC_DB_NM] = @SRC_DB_NM, [SRC_SCHEMA_NM] = @SRC_SCHEMA_NM, [SRC_TABLE_NM] = @SRC_TABLE_NM, [TRGT_SYS_NM] = @TRGT_SYS_NM, [TRGT_STRG_CONT_NM] = @TRGT_STRG_CONT_NM
             , [TRGT_STRG_PATH_NM] = @TRGT_STRG_PATH_NM, [TRGT_STRG_FILE_NM] = @TRGT_STRG_FILE_NM, [TRGT_DB_NM] = @TRGT_DB_NM, [TRGT_SCHEMA_NM] = @TRGT_SCHEMA_NM, [TRGT_TABLE_NM] = @TRGT_TABLE_NM
             , [PROC_EXEC_DT] = @PROC_EXEC_DT, [PROC_EXEC_HH] = @PROC_EXEC_HH, [PROC_EXEC_MM] = @PROC_EXEC_MM, [BATCH_TP] = @BATCH_TP, [WORK_NM] = @WORK_NM  
             , [RUN_STATUS] = @RUN_STATUS, [END_TIME] = @END_TIME, [ERROR_CD] = @ERROR_CD, [ERROR_MSG] = @ERROR_MSG, [PARTITION_KEY] = @PARTITION_KEY
             , [SRC_STRG_NM] = @SRC_STRG_NM, [TRGT_STRG_NM] = @TRGT_STRG_NM, [SRC_RECORD_CNT] = NULL, [TRGT_RECORD_CNT] = NULL
			 , [DURATION] = DATEDIFF(SECOND, [START_TIME], @END_TIME)
			 , [AVG_DURATION] = CASE WHEN @CNT_DURATION < @AVG_CNT THEN NULL ELSE @SUM_DURATION/@CNT_DURATION END
			 , [OUTLIER] = CASE WHEN @CNT_DURATION < @AVG_CNT  
					OR ABS(CASE WHEN @CNT_DURATION < @AVG_CNT THEN NULL ELSE @SUM_DURATION/@CNT_DURATION END - (DATEDIFF(SECOND, [START_TIME], @END_TIME)))
					   <= (@OUTLIER_PER/100.0) * (DATEDIFF(SECOND, [START_TIME], @END_TIME)) THEN NULL ELSE @OUTLIER_TXT END
			 , [INPUT_TP] = @INPUT_TP
         WHERE [RUN_ID] = @RUN_ID  
           AND [TASK_KEY] IS NULL;
     END  
     
	/* 5. Data Maintenance (Delete logs older than 14 days) */
	BEGIN
		DELETE [CTL].[LOG_HIST]
		 WHERE [START_TIME] <= TRY_CONVERT(DATE, DATEADD(DAY, -14, GETDATE()) AT TIME ZONE 'UTC' AT TIME ZONE 'Korea Standard Time');
	END
END

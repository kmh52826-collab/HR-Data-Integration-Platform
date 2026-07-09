# 📊 HR Fact Tables - 테이블 구조

## 개요

HR 데이터 통합 7개 팩트 테이블의 상세 구조 문서입니다.

* **저장 위치**: `gld.hr`
* **파일 형식**: Delta Lake (EXTERNAL)
* **스토리지**: Azure ADLS Gen2

---

## 1. f_hr_license (자격증 정보)

**테이블명**: `gld.hr.f_hr_license`

| 컬럼명 | 데이터 타입 | 설명 |
|--------|-------------|------|
| MOD_PRSN | decimal(38,10) | 변경자 |
| MOD_DTT | timestamp | 변경일시 |
| TZ_CD | varchar(10) | 타임존코드 |
| TZ_DTT | timestamp | 타임존일시 |
| EMP_ID | string | 사원ID |
| EMP_LCNS_ID | decimal(38,10) | 사원자격ID |
| ISSUE_ORG | varchar(500) | 발급기관 |
| LCNS_DIV_CD | varchar(10) | 자격구분코드 |
| LCNS_DIV_NM | varchar(150) | 자격구분명 |
| LCNS_NM | varchar(150) | 자격증명 |
| NOTE | varchar(200) | 비고 |
| BONUS_PAY_DIV_CD | varchar(10) | 수당지급구분 |
| REG_YN | varchar(1) | 등록여부 |
| LCNS_NO | varchar(100) | 자격면허번호 |
| VALID_DT | timestamp | 유효일자 |
| GET_DT | timestamp | 취득일자 |
| PRSNL_ID | decimal(38,10) | 개인ID |
| LCNS_CD | varchar(10) | 자격면허코드 |

---

## 2. f_hr_scholar (학력 정보)

**테이블명**: `gld.hr.f_hr_scholar`

| 컬럼명 | 데이터 타입 | 설명 |
|--------|-------------|------|
| SUBMJR_NM | varchar(60) | 부전공명 |
| SUBMJR_CD | varchar(10) | 부전공코드 |
| SCHENT_DIV_CD | varchar(10) | 입학구분코드 |
| SCH_DIV_CD | varchar(10) | 학교구분코드 |
| DAY_NIGHT_DIV_CD | varchar(10) | 주야간구분코드 |
| SCH_PLC_CD | varchar(10) | 소재지코드 |
| SCH_PLC_NM | varchar(500) | 소재지 |
| SCH_PLC_DTLS_CD | varchar(10) | 소재지세부코드 |
| PLC_REGION_DTLS | varchar(500) | 소재지역세부 |
| LAST_SCHLST_YN | varchar(1) | 최종학력여부 |
| CAREER_ADMIT_MTH_CNT | decimal(3,0) | 경력인정개월수 |
| NOTE | varchar(200) | 비고 |
| MOD_PRSN | decimal(38,10) | 변경자 |
| MOD_DTT | timestamp | 변경일시 |
| TZ_CD | varchar(10) | 타임존코드 |
| TZ_DTT | timestamp | 타임존일시 |
| EMP_SCHLST_ID | decimal(38,10) | 사원학력ID |
| EMP_ID | string | 사원ID |
| PRSNL_ID | decimal(38,10) | 개인ID |
| SCHENT_YYYYMM | varchar(6) | 입학년월 |
| GRAD_YYYYMM | varchar(6) | 졸업년월 |
| SCHLST_CD | string | 학력코드 |
| SCH_CD | varchar(10) | 학교코드 |
| MAJOR_CD | string | 전공코드 |
| DOU_MAJOR_CD | varchar(10) | 복수전공코드 |
| DOU_MAJOR_NM | varchar(60) | 복수전공명 |
| SCHLST_NM | string | 학력명 |
| SCH_NM | string | 학교명 |
| MJR_NM | string | 전공명 |
| LAST_SCH_NM | string | 최종학교명 |

---

## 3. f_hr_reward_penalty (상벌 정보)

**테이블명**: `gld.hr.f_hr_reward_penalty`

| 컬럼명 | 데이터 타입 | 설명 |
|--------|-------------|------|
| CAM_APPLY_YN | varchar(1) | 발령적용여부 |
| CAM_DEL_YN | varchar(1) | 발령삭제여부 |
| HR_FIELD_CD | varchar(10) | 인사영역코드 |
| EMP_ID | string | 사원ID |
| RWD_RNTY_DIV_CD | varchar(10) | 상벌구분 |
| RWD_RNTY_KIND_CD | varchar(10) | 상벌종류코드 |
| INOUT_HOUSE_DIV_CDD | varchar(10) | 사내구분 |
| RWD_RNTY_NO | varchar(50) | 상벌번호 |
| RWD_RNTY_NM | varchar(150) | 상벌명 |
| RWD_RNTY_DT | timestamp | 상벌일자 |
| RWD_AMT | decimal(10,0) | 포상금액 |
| RWD_PNTY_RSN | varchar(500) | 상벌사유 |
| END_DT | timestamp | 종료일 |
| PERCOM_DT_FRST | varchar(80) | 인사위일자 1차 |
| INPUT_DATA_TYPE_CD | varchar(50) | 인사위일자 2차 |
| MENTOR_POOL_ID | decimal(38,10) | 멘토링체계ID |
| CAM_REG_YN | varchar(2) | 발령등록유무(징계발령사용) |
| CAM_LINK_DTT | timestamp | 발령연동일시(징계발령사용) |
| CAM_CNF_DOC_ID | decimal(38,10) | 발령품의서ID(징계발령사용) |
| CAM_RCPNT_ID | decimal(38,10) | 발령대상자ID(징계발령사용) |
| NOTE | varchar(200) | 비고 |
| MOD_PRSN | decimal(38,10) | 변경자 |
| MOD_DTT | timestamp | 변경일시 |
| TZ_CD | varchar(10) | 타임존코드 |
| TZ_DTT | timestamp | 타임존일시 |
| RWD_DTLS_MNGMNT_ID | decimal(38,10) | 상벌상세관리ID |

---

## 4. f_hr_career (경력 정보)

**테이블명**: `gld.hr.f_hr_career`

| 컬럼명 | 데이터 타입 | 설명 |
|--------|-------------|------|
| EMP_CAREER_ID | decimal(38,10) | 사원경력ID |
| PLC | varchar(750) | 근무지 |
| PRSNL_ID | decimal(38,10) | 개인ID |
| WORK_STRT_DT | timestamp | 근무시작일자 |
| WORK_END_DT | timestamp | 근무종료일자 |
| WORK_ORG_NM | varchar(150) | 근무처명 |
| LAST_JOB_GD_NM | varchar(150) | 최종직급명 |
| RETRD_RSN | varchar(80) | 퇴사사유 |
| REAL_CAREER_MTH_CNT | decimal(3,0) | 실경력개월수 |
| ADMIT_RATE | decimal(3,0) | 인정률 |
| ADMIT_CAREER_MTH_CNT | string | 인정경력개월수 |
| NOTE | varchar(300) | 비고 |
| MOD_PRSN | decimal(38,10) | 변경자 |
| MOD_DTT | timestamp | 변경일시 |
| TZ_CD | varchar(10) | 타임존코드 |
| TZ_DTT | timestamp | 타임존일시 |
| EMGL_CMP_NM | varchar(150) | 영문회사명 |
| EMP_ID | string | 사원ID |
| WORK_NM | varchar(150) | 담당업무명 |

---

## 5. f_hr_military (병역 정보)

**테이블명**: `gld.hr.f_hr_military`

| 컬럼명 | 데이터 타입 | 설명 |
|--------|-------------|------|
| EMP_ID | string | 사원ID |
| INCMPL_RSN | varchar(50) | 미필사유 |
| SRV_TYPE_CD | varchar(50) | 복무형태코드 |
| EMP_MIL_SRVC_ID | decimal(38,10) | 사원병역ID |
| MIL_CPLT_DIV_CD | varchar(50) | 군필구분코드 |
| MIL_TYPE_CD | varchar(50) | 군별코드 |
| MIL_TYPE_NM | varchar(150) | 군별명 |
| MIL_BRNCH_CD | varchar(50) | 병과코드 |
| MIL_RANK_CD | varchar(50) | 계급코드 |
| MIL_RANK_NM | varchar(150) | 계급명 |
| MIL_NO | varchar(20) | 군번 |
| DSCHRG_DIV_CD | varchar(50) | 제대구분코드 |
| MIL_JOIN_DT | timestamp | 입대일자 |
| DSCHRG_DT | timestamp | 전역일자 |
| WRKPLC_RSRV_ARMY_JOIN_YN | decimal(5,0) | 직장인 예비군 가입여부 |
| MIL_CLASS_CD | varchar(50) | 역종코드 |
| MIL_CLASS_NM | varchar(150) | 역종명 |
| MIL_SP_CD | varchar(50) | 주특기코드 |
| MIL_SP_NM | varchar(150) | 주특기명 |
| NOTE | varchar(300) | 비고 |
| MOD_PRSN | decimal(38,10) | 변경자 |
| MOD_DTT | timestamp | 변경일시 |
| TZ_CD | varchar(10) | 타임존코드 |
| TZ_DTT | timestamp | 타임존일시 |
| PRSNL_ID | decimal(38,10) | 개인ID |
| MIL_ADMIT_MTH_CNT | double | 병역인정개월수 |

---

## 6. f_hr_language (어학 정보)

**테이블명**: `gld.hr.f_hr_language`

| 컬럼명 | 데이터 타입 | 설명 |
|--------|-------------|------|
| EMP_LANG_ESTM_ID | decimal(38,10) | 사원어학평가ID |
| EMP_ID | string | 사원ID |
| PRSNL_ID | decimal(38,10) | 개인ID |
| LANG_CD | varchar(10) | 어학코드 |
| LANG_NM | varchar(150) | 어학명 |
| STD_YYYY | varchar(4) | 기준일자(평가일자의 연도) |
| ESTM_DT | timestamp | 평가일자 |
| VALID_DT | timestamp | 유효일자 |
| LANG_DIV_CD | varchar(10) | 어학구분코드 |
| LANG_DIV_NM | varchar(150) | 어학구분명 |
| ESTM_ORG_CD | varchar(10) | 평가기관코드 |
| EST_ORG_NM | varchar(150) | 평가기관명 |
| LANG_SCR | varchar(50) | 어학점수 |
| LANG_GRD_CD | varchar(10) | 어학등급코드 |
| LANG_GRD_NM | varchar(150) | 어학등급명 |
| PRSNT_LEV | decimal(4,0) | Present Level |
| NOTE | varchar(200) | 비고 |
| MOD_PRSN | decimal(38,10) | 변경자 |
| MOD_DTT | timestamp | 변경일시 |
| TZ_CD | varchar(10) | 타임존코드 |
| TZ_DTT | timestamp | 타임존일시 |

---

## 7. f_hr_appoint_history (발령 정보)

**테이블명**: `gld.hr.f_hr_appoint_history`

| 컬럼명 | 데이터 타입 | 설명 |
|--------|-------------|------|
| LAYOFF_RTRN_SCHDL_DT | timestamp | 휴직복직예정일 |
| DSPTCH_YN | varchar(1) | 파견여부 |
| DSPTCH_DIV_CD | varchar(10) | 파견구분코드 |
| DSPTCH_RTRN_SCHDL_DT | timestamp | 파견복귀예정일 |
| DSPTCH_DEPT_CD | decimal(38,10) | 파견부서코드 |
| DSPTCH_PLC_NM | varchar(40) | 파견처명 |
| HIRED_DIV_CD | varchar(10) | 입사구분코드 |
| PENAL_CNCL_SCHDL_DT | timestamp | 징계해제예정일 |
| HR_RFLCTN_YN | varchar(1) | 인사반영여부 |
| SLRY_JOB_TTLE_GRD | varchar(10) | 급여직책등급 |
| PRNT_YN | varchar(1) | 출력여부 |
| JOB_GRP_CD | varchar(50) | 직군코드 |
| RFRNC_DIV_CD | varchar(50) | 신원보증구분 |
| ENTRST_YN | varchar(50) | 촉탁여부 |
| ENTRST_END_SCHDL_DT | varchar(50) | 촉탁종료예정일 |
| DEL_YN | varchar(50) | 삭제여부 |
| CNF_DOC_NO | varchar(100) | 품의번호 |
| CNF_DOC_NM | varchar(680) | 품의명칭 |
| CAM_RSN | varchar(900) | 발령사유 |
| NOTE | varchar(200) | 비고 |
| MOD_PRSN | decimal(38,10) | 변경자 |
| MOD_DTT | timestamp | 변경일시 |
| TZ_CD | varchar(10) | 타임존코드 |
| TZ_DTT | timestamp | 타임존일시 |
| CMP_DIV_CD | string | 회사구분코드 |
| CMP_DIV_NM | string | 회사구분명 |
| SLRY_STRT_SLRY_GRD_CD | varchar(10) | 급여시작급여등급코드 |
| FIRST_APPT_SLRY_KIND_CD | varchar(10) | 초임급여종류코드 |
| YRLY_SLRY_AMT | decimal(15,0) | 연봉금액 |
| JOB_SCND_YN | varchar(1) | 겸직여부 |
| JOB_SCND_CAM_CMP_CD | varchar(10) | 겸직발령회사코드 |
| JOB_SCND_JOB_GRP_CD | varchar(10) | 겸직직군코드 |
| RETRD_RSN_CD | varchar(10) | 퇴직사유코드 |
| RETRD_RSN_NM | varchar(150) | 퇴직사유명 |
| SLRY_GRD | varchar(10) | 급여등급 |
| SLRY_JOB_GRP | varchar(10) | 급여직군 |
| NEXTERM_JOB_GD_PRMT_DT | timestamp | 차기직급승진일자 |
| CAM_HIST_ID | decimal(38,10) | 발령이력ID |
| EMP_ID | string | 사원ID |
| PRSNL_ID | decimal(38,10) | 개인ID |
| CAM_CNF_ID | decimal(38,10) | 발령품의ID |
| CAM_STRT_DT | timestamp | 발령시작일자 |
| CAM_END_DT | timestamp | 발령종료일자 |
| CAM_DT | timestamp | 발령일자 |
| CAM_ORDER | decimal(5,0) | 발령순서 |
| CAM_CD | varchar(10) | 발령코드 |
| CAM_CLASS_CD | string | 발령분류코드 |
| CAM_HR_ZONE_CD | varchar(10) | 발령인사영역코드 |
| CAM_DEPT_ID | decimal(38,10) | 발령부서ID |
| CAM_JOB_RANK_CD | varchar(10) | 발령직급코드 |
| CAM_JOB_RANK_NM | string | 발령직급명 |
| JOB_CD | varchar(10) | 직무코드 |
| CAM_JOB_TTLE_CD | varchar(10) | 발령직책코드 |
| CAM_JOB_TTLE_NM | string | 발령직책명 |
| CAM_EMP_KIND_CD | varchar(10) | 발령사원종류코드 |
| CAM_YRLY_SLRY_TYPE | varchar(10) | 발령연봉유형 |
| PRBTN_YN | varchar(1) | 수습여부 |
| PRBTN_END_DT | timestamp | 수습종료일자 |
| JOB_SCND_DEPT_ID | decimal(38,10) | 겸직부서ID |
| JOB_SCND_JOB_GD_CD | varchar(10) | 겸직직급코드 |
| JOB_SCND_JOB_RANK_CD | varchar(10) | 겸직직급등급코드 |
| JOB_SCND_JOB_CD | varchar(10) | 겸직직무코드 |
| JOB_SCND_JOB_TTLE_CD | varchar(10) | 겸직직책코드 |
| LAYOFF_YN | varchar(1) | 휴직여부 |
| CAM_CLASS_NM | string | 발령분류명 |
| RETRD_TYPE | string | 퇴직유형 |
| RETRD_TYPE_NM | string | 퇴직유형명 |

---

## 컬럼 명명 규칙

* **ID 컬럼**: `_ID` 접미사 (예: EMP_ID, PRSNL_ID)
* **코드 컬럼**: `_CD` 접미사 (예: LCNS_CD, SCH_CD)
* **명칭 컬럼**: `_NM` 접미사 (예: LCNS_NM, SCH_NM)
* **일자 컬럼**: `_DT`, `_DTT` 접미사 (예: MOD_DTT, CAM_DT)
* **여부 컬럼**: `_YN` 접미사 (예: REG_YN, LAST_YN)
* **개월수**: `_MTH_CNT` 접미사
* **금액**: `_AMT` 접미사

## 공통 컬럼

모든 테이블에 공통적으로 포함되는 컬럼:

* **EMP_ID**: 사원 고유 식별자 (회사별 접두사 포함: f/q/a)
* **MOD_PRSN**: 최종 변경자
* **MOD_DTT**: 최종 변경일시
* **TZ_CD / TZ_DTT**: 타임존 정보
* **NOTE**: 비고/특이사항

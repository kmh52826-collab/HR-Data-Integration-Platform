# 🌐 HR Data Integration Platform
### Enterprise-Unified Analytics for Global Subsidiaries

> **10여 개 계열사의 이기종 HR 데이터를 통합하고 표준화하기 위한 엔드투엔드(End-to-End) 데이터 엔지니어링 솔루션입니다.**
>
> **[데이터 처리 및 현지화 안내]**
> * **현지화(Localization)**: 평가자의 이해를 돕기 위해 기존 시스템의 한글 필드명과 마스터 데이터를 모두 영어로 변환하여 구성했습니다.
> * **데이터 보안(Data Privacy)**: 기업의 민감 정보 보호를 위해 모든 실제 데이터는 **가데이터(Synthetic Data)** 로 대체되었으며, 이는 보안 정책을 준수합니다.


### **프로젝트 요약 (Project Executive Summary)**

본 프로젝트는 10여 개 계열사의 **이기종(Heterogeneous)** HR 데이터셋을 단일 통합 플랫폼으로 추상화(Abstraction)하여 데이터 기반 의사결정 체계를 구축한 엔드투엔드 데이터 엔지니어링 사례입니다. 

대규모 엔터프라이즈 환경에서의 **데이터 파편화(Data Fragmentation)** 문제를 해결하기 위해 다음과 같은 아키텍처 설계 원칙을 적용하였습니다:

* **Metadata-Driven Dynamic Orchestration**: **Azure Data Factory(ADF)** 와 메타데이터 저장소를 결합하여, 파이프라인 코드의 수정 없이 데이터 소스를 즉시 확장할 수 있는 **디커플링(Decoupling)** 구조를 구현했습니다.
* **Scalable ETL Processing**: **Azure Databricks(Apache Spark)** 를 활용하여 분산 컴퓨팅 기반의 고성능 ETL 프로세스를 구축함으로써 대용량 데이터 처리의 효율성을 극대화했습니다.
* **Unified Data Governance via Medallion Architecture**: **Bronze → Silver → Gold**로 이어지는 단계적 정제 계층을 통해 데이터 무결성(Data Integrity)을 확보하고, 분석 최적화된 고품질의 통합 데이터 자산을 구축했습니다.
* **Operational Observability & Visualization**: 전 과정에 걸친 모니터링 체계를 통합하여 시스템의 **관측성(Observability)** 을 확보하였으며, 이를 **Power BI**와 연동하여 전사적 인사이트를 도출하는 시각화 프레임워크를 완성했습니다.

---

### **🛠 Tech Stack**

| Category | Technologies |
| :--- | :--- |
| **Data Orchestration** | Azure Data Factory (ADF) |
| **Data Processing** | Azure Databricks, Apache Spark (PySpark), SQL |
| **Storage & Database** | Azure Data Lake Storage (ADLS) Gen2, Delta Lake, Azure SQL Database |
| **BI & Visualization** | Power BI (DAX, Star Schema Modeling), BI-Matrix |
| **Languages** | Python, SQL, JavaScript |
  
---
## 🏗️ Overall System Architecture
<img width="2559" height="174" alt="image" src="https://github.com/user-attachments/assets/3302ae1d-ea9d-41f5-82c3-b81828ddb2df" />
<img width="2557" height="1436" alt="image" src="https://github.com/user-attachments/assets/e139007a-e937-48eb-9394-d13fa95a388d" />

---
## 🏗️ Azure Data Factory Pipeline
<img width="2556" height="745" alt="image" src="https://github.com/user-attachments/assets/e070fd3e-ed81-49df-8362-7b3167d40fd0" />

> ### I engineered this **Metadata-Driven Dynamic Pipeline** to ensure high scalability and automated observability.

### Step 1. Contextual Observability (Logging)
* **Process:** 파이프라인 시작 시 `SP_INS_RAW_PIP_INFO` 프로시저를 호출하여 고유 Execution ID를 생성하고 세션 컨텍스트를 기록합니다.
* **Engineering Rationale:** 대규모 분산 환경에서 프로세스의 **상태 추적(State Tracking)** 과 **감사 추적(Audit Trail)** 을 자동화하여 시스템 전체의 **관측성(Observability)** 을 확보했습니다. 이는 복잡한 파이프라인 내의 병목 지점을 식별하고 디버깅 효율성을 극대화하기 위한 설계입니다.

### Step 2. Abstracted Orchestration (Dynamic)
* **Process:** `Get_Order_List` (Lookup) 단계를 통해 런타임 시점에 처리해야 할 소스 리스트와 메타데이터를 동적으로 쿼리합니다.
* **Engineering Rationale:** 비즈니스 로직과 데이터 소스를 완전히 분리하는 **디커플링(Decoupling)** 설계를 적용했습니다. 이를 통해 파이프라인 코드의 재배포 없이 데이터 소스를 확장할 수 있는 구조를 구현하여, 기업의 가변적인 데이터 요구사항에 즉각 대응할 수 있는 **유연성(Flexibility)** 을 확보했습니다.

### Step 3. Elastic Throughput & Resilience (Scale)
* **Process:** **ForEach 루프**를 활용하여 Apache Spark 기반의 Databricks 노트북을 병렬로 트리거하며, 각 태스크는 **지능형 재시도(Retry)** 로직을 포함합니다.
* **Engineering Rationale:** 컴퓨팅 자원의 효율적 배분을 위해 **병렬성(Parallelism)** 을 극대화하여 대용량 데이터 처리 시간을 단축했습니다. 또한, 개별 작업의 실패가 전체 워크플로우의 중단으로 이어지지 않도록 **결함 허용(Fault Tolerance)** 아키텍처를 구축하여 시스템 안정성을 높였습니다.

### Step 4. Transactional Integrity (Integrity)
* **Process:** 모든 병렬 작업의 결과를 종합하여 `SP_INS_RAW_PIP_INFO`를 통해 최종 성공/실패 여부를 판별하고 데이터셋의 유효성을 검증합니다.
* **Engineering Rationale:** 데이터 처리의 **원자성(Atomicity)** 과 **데이터 무결성(Data Integrity)** 을 보장하기 위한 최종 관문입니다. 모든 종속 작업이 성공적으로 검증된 경우에만 하위 Gold 레이어에 상태를 동기화함으로써, 분석가들에게 항상 신뢰할 수 있는 고품질의 데이터를 제공합니다.


### 🔗 **[View Detailed procedure (SP_INS_RAW_PIP_INFO.sql)](ETL/sql-procedure/SP_INS_RAW_PIP_INFO.sql)**
---
## 🏗️ Databricks Medallion Architecture
<img width="1594" height="691" alt="image" src="https://github.com/user-attachments/assets/e7d8f702-4eec-4337-9232-270f544aa38a" />

> 10여 개 계열사의 파편화된 데이터를 통합하고 시스템 전반의 신뢰성을 확보하기 위해 **메달리온 아키텍처(Medallion Architecture)** 를 설계했습니다. 단순히 데이터를 옮기는 것에 그치지 않고, 단계별 검증 체계를 구축하여 데이터 거버넌스와 무결성을 동시에 달성했습니다.

### Key Layers & Engineering Rationales

#### 🟫 Bronze (Raw Zone)
* **역할:** 이기종 소스 시스템(다양한 ERP)으로부터 수집된 가공되지 않은 원천 데이터 저장소.
* **설계 근거(Why):** 원천 데이터를 변형 없이 보존함으로써 **데이터 계보(Data Lineage)** 를 명확히 했습니다. 이는 추후 분석 요건이 변경되거나 시스템 장애가 발생했을 때, 소스 시스템에 재접속하지 않고도 언제든 데이터를 재처리(Reprocessing)할 수 있는 **결함 허용(Fault Tolerance)** 능력을 확보하기 위함입니다.

#### 🌫️ Silver (Validated Zone)
* **역할:** 정제, 검증 및 표준화가 완료된 데이터 저장소.
* **핵심 프로세스:** 데이터 클렌징, 중복 제거, 스키마 강제 적용(Schema Enforcement), MDM 매핑.
* **설계 근거(Why):** 서로 다른 코드 체계를 가진 계열사 데이터를 그룹 표준으로 통일하는 **데이터 표준화(Data Standardization)** 의 핵심 단계입니다. 이 계층에서 엄격한 품질 검증을 수행함으로써, 하위 분석 단계로 데이터 오류가 전이되는 것을 차단하고 플랫폼 전체의 **데이터 신뢰도**를 극대화했습니다.

#### 🟨 Gold (Enriched Zone)
* **역할:** 비즈니스 로직이 반영된 분석 최적화형 데이터 저장소 (HR Fact Tables).
* **핵심 프로세스:** 복잡한 조인(Join), 집계(Aggregation), 인사이트 도출을 위한 데이터 모델링.
* **설계 근거(Why):** Power BI 대시보드와 같은 실제 분석 환경에서 **고성능 쿼리 응답 속도**를 보장하기 위해 설계되었습니다. 정규화된 데이터를 분석 목적에 맞게 재구성(Denormalization)하여 사용자에게 즉각적이고 정확한 인사이트를 제공하는 **고품질 데이터 자산**을 구축했습니다.

---
## 🏗️ How the Gold Table is Built
<img width="1907" height="1375" alt="image" src="https://github.com/user-attachments/assets/99fd3a36-cf82-4487-8e65-55638f3d321a" />

### 📌 개요 (Overview)
* **Core Objective:** 시스템B(White) 및 시스템A(더존 3사)로 이원화된 소스 데이터를 통합하여 분석 최적화형 7종 **HR Fact Tables** 구축
* **Architecture:** Databricks Medallion Architecture의 **Gold Layer**에 위치하며, Delta Lake 포맷으로 Azure ADLS Gen2에 저장됩니다.
* **Key Value:** 전사 통합 사원 식별자(`EMP_ID`)를 기반으로 파편화된 인사 정보를 단일 뷰(Single View)로 제공하여 분석 효율성을 극대화합니다.

### 🎯 범위 (Scope)
인사 행정의 핵심인 7대 영역을 선정하여, 이력 추적 및 분석이 용이한 팩트 테이블을 설계하고 구현했습니다.

| 영역 (Category) | 테이블명 (Table Name) | 주요 관리 항목 (Key Attributes) |
| :--- | :--- | :--- |
| **자격증** | `f_hr_license` | 자격면허코드, 취득/유효일자, 발급기관, 수당지급구분 |
| **학력** | `f_hr_scholar` | 학교/전공/학력코드, 입학/졸업년월, 최종학력 여부 |
| **상벌** | `f_hr_reward_penalty` | 상벌구분/종류, 상벌일자, 포상금액, 상벌사유 |
| **경력** | `f_hr_career` | 이전 근무처, 담당업무, 인정률, 인정경력 개월수 |
| **병역** | `f_hr_military` | 군별/계급/역종, 입대/전역일자, 미필사유, 인정개월수 |
| **어학** | `f_hr_language` | 어학시험종류, 평가기관, 취득점수/등급, 유효기한 |
| **발령이력** | `f_hr_appoint_history` | 발령코드/분류, 부서/직급/직책 변동, 휴직/퇴직 정보 |


### 🔗 **[View Detailed Transformation Logic (01.NB_Fct_To_Gld.ipynb)](ETL/pipeline/01.NB_Fct_To_Gld.ipynb)**
### 🔗 **[View Detailed Table Definition (02.Table_Definition.md)](ETL/pipeline/02.Table_Definition.md)**

---

## 🏗️ How I Integrated Code Across Different Systems
<img width="1273" height="869" alt="image" src="https://github.com/user-attachments/assets/7833de2e-086c-4181-bc0c-879901f7e304" />


### ✅ Heterogeneous Data Integration & Master Data Management (MDM)

#### 10여 개 계열사의 상이한 데이터 스키마를 단일 표준으로 통합하기 위해, 기존 인프라를 활용한 독립적 MDM 엔진을 자체 설계 및 구현했습니다.

* **문제점 (Problem Context)**
    * **Semantic Inconsistency (의미론적 불일치)**: 서로 다른 ERP 시스템을 사용하는 10여 개 계열사 간의 마스터 코드 구조가 불일치하여, 전사적 차원의 인력 현황 집계 및 통계적 분석이 불가능한 **데이터 파편화(Data Fragmentation)** 문제가 존재했습니다.
    * **Resource Constraint (자원 제약)**: 상용 MDM 솔루션 도입은 막대한 비용과 시간이 소요되는 제약이 있었으므로, 기술적 목표 달성을 위해 한정된 예산 내에서 구동 가능한 **자체 구축형 솔루션**이 필수적이었습니다.

* **해결책 (Engineering Solution)**
    * **Custom MDM Framework 내재화**: 사내에 기 도입된 BI-Matrix 플랫폼을 활용하여 추가 비용 없이 독자적인 MDM 로직을 개발했습니다. 이는 기술적 자립도를 높임과 동시에 비즈니스 요구사항에 기민하게 대응할 수 있는 구조입니다.
    * **Standardized Schema Mapping**: 각 계열사의 로컬 코드를 그룹 표준 코드에 1:1로 정렬하는 **매핑 엔진**을 구축하여 데이터의 일관성을 확보했습니다. 이를 통해 이기종 데이터 소스 간의 **상호운용성(Interoperability)** 을 달성했습니다.
    * **Efficiency & Sustainability**: 솔루션 외주 대비 구축 비용을 획기적으로 절감함과 동시에, 향후 계열사 확장에 즉각 대응할 수 있는 지속 가능한 데이터 거버넌스 체계를 완성했습니다.

### 🔗 **[View Detailed MDM (01.MDM_Overview.md)](MDM/01.MDM_Overview.md)**

### Technical Note
> **BI-Matrix**: A specialized Low-code Business Intelligence (BI) platform used to rapidly design data interfaces and implement complex business logic.

---
## 🌟 Data Visualization & Analytical Modeling
> ### This is one of the analytical dashboards I developed during the HR project
<img width="2553" height="1193" alt="image" src="https://github.com/user-attachments/assets/cda8124d-cfbb-4c2c-90cf-5264a828f4a3" />
<img width="2262" height="1431" alt="image" src="https://github.com/user-attachments/assets/78cdb405-8282-4a5d-a09d-54d86a2acc8e" />

ETL 파이프라인을 통해 구축된 Gold Layer 데이터를 활용하여, 인사 의사결정을 지원하는 **분석 대시보드**와 **최적화된 데이터 모델(Star Schema)** 을 구현했습니다.

### 📈 Employee Turnover Analysis Dashboard
* **Insight-Driven Design:** 전사 퇴직률(Turnover Rate) 및 근속 연수(Avg. Tenure)를 실시간 모니터링하여 인력 손실 리스크를 조기 식별합니다.
* **Multidimensional Analysis:** 계열사별, 직급별, 퇴직 사유별 교차 분석 기능을 제공하여 데이터 기반의 인사 전략 수립을 지원합니다.

### 📐 Star Schema Data Modeling (ERD)
* **Optimization for BI:** 대규모 HR 데이터를 Power BI 환경에서 효율적으로 처리하기 위해 Fact와 Dimension 테이블을 명확히 분리한 **Star Schema** 구조를 설계했습니다.
* **Data Integrity:** `f_hr_employee_history`를 중심으로 인사 발령(`f_hr_appoint_history`), 조직 정보 등 복잡한 관계를 1:N으로 정규화하여 쿼리 성능과 데이터 정합성을 동시에 확보했습니다.
* **Row-Level Security (RLS):** 인사 데이터의 민감도를 고려하여 사용자 권한에 따른 데이터 접근 제어(`m_org_info_rls`)가 가능하도록 모델을 아키텍처링했습니다.

---

## 🏆 Key Accomplishments & Business Impact

본 프로젝트를 통해 기술적 부채를 해결하고, 데이터 기반의 인사 전략 수립이 가능한 엔터프라이즈 환경을 구축했습니다.

* **Single Source of Truth (SSOT) 구축**: 10여 개 계열사의 파편화된 인사 데이터를 전사 통합 사번(`EMP_ID`) 중심으로 표준화하여, 데이터 정합성이 확보된 신뢰할 수 있는 단일 원천을 완성했습니다.
* **분석 리드타임 획기적 단축**: 기존에 수일이 소요되던 계열사별 수동 집계 프로세스를 자동화된 **Gold Layer** 기반 쿼리로 대체하여, 전사 인력 현황 및 퇴직률 분석 속도를 실시간 수준으로 개선했습니다.
* **비용 최적화 및 기술 자립**: 고가의 상용 MDM 솔루션 대신 기존 인프라(BI-Matrix)를 활용한 **자체 MDM 엔진**을 구축하여 프로젝트 비용을 절감하고, 내부 요구사항에 기민하게 대응할 수 있는 기술적 내재화를 달성했습니다.
* **보안 및 거버넌스 강화**: **RLS(Row-Level Security)**를 적용한 데이터 모델링을 통해 민감한 인사 정보에 대한 보안 체계를 확립하고, 메달리온 아키텍처를 통한 체계적인 데이터 거버넌스를 구현했습니다.

## 💡 Lessons Learned

* **이기종 데이터 통합의 복잡성**: 서로 다른 비즈니스 로직을 가진 소스 시스템들을 하나의 표준으로 맞추는 과정에서, 기술적 구현만큼이나 현업 부서와의 **도메인 지식 공유 및 커뮤니케이션**이 중요함을 깊이 깨달았습니다.
* **확장성을 고려한 설계의 중요성**: ADF의 메타데이터 기반 동적 파이프라인을 구축하며, 초기 설계 단계에서의 **디커플링(Decoupling)** 이 향후 시스템 확장성과 유지보수 비용에 얼마나 큰 영향을 미치는지 체감했습니다.

---

## 📂 프로젝트 구조 (Project Structure)
```text
├── ETL/
│   ├── pipeline/          # 데이터 변환 및 가공을 위한 PySpark 스크립트 (.ipynb)
│   │   └── 01.NB_Fct_To_Gld.ipynb
│   │   └── 02.Table_Definition.md
│   └── sql-procedure/     # 파이프라인 실행 이력 기록 및 상태 업데이트 프로시저
│       └── SP_INS_RAW_PIP_INFO.sql
├── MDM/                   # 마스터 데이터(MDM) 매핑 및 검증 로직
│   ├── 01.MDM_Overview.md
│   └── 02.JScript.js
└── README.md              # 프로젝트 개요 및 가이드       

# 🌐 HR Data Integration Platform
### Enterprise-Unified Analytics for Global Subsidiaries

> **This is an end-to-end data engineering solution designed to integrate and standardize heterogeneous HR data across more than 10 subsidiaries.**
>
> **[Data Processing & Localization Guide]**
> * **Localization**: To facilitate understanding for evaluators, all Korean field names and master data from the legacy systems have been converted into English.
> * **Data Privacy**: To protect sensitive corporate information, all actual data has been replaced with **Synthetic Data**, ensuring full compliance with security policies.


### **Project Executive Summary**

This project is an end-to-end data engineering case study that establishes a data-driven decision-making system by abstracting **heterogeneous** HR datasets from over 10 subsidiaries into a single, unified platform.

To resolve **data fragmentation** issues in a large-scale enterprise environment, the following architectural design principles were applied:

* **Metadata-Driven Dynamic Orchestration**: Integrated **Azure Data Factory (ADF)** with a metadata repository to implement a **decoupling** structure that allows for the immediate expansion of data sources without modifying pipeline code.
* **Scalable ETL Processing**: Built a high-performance, distributed computing-based ETL process using **Azure Databricks (Apache Spark)** to maximize the efficiency of large-scale data processing.
* **Unified Data Governance via Medallion Architecture**: Secured data integrity through a phased refinement hierarchy from **Bronze → Silver → Gold**, building high-quality, integrated data assets optimized for analysis.
* **Operational Observability & Visualization**: Integrated a comprehensive monitoring system to ensure system **observability** and completed a visualization framework by linking it with **Power BI** to derive enterprise-wide insights.

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
* **Process:** At the start of the pipeline, the `SP_INS_RAW_PIP_INFO` procedure is called to generate a unique Execution ID and log the session context.
* **Engineering Rationale:** By automating **state tracking** and **audit trails** in a large-scale distributed environment, we achieved full system **observability**. This design is intended to identify bottlenecks within complex pipelines and maximize debugging efficiency.

### Step 2. Abstracted Orchestration (Dynamic)
* **Process:** Dynamically queries the list of sources and metadata to be processed at runtime through the `Get_Order_List` (Lookup) step.
* **Engineering Rationale:** Applied a **decoupling** design that completely separates business logic from data sources. This allows for the expansion of data sources without re-deploying pipeline code, ensuring the **flexibility** to immediately respond to variable corporate data requirements.

### Step 3. Elastic Throughput & Resilience (Scale)
* **Process:** Triggers Databricks notebooks based on Apache Spark in parallel using **ForEach loops**, with each task including intelligent **retry** logic.
* **Engineering Rationale:** Maximized **parallelism** for the efficient allocation of computing resources, reducing processing time for large-scale data. Furthermore, built a **fault-tolerant** architecture to ensure that the failure of individual tasks does not lead to the disruption of the entire workflow.

### Step 4. Transactional Integrity (Integrity)
* **Process:** Aggregates the results of all parallel tasks to determine final success/failure and verify dataset validity via `SP_INS_RAW_PIP_INFO`.
* **Engineering Rationale:** This is the final gateway to ensure the **atomicity** and **data integrity** of data processing. By synchronizing the status to the downstream Gold layer only when all dependent tasks are successfully verified, we provide analysts with consistently reliable, high-quality data.

### 🔗 **[View Detailed procedure (SP_INS_RAW_PIP_INFO.sql)](ETL/sql-procedure/SP_INS_RAW_PIP_INFO.sql)**
---
## 🏗️ Databricks Medallion Architecture
<img width="1594" height="691" alt="image" src="https://github.com/user-attachments/assets/e7d8f702-4eec-4337-9232-270f544aa38a" />

> To integrate fragmented data from over 10 subsidiaries and ensure reliability across the system, I designed the **Medallion Architecture**. Beyond simply moving data, I established a staged verification system to achieve both data governance and integrity.

### Key Layers & Engineering Rationales

#### 🟫 Bronze (Raw Zone)
* **Role:** A repository for unprocessed raw data collected from heterogeneous source systems.
* **Engineering Rationale (Why):** By preserving source data without modification, we clarified the **data lineage**. This ensures **fault tolerance** and the ability to re-process data at any time without reconnecting to source systems in the event of changes in analysis requirements or system failures.

#### 🌫️ Silver (Validated Zone)
* **Role:** A repository where cleansing, validation, and standardization are complete.
* **Key Process:** Data cleansing, deduplication, schema enforcement, and MDM mapping.
* **Engineering Rationale (Why):** This is the core stage of **data standardization**, uniting data from subsidiaries with different code systems into a group standard. By performing strict quality verification in this layer, we prevent data errors from propagating to lower analysis stages and maximize the **data reliability** of the entire platform.

#### 🟨 Gold (Enriched Zone)
* **Role:** An analysis-optimized data repository reflecting business logic (HR Fact Tables).
* **Key Process:** Complex joins, aggregation, and data modeling for insight derivation.
* **Engineering Rationale (Why):** Designed to guarantee **high-performance query response times** in actual analytical environments like Power BI dashboards. By reconstructing normalized data for specific analytical purposes (denormalization), we built **high-quality data assets** that provide immediate and accurate insights to users.

---
## 🏗️ How the Gold Table is Built
<img width="1907" height="1375" alt="image" src="https://github.com/user-attachments/assets/99fd3a36-cf82-4487-8e65-55638f3d321a" />

### 📌 Overview
* **Core Objective:** Integrate source data bifurcated into System B (White) and System A (3 Dozons) to build 7 types of analysis-optimized **HR Fact Tables**.
* **Architecture:** Located in the **Gold Layer** of the Databricks Medallion Architecture and stored in Azure ADLS Gen2 in Delta Lake format.
* **Key Value:** Provides a single view of fragmented personnel information based on the enterprise-integrated employee identifier (`EMP_ID`), maximizing analytical efficiency.

### 🎯 Scope
We selected 7 key areas of personnel administration and designed/implemented fact tables to facilitate history tracking and analysis.

| Category | Table Name | Key Attributes |
| :--- | :--- | :--- |
| **Certification** | `f_hr_license` | License code, Acquisition/Expiry date, Issuing body, Allowance classification |
| **Education** | `f_hr_scholar` | School/Major/Education code, Admission/Graduation year-month, Final education status |
| **Reward & Penalty** | `f_hr_reward_penalty` | Reward/Penalty type, Date, Amount, Reason |
| **Career** | `f_hr_career` | Previous employer, Job duty, Recognition rate, Recognized career months |
| **Military** | `f_hr_military` | Branch/Rank/Service type, Enlistment/Discharge date, Exemption reason, Recognized months |
| **Language** | `f_hr_language` | Test type, Evaluation body, Score/Grade, Expiration date |
| **Appointment History** | `f_hr_appoint_history` | Appointment code/Classification, Dept/Rank/Position changes, Leave/Retirement info |

### 🔗 **[View Detailed Transformation Logic (01.NB_Fct_To_Gld.ipynb)](ETL/pipeline/01.NB_Fct_To_Gld.ipynb)**
### 🔗 **[View Detailed Table Definition (02.Table_Definition.md)](ETL/pipeline/02.Table_Definition.md)**

---

## 🏗️ How I Integrated Code Across Different Systems
<img width="1273" height="869" alt="image" src="https://github.com/user-attachments/assets/7833de2e-086c-4181-bc0c-879901f7e304" />

### ✅ Heterogeneous Data Integration & Master Data Management (MDM)

#### To integrate the diverse data schemas of over 10 subsidiaries into a single standard, I self-designed and implemented an independent MDM engine utilizing existing infrastructure.

* **Problem Context**
    * **Semantic Inconsistency**: Because master code structures were inconsistent across 10+ subsidiaries using different ERP systems, there was a **data fragmentation** issue that made enterprise-wide personnel status aggregation and statistical analysis impossible.
    * **Resource Constraint**: Since introducing commercial MDM solutions involved prohibitive costs and time, a **self-built solution** that could operate within a limited budget was essential to achieve the technical goals.

* **Engineering Solution**
    * **Custom MDM Framework Internalization**: Developed proprietary MDM logic using the previously introduced BI-Matrix platform without additional costs. This structure increases technical independence while allowing for agile responses to business requirements.
    * **Standardized Schema Mapping**: Built a **mapping engine** that aligns local codes of each subsidiary to group standard codes 1:1, ensuring data consistency. This achieved **interoperability** between heterogeneous data sources.
    * **Efficiency & Sustainability**: Significantly reduced construction costs compared to outsourcing while completing a sustainable data governance system capable of responding immediately to future subsidiary expansions.

### 🔗 **[View Detailed MDM (01.MDM_Overview.md)](MDM/01.MDM_Overview.md)**

### Technical Note
> **BI-Matrix**: A specialized Low-code Business Intelligence (BI) platform used to rapidly design data interfaces and implement complex business logic.

---
## 🌟 Data Visualization & Analytical Modeling
> ### This is one of the analytical dashboards I developed during the HR project
<img width="2553" height="1193" alt="image" src="https://github.com/user-attachments/assets/cda8124d-cfbb-4c2c-90cf-5264a828f4a3" />
<img width="2262" height="1431" alt="image" src="https://github.com/user-attachments/assets/78cdb405-8282-4a5d-a09d-54d86a2acc8e" />

Utilizing Gold Layer data built via the ETL pipeline, I implemented **analytical dashboards** and an **optimized data model (Star Schema)** to support personnel decision-making.

### 📈 Employee Turnover Analysis Dashboard
* **Insight-Driven Design**: Real-time monitoring of company-wide turnover rates and average tenure to identify workforce loss risks early.
* **Multidimensional Analysis**: Provides cross-analysis capabilities by subsidiary, job rank, and reason for turnover to support data-driven HR strategy development.

### 📐 Star Schema Data Modeling (ERD)
* **Optimization for BI**: Designed a **Star Schema** structure that clearly separates Fact and Dimension tables for efficient processing of large-scale HR data in the Power BI environment.
* **Data Integrity**: Normalized complex relationships such as personnel appointments (`f_hr_appoint_history`) and organizational information around `f_hr_employee_history` in a 1:N structure to ensure query performance and data consistency.
* **Row-Level Security (RLS)**: Architected the model to enable data access control (`m_org_info_rls`) based on user permissions, considering the sensitivity of personnel data.

---

## 🏆 Key Accomplishments & Business Impact

Through this project, I resolved technical debt and built an enterprise environment capable of data-driven HR strategy establishment.

* **Establishment of Single Source of Truth (SSOT)**: Standardized fragmented personnel data from over 10 subsidiaries around the enterprise-integrated employee ID (`EMP_ID`), completing a reliable single source with ensured data consistency.
* **Drastic Reduction in Analysis Lead Time**: Replaced manual aggregation processes for each subsidiary, which previously took days, with automated **Gold Layer**-based queries, improving the speed of company-wide personnel status and turnover rate analysis to near real-time levels.
* **Cost Optimization & Technical Independence**: Built a **self-developed MDM engine** utilizing existing infrastructure (BI-Matrix) instead of expensive commercial MDM solutions, reducing project costs and achieving technical internalization capable of agile responses to internal requirements.
* **Strengthened Security & Governance**: Established a security system for sensitive personnel information through data modeling applying **Row-Level Security (RLS)** and implemented systematic data governance via the Medallion Architecture.

## 💡 Lessons Learned

* **Complexity of Heterogeneous Data Integration**: I deeply realized that in the process of aligning source systems with different business logics into a single standard, **domain knowledge sharing and communication** with business departments are as important as technical implementation.
* **Importance of Scalability-Oriented Design**: While building the metadata-driven dynamic pipeline in ADF, I felt how significantly **decoupling** at the initial design stage impacts future system scalability and maintenance costs.

---

## 📂 Project Structure
```text
├── ETL/
│   ├── pipeline/          # PySpark scripts for data transformation and processing (.ipynb)
│   │   └── 01.NB_Fct_To_Gld.ipynb
│   │   └── 02.Table_Definition.md
│   └── sql-procedure/     # Procedures for recording pipeline execution history and status updates
│       └── SP_INS_RAW_PIP_INFO.sql
├── MDM/                   # Master Data (MDM) mapping and validation logic
│   ├── 01.MDM_Overview.md
│   └── 02.JScript.js
└── README.md              # Project overview and guide

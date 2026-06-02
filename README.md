# 🚚 Last-Mile Delivery Intelligence Platform
> **End-to-end supply chain analytics consulting engagement**  
> SQL · Python · XGBoost · SHAP · Prophet · Power BI · DAX

---
## 📋 Business Problem
A D2C e-commerce company faces a **35.85% delivery failure rate** causing significant customer refunds and churn. The operations team lacked visibility into which delivery zones, courier partners, and product types were driving failures. 

**This project builds a complete analytics system to:**
- Identify root causes of delivery failures
- Predict at-risk shipments before they fail
- Forecast demand to enable proactive courier planning
- Track sustainability KPIs (CO₂ emissions & freight efficiency) across delivery operations

---
## 🎯 Key Results
| Metric | Value |
|--------|-------|
| OTIF Rate | 64.15% |
| Delivery Failure Rate | 35.85% |
| Avg Delivery Days | 12.09 days |
| Total Orders Analysed | 96,476 |
| ML Model ROC-AUC | 0.75+ |
| Total CO₂ Estimate | ~659.47 Metric Tons |
| Avg CO₂ per Delivery | 6.84 kg |
| Freight Efficiency Ratio | 6.01 R$ GMV / R$ Freight |

---
## 💡 Key Findings
1. **Premium products have worst delivery performance**
   — OTIF of 58.75% vs 68.96% for budget products.
   — Counter-intuitive finding with major business implications.
2. **Northern states drive 90%+ failure rates**
   — AP, AL, MA show failure rates above 85%.
   — Geographic distance from São Paulo seller hub is primary driver.
3. **Customer satisfaction directly correlates with delivery speed**
   — 1-star reviews average 19.6 delivery days.
   — 5-star reviews average 10.7 delivery days.
4. **XGBoost model identifies at-risk shipments**
   — Trained on 10,999 labelled shipments with SHAP explainability.
   — Risk scores enable proactive ops team intervention.
5. **Sustainability & Freight Inefficiencies**
   — High-cost states show an inverse relationship with OTIF reliability.
   — Total network carbon footprint is ~659.47K kg; Air freight remains the most emission-intensive mode per kg despite lower overall volume compared to Maritime shipping.

---
## 🏗️ Project Architecture
Raw Data (Kaggle)
↓
Python ETL Pipeline (pandas + SQLite)
↓
SQL Star Schema (15 business queries)
↓
Python EDA (6 charts + feature engineering)
↓
ML Model (XGBoost + SHAP + Prophet)
↓
Power BI Dashboard (6 pages with DAX Page-Level Filtering)
↓
Executive Presentation

---
## 🗂️ Project Structure
```text
last-mile-delivery-intelligence/
├── data/
│   ├── raw/                    ← Kaggle CSVs (gitignored)
│   └── processed/              ← ML outputs + charts
├── notebooks/
│   ├── 00_load_data.ipynb      ← ETL pipeline
│   ├── 01_eda.ipynb            ← Exploratory analysis
│   ├── 02_features.ipynb       ← Feature engineering
│   ├── 03_model.ipynb          ← XGBoost + SHAP
│   └── 04_forecast.ipynb       ← Prophet demand forecast
├── sql/
│   ├── schema.sql              ← Star schema views
│   └── business_queries.sql    ← 15 business queries
├── dashboard/
│   └── delivery_dashboard.pbix ← Power BI dashboard
├── presentation/
│   └── executive_deck.pdf      ← Consulting presentation
└── README.md
---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| Data Storage | SQLite |
| Data Processing | Python, Pandas |
| SQL Analysis | SQLite, DBeaver |
| Machine Learning | XGBoost, Scikit-learn |
| Explainability | SHAP |
| Forecasting | Prophet |
| Visualisation | Matplotlib, Seaborn, Plotly |
| Dashboard | Power BI, DAX |
| Version Control | Git, GitHub |

---

## 📊 Dashboard Pages

| Page | Description |
|------|-------------|
| Executive Summary | OTIF KPIs + monthly trend |
| Delivery Analysis | Speed, price tier, state performance |
| Zone Heatmap | Geographic delivery performance map |
| Risk Feed | ML-powered at-risk shipments |
| Demand Forecast | 8-week Prophet prediction |
| Sustainability | CO₂ and freight efficiency tracking |

---

## 🗃️ Datasets

| Dataset | Source | Rows |
|---------|--------|------|
| Olist Brazilian E-Commerce | Kaggle | 99,441 orders |
| E-Commerce Shipping (Prachi13) | Kaggle | 10,999 shipments |

---

## 🚀 How to Run

**1. Clone the repository:**
```bash
git clone https://github.com/SamyakG19/last-mile-delivery-intelligence.git
cd last-mile-delivery-intelligence
```

**2. Create virtual environment:**
```bash
python -m venv venv
venv\Scripts\activate        # Windows
source venv/bin/activate     # Mac/Linux
```

**3. Install dependencies:**
```bash
pip install -r requirements.txt
```

**4. Download datasets from Kaggle:**
```bash
kaggle datasets download -d olistbr/brazilian-ecommerce --unzip
kaggle datasets download -d prachi13/customer-analytics --unzip
```
Place CSV files in `data/raw/`

**5. Run notebooks in order:**
00_load_data.ipynb → 01_eda.ipynb → 02_features.ipynb → 03_model.ipynb → 04_forecast.ipynb

**6. Open dashboard:**
Open `dashboard/delivery_dashboard.pbix` in Power BI Desktop

---

## 📈 Resume Impact Statements

- Built end-to-end delivery failure prediction system using XGBoost on 100K+ shipment records, achieving 0.75+ ROC-AUC.
- Designed SQL star schema and ETL pipeline with 15 business queries surfacing a critical 35.85% SLA failure rate.
- Developed 6-page Power BI dashboard utilizing complex DAX measures, dynamic page-level filtering, and a Prophet-based 8-week demand forecast.
- Engineered a Sustainability Tracker calculating a 659.47K kg total carbon footprint and isolated freight efficiency ratios to recommend optimized transportation modes.
- Applied SHAP explainability to identify top drivers of delivery failure, enabling proactive operations intervention.

---

## 🔍 STAR Interview Answer

**Situation:** D2C e-commerce company with 35.85% delivery failure rate and no visibility into root causes or the environmental impact of their freight network.

**Task:** Build a data-driven system to identify failure drivers, predict at-risk shipments, track sustainability metrics, and enable proactive operations decisions.

**Action:** Built complete ETL pipeline, SQL star schema, Python EDA with hypothesis-driven analysis, XGBoost ML model with SHAP explainability, Prophet demand forecast, and an enterprise-grade 6-page Power BI dashboard.

**Result:** Identified premium products as worst OTIF performers and northern states driving 90%+ failure rates. Built an ML model enabling proactive shipment intervention and identified clear strategies to reduce the 6.84 kg CO₂ per delivery average. Packaged as an executive consulting deliverable.

---

## 👤 Author

**Samyak Gulde** GitHub: [@SamyakG19](https://github.com/SamyakG19)
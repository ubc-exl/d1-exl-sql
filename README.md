# d1-exl-sql

This repository contains SQL queries related to ExL's DestinyONE implementation. 

- **Deferred Revenue.sql** - a variant of the D1 built in GL Details - GL Account report, with calculated columns for revenue deferal. Run monthly by ExL's finance team.
- **Enrollment Transaction Report - Section** - a variant of the built-in report of the same name, intended as a sandbox/starting point for the ExL Looker Studio Dashboards report (the *Doina Dashboards*), which lives in Informer in its OASIS version as *Sec Count by ProgArea (enrollment Doina)*  
- **Program Office Costing Units** - lists all of the current CUs with their POs and the academic unit reference id from D1. This ID is used to connect Canvas subaccounts to D1 costing units and is required whenever a new costing unit is created with a corresponding Canvas subaccount, which is where new course shells will be created. 

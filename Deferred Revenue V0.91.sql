/**
 * Deferred Revenue Reprot / GL Details: 
 *  0.91 revision: included debit_amount column as well as credit_amount in the deferred rev calculation 
 */
 DECLARE @transactionStartDate datetime DECLARE @transactionEndDate datetime
SET
       @transactionStartDate = '2023-06-20 00:00:00'
SET
       @transactionEndDate = '2023-10-30 00:00:00'
SELECT
       allData.po_name,
       allData.cu_name,
       allData.course_code,
       allData.section_code,
       allData.sem_name,
       allData.glaccount_name,
       allData.debit_amount,
       allData.credit_amount,
       allData.start_date,
       allData.end_date,
        CAST( ROUND ( 
           (CASE WHEN allData.debit_amount>0 THEN -1.0 * allData.debit_amount ELSE allData.credit_amount END * (1.0 + DATEDIFF(
                DAY,
                CASE WHEN CAST(GETDATE() AS DATE)<allData.start_date THEN allData.start_date ELSE CAST(GETDATE() AS DATE) END,
                allData.end_date
            )) / (1.0 + DATEDIFF(
                DAY,
                allData.start_date,
                allData.end_date
            )))
        , 2)  AS DECIMAL(8, 2) ) AS deferred_rev,
       allData.rpt_type,
       allData.journal_entry_id,
       allData.code,
       allData.transaction_time,
       allData.basket_number,
       allData.email_address,
       allData.user_last_name,
       allData.user_first_name,
       allData.student_last_name,
       allData.e_first,
       allData.settlement_subtype,
       allData.account_type_code,
       allData.adjustment,
       allData.person_number,
       allData.system_time,
       allData.school_personnel_number,
       allData.payment_info_number,
       allData.custom_section_number
       

FROM
       (
              SELECT
                     DISTINCT 111111111 AS rpt_key,
                     'GL_DETAILS' AS rpt_type,
                     a.journal_entry_id,
                     ga.code,
                     ga.NAME AS glaccount_name,
                     a.entry_time AS transaction_time,
                     tb.basket_number,
                     e.email_address AS email_address,
                     e.last_name AS student_last_name,
                     e.first_name AS e_first,
                     a.settlement_type,
                     a.settlement_subtype,
                     ga.account_type_code,
                     f.last_name AS user_last_name,
                     f.first_name1 AS user_first_name,
                     a.course_code,
                     a.section_code,
                     a.sem_name,
                     a.po_name,
                     a.cu_name,
                     a.debit_amount,
                     a.credit_amount,
                     a.adjustment,
                     e.person_number,
                     getdate() AS system_time,
                     e.school_personnel_number,
                     a.dispersement_lw_id,
                     a.payment_info_number,
                     a.custom_section_number,
                     a.start_date,
                     a.end_date,
                     NULL AS deferred_rev
              FROM
                     (
                            --section 1: tuition 
                            SELECT
                                   a.journal_entry_id,
                                   a.glaccount_id,
                                   a.transaction_basket_id,
                                   a.settlement_type,
                                   a.settlement_subtype,
                                   a.entry_time,
                                   a.course_code,
                                   a.section_code,
                                   CASE
                                          WHEN (ay.NAME IS NOT NULL) THEN ay.NAME + ' - ' + sem.NAME
                                   END AS sem_name,
                                   CASE
                                          WHEN po.code IS NOT NULL THEN po.NAME + ' - ' + po.code
                                          ELSE ''
                                   END AS po_name,
                                   CASE
                                          WHEN cu.code IS NOT NULL THEN cu.NAME + ' - ' + cu.code
                                          ELSE ''
                                   END AS cu_name,
                                   a.debit_amount,
                                   a.credit_amount,
                                   a.creator_id,
                                   a.adjustment,
                                   a.dispersement_lw_id,
                                   a.payment_info_number,
                                   a.custom_section_number,
                                   a.start_date, 
                                   a.end_date
                            FROM
                                   (
                                          SELECT
                                                 *
                                          FROM
                                                 (
                                                        SELECT
                                                               je.journal_entry_id,
                                                               je.glaccount_id,
                                                               je.transaction_basket_id,
                                                               tpa.dispersement_lw_id,
                                                               tp.transaction_id,
                                                               tp.settlement_type,
                                                               tp.settlement_subtype,
                                                               je.entry_time,
                                                               cslw.coursesection_lw_id,
                                                               cslw.course_section_id AS entity_id,
                                                               je.debit_amount,
                                                               je.credit_amount,
                                                               je.creator_id,
                                                               CASE
                                                                      WHEN (
                                                                             je.b_reversed = 0
                                                                             AND je.reverse_to_journal_entry_id IS NULL
                                                                      ) THEN ''
                                                                      ELSE 'R'
                                                               END AS adjustment,
                                                               CASE
                                                                      WHEN tp.settlement_type = 'CreditCard' THEN tp.authorizationnumber
                                                                      WHEN tp.settlement_type = 'Cheque' THEN tp.settlement_medium_number
                                                                      WHEN tp.settlement_type = 'Invoice' THEN tp.purchase_order_number
                                                                      WHEN tp.settlement_type = 'DebitCard' THEN tp.bank_confirmation_number
                                                                      WHEN tp.settlement_type = 'BankWire' THEN tp.settlement_medium_number
                                                                      WHEN tp.settlement_type = 'Bursary' THEN tp.settlement_medium_number
                                                                      WHEN tp.settlement_type = 'GiftCert' THEN tp.settlement_medium_number
                                                                      WHEN tp.settlement_type = 'DirectBilling' THEN tp.settlement_medium_number
                                                                      WHEN tp.settlement_type = 'Waiver' THEN tp.personnel_number
                                                                      ELSE NULL
                                                               END AS payment_info_number,
                                                               c.costing_unit_id,
                                                               c.program_office_id,
                                                               sec.semester_id,
                                                               c.code AS course_code,
                                                               sec.code AS section_code,
                                                               sec.custom_section_number AS custom_section_number,                                                        
                                                               secsked.start_date AS start_date,
                                                               secsked.end_date AS end_date
                                                        FROM
                                                               journal_entry je
                                                               INNER JOIN transaction_payment tp ON je.transaction_id = tp.transaction_id
                                                               INNER JOIN transaction_payment_allocation tpa ON je.transaction_allocation_id = tpa.transaction_payment_alloc_id
                                                               INNER JOIN fee_lw flw ON flw.fee_lw_id = tpa.fee_lw_id
                                                               INNER JOIN coursesection_lw cslw ON cslw.coursesection_lw_id = flw.containing_cslw_id
                                                               LEFT JOIN section sec ON cslw.course_section_id = sec.section_id
                                                               LEFT JOIN course c ON sec.course_id = c.course_id
                                                               -- edits here to get section_schedule
                                                               INNER JOIN section_schedule secsked ON sec.section_id = secsked.section_id
                                                        WHERE
                                                               je.transaction_id IS NOT NULL
                                                               AND tpa.allocated_to_transaction_id IS NULL
                                                               AND cslw.b_tuition_profile_section <> '1'
                                                               AND je.b_allocated = '0'
                                                               AND c.course_id IS NOT NULL
                                                               AND c.course_id > 0 -- tpa.allocated_to_transaction_id is null -> if is not null, then means refund or invoice paydown 
                                                               -- normal tuitoon profile: revenue, if payment method criteria specified, no revenue 
                                                        UNION
                                                        ALL
                                                        SELECT
                                                               je.journal_entry_id,
                                                               je.glaccount_id,
                                                               je.transaction_basket_id,
                                                               CASE
                                                                      WHEN (tpa.dispersement_lw_id IS NOT NULL) THEN tpa.dispersement_lw_id
                                                                      ELSE jeToDispLW.dispersement_lw_id
                                                               END,
                                                               tp.transaction_id,
                                                               tp.settlement_type,
                                                               tp.settlement_subtype,
                                                               je.entry_time,
                                                               cslw.coursesection_lw_id,
                                                               cslw.course_section_id AS entity_id,
                                                               CASE
                                                                      WHEN (
                                                                             je.debit_amount = 0
                                                                             OR jeToDispLW.amount IS NULL
                                                                      ) THEN je.debit_amount
                                                                      ELSE jeToDispLW.amount
                                                               END,
                                                               CASE
                                                                      WHEN (
                                                                             je.credit_amount = 0
                                                                             OR jeToDispLW.amount IS NULL
                                                                      ) THEN je.credit_amount
                                                                      ELSE jeToDispLW.amount
                                                               END,
                                                               je.creator_id,
                                                               CASE
                                                                      WHEN (
                                                                             je.b_reversed = 0
                                                                             AND je.reverse_to_journal_entry_id IS NULL
                                                                      ) THEN ''
                                                                      ELSE 'R'
                                                               END AS adjustment,
                                                               CASE
                                                                      WHEN tp.settlement_type = 'CreditCard' THEN tp.authorizationnumber
                                                                      WHEN tp.settlement_type = 'Cheque' THEN tp.settlement_medium_number
                                                                      WHEN tp.settlement_type = 'Invoice' THEN tp.purchase_order_number
                                                                      WHEN tp.settlement_type = 'DebitCard' THEN tp.bank_confirmation_number
                                                                      WHEN tp.settlement_type = 'BankWire' THEN tp.settlement_medium_number
                                                                      WHEN tp.settlement_type = 'Bursary' THEN tp.settlement_medium_number
                                                                      WHEN tp.settlement_type = 'GiftCert' THEN tp.settlement_medium_number
                                                                      WHEN tp.settlement_type = 'DirectBilling' THEN tp.settlement_medium_number
                                                                      WHEN tp.settlement_type = 'Waiver' THEN tp.personnel_number
                                                                      ELSE NULL
                                                               END AS payment_info_number,
                                                               c.costing_unit_id,
                                                               c.program_office_id,
                                                               sec.semester_id,
                                                               c.code AS course_code,
                                                               sec.code AS section_code,
                                                               sec.custom_section_number AS custom_section_number,
                                                               secsked.start_date AS start_date,
                                                               secsked.end_date AS end_date
                                                        FROM
                                                               journal_entry je
                                                               INNER JOIN transaction_payment tp ON je.transaction_id = tp.transaction_id
                                                               INNER JOIN transaction_payment_allocation tpa ON je.transaction_allocation_id = tpa.transaction_payment_alloc_id
                                                               LEFT JOIN v_journal_entry_displw_dist jeToDispLW ON jeToDispLW.journal_entry_id = je.journal_entry_id
                                                               LEFT JOIN dispersement_lw displw ON displw.dispersement_lw_id = jeToDispLW.dispersement_lw_id
                                                               LEFT JOIN fee_lw_dispersement_lw flwDispLW ON flwDispLW.dispersement_lw_id = displw.dispersement_lw_id
                                                               LEFT JOIN fee_lw flw ON (
                                                                      flw.fee_lw_id = flwDispLW.fee_lw_id
                                                                      OR flw.fee_lw_id = tpa.fee_lw_id
                                                               )
                                                               LEFT JOIN coursesection_lw cslw ON cslw.coursesection_lw_id = flw.containing_cslw_id
                                                               LEFT JOIN section sec ON cslw.course_section_id = sec.section_id
                                                               LEFT JOIN course c ON sec.course_id = c.course_id
                                                               -- edits here to get section_schedule
                                                               INNER JOIN section_schedule secsked ON sec.section_id = secsked.section_id
                                                        WHERE
                                                               je.transaction_id IS NOT NULL
                                                               AND tpa.allocated_to_transaction_id IS NOT NULL
                                                               AND (
                                                                      cslw.b_tuition_profile_section IS NULL
                                                                      OR cslw.b_tuition_profile_section <> '1'
                                                               )
                                                               AND je.b_allocated = '0'
                                                               AND c.course_id IS NOT NULL
                                                               AND c.course_id > 0
                                                        UNION
                                                        ALL
                                                        SELECT
                                                               DISTINCT je.journal_entry_id,
                                                               je.glaccount_id,
                                                               je.transaction_basket_id,
                                                               je.dispersement_lw_id,
                                                               NULL AS transaction_id,
                                                               NULL AS settlement_type,
                                                               NULL AS settlement_subtype,
                                                               je.entry_time,
                                                               cslw.coursesection_lw_id,
                                                               cslw.course_section_id AS entity_id,
                                                               je.debit_amount,
                                                               je.credit_amount,
                                                               je.creator_id,
                                                               CASE
                                                                      WHEN (
                                                                             je.b_reversed = 0
                                                                             AND je.reverse_to_journal_entry_id IS NULL
                                                                      ) THEN ''
                                                                      ELSE 'R'
                                                               END AS adjustment,
                                                               NULL AS payment_info_number,
                                                               c.costing_unit_id,
                                                               c.program_office_id,
                                                               sec.semester_id,
                                                               c.code AS course_code,
                                                               sec.code AS section_code,
                                                               sec.custom_section_number AS custom_section_number,
                                                               secsked.start_date AS start_date,
                                                               secsked.end_date AS end_date
                                                        FROM
                                                               journal_entry je
                                                               INNER JOIN fee_lw_dispersement_lw fd ON fd.dispersement_lw_id = je.dispersement_lw_id
                                                               INNER JOIN fee_lw flw ON flw.fee_lw_id = fd.fee_lw_id
                                                               INNER JOIN coursesection_lw cslw ON cslw.coursesection_lw_id = flw.containing_cslw_id
                                                               LEFT JOIN section sec ON cslw.course_section_id = sec.section_id
                                                               LEFT JOIN course c ON sec.course_id = c.course_id
                                                               -- edits here to get section_schedule
                                                               INNER JOIN section_schedule secsked ON sec.section_id = secsked.section_id
                                                        WHERE
                                                               je.transaction_id IS NULL
                                                               AND je.dispersement_lw_id IS NOT NULL
                                                               AND cslw.b_tuition_profile_section <> '1'
                                                               AND je.b_allocated = '0'
                                                               AND c.course_id IS NOT NULL
                                                               AND c.course_id > 0
                                                        UNION
                                                        ALL
                                                        SELECT
                                                               je.journal_entry_id,
                                                               je.glaccount_id,
                                                               je.transaction_basket_id,
                                                               tpa.dispersement_lw_id,
                                                               tp.transaction_id,
                                                               tp.settlement_type,
                                                               tp.settlement_subtype,
                                                               je.entry_time,
                                                               splw.sales_pkg_lw_id,
                                                               splw.sales_pkg_id AS entity_id,
                                                               je.debit_amount,
                                                               je.credit_amount,
                                                               je.creator_id,
                                                               CASE
                                                                      WHEN (
                                                                             je.b_reversed = 0
                                                                             AND je.reverse_to_journal_entry_id IS NULL
                                                                      ) THEN ''
                                                                      ELSE 'R'
                                                               END AS adjustment,
                                                               CASE
                                                                      WHEN tp.settlement_type = 'CreditCard' THEN tp.authorizationnumber
                                                                      WHEN tp.settlement_type = 'Cheque' THEN tp.settlement_medium_number
                                                                      WHEN tp.settlement_type = 'Invoice' THEN tp.purchase_order_number
                                                                      WHEN tp.settlement_type = 'DebitCard' THEN tp.bank_confirmation_number
                                                                      WHEN tp.settlement_type = 'BankWire' THEN tp.settlement_medium_number
                                                                      WHEN tp.settlement_type = 'Bursary' THEN tp.settlement_medium_number
                                                                      WHEN tp.settlement_type = 'GiftCert' THEN tp.settlement_medium_number
                                                                      WHEN tp.settlement_type = 'DirectBilling' THEN tp.settlement_medium_number
                                                                      WHEN tp.settlement_type = 'Waiver' THEN tp.personnel_number
                                                                      ELSE NULL
                                                               END AS payment_info_number,
                                                               spi.costing_unit_id,
                                                               spi.program_office_id,
                                                               spi.semester_id,
                                                               '' AS custom_section_number,
                                                               CASE
                                                                      WHEN spi.sales_pkg_type = 'programOffering' THEN ''
                                                                      ELSE spi.parent_code
                                                               END AS course_code,
                                                               spi.code AS section_code,
                                                               NULL AS start_date,
                                                               NULL AS end_date
                                                        FROM
                                                               journal_entry je
                                                               INNER JOIN transaction_payment tp ON je.transaction_id = tp.transaction_id
                                                               INNER JOIN transaction_payment_allocation tpa ON je.transaction_allocation_id = tpa.transaction_payment_alloc_id
                                                               INNER JOIN fee_lw flw ON flw.fee_lw_id = tpa.fee_lw_id
                                                               INNER JOIN sales_pkg_lw splw ON splw.sales_pkg_lw_id = flw.containing_sales_pkg_lw_id
                                                               LEFT JOIN v_sales_pkg_info spi ON splw.sales_pkg_id = spi.sales_pkg_id
                                                        WHERE
                                                               je.transaction_id IS NOT NULL
                                                               AND tpa.allocated_to_transaction_id IS NULL
                                                               AND je.b_allocated = '0' -- tpa.allocated_to_transaction_id is null -> if is not null, then means refund or invoice paydown 
                                                               -- normal tuitoon profile: revenue, if payment method criteria specified, no revenue 
                                                               AND spi.sales_pkg_id IS NOT NULL
                                                               AND spi.sales_pkg_id > 0
                                                        UNION
                                                        ALL
                                                        SELECT
                                                               je.journal_entry_id,
                                                               je.glaccount_id,
                                                               je.transaction_basket_id,
                                                               CASE
                                                                      WHEN (tpa.dispersement_lw_id IS NOT NULL) THEN tpa.dispersement_lw_id
                                                                      ELSE jeToDispLW.dispersement_lw_id
                                                               END,
                                                               tp.transaction_id,
                                                               tp.settlement_type,
                                                               tp.settlement_subtype,
                                                               je.entry_time,
                                                               splw.sales_pkg_lw_id,
                                                               splw.sales_pkg_id AS entity_id,
                                                               CASE
                                                                      WHEN (
                                                                             je.debit_amount = 0
                                                                             OR jeToDispLW.amount IS NULL
                                                                      ) THEN je.debit_amount
                                                                      ELSE jeToDispLW.amount
                                                               END,
                                                               CASE
                                                                      WHEN (
                                                                             je.credit_amount = 0
                                                                             OR jeToDispLW.amount IS NULL
                                                                      ) THEN je.credit_amount
                                                                      ELSE jeToDispLW.amount
                                                               END,
                                                               je.creator_id,
                                                               CASE
                                                                      WHEN (
                                                                             je.b_reversed = 0
                                                                             AND je.reverse_to_journal_entry_id IS NULL
                                                                      ) THEN ''
                                                                      ELSE 'R'
                                                               END AS adjustment,
                                                               CASE
                                                                      WHEN tp.settlement_type = 'CreditCard' THEN tp.authorizationnumber
                                                                      WHEN tp.settlement_type = 'Cheque' THEN tp.settlement_medium_number
                                                                      WHEN tp.settlement_type = 'Invoice' THEN tp.purchase_order_number
                                                                      WHEN tp.settlement_type = 'DebitCard' THEN tp.bank_confirmation_number
                                                                      WHEN tp.settlement_type = 'BankWire' THEN tp.settlement_medium_number
                                                                      WHEN tp.settlement_type = 'Bursary' THEN tp.settlement_medium_number
                                                                      WHEN tp.settlement_type = 'GiftCert' THEN tp.settlement_medium_number
                                                                      WHEN tp.settlement_type = 'DirectBilling' THEN tp.settlement_medium_number
                                                                      WHEN tp.settlement_type = 'Waiver' THEN tp.personnel_number
                                                                      ELSE NULL
                                                               END AS payment_info_number,
                                                               spi.costing_unit_id,
                                                               spi.program_office_id,
                                                               spi.semester_id,
                                                               '' AS custom_section_number,
                                                               CASE
                                                                      WHEN spi.sales_pkg_type = 'programOffering' THEN ''
                                                                      ELSE spi.parent_code
                                                               END AS course_code,
                                                               spi.code AS section_code,
                                                               NULL AS start_date,
                                                               NULL AS end_date
                                                        FROM
                                                               journal_entry je
                                                               INNER JOIN transaction_payment tp ON je.transaction_id = tp.transaction_id
                                                               INNER JOIN transaction_payment_allocation tpa ON je.transaction_allocation_id = tpa.transaction_payment_alloc_id
                                                               LEFT JOIN v_journal_entry_displw_dist jeToDispLW ON jeToDispLW.journal_entry_id = je.journal_entry_id
                                                               LEFT JOIN dispersement_lw displw ON displw.dispersement_lw_id = jeToDispLW.dispersement_lw_id
                                                               LEFT JOIN fee_lw_dispersement_lw flwDispLW ON flwDispLW.dispersement_lw_id = displw.dispersement_lw_id
                                                               LEFT JOIN fee_lw flw ON (
                                                                      flw.fee_lw_id = flwDispLW.fee_lw_id
                                                                      OR flw.fee_lw_id = tpa.fee_lw_id
                                                               )
                                                               LEFT JOIN sales_pkg_lw splw ON splw.sales_pkg_lw_id = flw.containing_sales_pkg_lw_id
                                                               LEFT JOIN v_sales_pkg_info spi ON splw.sales_pkg_id = spi.sales_pkg_id
                                                        WHERE
                                                               je.transaction_id IS NOT NULL
                                                               AND tpa.allocated_to_transaction_id IS NOT NULL
                                                               AND je.b_allocated = '0'
                                                               AND spi.sales_pkg_id IS NOT NULL
                                                               AND spi.sales_pkg_id > 0
                                                        UNION
                                                        ALL
                                                        SELECT
                                                               DISTINCT je.journal_entry_id,
                                                               je.glaccount_id,
                                                               je.transaction_basket_id,
                                                               je.dispersement_lw_id,
                                                               NULL AS transaction_id,
                                                               NULL AS settlement_type,
                                                               NULL AS settlement_subtype,
                                                               je.entry_time,
                                                               splw.sales_pkg_lw_id,
                                                               splw.sales_pkg_id AS entity_id,
                                                               je.debit_amount,
                                                               je.credit_amount,
                                                               je.creator_id,
                                                               CASE
                                                                      WHEN (
                                                                             je.b_reversed = 0
                                                                             AND je.reverse_to_journal_entry_id IS NULL
                                                                      ) THEN ''
                                                                      ELSE 'R'
                                                               END AS adjustment,
                                                               NULL AS payment_info_number,
                                                               spi.costing_unit_id,
                                                               spi.program_office_id,
                                                               spi.semester_id,
                                                               '' AS custom_section_number,
                                                               CASE
                                                                      WHEN spi.sales_pkg_type = 'programOffering' THEN ''
                                                                      ELSE spi.parent_code
                                                               END AS course_code,
                                                               spi.code AS section_code,
                                                               NULL AS start_date,  
                                                               NULL AS end_date
                                                        FROM
                                                               journal_entry je
                                                               INNER JOIN fee_lw_dispersement_lw fd ON fd.dispersement_lw_id = je.dispersement_lw_id
                                                               INNER JOIN fee_lw flw ON flw.fee_lw_id = fd.fee_lw_id
                                                               INNER JOIN sales_pkg_lw splw ON splw.sales_pkg_lw_id = flw.containing_sales_pkg_lw_id
                                                               LEFT JOIN v_sales_pkg_info spi ON splw.sales_pkg_id = spi.sales_pkg_id
                                                        WHERE
                                                               je.transaction_id IS NULL
                                                               AND je.dispersement_lw_id IS NOT NULL
                                                               AND je.b_allocated = '0'
                                                               AND spi.sales_pkg_id IS NOT NULL
                                                               AND spi.sales_pkg_id > 0 -- virtual section 
                                                        UNION
                                                        ALL
                                                        SELECT
                                                               je.journal_entry_id,
                                                               je.glaccount_id,
                                                               je.transaction_basket_id,
                                                               tpa.dispersement_lw_id,
                                                               tp.transaction_id,
                                                               tp.settlement_type,
                                                               tp.settlement_subtype,
                                                               je.entry_time,
                                                               cslw.coursesection_lw_id,
                                                               cslw.course_section_id AS entity_id,
                                                               je.debit_amount,
                                                               je.credit_amount,
                                                               je.creator_id,
                                                               CASE
                                                                      WHEN (
                                                                             je.b_reversed = 0
                                                                             AND je.reverse_to_journal_entry_id IS NULL
                                                                      ) THEN ''
                                                                      ELSE 'R'
                                                               END AS adjustment,
                                                               CASE
                                                                      WHEN tp.settlement_type = 'CreditCard' THEN tp.authorizationnumber
                                                                      WHEN tp.settlement_type = 'Cheque' THEN tp.settlement_medium_number
                                                                      WHEN tp.settlement_type = 'Invoice' THEN tp.purchase_order_number
                                                                      WHEN tp.settlement_type = 'DebitCard' THEN tp.bank_confirmation_number
                                                                      WHEN tp.settlement_type = 'BankWire' THEN tp.settlement_medium_number
                                                                      WHEN tp.settlement_type = 'Bursary' THEN tp.settlement_medium_number
                                                                      WHEN tp.settlement_type = 'GiftCert' THEN tp.settlement_medium_number
                                                                      WHEN tp.settlement_type = 'DirectBilling' THEN tp.settlement_medium_number
                                                                      WHEN tp.settlement_type = 'Waiver' THEN tp.personnel_number
                                                                      ELSE NULL
                                                               END AS payment_info_number,
                                                               c.costing_unit_id,
                                                               c.program_office_id,
                                                               sec.semester_id,
                                                               c.code AS course_code,
                                                               sec.code AS section_code,
                                                               sec.custom_section_number AS custom_section_number,
                                                               secsked.start_date AS start_date,
                                                               secsked.end_date AS end_date                                                               
                                                        FROM
                                                               journal_entry je
                                                               INNER JOIN transaction_payment tp ON je.transaction_id = tp.transaction_id
                                                               INNER JOIN transaction_payment_allocation tpa ON je.transaction_allocation_id = tpa.transaction_payment_alloc_id
                                                               INNER JOIN fee_lw_dispersement_lw fldl ON fldl.dispersement_lw_id = je.allocate_dispersement_lw_id
                                                               INNER JOIN fee_lw flw ON flw.fee_lw_id = fldl.fee_lw_id
                                                               INNER JOIN fee_lw_comp_fee_lw flcfl ON flcfl.comp_fee_lw_id = flw.fee_lw_id
                                                               INNER JOIN fee_lw flw_tp ON flw_tp.fee_lw_id = flcfl.fee_lw_id
                                                               INNER JOIN coursesection_lw cslw ON cslw.coursesection_lw_id = flw_tp.actual_cslw_id
                                                               LEFT JOIN section sec ON cslw.course_section_id = sec.section_id
                                                               LEFT JOIN course c ON sec.course_id = c.course_id
                                                               -- edits here to get section_schedule
                                                               INNER JOIN section_schedule secsked ON sec.section_id = secsked.section_id
                                                        WHERE
                                                               je.transaction_id IS NOT NULL
                                                               AND tpa.allocated_to_transaction_id IS NULL
                                                               AND cslw.b_tuition_profile_section <> '1'
                                                               AND je.b_allocated = '1'
                                                               AND c.course_id IS NOT NULL
                                                               AND c.course_id > 0 -- tpa.allocated_to_transaction_id is null -> if is not null, then means refund 
                                                               -- normal tuitoon profile: revenue, if payment method criteria specified, no revenue 
                                                        UNION
                                                        ALL
                                                        SELECT
                                                               DISTINCT je.journal_entry_id,
                                                               je.glaccount_id,
                                                               je.transaction_basket_id,
                                                               je.dispersement_lw_id,
                                                               NULL AS transaction_id,
                                                               NULL AS settlement_type,
                                                               NULL AS settlement_subtype,
                                                               je.entry_time,
                                                               cslw.coursesection_lw_id,
                                                               cslw.course_section_id AS entity_id,
                                                               je.debit_amount,
                                                               je.credit_amount,
                                                               je.creator_id,
                                                               CASE
                                                                      WHEN (
                                                                             je.b_reversed = 0
                                                                             AND je.reverse_to_journal_entry_id IS NULL
                                                                      ) THEN ''
                                                                      ELSE 'R'
                                                               END AS adjustment,
                                                               NULL AS payment_info_number,
                                                               c.costing_unit_id,
                                                               c.program_office_id,
                                                               sec.semester_id,
                                                               c.code AS course_code,
                                                               sec.code AS section_code,
                                                               sec.custom_section_number AS custom_section_number,
                                                               secsked.start_date AS start_date,
                                                               secsked.end_date AS end_date
                                                        FROM
                                                               journal_entry je
                                                               INNER JOIN fee_lw_dispersement_lw fd ON fd.dispersement_lw_id = je.allocate_dispersement_lw_id
                                                               INNER JOIN fee_lw flw ON flw.fee_lw_id = fd.fee_lw_id
                                                               INNER JOIN fee_lw_comp_fee_lw flcfl ON flcfl.comp_fee_lw_id = flw.fee_lw_id
                                                               INNER JOIN fee_lw flw_tp ON flw_tp.fee_lw_id = flcfl.fee_lw_id
                                                               INNER JOIN coursesection_lw cslw ON cslw.coursesection_lw_id = flw_tp.actual_cslw_id
                                                               LEFT JOIN section sec ON cslw.course_section_id = sec.section_id
                                                               LEFT JOIN course c ON sec.course_id = c.course_id -- edits here to get section_schedule
                                                               INNER JOIN section_schedule secsked ON sec.section_id = secsked.section_id
                                                        WHERE
                                                               je.transaction_id IS NULL
                                                               AND je.dispersement_lw_id IS NOT NULL
                                                               AND cslw.b_tuition_profile_section <> '1'
                                                               AND je.b_allocated = '1'
                                                               AND c.course_id IS NOT NULL
                                                               AND c.course_id > 0 --end of  virtual section 
                                                 ) a
                                          WHERE
                                                 1 = 1
                                                 --AND a.entry_time >= @transactionStartDate
                                                 --AND a.entry_time < @transactionEndDate
                                                 AND getdate() < a.end_date
                                   ) a
                                   LEFT JOIN semester sem ON sem.semester_id = a.semester_id
                                   LEFT JOIN academic_year ay ON ay.academic_year_id = sem.academic_year_id
                                   LEFT JOIN program_office po ON po.program_office_id = a.program_office_id
                                   LEFT JOIN costing_unit cu ON cu.costing_unit_id = a.costing_unit_id -- end of section 1: section fee. 
                                   -- section 2: other fee 
                                   UNION
                            ALL
                            SELECT
                                   DISTINCT je.journal_entry_id,
                                   je.glaccount_id,
                                   je.transaction_basket_id,
                                   tp.settlement_type,
                                   tp.settlement_subtype,
                                   je.entry_time,
                                   fee.printcode,
                                   '' AS sec_code,
                                   CASE
                                          WHEN (ay.NAME IS NOT NULL) THEN ay.NAME + ' - ' + sem.NAME
                                   END AS sem_name,
                                   CASE
                                          WHEN displw_po_cu.po_name IS NOT NULL THEN displw_po_cu.po_name + ' - ' + displw_po.code
                                          ELSE ''
                                   END AS po_name,
                                   CASE
                                          WHEN displw_po_cu.cu_name IS NOT NULL THEN displw_po_cu.cu_name + ' - ' + displw_cu.code
                                          ELSE ''
                                   END AS cu_name,
                                   je.debit_amount,
                                   je.credit_amount,
                                   je.creator_id,
                                   CASE
                                          WHEN (
                                                 je.b_reversed = 0
                                                 AND je.reverse_to_journal_entry_id IS NULL
                                          ) THEN ''
                                          ELSE 'R'
                                   END AS adjustment,
                                   tpa.dispersement_lw_id,
                                   CASE
                                          WHEN tp.settlement_type = 'CreditCard' THEN tp.authorizationnumber
                                          WHEN tp.settlement_type = 'Cheque' THEN tp.settlement_medium_number
                                          WHEN tp.settlement_type = 'Invoice' THEN tp.purchase_order_number
                                          WHEN tp.settlement_type = 'DebitCard' THEN tp.bank_confirmation_number
                                          WHEN tp.settlement_type = 'BankWire' THEN tp.settlement_medium_number
                                          WHEN tp.settlement_type = 'Bursary' THEN tp.settlement_medium_number
                                          WHEN tp.settlement_type = 'GiftCert' THEN tp.settlement_medium_number
                                          WHEN tp.settlement_type = 'DirectBilling' THEN tp.settlement_medium_number
                                          WHEN tp.settlement_type = 'Waiver' THEN tp.personnel_number
                                          ELSE NULL
                                   END AS payment_info_number,
                                   '' AS custom_section_number,
                                   NULL AS start_date,  
                                   NULL AS end_date
                            FROM
                                   journal_entry je
                                   INNER JOIN transaction_payment tp ON je.transaction_id = tp.transaction_id
                                   INNER JOIN transaction_payment_allocation tpa ON je.transaction_allocation_id = tpa.transaction_payment_alloc_id
                                   INNER JOIN v_dispersement_lw_po_cu displw_po_cu ON displw_po_cu.dispersement_lw_id = tpa.dispersement_lw_id
                                   INNER JOIN fee_lw flw ON flw.fee_lw_id = tpa.fee_lw_id
                                   INNER JOIN fee ON flw.fee_id = fee.fee_id
                                   LEFT JOIN program_office displw_po ON displw_po.program_office_id = displw_po_cu.sr_program_office_id
                                   LEFT JOIN costing_unit displw_cu ON displw_cu.costing_unit_id = displw_po_cu.sr_costing_unit_id
                                   LEFT JOIN special_request sr ON sr.special_request_id = fee.fee_id
                                   LEFT JOIN semester sem ON sem.semester_id = sr.semester_id
                                   LEFT JOIN academic_year ay ON ay.academic_year_id = sr.academic_year_id
                            WHERE
                                   je.transaction_id IS NOT NULL
                                   AND tpa.allocated_to_transaction_id IS NULL
                                   AND flw.transaction_basket_id IS NOT NULL
                                   AND je.b_allocated = '0'
                            UNION
                            ALL
                            SELECT
                                   DISTINCT je.journal_entry_id,
                                   je.glaccount_id,
                                   je.transaction_basket_id,
                                   NULL AS settlement_type,
                                   NULL AS settlement_subtype,
                                   je.entry_time,
                                   fee.printcode,
                                   '' AS sec_code,
                                   CASE
                                          WHEN (ay.NAME IS NOT NULL) THEN ay.NAME + ' - ' + sem.NAME
                                   END AS sem_name,
                                   CASE
                                          WHEN displw_po_cu.po_name IS NOT NULL THEN displw_po_cu.po_name + ' - ' + displw_po.code
                                          ELSE ''
                                   END AS po_name,
                                   CASE
                                          WHEN displw_po_cu.cu_name IS NOT NULL THEN displw_po_cu.cu_name + ' - ' + displw_cu.code
                                          ELSE ''
                                   END AS cu_name,
                                   je.debit_amount,
                                   je.credit_amount,
                                   je.creator_id,
                                   CASE
                                          WHEN (
                                                 je.b_reversed = 0
                                                 AND je.reverse_to_journal_entry_id IS NULL
                                          ) THEN ''
                                          ELSE 'R'
                                   END AS adjustment,
                                   je.dispersement_lw_id,
                                   NULL AS payment_info_number,
                                   '' AS custom_section_number,
                                   NULL AS start_date,  
                                   NULL AS end_date
                            FROM
                                   journal_entry je
                                   INNER JOIN v_dispersement_lw_po_cu displw_po_cu ON displw_po_cu.dispersement_lw_id = je.dispersement_lw_id
                                   INNER JOIN fee_lw_dispersement_lw fd ON fd.dispersement_lw_id = je.dispersement_lw_id
                                   INNER JOIN fee_lw flw ON flw.fee_lw_id = fd.fee_lw_id
                                   INNER JOIN fee ON flw.fee_id = fee.fee_id
                                   LEFT JOIN program_office displw_po ON displw_po.program_office_id = displw_po_cu.sr_program_office_id
                                   LEFT JOIN costing_unit displw_cu ON displw_cu.costing_unit_id = displw_po_cu.sr_costing_unit_id
                                   LEFT JOIN special_request sr ON sr.special_request_id = fee.fee_id
                                   LEFT JOIN semester sem ON sem.semester_id = sr.semester_id
                                   LEFT JOIN academic_year ay ON ay.academic_year_id = sr.academic_year_id
                            WHERE
                                   je.transaction_id IS NULL
                                   AND je.dispersement_lw_id IS NOT NULL
                                   AND flw.transaction_basket_id IS NOT NULL
                                   AND je.b_allocated = '0'
                            UNION
                            ALL
                            SELECT
                                   DISTINCT je.journal_entry_id,
                                   je.glaccount_id,
                                   je.transaction_basket_id,
                                   tp.settlement_type,
                                   tp.settlement_subtype,
                                   je.entry_time,
                                   fee.printcode,
                                   '' AS sec_code,
                                   CASE
                                          WHEN (ay.NAME IS NOT NULL) THEN ay.NAME + ' - ' + sem.NAME
                                   END AS sem_name,
                                   CASE
                                          WHEN displw_po_cu.po_name IS NOT NULL THEN displw_po_cu.po_name + ' - ' + displw_po.code
                                          ELSE ''
                                   END AS po_name,
                                   CASE
                                          WHEN displw_po_cu.cu_name IS NOT NULL THEN displw_po_cu.cu_name + ' - ' + displw_cu.code
                                          ELSE ''
                                   END AS cu_name,
                                   CASE
                                          WHEN (
                                                 je.debit_amount = 0
                                                 OR jeToDispLW.amount IS NULL
                                          ) THEN je.debit_amount
                                          ELSE jeToDispLW.amount
                                   END AS debit_amount,
                                   CASE
                                          WHEN (
                                                 je.credit_amount = 0
                                                 OR jeToDispLW.amount IS NULL
                                          ) THEN je.credit_amount
                                          ELSE jeToDispLW.amount
                                   END AS credit_amount,
                                   je.creator_id,
                                   CASE
                                          WHEN (
                                                 je.b_reversed = 0
                                                 AND je.reverse_to_journal_entry_id IS NULL
                                          ) THEN ''
                                          ELSE 'R'
                                   END AS adjustment,
                                   CASE
                                          WHEN (tpa.dispersement_lw_id IS NOT NULL) THEN tpa.dispersement_lw_id
                                          ELSE jeToDispLW.dispersement_lw_id
                                   END AS dispersement_lw_id,
                                   CASE
                                          WHEN tp.settlement_type = 'CreditCard' THEN tp.authorizationnumber
                                          WHEN tp.settlement_type = 'Cheque' THEN tp.settlement_medium_number
                                          WHEN tp.settlement_type = 'Invoice' THEN tp.purchase_order_number
                                          WHEN tp.settlement_type = 'DebitCard' THEN tp.bank_confirmation_number
                                          WHEN tp.settlement_type = 'BankWire' THEN tp.settlement_medium_number
                                          WHEN tp.settlement_type = 'Bursary' THEN tp.settlement_medium_number
                                          WHEN tp.settlement_type = 'GiftCert' THEN tp.settlement_medium_number
                                          WHEN tp.settlement_type = 'DirectBilling' THEN tp.settlement_medium_number
                                          WHEN tp.settlement_type = 'Waiver' THEN tp.personnel_number
                                          ELSE NULL
                                   END AS payment_info_number,
                                   '' AS custom_section_number,
                                   NULL AS start_date,  
                                   NULL AS end_date
                            FROM
                                   journal_entry je
                                   INNER JOIN transaction_payment tp ON je.transaction_id = tp.transaction_id
                                   INNER JOIN transaction_payment_allocation tpa ON je.transaction_allocation_id = tpa.transaction_payment_alloc_id
                                   LEFT JOIN v_journal_entry_displw_dist jeToDispLW ON jeToDispLW.journal_entry_id = je.journal_entry_id
                                   LEFT JOIN dispersement_lw displw ON (
                                          displw.dispersement_lw_id = jeToDispLW.dispersement_lw_id
                                          OR displw.dispersement_lw_id = tpa.dispersement_lw_id
                                   )
                                   LEFT JOIN fee_lw_dispersement_lw flwDispLW ON flwDispLW.dispersement_lw_id = displw.dispersement_lw_id
                                   LEFT JOIN fee_lw flw ON flw.fee_lw_id = flwDispLW.fee_lw_id
                                   LEFT JOIN fee ON flw.fee_id = fee.fee_id
                                   LEFT JOIN v_dispersement_lw_po_cu displw_po_cu ON displw_po_cu.dispersement_lw_id = displw.dispersement_lw_id
                                   LEFT JOIN program_office displw_po ON displw_po.program_office_id = displw_po_cu.sr_program_office_id
                                   LEFT JOIN costing_unit displw_cu ON displw_cu.costing_unit_id = displw_po_cu.sr_costing_unit_id
                                   LEFT JOIN special_request sr ON sr.special_request_id = fee.fee_id
                                   LEFT JOIN semester sem ON sem.semester_id = sr.semester_id
                                   LEFT JOIN academic_year ay ON ay.academic_year_id = sr.academic_year_id
                            WHERE
                                   je.transaction_id IS NOT NULL
                                   AND tpa.allocated_to_transaction_id IS NOT NULL
                                   AND (
                                          flw.transaction_basket_id IS NOT NULL
                                          OR flw.fee_lw_id IS NULL
                                   )
                                   AND je.b_allocated = '0' -- end of section 2: other fee. 
                         -- insert original code lines 580 to 781 here, with appropriate modifications for colums and joins  
                            
                     ) a
                     INNER JOIN transaction_basket tb ON a.transaction_basket_id = tb.transaction_basket_id
                     LEFT JOIN (
                            SELECT
                                   p.person_id,
                                   p.person_type_code,
                                   p.school_personnel_number,
                                   CASE
                                          WHEN p.person_type_code = 'StudentGroup' THEN p.NAME
                                          ELSE p.last_name
                                   END AS last_name,
                                   CASE
                                          WHEN p.person_type_code = 'StudentGroup' THEN ''
                                          ELSE p.first_name1
                                   END AS first_name,
                                   CASE
                                          WHEN p.person_type_code = 'Student' THEN st.student_number
                                          WHEN p.person_type_code = 'StudentGroup' THEN sg.group_number
                                          ELSE ''
                                   END AS person_number,
                                   ppe.email_address AS email_address
                            FROM
                                   person p
                                   LEFT JOIN student st ON p.person_id = st.student_id
                                   LEFT JOIN student_group sg ON p.person_id = sg.student_group_id
                                   LEFT JOIN v_person_preferred_email ppe ON p.person_id = ppe.person_id
                            WHERE
                                   p.person_type_code IN (
                                          'Student',
                                          'StudentGroup'
                                   )
                     ) e ON e.person_id = tb.settlement_client_id
                     LEFT JOIN person f ON f.person_id = a.creator_id
                     INNER JOIN glaccount ga ON a.glaccount_id = ga.glaccount_id
              WHERE
                     (
                            tb.transaction_basket_status = 'Processed'
                            OR tb.transaction_basket_status = 'Void'
                     )
                     AND ga.account_type_code = 'revenue'
                     AND getdate() < a.end_date
                      -- section 3: gl adjustment 
              UNION
              ALL
              SELECT
                     568284560,
                     'GL_DETAILS',
                     0,
                     ga.code,
                     ga.NAME AS glaccount_name,
                     a.entry_time AS transaction_time,
                     '' AS basket_num,
                     '' AS email_address,
                     '' AS customer_last_name,
                     '' AS customer_first_name,
                     '' AS settlement_type,
                     '' AS settlement_subtype,
                     ga.account_type_code,
                     f.last_name AS user_last_name,
                     f.first_name1 AS user_first_name,
                     '' AS course_code,
                     '' AS section_code,
                     '' AS sem_name,
                     '' AS po_name,
                     '' AS cu_name,
                     a.debit_amount,
                     a.credit_amount,
                     'G' AS ajustment,
                     '' AS person_number,
                     getdate(),
                     '' AS school_personnel_number,
                     a.dispersement_lw_id,
                     NULL AS payment_info_number,
                     '' AS custom_section_number,
                     NULL AS start_date,  
                     NULL AS end_date,
                     NULL AS deferred_rev
              FROM
                     journal_entry a
                     INNER JOIN person f ON f.person_id = a.creator_id
                     INNER JOIN glaccount ga ON a.glaccount_id = ga.glaccount_id
              WHERE
                     a.transaction_basket_id IS NULL
                     AND a.transaction_id IS NULL
                     AND a.dispersement_lw_id IS NULL
                     AND ga.account_type_code = 'revenue'
                     --AND a.entry_time >= @transactionStartDate
                     --AND a.entry_time < @transactionEndDate -- end of section 3, adjustment 
       ) allData
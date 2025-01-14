SELECT
    TRANSACTION_BASKET.creation_time AS registration_date,
    PERSON.login_id,
    PERSON.first_name1,
    PERSON.last_name,
    STUDENT.student_number,
    SECTION.section_id,
    CONCAT(COURSE.code, ' ', SECTION.code) AS course_section_code,
    SECTION.section_title,
    SECTION_SCHEDULE.start_date,
    SECTION_SCHEDULE.end_date,
    '' AS status,
    fee_lw_real.amount,
    academic_year.name AS academic_year_name,
    SEMESTER.name AS term_name,
    PROGRAM_OFFICE.program_office_id,
    PROGRAM_OFFICE.code AS program_office_code,
    PROGRAM_OFFICE.name AS program_office_name,
    COSTING_UNIT.code AS costing_unit_code,
    COSTING_UNIT.name AS costing_unit_name,
    coursesection_lw.coursesection_lw_id,
    coursesection_lw.transaction_basket_id,
    PERSON_ADDRESS.country,
    PERSON_ADDRESS.city,
    PERSON_ADDRESS.province_state,
    TRANSACTION_BASKET.basket_number,
    fee_lw.coursesection_lw_id,
    fee_lw.amount,
    fee_lw.actual_cslw_id
    
FROM
    (
        (
            (
                (
                    (
                        (
                            (
                                (
                                    (
                                        (
                                            (
                                                (
                                                    (
                                                        (
                                                            (
                                                                (
                                                                    (
                                                                        (
                                                                            "section" SECTION
                                                                            LEFT OUTER JOIN section_denorm SECTION_DENORM ON SECTION.section_id = SECTION_DENORM.section_id
                                                                        )
                                                                        LEFT OUTER JOIN coursesection_lw coursesection_lw ON SECTION.section_id = coursesection_lw.course_section_id
                                                                    )
                                                                    LEFT OUTER JOIN student STUDENT ON coursesection_lw.student_id = STUDENT.student_id
                                                                )
                                                                LEFT OUTER JOIN person PERSON ON STUDENT.student_id = PERSON.person_id
                                                            )
                                                            LEFT OUTER JOIN transaction_basket TRANSACTION_BASKET ON coursesection_lw.transaction_basket_id = TRANSACTION_BASKET.transaction_basket_id
                                                        )
                                                        LEFT OUTER JOIN person PERSON_USER ON TRANSACTION_BASKET.create_person_id = PERSON_USER.person_id
                                                    )
                                                    LEFT OUTER JOIN coursesection_lw coursesection_lw_withdrawals ON coursesection_lw.coursesection_lw_id = coursesection_lw_withdrawals.withdraw_coursesection_lw_id
                                                )
                                                LEFT OUTER JOIN fee_lw fee_lw ON coursesection_lw.coursesection_lw_id = fee_lw.actual_cslw_id
                                            )
                                            LEFT OUTER JOIN fee_lw fee_lw_real ON coursesection_lw.coursesection_lw_id = fee_lw_real.coursesection_lw_id
                                        )
                                        LEFT OUTER JOIN section_instruction_method section_instruction_method ON SECTION.section_id = section_instruction_method.section_id
                                    )
                                    LEFT OUTER JOIN fee fee ON section_instruction_method.instruction_method_id = fee.fee_id
                                )
                                LEFT OUTER JOIN course COURSE ON SECTION.course_id = COURSE.course_id
                            )
                            LEFT OUTER JOIN section_schedule SECTION_SCHEDULE ON SECTION.section_id = SECTION_SCHEDULE.section_id
                        )
                        INNER JOIN costing_unit COSTING_UNIT ON COURSE.costing_unit_id = COSTING_UNIT.costing_unit_id
                    )
                    INNER JOIN program_office PROGRAM_OFFICE ON COURSE.program_office_id = PROGRAM_OFFICE.program_office_id
                )
                LEFT OUTER JOIN semester SEMESTER ON SECTION.semester_id = SEMESTER.semester_id
            )
            LEFT OUTER JOIN academic_year academic_year ON SEMESTER.academic_year_id = academic_year.academic_year_id
        )
        LEFT OUTER JOIN instructor_contract INSTRUCTOR_CONTRACT ON SECTION.section_id = INSTRUCTOR_CONTRACT.course_section_id
    )
    LEFT OUTER JOIN person_address PERSON_ADDRESS ON PERSON.person_id = PERSON_ADDRESS.person_id
WHERE
    (
        TRANSACTION_BASKET.transaction_basket_status = N'Processed'
    )
    AND (
        coursesection_lw.course_section_activity_code = N'Sale'
    )
    AND (
        coursesection_lw_withdrawals.withdraw_coursesection_lw_id is null
    )
    AND (
        coursesection_lw.b_tuition_profile_section = N'0'
    )
    AND (
        PERSON_ADDRESS.preferred_status = N'1'
    )
    AND (
        (
            fee_lw_real.fee_lw_id is null
            OR (fee_lw_real.fee_type_code = N'TuitionProfile')
        )
    )
    AND (
        TRANSACTION_BASKET.creation_time >= convert(datetime, '20230228 00:00:00.000')
    )
ORDER BY
    TRANSACTION_BASKET.creation_time DESC,
    PROGRAM_OFFICE.name,
    PROGRAM_OFFICE.program_office_id,
    COSTING_UNIT.name,
    COSTING_UNIT.costing_unit_id,
    COURSE.code,
    COURSE.course_id,
    SECTION.code,
    SECTION.section_id,
    PERSON.last_name + N', ' + PERSON.first_name1,
    PERSON.person_id,
    coursesection_lw.transaction_basket_id,
    coursesection_lw.coursesection_lw_id,
    fee_lw.coursesection_lw_id
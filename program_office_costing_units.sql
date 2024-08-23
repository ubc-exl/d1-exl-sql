/*
    Query to extract academic unit reference id from D1
        - used to connect Canvas subaccounts to D1 costing units
        - required whenever a new costing unit is created with a corresponding
            Canvas subaccount, which is where new course shells will be created
    v0.1 - Larry Bouthillier 2024-08-14
*/

select
    po.program_office_id,
    po.code,
    po.name,
    po.org_code,
    po.public_name,
    cu.costing_unit_id,
    cu.code,
    cu.name,
    CONCAT('ACADEMIC_UNIT-LLIS-', po.program_office_id, '_', cu.costing_unit_id) AS academic_unit_reference_id
from
    program_office po,
    program_office_costing_unit pocu,
    costing_unit cu
where
    pocu.program_office_id = po.program_office_id
    and pocu.costing_unit_id = cu.costing_unit_id
SELECT 
    b.assignment_id,
    b.level_6_full_code,
    s.nama_usaha,
   
   CONCAT_WS(', ',
        CASE WHEN s.lap_keuangan_value = '2' AND badan_usaha_value = '1a' 
             THEN 'E32' END,
        CASE WHEN s.klasifikasi_value = '5'AND b.level_2_code NOT IN ('01','02','15','17')
             THEN 'E33' END,
        CASE WHEN s.klasifikasi_value = '4' AND b.level_2_code NOT IN ('02','10','14','15','17','71')
             THEN 'E34' END,
        CASE WHEN s.klasifikasi_value = '3' AND b.level_2_code NOT IN ('01','02','07','15','71')
             THEN 'E54' END,
        CASE WHEN s.klasifikasi_value = '2' AND b.level_2_code NOT IN ('01','02','06','15','17','71')
             THEN 'E55' END,
        CASE WHEN s.klasifikasi_value = '1' AND b.level_2_code NOT IN ('01','02','11','14')
             THEN 'E56' END
    ) AS "KODE_ANOMALI",
    
    s.keg_utama, u.kbli, s.lap_keuangan_value, s.klasifikasi_value,
    r.catatan,
    CONCAT(
        'https://fasih-sm.bps.go.id/app/assignment/fd68e454-ba45-4b85-8205-f3bf777ded24/',
        b.assignment_id
    ) AS Link
FROM tgr_fd68e454.base_table_assignment b
LEFT JOIN tgr_fd68e454.root_table r
    ON b.assignment_id = r.assignment_id AND b.date_modified = r.assignment_date_modified
LEFT JOIN tgr_fd68e454.se2026_nested s
    ON b.assignment_id = s.assignment_id AND b.date_modified = s.assignment_date_modified
LEFT JOIN tgr_fd68e454.USAHA_REF u
    ON b.assignment_id = u.assignment_id AND b.date_modified = u.assignment_date_modified

WHERE (b.is_active = 1 AND b.assignment_status_id > 1) AND
( s.lap_keuangan_value = '2' AND badan_usaha_value = '1a' )
OR
( s.klasifikasi_value = '5'AND b.level_2_code NOT IN ('01','02','15','17') )
OR
( s.klasifikasi_value = '4' AND b.level_2_code NOT IN ('02','10','14','15','17','71') )
OR
( s.klasifikasi_value = '3' AND b.level_2_code NOT IN ('01','02','07','15','71') )
OR
( s.klasifikasi_value = '2' AND b.level_2_code NOT IN ('01','02','06','15','17','71') )
OR
( s.klasifikasi_value = '1' AND b.level_2_code NOT IN ('01','02','11','14') )
ORDER BY
    b.level_6_full_code,
    b.assignment_id
LIMIT 9000 OFFSET 0
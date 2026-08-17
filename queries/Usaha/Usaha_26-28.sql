SELECT 
    b.assignment_id,
    b.level_6_full_code,
    s.nama_usaha,
   
   CONCAT_WS(', ',
        CASE WHEN s.badan_usaha_value = '1a' AND s.punya_nib_value = '2' 
             THEN 'E26' END,
        CASE WHEN s.badan_usaha_value IN ('10', '11')
             THEN 'E27' END,
        CASE WHEN s.badan_usaha_value NOT IN ('1','3','4','5','6','12') AND s.pemerintah > 0
             THEN 'E28' END
    ) AS "KODE_ANOMALI",
    
    s.keg_utama, u.kbli, s.badan_usaha_value, s.punya_nib_value, s.pemerintah,
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
( s.badan_usaha_value = '1a' AND s.punya_nib_value = '2' )
OR
( s.badan_usaha_value IN ('10', '11') )
OR
( s.badan_usaha_value NOT IN ('1','3','4','5','6','12') AND s.pemerintah > 0 )

ORDER BY
    b.level_6_full_code,
    b.assignment_id
LIMIT 9000 OFFSET 0
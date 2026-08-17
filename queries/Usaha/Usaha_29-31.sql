SELECT 
    b.assignment_id,
    b.level_6_full_code,
    s.nama_usaha,
   
   CONCAT_WS(', ',
        CASE WHEN (( 
                s.publik > 0 OR s.non_publik > 0 OR s.publik_didirikan > 0 OR s.nonpublik_didirikan > 0
                OR s.pemerintah > 0 OR s.pemerintah_didirikan > 0 OR s.asing > 0 OR s.asing_didirikan > 0
            ) AND s.badan_usaha_value = '13')
             THEN 'E29' END,
        CASE WHEN ( s.badan_usaha_value = '1a' AND ( s.pribadi = 100 OR s.pribadi_didirikan = 100 ))
             THEN 'E30' END,
        CASE WHEN ( asing > 0 AND badan_usaha_value IN ('5','6') )
             THEN 'E31' END
    ) AS "KODE_ANOMALI",
    
    s.keg_utama, u.kbli, s.badan_usaha_value, s.publik, s.non_publik,
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
(( 
    s.publik > 0 OR s.non_publik > 0 OR s.publik_didirikan > 0 OR s.nonpublik_didirikan > 0
    OR s.pemerintah > 0 OR s.pemerintah_didirikan > 0 OR s.asing > 0 OR s.asing_didirikan > 0
) AND s.badan_usaha_value = '13')
OR
( s.badan_usaha_value = '1a' AND ( s.pribadi = 100 OR s.pribadi_didirikan = 100) )
OR
( asing > 0 AND badan_usaha_value IN ('5','6') )

ORDER BY
    b.level_6_full_code,
    b.assignment_id
LIMIT 9000 OFFSET 0
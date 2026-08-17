SELECT 
    a.assignment_id,
    a.level_6_full_code,
    a.nama_usaha,
    a.keg_utama, 
    c.kbli, 
    jenis_usaha_value, 
    lokasi_usaha_value, 
    jaringan_value,
  
   CONCAT_WS(', ',
        CASE WHEN jenis_usaha_value = 2 AND lokasi_usaha_value NOT IN (10) 
             THEN 'E1' END,
        CASE WHEN jaringan_value = 2 AND c.kbli NOT IN ('701000', '64210')
             THEN 'E2' END,
        CASE WHEN jaringan_value = 2
             THEN 'E3' END
    ) AS "KODE_ANOMALI",
    
    b.catatan,
    CONCAT(
          'https://fasih-sm.bps.go.id/app/assignment/fd68e454-ba45-4b85-8205-f3bf777ded24/',
          a.assignment_id
          
      ) AS Link
FROM tgr_fd68e454.USAHA_REF c
LEFT JOIN tgr_fd68e454.se2026_nested  a
    ON a.assignment_id = c.assignment_id AND a.assignment_date_modified = c.assignment_date_modified AND a.index1 = c.index1
LEFT JOIN tgr_fd68e454.root_table   b
    ON c.assignment_id = b.assignment_id AND c.assignment_date_modified = b.assignment_date_modified
LEFT JOIN tgr_fd68e454.base_table_assignment d
    ON d.assignment_id = c.assignment_id AND d.date_modified = c.assignment_date_modified
WHERE  ( a.keberadaan_usaha_value IN (1,2) ) AND d.is_active = 1
AND ( 
(jenis_usaha_value = 2 AND lokasi_usaha_value NOT IN (10))
OR (jaringan_value = 2 AND c.kbli NOT IN ('701000', '64210'))
OR (jaringan_value = 2 )
)

ORDER BY
    a.level_6_full_code,
    a.assignment_id
LIMIT 9000 OFFSET 0
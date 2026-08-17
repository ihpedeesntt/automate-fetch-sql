SELECT 
    a.assignment_id,
    a.level_2_code,
    a.level_6_full_code,
    a.nama_usaha,
    a.keg_utama, 
    nilai_pendapatan, 
    c.kbli, 
    barang_non_pddk_value,
    jenis_kawasan_value, 
    jenis_usaha_value,
   
   CONCAT_WS(', ',
        CASE WHEN (data6 = 'UM' or data6 like 'UM %' )  AND nilai_pendapatan > 50000000000
             THEN 'E19' END,
        CASE WHEN jenis_kawasan_value <> 10 AND jenis_usaha_value = 2
             THEN 'E21' END,
        CASE WHEN jenis_kawasan_value IN (1, 3, 7)
             THEN 'E22' END,
        CASE WHEN jenis_kawasan_value = 4 AND a.level_2_code NOT IN ('02','06','07','08','09','10','11','12','13','14','15','17','20','71')
             THEN 'E23' END,
        CASE WHEN jenis_kawasan_value = 5 AND a.level_2_code NOT IN ('02','03','05','06','07','08','09','10','11','12','13','14','15','17','18','19','20','71')
             THEN 'E24' END,
        CASE WHEN jenis_kawasan_value IN (1,2,3,4,5,6,7,8,9) AND jenis_usaha_value IN (1,6)
             THEN 'E25' END
    ) AS "KODE_ANOMALI",
    
    data6 as 'skala_usaha',  
    c.kbli, b.catatan,
    CONCAT(
          'https://fasih-sm.bps.go.id/app/assignment/fd68e454-ba45-4b85-8205-f3bf777ded24/',
          a.assignment_id
          
      ) AS Link
FROM tgr_fd68e454.USAHA_REF c
LEFT JOIN tgr_fd68e454.se2026_nested  a
    ON a.assignment_id = c.assignment_id 
    AND a.assignment_date_modified = c.assignment_date_modified 
    AND a.index1 = c.index1
LEFT JOIN tgr_fd68e454.root_table   b
    ON c.assignment_id = b.assignment_id 
    AND c.assignment_date_modified = b.assignment_date_modified
LEFT JOIN tgr_fd68e454.base_table_assignment d
    ON d.assignment_id = c.assignment_id 
    AND d.date_modified = c.assignment_date_modified
WHERE ( a.keberadaan_usaha_value IN (1,2) ) 
  AND d.is_active = 1
  AND (
        ((data6 = 'UM' or data6 like 'UM %' )  AND nilai_pendapatan > 50000000000)
     OR (jenis_kawasan_value <> 10 AND jenis_usaha_value = 2)
     OR (jenis_kawasan_value IN (1, 3, 7))
     OR (jenis_kawasan_value = 4 AND a.level_2_code NOT IN ('04','05','07','13'))
     OR (jenis_kawasan_value = 5 AND a.level_2_code = '11')
     OR (jenis_kawasan_value IN (1,2,3,4,5,6,7,8,9) AND jenis_usaha_value IN (1,6))
  )
ORDER BY
    a.level_6_full_code,
    a.assignment_id
LIMIT 9000 OFFSET 0;

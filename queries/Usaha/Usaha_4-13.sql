SELECT 
    a.assignment_id,
    a.level_2_code,
    a.level_6_full_code,
    a.nama_usaha,
    a.keg_utama,
    c.kbli,
    a.kategori,
    CONCAT_WS(', ',
       
        CASE WHEN a.kategori='R' AND c.kbli NOT LIKE '86%' AND c.kbli NOT IN ('87303','88906','88907')
             THEN 'E4' END,
        CASE WHEN c.kbli IN ('92','97','98','99','84')
             THEN 'E5' END,
        CASE WHEN c.kbli IN ('94','91','87','88','86','85','80','81','82','78','75','73','72','62','63','60','58','39','37','29','28','27','21','09','26')
             THEN 'E6' END,
        CASE WHEN c.kbli LIKE '51%' AND a.level_2_code NOT IN ('04','05','07','13','72')
             THEN 'E7' END
        --CASE WHEN c.kbli LIKE '07%' AND a.level_2_code IN ('01','02','07','09','11','12','13','15','71','72')
          --   THEN 'E8' END,
        --CASE WHEN c.kbli LIKE '12%' AND a.level_2_code NOT IN ('03','05','06')
          --   THEN 'E9' END,
        --CASE WHEN c.kbli IN ('15','17','19','05','06')
          --   THEN 'E10' END,
        --CASE WHEN c.kbli LIKE '24%' AND a.level_2_code NOT IN ('03','04')
          --   THEN 'E11' END,
        --CASE WHEN c.kbli LIKE '70%' AND a.level_2_code NOT IN ('71')
          --   THEN 'E12' END,
        --CASE WHEN c.kbli LIKE '65%' AND a.level_2_code IN ('02','03','04','05','07','08','09','10','11','71','72')
          --   THEN 'E13' END
    ) AS KODE_ANOMALI,
    b.catatan,
    CONCAT(
          'https://fasih-sm.bps.go.id/app/assignment/fd68e454-ba45-4b85-8205-f3bf777ded24/',
          a.assignment_id
          
      ) AS Link
FROM tgr_fd68e454.USAHA_REF c
LEFT JOIN tgr_fd68e454.se2026_nested a
    ON a.assignment_id = c.assignment_id 
   AND a.assignment_date_modified = c.assignment_date_modified AND c.index1 = a.index1
LEFT JOIN tgr_fd68e454.root_table b
    ON c.assignment_id = b.assignment_id 
   AND c.assignment_date_modified = b.assignment_date_modified
LEFT JOIN tgr_fd68e454.base_table_assignment d
    ON d.assignment_id = c.assignment_id AND d.date_modified = c.assignment_date_modified
WHERE a.keberadaan_usaha_value IN (1,2) AND d.is_active = 1
  AND (
       (a.kategori='R' AND c.kbli NOT LIKE '86%' AND c.kbli NOT IN ('87303','88906','88907'))
       OR (c.kbli IN ('92','97','98','99','84'))
       OR (c.kbli IN ('94','91','87','88','86','85','80','81','82','78','75','73','72','62','63','60','58','39','37','29','28','27','21','09','26'))
       OR (c.kbli LIKE '51%' AND a.level_2_code NOT IN ('04','05','07','13','72'))
    --   OR (c.kbli LIKE '07%' AND a.level_2_code IN ('01','02','07','09','11','12','13','15','71','72'))
    --   OR (c.kbli LIKE '12%' AND a.level_2_code NOT IN ('03','05','06'))
    --   OR (c.kbli IN ('15','17','19','05','06'))
    --   OR (c.kbli LIKE '24%' AND a.level_2_code NOT IN ('03','04'))
    --   OR (c.kbli LIKE '70%' AND a.level_2_code NOT IN ('71'))
     --  OR (c.kbli LIKE '65%' AND a.level_2_code IN ('02','03','04','05','07','08','09','10','11','71','72'))
      )
ORDER BY
    a.level_6_full_code,
    a.assignment_id
LIMIT 9000 OFFSET 0;

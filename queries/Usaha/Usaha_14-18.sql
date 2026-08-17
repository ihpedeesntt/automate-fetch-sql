SELECT 
    a.assignment_id,
    a.level_2_code,
    a.level_6_full_code,
    a.nama_usaha,
    a.keg_utama,
    c.kbli,
    a.peran_mbg_value,
    a.barang_non_pddk_value,
    a.beli_jasa_non_pddk_value,
    a.jasa_non_pddk_value,
    a.total_tk_jk,
   
    CONCAT_WS(', ',
        CASE WHEN a.peran_mbg_value = 1 AND c.kbli NOT LIKE '56290%'
             THEN 'E14' END,
        CASE WHEN a.peran_mbg_value = 3 
              AND (c.kbli NOT LIKE '851%' 
                   AND c.kbli NOT LIKE '852%' 
                   AND c.kbli NOT LIKE '853%' 
                   AND c.kbli NOT LIKE '86102%'
                   AND c.kbli NOT LIKE '88906%'
                   AND c.kbli NOT LIKE '88907%')
             THEN 'E15' END,
        CASE WHEN a.peran_mbg_value = 1 
              AND (a.barang_non_pddk_value = 1 
                   OR a.beli_jasa_non_pddk_value = 1 
                   OR a.jasa_non_pddk_value = 1)
             THEN 'E16' END,
        CASE WHEN a.peran_mbg_value = 4 
              AND (c.kbli NOT LIKE '41%' 
                 AND c.kbli NOT LIKE '43%' 
                 AND c.kbli NOT LIKE '49%' 
                 AND c.kbli NOT LIKE '52%' 
                 AND c.kbli NOT LIKE '53%' 
                 AND c.kbli NOT LIKE '61%' 
                 AND c.kbli NOT LIKE '62%' 
                 AND c.kbli NOT LIKE '63%' 
                 AND c.kbli NOT LIKE '64%' 
                 AND c.kbli NOT LIKE '65%' 
                 AND c.kbli NOT LIKE '66%' 
                 AND c.kbli NOT LIKE '68%' 
                 AND c.kbli NOT LIKE '69%' 
                 AND c.kbli NOT LIKE '70%' 
                 AND c.kbli NOT LIKE '71%' 
                 AND c.kbli NOT LIKE '72%')
             THEN 'E17' END,
        CASE WHEN a.peran_mbg_value = 1 AND a.total_tk_jk <= 3
             THEN 'E18' END
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
       (a.peran_mbg_value = 1 AND c.kbli NOT LIKE '56290%')
       OR (a.peran_mbg_value = 3 
            AND (c.kbli NOT LIKE '851%' 
                 AND c.kbli NOT LIKE '852%' 
                 AND c.kbli NOT LIKE '853%' 
                 AND c.kbli NOT LIKE '86102%'
                 AND c.kbli NOT LIKE '88906%'
                 AND c.kbli NOT LIKE '88907%'))
       OR (a.peran_mbg_value = 1 
            AND (a.barang_non_pddk_value = 1 
                 OR a.beli_jasa_non_pddk_value = 1 
                 OR a.jasa_non_pddk_value = 1))
       OR (a.peran_mbg_value = 4 
            AND (c.kbli NOT LIKE '41%' 
                 AND c.kbli NOT LIKE '42%' 
                 AND c.kbli NOT LIKE '43%' 
                 AND c.kbli NOT LIKE '49%' 
                 AND c.kbli NOT LIKE '52%' 
                 AND c.kbli NOT LIKE '53%' 
                 AND c.kbli NOT LIKE '61%' 
                 AND c.kbli NOT LIKE '62%' 
                 AND c.kbli NOT LIKE '63%' 
                 AND c.kbli NOT LIKE '64%' 
                 AND c.kbli NOT LIKE '65%' 
                 AND c.kbli NOT LIKE '66%' 
                 AND c.kbli NOT LIKE '68%' 
                 AND c.kbli NOT LIKE '69%' 
                 AND c.kbli NOT LIKE '70%' 
                 AND c.kbli NOT LIKE '71%' 
                 AND c.kbli NOT LIKE '72%'))
       OR (a.peran_mbg_value = 1 AND a.total_tk_jk <= 3)
      )
ORDER BY
    a.level_6_full_code,
    a.assignment_id
LIMIT 9000 OFFSET 0;

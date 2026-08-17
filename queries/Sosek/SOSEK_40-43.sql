SELECT
    r.assignment_id,
    r.level_6_full_code AS "KODE_SUBSLS",
    r.nama_kk AS "NAMA_KK",
    

    COALESCE(
        CONCAT_WS(', ',
            CASE WHEN (v.sakit_hipertensi_value = 1 AND v.sakit_rematik_value = 1 
                       AND v.sakit_asma_value = 1 AND v.sakit_jantung_value = 1 
                       AND v.sakit_diabetes_value = 1 AND v.sakit_tbc_value = 1 
                       AND v.sakit_stroke_value = 1 AND v.sakit_kanker_value = 1 
                       AND v.sakit_hemofilia_value = 1 AND v.sakit_ginjal_value = 1 
                       AND v.sakit_hiv_value = 1 AND v.sakit_kolestrol_value = 1 
                       AND v.sakit_sirosis_value = 1 AND v.sakit_talasemia_value = 1 
                       AND v.sakit_leukemia_value = 1 AND v.sakit_alzheimer_value = 1 
                       AND v.sakit_lainnya_value = 1)
                 THEN 'S40' END,
            CASE WHEN (v.dis_fisik_value = 1 AND v.dis_mental_value = 1 
                       AND v.dis_netra_value = 1 AND v.dis_rungu_value = 1 
                       AND v.dis_wicara_value = 1 AND v.dis_intelek_value = 1)
                 THEN 'S41' END,
            CASE WHEN (n.umur_ak < 11 AND v.ijazah_value IN (1,2,3,4,5,6))
                   OR (n.umur_ak < 14 AND v.ijazah_value IN (2,3,4,5,6))
                   OR (n.umur_ak < 16 AND v.ijazah_value IN (3,4,5,6))
                   OR (n.umur_ak < 17 AND v.ijazah_value IN (4,5,6))
                   OR (n.umur_ak < 19 AND v.ijazah_value IN (5,6))
                   OR (n.umur_ak < 20 AND v.ijazah_value IN (6))
                 THEN 'S42' END,
            CASE WHEN NOT EXISTS (
                      SELECT 1
                      FROM tgr_fd68e454.nested_dtsen_var v2
                      WHERE v2.assignment_id = r.assignment_id
                        
                        AND v2.status_kerja_value = 4
                  )
                 THEN 'S43' END
        ),
        'LAINNYA'
    ) AS "KODE_ANOMALI",
    r.no_kk AS "NO_KK",
    v.nama_dtsen_var AS "NAMA_ART",
    
    CONCAT_WS(', ',
        v.sakit_hipertensi_value,
        v.sakit_rematik_value,
        v.sakit_asma_value,
        v.sakit_jantung_value,
        v.sakit_diabetes_value,
        v.sakit_tbc_value,
        v.sakit_stroke_value,
        v.sakit_kanker_value,
        v.sakit_hemofilia_value,
        v.sakit_ginjal_value,
        v.sakit_hiv_value,
        v.sakit_kolestrol_value,
        v.sakit_sirosis_value,
        v.sakit_talasemia_value,
        v.sakit_leukemia_value,
        v.sakit_alzheimer_value,
        v.sakit_lainnya_value
    ) AS "PENYAKIT",
    
    CONCAT_WS(', ',
        v.dis_fisik_value,
        v.dis_mental_value,
        v.dis_intelek_value,
        v.dis_netra_value,
        v.dis_rungu_value,
        v.dis_wicara_value
    ) AS "DISABILITAS",
    n.umur_ak,
    v.ijazah_value,
    
    r.status_kepemilikan_value,
    v.status_kerja_value,
    r.catatan,
    CONCAT(
          '<a href="https://fasih-sm.bps.go.id/app/assignment/fd68e454-ba45-4b85-8205-f3bf777ded24/',
          r.assignment_id,
          '" target="_blank">Link Assignment</a>'
      ) AS Link
FROM tgr_fd68e454.nested_dtsen n
LEFT JOIN tgr_fd68e454.root_table r 
       ON n.assignment_id = r.assignment_id
LEFT JOIN tgr_fd68e454.nested_dtsen_var v 
       ON n.assignment_id = v.assignment_id 
      AND n.index1 = v.index1
WHERE 
    (v.sakit_hipertensi_value = 1 AND v.sakit_rematik_value = 1 
     AND v.sakit_asma_value = 1 AND v.sakit_jantung_value = 1 
     AND v.sakit_diabetes_value = 1 AND v.sakit_tbc_value = 1 
     AND v.sakit_stroke_value = 1 AND v.sakit_kanker_value = 1 
     AND v.sakit_hemofilia_value = 1 AND v.sakit_ginjal_value = 1 
     AND v.sakit_hiv_value = 1 AND v.sakit_kolestrol_value = 1 
     AND v.sakit_sirosis_value = 1 AND v.sakit_talasemia_value = 1 
     AND v.sakit_leukemia_value = 1 AND v.sakit_alzheimer_value = 1 
     AND v.sakit_lainnya_value = 1)
    OR (v.dis_fisik_value = 1 AND v.dis_mental_value = 1 
         AND v.dis_netra_value = 1 AND v.dis_rungu_value = 1 
         AND v.dis_wicara_value = 1 AND v.dis_intelek_value = 1)
    OR (
         (n.umur_ak < 11 AND v.ijazah_value IN (1,2,3,4,5,6))
      OR (n.umur_ak < 14 AND v.ijazah_value IN (2,3,4,5,6))
      OR (n.umur_ak < 16 AND v.ijazah_value IN (3,4,5,6))
      OR (n.umur_ak < 17 AND v.ijazah_value IN (4,5,6))
      OR (n.umur_ak < 19 AND v.ijazah_value IN (5,6))
      OR (n.umur_ak < 20 AND v.ijazah_value IN (6))
    )
    OR 
    (r.status_kepemilikan_value = 4
    AND NOT EXISTS (
        SELECT 1
        FROM tgr_fd68e454.nested_dtsen_var v2
        WHERE v2.assignment_id = r.assignment_id
          AND v2.status_kerja_value = 4
    ))
ORDER BY
    r.level_6_full_code,
    r.nama_kk,
    r.no_kk
LIMIT 9000 OFFSET 0;

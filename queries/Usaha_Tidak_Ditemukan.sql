WITH aktif AS (
    SELECT assignment_id, assignment_date_modified, survey_period_id
    FROM tgr_fd68e454.base_table_assignment WHERE is_active = 1
),
hilang AS (
    SELECT n.assignment_id, a.survey_period_id,
           n.level_2_name AS kab, n.level_3_name AS kec,
           n.level_4_name AS desa, n.level_6_full_code AS subsls,
           n.nama_usaha, n.keberadaan_usaha_label, n.idsbr, n.skala_usaha,
           TRIM(COALESCE(r.nik_prelist, r.nik)) AS nik,
           r.catatan
    FROM tgr_fd68e454.se2026_nested n
    INNER JOIN aktif a ON a.assignment_id = n.assignment_id
                      AND a.assignment_date_modified = n.assignment_date_modified
    LEFT JOIN tgr_fd68e454.root_table r
           ON r.assignment_id = n.assignment_id
          AND r.assignment_date_modified = n.assignment_date_modified
    WHERE n.keberadaan_usaha_value IN ('00','0')
      AND LENGTH(TRIM(COALESCE(r.nik_prelist, r.nik))) = 16
      AND TRIM(COALESCE(r.nik_prelist, r.nik)) NOT LIKE '%99999999%'
),
ditemukan AS (
    SELECT n.assignment_id, a.survey_period_id,
           n.level_2_name AS kab, n.level_3_name AS kec,
           n.level_4_name AS desa, n.level_6_full_code AS subsls,
           n.nama_usaha, n.keberadaan_usaha_label, n.idsbr, n.skala_usaha,
           TRIM(COALESCE(r.nik_prelist, r.nik)) AS nik
    FROM tgr_fd68e454.se2026_nested n
    INNER JOIN aktif a ON a.assignment_id = n.assignment_id
                      AND a.assignment_date_modified = n.assignment_date_modified
    LEFT JOIN tgr_fd68e454.root_table r
           ON r.assignment_id = n.assignment_id
          AND r.assignment_date_modified = n.assignment_date_modified
    WHERE n.keberadaan_usaha_value IN ('2','2')
      AND LENGTH(TRIM(COALESCE(r.nik_prelist, r.nik))) = 16
      AND TRIM(COALESCE(r.nik_prelist, r.nik)) NOT LIKE '%99999999%'
),
art AS (            
    SELECT nik, nama, kab2, kec2, desa2, subsls2, asg2, spid2
    FROM (
        SELECT TRIM(d.nik_dtsen)   AS nik,
               d.nama_dtsen        AS nama,
               d.level_2_name      AS kab2,
               d.level_3_name      AS kec2,
               d.level_4_name      AS desa2,
               d.level_6_full_code AS subsls2,
               d.assignment_id     AS asg2,
               a.survey_period_id  AS spid2,
               ROW_NUMBER() OVER (PARTITION BY TRIM(d.nik_dtsen)
                                  ORDER BY d.assignment_id) AS rn
        FROM tgr_fd68e454.nested_dtsen d
        INNER JOIN aktif a ON a.assignment_id = d.assignment_id
                          AND a.assignment_date_modified = d.assignment_date_modified
        WHERE LENGTH(TRIM(d.nik_dtsen)) = 16
          AND TRIM(d.nik_dtsen) NOT LIKE '%99999999%'
    ) x WHERE rn = 1
)
SELECT h.kab, h.kec, h.desa, h.subsls,
       h.nama_usaha, h.keberadaan_usaha_label, h.idsbr, h.skala_usaha, h.nik, h.catatan,
       d.nama_usaha, d.kab, d.kec, d.desa, d.subsls , d.keberadaan_usaha_label,
       CASE WHEN d.kab  <> h.kab  THEN 'BEDA KABUPATEN'
            WHEN d.kec  <> h.kec  THEN 'BEDA KECAMATAN'
            WHEN d.desa <> h.desa THEN 'BEDA DESA'
            WHEN d.subsls <> h.subsls THEN 'BEDA SLS'
            ELSE 'SAMA SLS' END AS lokasi_usaha_baru,
       t.nama   AS nama_pemilik,
       t.kec2   AS kec_pemilik,
       t.desa2  AS desa_pemilik,
       t.subsls2 AS subsls_pemilik,
       CASE WHEN t.kab2  <> h.kab  THEN 'BEDA KABUPATEN'
            WHEN t.kec2  <> h.kec  THEN 'BEDA KECAMATAN'
            WHEN t.desa2 <> h.desa THEN 'BEDA DESA'
            ELSE 'SAMA DESA' END AS lokasi_pemilik,
       CONCAT('https://fasih-sm.bps.go.id/app/assignment/',
              h.survey_period_id,'/',h.assignment_id) AS link_usaha,
       CONCAT('https://fasih-sm.bps.go.id/app/assignment/',
              d.survey_period_id,'/',d.assignment_id) AS link_usaha_baru,
       CONCAT('https://fasih-sm.bps.go.id/app/assignment/',
              t.spid2,'/',t.asg2) AS link_keluarga_pemilik
FROM hilang h
INNER JOIN art t ON t.nik = h.nik
INNER JOIN ditemukan d ON d.nik = t.nik
ORDER BY h.skala_usaha, h.kab, h.subsls
LIMIT 27000, 9000;
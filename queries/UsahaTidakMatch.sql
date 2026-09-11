WITH aktif AS (
    SELECT assignment_id, assignment_date_modified, survey_period_id
    FROM tgr_fd68e454.base_table_assignment
    WHERE is_active = 1
),

hilang AS (
    SELECT
        n.assignment_id,
        a.survey_period_id,
        n.level_2_name AS kab,
        n.level_3_name AS kec,
        n.level_4_name AS desa,
        n.level_6_full_code AS subsls,
        n.nama_usaha,
        n.keberadaan_usaha_label,
        n.idsbr,
        n.skala_usaha,
        TRIM(COALESCE(r.nik_prelist, r.nik)) AS nik,
        r.catatan
    FROM tgr_fd68e454.se2026_nested n
    INNER JOIN aktif a
        ON a.assignment_id = n.assignment_id
       AND a.assignment_date_modified = n.assignment_date_modified
    LEFT JOIN tgr_fd68e454.root_table r
        ON r.assignment_id = n.assignment_id
       AND r.assignment_date_modified = n.assignment_date_modified
    WHERE n.keberadaan_usaha_value IN ('00', '0')
      AND LENGTH(TRIM(COALESCE(r.nik_prelist, r.nik))) = 16
      AND TRIM(COALESCE(r.nik_prelist, r.nik)) NOT LIKE '%99999999%'
),

ditemukan AS (
    SELECT
        n.assignment_id,
        a.survey_period_id,
        n.level_2_name AS kab,
        n.level_3_name AS kec,
        n.level_4_name AS desa,
        n.level_6_full_code AS subsls,
        n.nama_usaha,
        n.keberadaan_usaha_label,
        n.idsbr,
        n.skala_usaha,
        TRIM(COALESCE(r.nik_prelist, r.nik)) AS nik
    FROM tgr_fd68e454.se2026_nested n
    INNER JOIN aktif a
        ON a.assignment_id = n.assignment_id
       AND a.assignment_date_modified = n.assignment_date_modified
    LEFT JOIN tgr_fd68e454.root_table r
        ON r.assignment_id = n.assignment_id
       AND r.assignment_date_modified = n.assignment_date_modified
    WHERE n.keberadaan_usaha_value = '2'
      AND LENGTH(TRIM(COALESCE(r.nik_prelist, r.nik))) = 16
      AND TRIM(COALESCE(r.nik_prelist, r.nik)) NOT LIKE '%99999999%'
),

art AS (
    SELECT nik, nama, kab2, kec2, desa2, subsls2, asg2, spid2, keberadaan2
    FROM (
        SELECT
            TRIM(d.nik_dtsen) AS nik,
            d.nama_dtsen AS nama,
            d.level_2_name AS kab2,
            d.level_3_name AS kec2,
            d.level_4_name AS desa2,
            d.level_6_full_code AS subsls2,
            d.keberadaan_dtsen_label AS keberadaan2,
            d.assignment_id AS asg2,
            a.survey_period_id AS spid2,
            ROW_NUMBER() OVER (
                PARTITION BY TRIM(d.nik_dtsen)
                ORDER BY d.assignment_id
            ) AS rn
        FROM tgr_fd68e454.nested_dtsen d
        INNER JOIN aktif a
            ON a.assignment_id = d.assignment_id
           AND a.assignment_date_modified = d.assignment_date_modified
        WHERE LENGTH(TRIM(d.nik_dtsen)) = 16
          AND TRIM(d.nik_dtsen) NOT LIKE '%99999999%'
    ) x
    WHERE rn = 1
)

SELECT
    h.kab,
    h.kec,
    h.desa,
    h.subsls,
    h.nama_usaha,
    h.keberadaan_usaha_label,
    h.idsbr,
    h.skala_usaha,
    h.nik,
    h.catatan,
    CONCAT(
        'https://fasih-sm.bps.go.id/app/assignment/',
        h.survey_period_id, '/', h.assignment_id
    ) AS link_usaha
FROM hilang h
WHERE NOT EXISTS (
    SELECT 1
    FROM ditemukan d
    WHERE d.nik = h.nik
)
AND NOT EXISTS (
    SELECT 1
    FROM art t
    WHERE t.nik = h.nik
)
ORDER BY
    h.skala_usaha,
    h.kab,
    h.subsls
LIMIT 0,9000;
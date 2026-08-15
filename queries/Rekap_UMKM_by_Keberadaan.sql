SELECT
        level_6_full_code,

        SUM(CASE WHEN keberadaan_usaha_value = '00' THEN 1 ELSE 0 END) AS usaha_tidak_ditemukan,
        SUM(CASE WHEN keberadaan_usaha_value = '1' THEN 1 ELSE 0 END) AS usaha_ditemukan,
        SUM(CASE WHEN keberadaan_usaha_value = '2' THEN 1 ELSE 0 END) AS usaha_baru,
        SUM(CASE WHEN keberadaan_usaha_value = '3' THEN 1 ELSE 0 END) AS usaha_tutup,
        SUM(CASE WHEN keberadaan_usaha_value = '4' THEN 1 ELSE 0 END) AS usaha_ganda,
        SUM(CASE WHEN keberadaan_usaha_value = '9' THEN 1 ELSE 0 END) AS usaha_nonrespon,
        SUM(CASE WHEN keberadaan_usaha_value IS NULL THEN 1 ELSE 0 END) AS usaha_status_draft
        -- SUM(CASE WHEN assignment_listing = 0 AND keberadaan_usaha_value <> 2 THEN 1 ELSE 0 END) AS usaha_prelist
    FROM pengolahan_se2026.MV_UMKM 
    WHERE level_1_full_code IN ('53')
    GROUP BY level_6_full_code
    ORDER BY level_6_full_code
    LIMIT 0, 1000
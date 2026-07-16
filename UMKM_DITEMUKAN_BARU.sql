SELECT DISTINCT
    assignment_id,
    level_6_full_code,
    data1,
    nama_usaha,
    keberadaan_usaha_label,
    nama_komersial,
    nama_usaha_bang,
    geotag_latitude,
    geotag_longitude,
    CONCAT(
        'https://www.google.com/maps?q=',
        geotag_latitude,
        ',',
        geotag_longitude
    ) AS gmaps
FROM pengolahan_se2026.MV_UMKM
WHERE level_2_full_code = 5371
ORDER BY
    level_6_full_code DESC,
    data1
LIMIT 0, 1000
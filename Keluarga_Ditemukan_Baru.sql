SELECT DISTINCT
    assignment_id,
    level_6_full_code,
    data1,
    nama_kk,
    ada_keluarga_label,
    geotag_latitude,
    geotag_longitude,
    CONCAT(
        'https://www.google.com/maps?q=',
        geotag_latitude,
        ',',
        geotag_longitude
    ) AS gmaps
FROM pengolahan_se2026.MV_ANGGOTA_KELUARGA
WHERE level_2_full_code = 5371
ORDER BY
    assignment_id,
    level_6_full_code DESC,
    data1,
    nama_kk,
    ada_keluarga_label,
    geotag_latitude,
    geotag_longitude
LIMIT 0, 1000;
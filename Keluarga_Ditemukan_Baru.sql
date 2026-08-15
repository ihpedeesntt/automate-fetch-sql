SELECT DISTINCT
    assignment_id as "Assignment Id",
    level_3_name AS "Nama Kecamatan",
    level_4_name AS "Nama Kelurahan/Desa",
    level_6_full_code as "Kode SubSLS",
    level_6_name as "Nama SLS",
    nama_kk as "Nama Kepala Keluarga",
    no_bang as "Nomor Bangunan",
    ada_keluarga_label as "Status Keluarga",
    kode_bang_label as "Penggunaan Bangunan",
    geotag_latitude as "Latitude",
    geotag_longitude as "Longitude",
    assignment_status_alias,
    assignment_status_id,
    CONCAT(
        'https://www.google.com/maps?q=',
        geotag_latitude,
        ',',
        geotag_longitude
    ) AS gmaps,
    catatan,
    CONCAT("https://fasih-sm.bps.go.id/app/assignment/fd68e454-ba45-4b85-8205-f3bf777ded24/",assignment_id) AS "Link Assignment"
FROM tgr_fd68e454.root_table 
WHERE level_2_full_code = 5371 AND assignment_status_id <> 0 AND ada_keluarga_value IS NOT NULL
ORDER BY
    level_6_full_code DESC,
    nama_kk
LIMIT 0, 1000;
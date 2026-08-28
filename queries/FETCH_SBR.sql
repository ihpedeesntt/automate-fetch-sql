SELECT DISTINCT
    root.assignment_id as "Assignment Id",
    root.level_3_name AS "Nama Kecamatan",
    root.level_4_name AS "Nama Kelurahan/Desa",
    root.level_6_full_code as "Kode SubSLS",
    root.level_6_name as "Nama SLS",
    root.nama_kk as "Nama KK Berusaha",
    root.nama_usaha_bang as "Nama Bangunan Usaha",
    usaha.nama_usaha as "Nama Usaha",
    usaha.idsbr as "ID SBR",
    root.no_bang as "Nomor Bangunan",
    root.ada_keluarga_label as "Status Keluarga",
    root.ada_bang_usaha_label as "Status Usaha",
    usaha.keberadaan_usaha_label as "Keberadaan Usaha",
    root.kode_bang_label as "Penggunaan Bangunan",
    root.geotag_latitude as "Latitude",
    root.geotag_longitude as "Longitude",
    root.assignment_status_alias,
    root.assignment_status_id,
    CONCAT(
        'https://www.google.com/maps?q=',
        root.geotag_latitude,
        ',',
        root.geotag_longitude
    ) AS gmaps,
    root.catatan,
    CONCAT("https://fasih-sm.bps.go.id/app/assignment/fd68e454-ba45-4b85-8205-f3bf777ded24/",root.assignment_id) AS "Link Assignment"
FROM tgr_fd68e454.root_table root
LEFT JOIN tgr_fd68e454.se2026_nested usaha ON root.assignment_id = usaha.assignment_id 
WHERE root.assignment_status_id = 2 AND (root.ada_bang_usaha_label IS NOT NULL OR usaha.keberadaan_usaha_label IS NOT NULL)
AND usaha.idsbr IS NOT NULL
ORDER BY
    root.level_6_full_code DESC,
    root.nama_usaha_bang
LIMIT 306000, 9000;
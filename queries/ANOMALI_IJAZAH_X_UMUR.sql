SELECT
    assignment_id,
    level_2_code,
    level_2_name,
    level_3_full_code,
    level_3_name,
    level_4_full_code,
    level_4_name,
    level_5_full_code,
    level_5_name,
    index1,
    no_urut_kk,
    nama_kk,
    nama_art,
    umur,
    ijazah,
    ijazah_label AS "Ijazah Pendidikan Tertinggi",
    sekolah_value,
    sekolah_label AS "Status Sekolah",
    anomali,
    CONCAT("https://fasih-sm.bps.go.id/app/assignment/fd68e454-ba45-4b85-8205-f3bf777ded24/",assignment_id) AS "Link Assignment"
FROM (
    SELECT
        a.assignment_id,
        a.level_2_name,
        a.level_2_code,
        a.level_3_full_code,
        a.level_3_name,
        a.level_4_full_code,
        a.level_4_name,
        a.level_5_full_code,
        a.level_5_name,
        a.index1,
        t.nama_kk,
        t.nama_ak_lain,
        r.no_urut_kk,
        r.nama_dtsen AS nama_art,
        r.umur_ak AS umur,
        a.ijazah_value AS ijazah,
        a.ijazah_label AS ijazah_label,
        a.sekolah_value,
        a.sekolah_label AS sekolah_label,
        "Anomali Ijazah x Umur" AS anomali
    FROM tgr_fd68e454.nested_dtsen_var a
    INNER JOIN tgr_fd68e454.nested_dtsen r
        ON a.assignment_id = r.assignment_id
     JOIN tgr_fd68e454.root_table t 
        ON r.assignment_id = t.assignment_id
    WHERE a.sekolah_value = 1
      AND t.assignment_status_id = 2
      AND r.umur_ak BETWEEN 5 AND 18
      AND (
          (r.umur_ak BETWEEN 5 AND 12 AND a.ijazah_value > 1)
          OR (r.umur_ak BETWEEN 13 AND 15 AND a.ijazah_value > 3)
          OR (r.umur_ak BETWEEN 16 AND 18 AND a.ijazah_value > 5)
      )
) filtered_data
ORDER BY index1, level_2_code ASC, level_3_full_code ASC, level_4_full_code ASC, level_5_full_code ASC
LIMIT 0, 1000;
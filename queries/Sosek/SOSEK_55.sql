SELECT
    r.assignment_id,
    r.level_6_full_code AS "KODE_SUBSLS",
    r.nama_kk AS "NAMA_KK",

    CASE
        WHEN COALESCE(d.jumlah_krt, 0) = 0
          OR COALESCE(d.jumlah_suami_istri, 0) > 1
        THEN 'S55'
    END AS "KODE_ANOMALI",
    r.no_kk AS "NO_KK",

    r.nama_principal,
    r.ada_keluarga_label,

    COALESCE(d.jumlah_art, 0) AS jumlah_art,
    COALESCE(d.jumlah_krt, 0) AS jumlah_krt,
    COALESCE(d.jumlah_suami_istri, 0) AS jumlah_suami_istri,
    r.geotag_latitude,
    r.geotag_longitude,

    CONCAT(
        'https://fasih-sm.bps.go.id/app/assignment/fd68e454-ba45-4b85-8205-f3bf777ded24/',
        r.assignment_id
    ) AS "Link Assignment",

    r.catatan

FROM tgr_fd68e454.root_table r

LEFT JOIN (
    SELECT
        assignment_id,
        COUNT(*) AS jumlah_art,

        SUM(
            CASE
                WHEN hubungan_value = '1' THEN 1
                ELSE 0
            END
        ) AS jumlah_krt,

        SUM(
            CASE
                WHEN hubungan_value = '2' THEN 1
                ELSE 0
            END
        ) AS jumlah_suami_istri

    FROM tgr_fd68e454.nested_dtsen

    GROUP BY
        assignment_id
) d
    ON d.assignment_id = r.assignment_id

INNER JOIN tgr_fd68e454.base_table_assignment b
    ON b.assignment_id = r.assignment_id
    AND b.is_active = 1

WHERE
    r.ada_keluarga_value = 1

    AND r.assignment_status_id > 0
    AND r.assignment_status_alias <> 'DRAFT'

    AND EXISTS (
        SELECT 1
        FROM tgr_fd68e454.se2026_nested s
        WHERE s.assignment_id = r.assignment_id
          AND s.assignment_date_modified = r.assignment_date_modified
    )

    AND (
        COALESCE(d.jumlah_krt, 0) = 0
        OR COALESCE(d.jumlah_suami_istri, 0) > 1
    )

ORDER BY
    r.level_6_full_code,
    r.assignment_id

LIMIT 9000 OFFSET 0;
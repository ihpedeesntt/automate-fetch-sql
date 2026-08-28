SELECT
    usaha.level_2_full_code,
    usaha.level_2_name,
    usaha.kbli_akhir,
    usaha.kategori,
    COUNT(*) AS jumlah

FROM tgr_fd68e454.root_table r

-- Aturan 1:
-- Assignment harus aktif
INNER JOIN tgr_fd68e454.base_table_assignment b
    ON r.assignment_id = b.assignment_id
    AND b.is_active = 1

-- Aturan 2:
-- Root dan roster harus berasal dari snapshot yang sama
INNER JOIN tgr_fd68e454.se2026_nested usaha
    ON r.assignment_id = usaha.assignment_id
    AND r.assignment_date_modified = usaha.assignment_date_modified
    AND usaha.keberadaan_usaha_value IN (1, 2)

-- Aturan 3:
-- Pastikan snapshot tersedia di USAHA_REF
INNER JOIN (
    SELECT DISTINCT
        assignment_id,
        assignment_date_modified
    FROM tgr_fd68e454.USAHA_REF
) u
    ON r.assignment_id = u.assignment_id
    AND r.assignment_date_modified = u.assignment_date_modified

WHERE
    r.assignment_status_id = 2
    AND usaha.kbli_akhir IS NOT NULL

GROUP BY
    usaha.level_2_full_code,
    usaha.level_2_name,
    usaha.kbli_akhir,
    usaha.kategori

ORDER BY
    usaha.level_2_full_code ASC,
    usaha.kbli_akhir ASC,
    jumlah ASC

LIMIT 9000 OFFSET 0;
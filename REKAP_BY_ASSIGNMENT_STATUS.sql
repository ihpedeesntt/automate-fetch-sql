SELECT *
FROM (
    SELECT
        level_6_full_code,
        assignment_status_alias,
        SUM(CASE 
                WHEN ada_keluarga_label IS NOT NULL 
                THEN 1 ELSE 0 
            END) AS jumlah_ada_keluarga,

        SUM(CASE 
                WHEN ada_bang_usaha_label IS NOT NULL 
                THEN 1 ELSE 0 
            END) AS jumlah_ada_bang_usaha,

        SUM(CASE 
                WHEN ada_keluarga_label IS NOT NULL
                  OR ada_bang_usaha_label IS NOT NULL
                THEN 1 ELSE 0 
            END) AS jumlah_total_terisi
    FROM tgr_fd68e454.root_table
    WHERE level_1_full_code = 53
      AND assignment_status_id > 0
      AND assignment_status_id <> 3
    GROUP BY
        level_6_full_code,
        assignment_status_alias
    ORDER BY
        level_6_full_code,
        assignment_status_alias
  OFFSET 1000*0 ROWS
  FETCH NEXT 1000 ROWS ONLY
) AS a
ORDER BY
    level_6_full_code ASC,
    assignment_status_alias;
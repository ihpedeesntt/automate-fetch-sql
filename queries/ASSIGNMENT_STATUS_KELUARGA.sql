SELECT * FROM (
SELECT level_6_full_code , ada_keluarga_label, COUNT(ada_keluarga_label) as jumlah_keluarga
FROM tgr_fd68e454.root_table
WHERE level_1_full_code = 53 AND assignment_status_id NOT IN (0,3) AND ada_keluarga_label IS NOT NULL
GROUP BY level_6_full_code, ada_keluarga_label
ORDER BY level_6_full_code ASC, ada_keluarga_label
OFFSET 1000*0 ROWS FETCH NEXT 1000 ROWS ONLY 
) a ORDER BY level_6_full_code ASC
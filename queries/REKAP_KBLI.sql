SELECT usaha.level_2_full_code, usaha.level_2_name, usaha.kbli_akhir,usaha.kategori, count(usaha.kbli_akhir) as jumlah
FROM tgr_fd68e454.se2026_nested usaha
LEFT JOIN tgr_fd68e454.root_table root ON root.assignment_id = usaha.assignment_id
WHERE root.assignment_status_id = 2 AND usaha.kbli_akhir is NOT NULL
GROUP BY usaha.level_2_full_code, usaha.level_2_name, usaha.kbli_akhir, usaha.kategori
ORDER BY usaha.level_2_full_code ASC, kbli_akhir ASC ,count(kbli_akhir) ASC
LIMIT 0,1000
SELECT * FROM (
SELECT kbli_akhir,kategori, level_6_full_code,COUNT(*) as jumlah,
SUM(total_pengeluaran) as total_pengeluaran, 
SUM(total_pendapatan) as total_pendapatan
FROM tgr_fd68e454.T_USAHA 
WHERE level_1_full_code = '53' AND kbli_akhir IS NOT NULL
GROUP BY kbli_akhir, level_6_full_code ,kategori
order by level_6_full_code, kbli_akhir, kategori
OFFSET 1000*0 ROWS FETCH NEXT 1000 ROWS ONLY
) A ORDER BY level_6_full_code, jumlah DESC, kbli_akhir, kategori
SELECT 
    b.assignment_id,
    b.level_6_full_code,
    s.nama_usaha,
   
   CONCAT_WS(', ',
        CASE WHEN s.gaji > (s.nilai_pendapatan - (s.biaya_produksi + s.biaya_pembelian + s.operasional)) 
             THEN 'E40' END,
        CASE WHEN (r.pengeluaran_makanan_mingguan = 0 OR r.pengeluaran_non_makan_bulanan = 0 OR r.pengeluaran_non_makan_tahunan = 0) AND (r.catatan IS NULL OR TRIM(r.catatan) = '')
             THEN 'E41' END
    ) AS "KODE_ANOMALI",
    
    s.keg_utama, u.kbli, s.gaji, s.nilai_pendapatan, s.biaya_produksi, s.biaya_pembelian, s.operasional,
    r.pengeluaran_makanan_mingguan, r.pengeluaran_non_makan_bulanan, r.pengeluaran_non_makan_tahunan, r.jml_kk_update > 2,
    r.catatan,
    CONCAT(
        'https://fasih-sm.bps.go.id/app/assignment/fd68e454-ba45-4b85-8205-f3bf777ded24/',
        b.assignment_id
    ) AS Link
FROM tgr_fd68e454.base_table_assignment b
LEFT JOIN tgr_fd68e454.root_table r
    ON b.assignment_id = r.assignment_id AND b.date_modified = r.assignment_date_modified
LEFT JOIN tgr_fd68e454.se2026_nested s
    ON b.assignment_id = s.assignment_id AND b.date_modified = s.assignment_date_modified
LEFT JOIN tgr_fd68e454.USAHA_REF u
    ON b.assignment_id = u.assignment_id AND b.date_modified = u.assignment_date_modified

WHERE (b.is_active = 1 AND b.assignment_status_id > 1) AND
( s.gaji > (s.nilai_pendapatan - (s.biaya_produksi + s.biaya_pembelian + s.operasional)) )
OR
( (r.pengeluaran_makanan_mingguan = 0 OR r.pengeluaran_non_makan_bulanan = 0 OR r.pengeluaran_non_makan_tahunan = 0) AND (r.catatan IS NULL OR TRIM(r.catatan) = '' OR r.jml_kk_update > 2) )

ORDER BY
    b.level_6_full_code,
    b.assignment_id
LIMIT 9000 OFFSET 0
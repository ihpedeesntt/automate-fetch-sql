SELECT 
    b.assignment_id,
    b.level_6_full_code,
    s.nama_usaha,
   
   CONCAT_WS(', ',
        CASE WHEN (
              (s.nilai_pendapatan - (s.biaya_produksi + s.biaya_pembelian + s.operasional)) / (s.nilai_pendapatan - s.biaya_pembelian) < 0.25
              OR (s.nilai_pendapatan - (s.biaya_produksi + s.biaya_pembelian + s.operasional)) / (s.nilai_pendapatan - s.biaya_pembelian) > 0.75
          )  THEN 'E46' END,
        CASE WHEN (
              (s.nilai_pendapatan_bln - (s.biaya_produksi_bln + s.biaya_pembelian_bln + s.operasional_bln)) / (s.nilai_pendapatan_bln - s.biaya_pembelian_bln) < 0.25
              OR (s.nilai_pendapatan_bln - (s.biaya_produksi_bln + s.biaya_pembelian_bln + s.operasional_bln)) / (s.nilai_pendapatan_bln - s.biaya_pembelian_bln) > 0.75
          )  THEN 'E47' END
    ) AS "KODE_ANOMALI",
    
    s.keg_utama, u.kbli, s.nilai_pendapatan, s.biaya_produksi, s.biaya_pembelian, s.operasional,
    s.nilai_pendapatan_bln, s.biaya_produksi_bln, s.biaya_pembelian_bln, s.operasional_bln,
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
(
    (s.nilai_pendapatan - (s.biaya_produksi + s.biaya_pembelian + s.operasional)) / (s.nilai_pendapatan - s.biaya_pembelian) < 0.25
    OR (s.nilai_pendapatan - (s.biaya_produksi + s.biaya_pembelian + s.operasional)) / (s.nilai_pendapatan - s.biaya_pembelian) > 0.75
)
OR
(
    (s.nilai_pendapatan_bln - (s.biaya_produksi_bln + s.biaya_pembelian_bln + s.operasional_bln)) / (s.nilai_pendapatan_bln - s.biaya_pembelian_bln) < 0.25
    OR (s.nilai_pendapatan_bln - (s.biaya_produksi_bln + s.biaya_pembelian_bln + s.operasional_bln)) / (s.nilai_pendapatan_bln - s.biaya_pembelian_bln) > 0.75
)

ORDER BY
    b.level_6_full_code,
    b.assignment_id
LIMIT 9000 OFFSET 0
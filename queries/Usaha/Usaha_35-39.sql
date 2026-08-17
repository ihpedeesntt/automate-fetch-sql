SELECT 
    b.assignment_id,
    b.level_6_full_code,
    s.nama_usaha,
   
   CONCAT_WS(', ',
        CASE WHEN s.lokasi_usaha_value = '1' AND u.kbli NOT IN ('47721', '86201', '86202', '86203', '86105') 
             THEN 'E35' END,
        CASE WHEN s.lokasi_usaha_value = '9' AND u.kbli NOT LIKE '56%' AND (s.nilai_pendapatan = 360000000 OR s.nilai_pendapatan_bln = 30000000)
             THEN 'E36' END,
        CASE WHEN s.lokasi_usaha_value = '9' AND s.layanan_mamin_value = '2'
             THEN 'E37' END,
        CASE WHEN s.lokasi_usaha_value = '11' AND s.internet_pesanan_value = '2' AND s.produk_seni_value = '2'
             THEN 'E38' END,
        CASE WHEN s.lokasi_usaha_value = '9' AND u.kbli NOT LIKE '56%'
             THEN 'E39' END
    ) AS "KODE_ANOMALI",
    
    s.keg_utama, u.kbli, s.lokasi_usaha_value, s.layanan_mamin_value, s.internet_pesanan_value, s.produk_seni_value, s.nilai_pendapatan, s.nilai_pendapatan_bln,
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
( s.lokasi_usaha_value = '1' AND u.kbli NOT IN ('47721', '86201', '86202', '86203', '86105') )
OR
( s.lokasi_usaha_value = '9' AND u.kbli NOT LIKE '56%' AND (s.nilai_pendapatan = 360000000 OR s.nilai_pendapatan_bln = 30000000) )
OR
( s.lokasi_usaha_value = '9' AND s.layanan_mamin_value = '2' )
OR
( s.lokasi_usaha_value = '11' AND s.internet_pesanan_value = '2' AND s.produk_seni_value = '2' )
OR
( s.lokasi_usaha_value = '9' AND u.kbli NOT LIKE '56%' )

ORDER BY
    b.level_6_full_code,
    b.assignment_id
LIMIT 9000 OFFSET 0
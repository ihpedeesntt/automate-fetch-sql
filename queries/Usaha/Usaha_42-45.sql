SELECT 
    b.assignment_id,
    b.level_6_full_code,
    s.nama_usaha,
   
   CONCAT_WS(', ',
        CASE WHEN s.koperasi_kdkmp_value = '1' AND s.mitra_kdkmp_value = '1' 
             THEN 'E42' END,
        CASE WHEN (s.gaji / s.total_tk_bayar) > 384000000
             THEN 'E43' END,
        CASE WHEN s.internet_pesanan_value AND  ( s.pendapatan_online = 0 OR s.pendapatan_online_bln = 0 )
             THEN 'E44' END,
        CASE WHEN s.jumlah_kc > 99
             THEN 'E45' END
    ) AS "KODE_ANOMALI",
    
    s.keg_utama, u.kbli, s.koperasi_kdkmp_value, s.mitra_kdkmp_value, s.gaji, s.total_tk_jk, s.internet_pesanan_value, s.pendapatan_online, s.pendapatan_online_bln, s.jumlah_kc,
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
( s.koperasi_kdkmp_value = '1' AND s.mitra_kdkmp_value = '1' )
OR
( (s.gaji / s.total_tk_bayar) > 384000000 )
OR
( s.internet_pesanan_value AND  ( s.pendapatan_online = 0 OR s.pendapatan_online_bln = 0 ) )
OR
( s.jumlah_kc > 99 )

ORDER BY
    b.level_6_full_code,
    b.assignment_id
LIMIT 9000 OFFSET 0
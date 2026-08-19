SELECT filter.KODE_KAB, filter.KODE_KEC, filter.NAMA_KEC, 
    filter.KODE_DESA, filter.NAMA_DESA, filter.KODE_SLS, filter.NAMA_SLS, filter.KODE_SUBSLS,
    filter.nama_usaha, 
    filter.jenis_usaha_value,
    filter.layanan_mamin_value,
    filter.keg_penjualan_value,
    filter.lokasi_usaha_value

FROM (
    SELECT  
        a.level_2_full_code AS 'KODE_KAB',
        a.level_3_full_code AS 'KODE_KEC', 
        a.level_3_name AS 'NAMA_KEC',
        a.level_4_full_code AS 'KODE_DESA', 
        a.level_4_name AS 'NAMA_DESA',
        a.level_5_full_code AS 'KODE_SLS', 
        a.level_5_name AS 'NAMA_SLS',
        a.level_6_full_code AS 'KODE_SUBSLS', 
        nama_usaha,
        jenis_usaha_value,
        layanan_mamin_value,
        keg_penjualan_value,
        lokasi_usaha_value
    FROM  tgr_fd68e454.se2026_nested  a
    INNER JOIN tgr_fd68e454.USAHA_REF u 
      ON a.assignment_id = u.assignment_id AND a.assignment_date_modified = u.assignment_date_modified
    WHERE (jenis_usaha_value = 2 AND lokasi_usaha_value <> 10) 
    OR (layanan_mamin_value = 1 AND lokasi_usaha_value NOT IN(5,6,7,8,9,10,11) ) 
    OR(keg_penjualan_value = 1 AND lokasi_usaha_value NOT IN(1,4,10,11) )

) AS filter

ORDER BY 
        a.level_2_full_code,
        a.level_3_full_code, a.level_3_name,
        a.level_4_full_code, a.level_4_name,
        a.level_5_full_code, a.level_5_name,
        a.level_6_full_code

LIMIT 9000 OFFSET 0
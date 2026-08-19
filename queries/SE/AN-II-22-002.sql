SELECT filter.KODE_KAB, filter.KODE_KEC, filter.NAMA_KEC, 
    filter.KODE_DESA, filter.NAMA_DESA, filter.KODE_SLS, filter.NAMA_SLS, filter.KODE_SUBSLS,
    filter.nama_usaha, filter.peran_mbg_value, filter.total_tk_jk

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
        peran_mbg_value,
        total_tk_jk
    FROM  tgr_fd68e454.se2026_nested  a
    INNER JOIN tgr_fd68e454.USAHA_REF u 
      ON a.assignment_id = u.assignment_id AND a.assignment_date_modified = u.assignment_date_modified
    WHERE peran_mbg_value = 1 AND total_tk_jk < 4
) AS filter

ORDER BY
    filter.KODE_KAB,
    filter.KODE_KEC, 
    filter.NAMA_KEC,
    filter.KODE_DESA, 
    filter.NAMA_DESA,
    filter.KODE_SLS, 
    filter.NAMA_SLS,
    filter.KODE_SUBSLS

LIMIT 9000 OFFSET 0;
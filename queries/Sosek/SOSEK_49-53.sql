SELECT
    r.assignment_id,
    r.level_6_full_code AS "KODE_SUBSLS",
    r.nama_kk AS "NAMA_KK",
    

    COALESCE(
        CONCAT_WS(', ',
            CASE WHEN r.sewa_dinas = 0 AND r.sewa_kontrak = 0 AND r.sewa_sendiri = 0
                 THEN 'S49' END,
            CASE WHEN sewa_dinas < 50000 OR sewa_dinas > 100000000 OR sewa_kontrak < 10000 OR sewa_kontrak > 100000000 OR sewa_sendiri < 10000 OR sewa_sendiri > 100000000
                 THEN 'S50' END,
            CASE WHEN (v.pend_gaji + v.pend_honor + v.pend_lainnya + v.pend_lembur + v.pend_tunjangan + v.pend_uangmkn < 100000 
                       OR v.pend_gaji + v.pend_honor + v.pend_lainnya + v.pend_lembur + v.pend_tunjangan + v.pend_uangmkn > 100000000)
                      AND v.profesi_value NOT IN ('000') AND status_kerja_value IN (3,4,5)
                 THEN 'S51' END,
            CASE WHEN (pend_gaji+pend_tunjangan+pend_uangmkn+pend_honor+pend_lembur+pend_lainnya + v.pend_usaha > 0) 
                      AND v.profesi_value IN ('000','999')
                 THEN 'S52' END,
            CASE WHEN v.profesi_value NOT IN ('005','006','007','008','012','018','020','028','031','032','033','034','035','036',
                '040','041','042','043','045','046','052','059','062','064','071','079','083','105',
                '127','128','131','133','135','136','137','138','139','141','144','145','153','158',
                '177','178','179','180','181', '155', '157')
                      AND v.status_kerja_value = 4
                 THEN 'S53' END
        ),
        'LAINNYA'
    ) AS "KODE_ANOMALI",
    r.no_kk AS "NO_KK",
    v.nama_dtsen_var AS "NAMA_ART",
    n.umur_ak,
    v.profesi_value,
    v.profesi_label,
    v.profesi_lainnya,
    v.status_kerja_value,
    r.sewa_dinas,
    r.sewa_kontrak,
    r.sewa_sendiri,
    v.pend_gaji,
    v.pend_honor,
    v.pend_lainnya,
    v.pend_lembur,
    v.pend_tunjangan,
    v.pend_uangmkn,
    pend_gaji+pend_tunjangan+pend_uangmkn+pend_honor+pend_lembur+pend_lainnya as nilai_pend_pekerjaan,
    v.pend_usaha,
    r.catatan,  
    CONCAT(
          '<a href="https://fasih-sm.bps.go.id/app/assignment/fd68e454-ba45-4b85-8205-f3bf777ded24/',
          r.assignment_id,
          '" target="_blank">Link Assignment</a>'
      ) AS Link
FROM tgr_fd68e454.nested_dtsen n
LEFT JOIN tgr_fd68e454.root_table r 
       ON n.assignment_id = r.assignment_id
LEFT JOIN tgr_fd68e454.nested_dtsen_var v 
       ON n.assignment_id = v.assignment_id 
      AND n.index1 = v.index1
WHERE 
    (r.sewa_dinas = 0 AND r.sewa_kontrak = 0 AND r.sewa_sendiri = 0)
 OR (sewa_dinas < 50000 OR sewa_dinas > 100000000 OR sewa_kontrak < 10000 OR sewa_kontrak > 100000000 OR sewa_sendiri < 10000 OR sewa_sendiri > 100000000)
 OR ((v.pend_gaji + v.pend_honor + v.pend_lainnya + v.pend_lembur + v.pend_tunjangan + v.pend_uangmkn < 100000 
      OR v.pend_gaji + v.pend_honor + v.pend_lainnya + v.pend_lembur + v.pend_tunjangan + v.pend_uangmkn > 100000000)
     AND v.profesi_value NOT IN ('000') AND status_kerja_value IN (3,4,5))
 OR ((pend_gaji+pend_tunjangan+pend_uangmkn+pend_honor+pend_lembur+pend_lainnya + v.pend_usaha > 0) AND v.profesi_value IN ('000','999'))
 OR (v.profesi_value NOT IN ('005','006','007','008','012','018','020','028','031','032','033','034','035','036',
                '040','041','042','043','045','046','052','059','062','064','071','079','083','105',
                '127','128','131','133','135','136','137','138','139','141','144','145','153','158',
                '177','178','179','180','181', '155', '157')
     AND v.status_kerja_value = 4)
ORDER BY
    r.level_6_full_code,
    r.nama_kk,
    r.no_kk
LIMIT 9000 OFFSET 0;

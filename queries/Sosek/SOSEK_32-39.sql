SELECT
    roott.assignment_id,
    roott.level_6_full_code AS "KODE_SUBSLS",
    roott.nama_kk AS "NAMA_KK",
    

    COALESCE(
        CONCAT_WS(', ',
            CASE WHEN roott.air_minum_value = 11 
                 THEN 'S26' END,
            CASE WHEN roott.buang_tinja_value IN (2, 6) 
                 THEN 'S27' END,
            CASE WHEN roott.tempat_bab_value = 5 
                 THEN 'S28' END,
            CASE WHEN roott.jns_atap_value IN (5, 6) 
                 THEN 'S29' END,
            CASE WHEN roott.jns_dinding_value = 5 
                 THEN 'S30' END,
            CASE WHEN roott.jns_lantai_value IN (3, 9) 
                 THEN 'S31' END
        ),
        'LAINNYA'
    ) AS "KODE_ANOMALI",
    roott.no_kk AS "NO_KK",
    roott.jml_kk_update AS "JML_AK_PENDATAAN",
    roott.air_minum_value,
    roott.buang_tinja_value,
    roott.tempat_bab_value,
    roott.jns_atap_value,
    roott.jns_dinding_value,
    roott.jns_lantai_value,
    roott.catatan,
    CONCAT(
          '<a href="https://fasih-sm.bps.go.id/app/assignment/fd68e454-ba45-4b85-8205-f3bf777ded24/',
          roott.assignment_id,
          '" target="_blank">Link Assignment</a>'
      ) AS Link
FROM tgr_fd68e454.root_table roott
WHERE (
        roott.air_minum_value = 11
     OR roott.buang_tinja_value IN (2, 6)
     OR roott.tempat_bab_value = 5
     OR roott.jns_atap_value IN (5, 6)
     OR roott.jns_dinding_value = 5
     OR roott.jns_lantai_value IN (3, 9)
  )
ORDER BY
    roott.level_6_full_code,
    roott.nama_kk,
    roott.no_kk
LIMIT 9000 OFFSET 0;

SELECT
    roott.assignment_id,
    roott.level_6_full_code AS "KODE_SUBSLS",
    roott.nama_kk AS "NAMA_KK",
    
    
    CONCAT_WS(', ',
        CASE WHEN roott.jumlah_laptop_new > 9 THEN 'S15' END,
        CASE WHEN roott.jumlah_emas_new > 500 THEN 'S16' END,
        CASE WHEN roott.jumlah_ac_new > 9 THEN 'S17' END,
        CASE WHEN roott.jumlah_kulkas_new > 9 THEN 'S18' END,
        CASE WHEN roott.jumlah_tabung5kg_new > 9 THEN 'S19' END,
        CASE WHEN roott.jumlah_tabung3kg_new > 9 THEN 'S20' END
    ) AS "KODE_ANOMALI",
    roott.no_kk AS "NO_KK",
    roott.jumlah_laptop_new AS "JML_LAPTOP",
    roott.jumlah_emas_new AS "JML_EMAS",
    roott.jumlah_ac_new AS "JML_AC",
    roott.jumlah_kulkas_new AS "JML_KULKAS",
    roott.jumlah_tabung5kg_new AS "JML_GAS_5,5KG",
    roott.jumlah_tabung3kg_new AS "JML_GAS_3KG",
    roott.catatan,
    CONCAT(
          '<a href="https://fasih-sm.bps.go.id/app/assignment/fd68e454-ba45-4b85-8205-f3bf777ded24/',
          roott.assignment_id,
          '" target="_blank">Link Assignment</a>'
      ) AS Link
FROM tgr_fd68e454.root_table roott
WHERE (
        roott.jumlah_laptop_new > 9
     OR roott.jumlah_emas_new > 500
     OR roott.jumlah_ac_new > 9
     OR roott.jumlah_kulkas_new > 9
     OR roott.jumlah_tabung5kg_new > 9
     OR roott.jumlah_tabung3kg_new > 9
  )
ORDER BY
    roott.level_6_full_code,
    roott.nama_kk,
    roott.no_kk
LIMIT 1000 OFFSET 0;

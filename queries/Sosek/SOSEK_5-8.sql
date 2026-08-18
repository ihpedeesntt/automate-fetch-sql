SELECT
    roott.assignment_id,
    roott.level_6_full_code AS "KODE_SUBSLS",
    roott.nama_kk AS "NAMA_KK",
    
    COALESCE(
        CONCAT_WS(', ',
            CASE WHEN roott.jumlah_rumah_new > 9 
                 THEN 'S5' END,
            CASE WHEN roott.jumlah_rumah_new > 0 AND roott.nilai_rumah = 0 
                 THEN 'S6' END,
            CASE WHEN roott.jumlah_rumah_new > 0 
                  AND (roott.nilai_rumah / roott.jumlah_rumah_new) < 1000000 
                 THEN 'S7' END,
            CASE WHEN roott.jumlah_rumah_new > 0 
                  AND (roott.nilai_rumah / roott.jumlah_rumah_new) > 5000000000 
                 THEN 'S8' END
        ),
        'LAINNYA'
    ) AS "KODE_ANOMALI",
    
    roott.no_kk AS "NO_KK",
    roott.jumlah_rumah_new AS "JML_RUMAH_LAIN",
    roott.nilai_rumah AS "NILAI_RUMAH",
    roott.catatan,
    CONCAT(
          '<a href="https://fasih-sm.bps.go.id/app/assignment/fd68e454-ba45-4b85-8205-f3bf777ded24/',
          roott.assignment_id,
          '" target="_blank">Link Assignment</a>'
      ) AS Link
FROM tgr_fd68e454.root_table roott
WHERE (
        roott.jumlah_rumah_new > 9
     OR (roott.jumlah_rumah_new > 0 AND roott.nilai_rumah = 0)
     OR (roott.jumlah_rumah_new > 0 AND (roott.nilai_rumah / roott.jumlah_rumah_new) < 1000000)
     OR (roott.jumlah_rumah_new > 0 AND (roott.nilai_rumah / roott.jumlah_rumah_new) > 5000000000)
  )
ORDER BY
    roott.level_6_full_code,
    roott.nama_kk,
    roott.no_kk
LIMIT 1000 OFFSET 0;

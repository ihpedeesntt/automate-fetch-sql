SELECT
    roott.assignment_id,
    roott.level_6_full_code AS "KODE_SUBSLS",
    roott.nama_kk AS "NAMA_KK",
    
    CONCAT_WS(', ',
        CASE WHEN roott.jumlah_lahan_new > 9 
             THEN 'S1' END,
        CASE WHEN roott.jumlah_lahan_new > 0 AND roott.nilai_lahan = 0 
             THEN 'S2' END,
        CASE WHEN roott.jumlah_lahan_new > 0 
              AND (roott.nilai_lahan / roott.jumlah_lahan_new) < 1000000 
             THEN 'S3' END,
        CASE WHEN roott.jumlah_lahan_new > 0 
              AND (roott.nilai_lahan / roott.jumlah_lahan_new) > 5000000000 
             THEN 'S4' END
    ) AS "KODE_ANOMALI",
    roott.no_kk AS "NO_KK",
    roott.jumlah_lahan_new AS "JML_LAHAN_LAIN",
    roott.nilai_lahan AS "NILAI_LAHAN",
    roott.catatan,
    CONCAT(
          '<a href="https://fasih-sm.bps.go.id/app/assignment/fd68e454-ba45-4b85-8205-f3bf777ded24/',
          roott.assignment_id,
          '" target="_blank">Link Assignment</a>'
      ) AS Link
FROM tgr_fd68e454.root_table roott
WHERE (
        roott.jumlah_lahan_new > 9
     OR (roott.jumlah_lahan_new > 0 AND roott.nilai_lahan = 0)
     OR (roott.jumlah_lahan_new > 0 AND (roott.nilai_lahan / roott.jumlah_lahan_new) < 1000000)
     OR (roott.jumlah_lahan_new > 0 AND (roott.nilai_lahan / roott.jumlah_lahan_new) > 5000000000)
  )
ORDER BY
    roott.level_6_full_code,
    roott.nama_kk,
    roott.no_kk
LIMIT 9000 OFFSET 0;

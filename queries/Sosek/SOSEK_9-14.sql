SELECT
    roott.assignment_id,
    roott.level_6_full_code AS "KODE_SUBSLS",
    roott.nama_kk AS "NAMA_KK",
    

    COALESCE(
        CONCAT_WS(', ',
            CASE WHEN roott.jumlah_mobil_new > 9 
                 THEN 'S9' END,
            CASE WHEN roott.jumlah_mobil_new > 0 
                  AND (roott.nilai_mobil / roott.jumlah_mobil_new) < 10000000 
                 THEN 'S10' END,
            CASE WHEN roott.jumlah_mobil_new > 0 
                  AND (roott.nilai_mobil / roott.jumlah_mobil_new) > 5000000000 
                 THEN 'S11' END,
            CASE WHEN roott.jumlah_motor_new > 9 
                 THEN 'S12' END,
            CASE WHEN roott.jumlah_motor_new > 0 
                  AND (roott.nilai_motor / roott.jumlah_motor_new) < 500000 
                 THEN 'S13' END,
            CASE WHEN roott.jumlah_motor_new > 0 
                  AND (roott.nilai_motor / roott.jumlah_motor_new) > 1000000000 
                 THEN 'S14' END
        ),
        'LAINNYA'
    ) AS "KODE_ANOMALI",
    roott.no_kk AS "NO_KK",
    roott.jml_kk_update AS "JML_AK_PENDATAAN",
    roott.jumlah_mobil_new AS "JML_MOBIL",
    roott.nilai_mobil AS "NILAI_MOBIL",
    roott.jumlah_motor_new AS "JML_MOTOR",
    roott.nilai_motor AS "NILAI_MOTOR",
    roott.catatan,
    CONCAT(
          '<a href="https://fasih-sm.bps.go.id/app/assignment/fd68e454-ba45-4b85-8205-f3bf777ded24/',
          roott.assignment_id,
          '" target="_blank">Link Assignment</a>'
      ) AS Link
FROM tgr_fd68e454.root_table roott
WHERE (
        roott.jumlah_mobil_new > 9
     OR (roott.jumlah_mobil_new > 0 AND (roott.nilai_mobil / roott.jumlah_mobil_new) < 10000000)
     OR (roott.jumlah_mobil_new > 0 AND (roott.nilai_mobil / roott.jumlah_mobil_new) > 5000000000)
     OR roott.jumlah_motor_new > 9
     OR (roott.jumlah_motor_new > 0 AND (roott.nilai_motor / roott.jumlah_motor_new) < 500000)
     OR (roott.jumlah_motor_new > 0 AND (roott.nilai_motor / roott.jumlah_motor_new) > 1000000000)
  )
ORDER BY
    roott.level_6_full_code,
    roott.nama_kk,
    roott.no_kk
LIMIT 1000 OFFSET 0;

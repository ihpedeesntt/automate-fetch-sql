SELECT
    roott.assignment_id,
    roott.level_6_full_code AS "KODE_SUBSLS",
    roott.nama_kk AS "NAMA_KK",
    

    COALESCE(
        CONCAT_WS(', ',
            CASE WHEN roott.jml_ak_tinggal IS NOT NULL AND roott.jml_ak_tinggal > 0
                      AND (roott.pengeluaran_non_makan_tahunan / roott.jml_ak_tinggal) > 1000000000
                 THEN 'S21' END,
            CASE WHEN roott.jml_ak_tinggal IS NOT NULL AND roott.jml_ak_tinggal > 0
                      AND (roott.pengeluaran_non_makan_bulanan / roott.jml_ak_tinggal) > 50000000
                 THEN 'S22' END,
            CASE WHEN roott.jml_ak_tinggal IS NOT NULL AND roott.jml_ak_tinggal > 0
                      AND (roott.pengeluaran_makanan_mingguan / roott.jml_ak_tinggal) > 5000000
                 THEN 'S23' END,
            CASE WHEN roott.jml_ak_tinggal = 1
                      AND (
                          (
                              (roott.pengeluaran_makanan_mingguan * 30/7) 
                              + roott.pengeluaran_non_makan_bulanan 
                              + (roott.pengeluaran_non_makan_tahunan / 12)
                          ) / roott.jml_ak_tinggal < 50000
                          OR (
                              (roott.pengeluaran_makanan_mingguan * 30/7) 
                              + roott.pengeluaran_non_makan_bulanan 
                              + (roott.pengeluaran_non_makan_tahunan / 12)
                          ) / roott.jml_ak_tinggal > 100000000
                      )
                 THEN 'S24' END,
            CASE WHEN roott.jml_ak_tinggal = 1 
                      AND roott.pengeluaran_makanan_mingguan = 0 
                      AND roott.pengeluaran_non_makan_bulanan = 0 
                      AND roott.pengeluaran_non_makan_tahunan = 0
                 THEN 'S25' END
        ),
        'LAINNYA'
    ) AS "KODE_ANOMALI",
    roott.no_kk AS "NO_KK",
    roott.pengeluaran_non_makan_tahunan,
    roott.pengeluaran_non_makan_bulanan,
    roott.pengeluaran_makanan_mingguan,
    roott.jml_kk_update AS "JML_AK_PENDATAAN",
    roott.jml_ak_tinggal AS "JML_KELUARGA",
    roott.catatan,
    CONCAT(
          '<a href="https://fasih-sm.bps.go.id/app/assignment/fd68e454-ba45-4b85-8205-f3bf777ded24/',
          roott.assignment_id,
          '" target="_blank">Link Assignment</a>'
      ) AS Link
FROM tgr_fd68e454.root_table roott
WHERE (
        (roott.jml_ak_tinggal IS NOT NULL AND roott.jml_ak_tinggal > 0
         AND (roott.pengeluaran_non_makan_tahunan / roott.jml_ak_tinggal) > 1000000000)
     OR (roott.jml_ak_tinggal IS NOT NULL AND roott.jml_ak_tinggal > 0
         AND (roott.pengeluaran_non_makan_bulanan / roott.jml_ak_tinggal) > 50000000)
     OR (roott.jml_ak_tinggal IS NOT NULL AND roott.jml_ak_tinggal > 0
         AND (roott.pengeluaran_makanan_mingguan / roott.jml_ak_tinggal) > 5000000)
     OR (roott.jml_ak_tinggal = 1
         AND (
             ((roott.pengeluaran_makanan_mingguan * 30/7) 
              + roott.pengeluaran_non_makan_bulanan 
              + (roott.pengeluaran_non_makan_tahunan / 12)
             ) / roott.jml_ak_tinggal < 50000
             OR
             ((roott.pengeluaran_makanan_mingguan * 30/7) 
              + roott.pengeluaran_non_makan_bulanan 
              + (roott.pengeluaran_non_makan_tahunan / 12)
             ) / roott.jml_ak_tinggal > 100000000
         )
     )
     OR (roott.jml_ak_tinggal = 1 
         AND roott.pengeluaran_makanan_mingguan = 0 
         AND roott.pengeluaran_non_makan_bulanan = 0 
         AND roott.pengeluaran_non_makan_tahunan = 0)
  )
ORDER BY
    roott.level_6_full_code,
    roott.nama_kk,
    roott.no_kk
LIMIT 9000 OFFSET 0
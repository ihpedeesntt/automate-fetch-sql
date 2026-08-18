SELECT
    roott.assignment_id,
    roott.level_6_full_code AS "KODE_SUBSLS",
    roott.nama_kk AS "NAMA_KK",
    
    COALESCE(
        CONCAT_WS(', ',
            CASE WHEN roott.jns_lantai_value = 1 AND roott.jns_dinding_value <> 1
                 THEN 'S32' END,
            CASE WHEN roott.jns_lantai_value IN (5, 7) AND roott.jns_dinding_value = 1
                 THEN 'S33' END,
            CASE WHEN roott.jns_dinding_value = 7 AND roott.jns_atap_value = 2
                 THEN 'S34' END,
            CASE WHEN roott.jns_dinding_value <> 1 AND roott.jns_atap_value = 1
                 THEN 'S35' END,
            CASE WHEN roott.jns_dinding_value = 1 AND roott.jns_atap_value IN (7, 8)
                 THEN 'S36' END,
            CASE WHEN roott.jns_lantai_value IN (5, 7, 8, 9) AND roott.jns_atap_value = 1
                 THEN 'S37' END,
            CASE WHEN roott.status_kepemilikan_value = 5
                 THEN 'S38' END,
            CASE WHEN roott.jns_bangunan_value IN (4, 5)
                 THEN 'S39' END
        ),
        'LAINNYA'
    ) AS "KODE_ANOMALI",
    roott.no_kk AS "NO_KK",
    roott.jml_kk_update AS "JML_AK_PENDATAAN",
    roott.jns_lantai_value,
    roott.jns_dinding_value,
    roott.jns_atap_value,
    status_kepemilikan_value,
    status_kepemilikan_lain,
    jns_bangunan_value,
    jns_bangunan_lain,

    roott.catatan,
    CONCAT(
          '<a href="https://fasih-sm.bps.go.id/app/assignment/fd68e454-ba45-4b85-8205-f3bf777ded24/',
          roott.assignment_id,
          '" target="_blank">Link Assignment</a>'
      ) AS Link
FROM tgr_fd68e454.root_table roott
WHERE (
        (roott.jns_lantai_value = 1 AND roott.jns_dinding_value <> 1)
     OR (roott.jns_lantai_value IN (5, 7) AND roott.jns_dinding_value = 1)
     OR (roott.jns_dinding_value = 7 AND roott.jns_atap_value = 2)
     OR (roott.jns_dinding_value <> 1 AND roott.jns_atap_value = 1)
     OR (roott.jns_dinding_value = 1 AND roott.jns_atap_value IN (7, 8))
     OR (roott.jns_lantai_value IN (5, 7, 8, 9) AND roott.jns_atap_value = 1)
     OR (roott.status_kepemilikan_value = 5)
     OR (roott.jns_bangunan_value IN (4, 5))
  )
ORDER BY
    roott.level_6_full_code,
    roott.nama_kk,
    roott.no_kk
LIMIT 9000 OFFSET 0
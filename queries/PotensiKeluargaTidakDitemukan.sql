WITH aktif AS (
    SELECT
        assignment_id,
        assignment_date_modified,
        survey_period_id,
        data1,
        code_identity
    FROM tgr_fd68e454.base_table_assignment
    WHERE is_active = 1
      AND assignment_status_id > 0
),

tdk_ditemukan AS (
    SELECT
        root.level_2_full_code,
        root.level_2_name,
        root.level_3_code,
        root.level_3_name,
        root.level_4_code,
        root.level_4_name,
        root.level_6_full_code,
        root.level_6_name,
        COALESCE(root.nama_kk, a.data1) AS nama_kk,
        COALESCE(root.nik_kk, root.nik) AS nik,
        root.alamat_prelist,
        root.catatan,
        root.assignment_id,
        root.assignment_status_alias,
        a.code_identity,
        a.survey_period_id,
        root.ada_keluarga_label,
        CONCAT(
            'https://fasih-sm.bps.go.id/app/assignment-detail/',
            root.assignment_id
        ) AS LINK_FASIH_TDK_DITEMUKAN
    FROM tgr_fd68e454.root_table root
    INNER JOIN aktif a
        ON a.assignment_id = root.assignment_id
       AND a.assignment_date_modified = root.assignment_date_modified
    WHERE IFNULL(root.jenis_prelist, '') <> 'dummy'
      AND (
          root.jenis_prelist = 'keluarga'
          OR root.ada_keluarga_value IS NOT NULL
          OR root.ada_keluarga_label IS NOT NULL
      )
      AND (
          root.ada_keluarga_label LIKE '%Tidak Ditemukan%'
          OR root.ada_keluarga_value = '0'
      )
      AND NOT (
          TRIM(COALESCE(root.nik_prelist, root.nik)) LIKE '%9999%'
          OR TRIM(COALESCE(root.nik_prelist, root.nik)) LIKE '%7777%'
      )
),

ditemukan AS (
    SELECT
        root.level_2_full_code,
        root.level_2_name,
        root.level_3_code,
        root.level_3_name,
        root.level_4_code,
        root.level_4_name,
        root.level_6_full_code,
        root.level_6_name,
        COALESCE(art.nama_dtsen, art.nama_dtsen_edit) AS nama_art,
        COALESCE(art.nik_dtsen, art.nik_dtsen_prelist) AS nik,
        art.hubungan_label,
        root.catatan,
        root.assignment_id,
        root.assignment_status_alias,
        a.code_identity,
        a.survey_period_id,
        root.ada_keluarga_label,
        CONCAT(
            'https://fasih-sm.bps.go.id/app/assignment-detail/',
            root.assignment_id
        ) AS LINK_FASIH_DITEMUKAN
    FROM tgr_fd68e454.root_table root
    INNER JOIN aktif a
        ON a.assignment_id = root.assignment_id
       AND a.assignment_date_modified = root.assignment_date_modified
    INNER JOIN tgr_fd68e454.nested_dtsen art
        ON root.assignment_id = art.assignment_id
    WHERE IFNULL(root.jenis_prelist, '') <> 'dummy'
      AND (
          root.jenis_prelist = 'keluarga'
          OR root.ada_keluarga_value IS NOT NULL
          OR root.ada_keluarga_label IS NOT NULL
      )
      AND (
          root.ada_keluarga_label NOT LIKE '%Tidak Ditemukan%'
          AND root.ada_keluarga_value NOT IN ('00', '0')
      )
      AND LENGTH(
          TRIM(COALESCE(art.nik_dtsen, art.nik_dtsen_prelist))
      ) = 16
      AND NOT (
          TRIM(COALESCE(root.nik_prelist, root.nik)) LIKE '%9999%'
          OR TRIM(COALESCE(root.nik_prelist, root.nik)) LIKE '%7777%'
          OR TRIM(COALESCE(art.nik_dtsen, art.nik_dtsen_prelist)) LIKE '%9999%'
          OR TRIM(COALESCE(art.nik_dtsen, art.nik_dtsen_prelist)) LIKE '%7777%'
      )
)

SELECT
    tdk.level_2_full_code AS "KODE KAB TDK DITEMUKAN",
    tdk.level_2_name AS "KAB TDK DITEMUKAN",

    tdk.level_3_code AS "KODE KEC TDK DITEMUKAN",
    tdk.level_3_name AS "KEC TDK DITEMUKAN",

    tdk.level_4_code AS "KODE DESA TDK DITEMUKAN",
    tdk.level_4_name AS "DESA TDK DITEMUKAN",

    tdk.level_6_full_code AS "KODE SLS TDK DITEMUKAN",

    tdk.nama_kk AS "NAMA KK TDK DITEMUKAN",
    tdk.nik AS "NIK KK TDK DITEMUKAN",
    tdk.alamat_prelist AS "ALAMAT KK TDK DITEMUKAN",
    tdk.ada_keluarga_label AS "STATUS KK TDK DITEMUKAN",

    d.nama_art AS "NAMA ART DITEMUKAN",
    d.nik AS "NIK ART",
    d.hubungan_label,

    d.level_2_full_code AS "KODE KAB DITEMUKAN",
    d.level_2_name AS "KAB DITEMUKAN",

    d.level_3_code AS "KODE KEC DITEMUKAN",
    d.level_3_name AS "KEC DITEMUKAN",

    d.level_4_code AS "KODE DESA DITEMUKAN",
    d.level_4_name AS "DESA DITEMUKAN",

    d.level_6_full_code AS "KODE SLS DITEMUKAN",
    d.ada_keluarga_label AS "STATUS KK DITEMUKAN",

    CASE
        WHEN d.level_2_full_code <> tdk.level_2_full_code
            THEN 'BEDA KABUPATEN'
        WHEN d.level_3_code <> tdk.level_3_code
            THEN 'BEDA KECAMATAN'
        WHEN d.level_4_code <> tdk.level_4_code
            THEN 'BEDA DESA'
        WHEN d.level_6_full_code <> tdk.level_6_full_code
            THEN 'BEDA SLS'
        ELSE 'SAMA SLS'
    END AS lokasi_kk_baru,

    tdk.LINK_FASIH_TDK_DITEMUKAN,
    d.LINK_FASIH_DITEMUKAN

FROM tdk_ditemukan tdk

INNER JOIN ditemukan d
    ON tdk.nik = d.nik

ORDER BY tdk.level_6_full_code
LIMIT 0, 9000;

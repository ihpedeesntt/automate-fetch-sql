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
      AND LENGTH(TRIM(COALESCE(root.nik_prelist, root.nik_kk, root.nik))) = 16
      AND TRIM(COALESCE(root.nik_prelist, root.nik_kk, root.nik)) NOT LIKE '%9999%'
      AND TRIM(COALESCE(root.nik_prelist, root.nik_kk, root.nik)) NOT LIKE '%7777%'
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
        COALESCE(root.nama_kk, a.data1) AS nama_kk,
        COALESCE(root.nik_prelist, root.nik_kk, root.nik) AS nik,
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
        ) AS LINK_FASIH_DITEMUKAN
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
          root.ada_keluarga_label NOT LIKE '%Tidak Ditemukan%'
          AND root.ada_keluarga_value NOT IN ('00', '0')
      )
      AND LENGTH(TRIM(COALESCE(root.nik_prelist, root.nik_kk, root.nik))) = 16
      AND TRIM(COALESCE(root.nik_prelist, root.nik_kk, root.nik)) NOT LIKE '%9999%'
      AND TRIM(COALESCE(root.nik_prelist, root.nik_kk, root.nik)) NOT LIKE '%7777%'
)

SELECT
    tdk.level_2_full_code AS "KODE KAB TDK DITEMUKAN",
    tdk.level_2_name AS "KAB TDK DITEMUKAN",

    tdk.level_3_code AS "KODE KEC TDK DITEMUKAN",
    tdk.level_3_name AS "KEC TDK DITEMUKAN",

    tdk.level_4_code AS "KODE DESA TDK DITEMUKAN",
    tdk.level_4_name AS "DESA TDK DITEMUKAN",

    tdk.level_6_full_code AS "KODE SLS TDK DITEMUKAN",
    tdk.level_6_name AS "SLS TDK DITEMUKAN",

    tdk.nama_kk AS "NAMA KK TDK DITEMUKAN",
    tdk.nik AS "NIK KK TDK DITEMUKAN",
    tdk.alamat_prelist AS "ALAMAT KK TDK DITEMUKAN",
    tdk.ada_keluarga_label AS "STATUS KK TDK DITEMUKAN",
    tdk.catatan AS "CATATAN KK TDK DITEMUKAN",

    tdk.assignment_id,
    tdk.assignment_status_alias,
    tdk.code_identity,
    tdk.survey_period_id,

    tdk.LINK_FASIH_TDK_DITEMUKAN

FROM tdk_ditemukan tdk

WHERE NOT EXISTS (
    SELECT 1
    FROM ditemukan d
    WHERE TRIM(d.nik) = TRIM(tdk.nik)
)

ORDER BY tdk.level_6_full_code
LIMIT 0,9000;

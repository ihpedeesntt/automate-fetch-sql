-- Keterangan lengkap daftar anomali dapat dilihat di sini : http://s.bps.go.id/anomali_sakernas_ags26

WITH 

anomali_1 AS (
 SELECT 
	root.assignment_id,
	root.nks,
        root.no_dsrt,
        art.ppno,
        art.dem_name,
	',I1' AS anomali
FROM tok_3fd42e0e.art_roster art
         LEFT JOIN tok_3fd42e0e.root_table root
                   ON root.assignment_id = art.assignment_id
         LEFT JOIN tok_3fd42e0e.base_table_assignment base
                   ON base.id = art.assignment_id

WHERE base.is_active = 1
  AND dem_age >= 5
  AND mjjemprel1_value IS NOT NULL
  AND mjj_kbji_value IS NOT NULL
  AND mjj_kbli_value IS NOT NULL
  AND mju_ins_value IS NOT NULL
  AND (mjj_kbji_value 
        >= 0111 AND mjj_kbji_value 
        <= 0315) 
  AND (
        (mjj_kbli_value < 84221 OR mjj_kbli_value > 84232) 
        OR mjjemprel1_value <> 1 
        OR mju_ins_value <> 1
      )
),

anomali_2 AS (
 SELECT 
	root.assignment_id,
	root.nks,
        root.no_dsrt,
        art.ppno,
        art.dem_name,
	',I2' AS anomali
FROM tok_3fd42e0e.art_roster art
         LEFT JOIN tok_3fd42e0e.root_table root
                   ON root.assignment_id = art.assignment_id
         LEFT JOIN tok_3fd42e0e.base_table_assignment base
                   ON base.id = art.assignment_id

WHERE base.is_active = 1
  AND dem_age >= 5
  AND sjjemprel1_value IS NOT NULL
  AND sjj_kbli_value IS NOT NULL 
  AND sjj_kbji_value IS NOT NULL
  AND (sjj_kbji_value >= 0111 AND sjj_kbji_value <= 0315) 
  AND ((sjj_kbli_value < 84221 OR sjj_kbli_value > 84232) 
          OR sjjemprel1_value <> 1
      ) 
),

anomali_3 AS (
 SELECT 
	root.assignment_id,
	root.nks,
        root.no_dsrt,
        art.ppno,
        art.dem_name,
	',I3' AS anomali
FROM tok_3fd42e0e.art_roster art
         LEFT JOIN tok_3fd42e0e.root_table root
                   ON root.assignment_id = art.assignment_id
         LEFT JOIN tok_3fd42e0e.base_table_assignment base
                   ON base.id = art.assignment_id

WHERE base.is_active = 1
  AND dem_age >= 5
  AND mpk_status_value IS NOT NULL
  AND mpk_kbli_value IS NOT NULL
  AND mpk_kbji_value IS NOT NULL
  AND (mpk_kbji_value >= 0111 AND mpk_kbji_value <= 0315) 
  AND ((mpk_kbli_value < 84221 OR mpk_kbli_value > 84232) 
        OR mpk_status_value <> 4
      )
)


,
paged_result AS (
SELECT art.level_1_full_code,
       art.level_1_name                                                                    AS PROV,
       art.level_2_full_code,
       art.level_2_name                                                                    AS KAB,
       art.level_3_name                                                                    AS KEC,
       art.level_4_name                                                                    AS DESA,
       art.level_5_name                                                                    AS SLS,
       art.level_6_name                                                                    AS SUBSLS,
       root.nks                                                                            AS NKS,
       root.no_dsrt                                                                        AS DSRT,
       art.ppno                                                                            AS NO_ART,
       art.dem_name                                                                        AS NAMA_ART,
       dem_age,
       CONCAT('MJJEmprel1_Value: ',mjjemprel1_value,'; MJU_ins: ',mju_ins_value)           AS MJJEMPREL1_MJU_INS,
       CONCAT('MJJ_KBJI: ',mjj_kbji_value,'; MJJ_KBLI: ',mjj_kbli_value)                   AS MJJ_KBJI_KBLI,
       sjjemprel1_value,
       CONCAT('SJJ_KBJI: ',sjj_kbji_value,'; SJJ_KBLI: ',sjj_kbli_value)                   AS SJJ_KBJI_KBLI,
       mpk_status_value,
       CONCAT('MPK_KBJI: ',mpk_kbji_value,'; MPK_KBLI: ',mpk_kbli_value)                   AS MPK_KBJI_KBLI,
       CONCAT('PML: ',p.PML,'; PPL: ',p.PPL,'; Status: ',base.assignment_status_alias)     AS petugas,
       LTRIM(
		STUFF(
			CONCAT(
			a1.anomali, a2.anomali, a3.anomali
		)
		,1,1,'')
		) AS anomali,
      root.catatan,
      CONCAT('<a href="https://fasih-sm.bps.go.id/app/assignment-detail/',
              art.assignment_id
           ,'" target="_blank">Link Assignment</a>') AS Link,
      root.survey_period_id
      

FROM tok_3fd42e0e.art_roster art
         LEFT JOIN tok_3fd42e0e.root_table root
                   ON root.assignment_id = art.assignment_id
	LEFT JOIN anomali_1 as a1
                   ON a1.assignment_id = root.assignment_id AND 
			  a1.nks = root.nks AND 
        		  a1.no_dsrt = root.no_dsrt AND 
        		  a1.ppno = art.ppno AND
        		  a1.dem_name = art.dem_name
	LEFT JOIN anomali_2 as a2
                   ON a2.assignment_id = root.assignment_id AND 
			  a2.nks = root.nks AND 
        		  a2.no_dsrt = root.no_dsrt AND 
        		  a2.ppno = art.ppno AND
        		  a2.dem_name = art.dem_name
	LEFT JOIN anomali_3 as a3
                   ON a3.assignment_id = root.assignment_id AND 
			  a3.nks = root.nks AND 
        		  a3.no_dsrt = root.no_dsrt AND 
        		  a3.ppno = art.ppno AND
        		  a3.dem_name = art.dem_name
  LEFT JOIN tok_3fd42e0e.petugas as p
              ON p.assignment_id = root.assignment_id 
  LEFT JOIN tok_3fd42e0e.base_table_assignment base
                   ON base.id = art.assignment_id

WHERE base.is_active = 1 AND (base.assignment_status_alias <> 'DRAFT' AND base.assignment_status_alias <> 'OPEN')
  AND (a1.anomali IS NOT NULL OR
		a2.anomali IS NOT NULL OR
		a3.anomali IS NOT NULL
	)

ORDER BY
    art.assignment_id,
    art.ppno,
    art.dem_name
OFFSET 0 ROWS FETCH NEXT 9000 ROWS ONLY

)
SELECT
    CAST(GETDATE() AS date) AS tanggal_update,
    paged_result.level_1_full_code,
    paged_result.PROV,
    paged_result.level_2_full_code,
    paged_result.KAB,
    paged_result.KEC,
    paged_result.DESA,
    paged_result.SLS,
    paged_result.SUBSLS,
    paged_result.NKS,
    paged_result.DSRT,
    paged_result.NO_ART,
    paged_result.NAMA_ART,
    paged_result.petugas,
    paged_result.anomali,
    paged_result.catatan,
    paged_result.Link
FROM paged_result

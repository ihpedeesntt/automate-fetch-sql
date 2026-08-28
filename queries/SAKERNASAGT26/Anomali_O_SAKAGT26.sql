-- Keterangan lengkap daftar anomali dapat dilihat di sini : http://s.bps.go.id/anomali_sakernas_ags26

WITH 

anomali_1 AS (
 SELECT 
	root.assignment_id,
	root.nks,
        root.no_dsrt,
        art.ppno,
        art.dem_name,
	',O1' AS anomali
FROM tok_3fd42e0e.art_roster art
         LEFT JOIN tok_3fd42e0e.root_table root
                   ON root.assignment_id = art.assignment_id
         LEFT JOIN tok_3fd42e0e.base_table_assignment base
                   ON base.id = art.assignment_id

WHERE base.is_active = 1
  AND dem_age >= 5
  AND mjj_kbji_value IS NOT NULL
  AND mjj_kbli_value IS NOT NULL
  AND mjjemprel1_value IS NOT NULL
  AND mjj_emprel_value IS NOT NULL
  AND mju_ins_value IS NOT NULL
  AND (mjj_kbji_value 
      = 1111 OR mjj_kbji_value 
      = 1112 OR mjj_kbji_value 
      = 2612 OR mjj_kbji_value 
      = 3351 OR mjj_kbji_value 
      = 3352 OR mjj_kbji_value 
      = 3353 OR mjj_kbji_value 
      = 3354 OR mjj_kbji_value 
      = 3359 OR mjj_kbji_value 
      = 5411 OR mjj_kbji_value 
      = 5413) 
  AND ((mjj_kbli_value 
        < 84111 OR mjj_kbli_value 
        > 84300) OR mjjemprel1_value 
        = 2 OR mjj_emprel_value 
        = 2 OR mjj_emprel_value 
        = 3 OR mjj_emprel_value 
        = 5 OR mju_ins_value 
        <>1)
      
),

anomali_2 AS (
 SELECT 
	root.assignment_id,
	root.nks,
        root.no_dsrt,
        art.ppno,
        art.dem_name,
	',O2' AS anomali
FROM tok_3fd42e0e.art_roster art
         LEFT JOIN tok_3fd42e0e.root_table root
                   ON root.assignment_id = art.assignment_id
         LEFT JOIN tok_3fd42e0e.base_table_assignment base
                   ON base.id = art.assignment_id

WHERE base.is_active = 1
  AND dem_age >= 5
  AND sjj_kbli_value IS NOT NULL
  AND sjj_kbji_value IS NOT NULL
  AND sjjemprel1_value IS NOT NULL
  AND sjj_emprel_value IS NOT NULL
  AND (sjj_kbji_value 
      = 1111 OR sjj_kbji_value 
      = 1112 OR sjj_kbji_value 
      = 2612 OR sjj_kbji_value 
      = 3351 OR sjj_kbji_value 
      = 3352 OR sjj_kbji_value 
      = 3353 OR sjj_kbji_value 
      = 3354 OR sjj_kbji_value 
      = 3359 OR sjj_kbji_value 
      = 5411 OR sjj_kbji_value 
      = 5413) 
  AND ((sjj_kbli_value 
        < 84111 OR sjj_kbli_value 
        > 84300) OR sjjemprel1_value 
        = 2 OR sjj_emprel_value 
        = 2 OR sjj_emprel_value 
        = 3 OR sjj_emprel_value
        = 5)
),

anomali_3 AS (
 SELECT 
	root.assignment_id,
	root.nks,
        root.no_dsrt,
        art.ppno,
        art.dem_name,
	',O3' AS anomali
FROM tok_3fd42e0e.art_roster art
         LEFT JOIN tok_3fd42e0e.root_table root
                   ON root.assignment_id = art.assignment_id
         LEFT JOIN tok_3fd42e0e.base_table_assignment base
                   ON base.id = art.assignment_id

WHERE base.is_active = 1
  AND dem_age >= 5
  AND mpk_kbli_value IS NOT NULL
  AND mpk_kbji_value IS NOT NULL
  AND mpk_status_value IS NOT NULL
  AND (mpk_kbji_value 
      = 1111 OR mpk_kbji_value 
      = 1112 OR mpk_kbji_value 
      = 2612 OR mpk_kbji_value 
      = 3351 OR mpk_kbji_value 
      = 3352 OR mpk_kbji_value 
      = 3353 OR mpk_kbji_value 
      = 3354 OR mpk_kbji_value 
      = 3359 OR mpk_kbji_value 
      = 5411 OR mpk_kbji_value 
      = 5413
      ) 
  AND ((mpk_kbli_value 
        < 84111 OR mpk_kbli_value 
        > 84300) OR mpk_status_value 
        = 1 OR mpk_status_value 
        = 2 OR mpk_status_value 
        = 3 OR mpk_status_value 
        = 5 OR mpk_status_value 
        = 6 OR mpk_status_value 
        = 7 OR mpk_status_value 
        = 9)
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
       CONCAT('MJJ_KBLI: ',mjj_kbli_value,
              '; MJJ_KBJI: ',mjj_kbji_value,
              '; MJJ_EMPREL1: ',mjjemprel1_value,
              '; MJJ_EMPREL: ',mjj_emprel_value,
              '; MJU_INS: ',mju_ins_value)                                                 AS MJJ_MJU,
       CONCAT('SJJ_KBLI: ',sjj_kbli_value,
              '; SJJ_KBJI: ',sjj_kbji_value,
              '; SJJ_EMPREL1: ',sjjemprel1_value,
              '; SJJ_EMPREL: ',sjj_emprel_value)                                           AS SJJ,
       mpk_kbli_value,
       mpk_kbji_value,
       mpk_status_value,
       CONCAT('PML: ',p.PML,'; PPL: ',p.PPL,'; Status: ',base.assignment_status_alias) AS petugas,
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

-- Keterangan lengkap daftar anomali dapat dilihat di sini : http://s.bps.go.id/anomali_sakernas_ags26

WITH 

anomali_1 AS (
 SELECT 
	root.assignment_id,
	root.nks,
        root.no_dsrt,
        art.ppno,
        art.dem_name,
	',A1' AS anomali
FROM tok_3fd42e0e.art_roster art
         LEFT JOIN tok_3fd42e0e.root_table root
                   ON root.assignment_id = art.assignment_id
         LEFT JOIN tok_3fd42e0e.base_table_assignment base
                   ON base.id = art.assignment_id

WHERE base.is_active = 1
  AND dem_age >= 5
  AND mjj_kbli_value IS NOT NULL
  AND (mjj_kbli_value
        = 59111 OR mjj_kbli_value
        = 59121 OR mjj_kbli_value
        = 59131 OR mjj_kbli_value
        = 60311 OR (mjj_kbli_value
                    >= 84111 AND mjj_kbli_value
                    <= 84300) OR mjj_kbli_value
	      = 85101 OR mjj_kbli_value 
	      = 85201 OR mjj_kbli_value
	      = 85311 OR mjj_kbli_value
	      = 85315 OR mjj_kbli_value
	      = 85321 OR mjj_kbli_value
	      = 85401 OR mjj_kbli_value
	      = 85403 OR mjj_kbli_value
	      = 85550 OR mjj_kbli_value
	      = 85560 OR mjj_kbli_value
	      = 86101 OR mjj_kbli_value
	      = 86102 OR mjj_kbli_value
	      = 86104 OR mjj_kbli_value
	      = 87101 OR mjj_kbli_value
	      = 87201 OR mjj_kbli_value
	      = 87301 OR mjj_kbli_value
	      = 88101 OR mjj_kbli_value
	      = 88901 OR mjj_kbli_value
	      = 91111 OR mjj_kbli_value
	      = 91121 OR mjj_kbli_value
	      = 91211 OR mjj_kbli_value
	      = 91221 )
  AND mjj_emprel_value IS NOT NULL
  AND mju_ins_value IS NOT NULL
  AND (mjj_emprel_value
           = 2 OR mjj_emprel_value
           = 3 OR mju_ins_value
           <> 1)
),

anomali_2 AS (
 SELECT 
	root.assignment_id,
	root.nks,
        root.no_dsrt,
        art.ppno,
        art.dem_name,
	',A2' AS anomali
FROM tok_3fd42e0e.art_roster art
         LEFT JOIN tok_3fd42e0e.root_table root
                   ON root.assignment_id = art.assignment_id
         LEFT JOIN tok_3fd42e0e.base_table_assignment base
                   ON base.id = art.assignment_id

WHERE base.is_active = 1
  AND dem_age >= 5
  AND sjj_kbli_value IS NOT NULL
  AND (sjj_kbli_value
		= 59111 OR sjj_kbli_value 
		= 59121 OR sjj_kbli_value
		= 59131 OR sjj_kbli_value
		= 60311 OR (sjj_kbli_value
				>= 84111 AND sjj_kbli_value
				<= 84300) OR sjj_kbli_value
		= 85101 OR sjj_kbli_value
		= 85201 OR sjj_kbli_value
		= 85311 OR sjj_kbli_value
		= 85315 OR sjj_kbli_value
		= 85321 OR sjj_kbli_value
		= 85401 OR sjj_kbli_value
		= 85403 OR sjj_kbli_value
		= 85550 OR sjj_kbli_value
		= 85560 OR sjj_kbli_value
		= 86101 OR sjj_kbli_value
		= 86102 OR sjj_kbli_value
		= 86104 OR sjj_kbli_value
		= 87101 OR sjj_kbli_value
		= 87201 OR sjj_kbli_value
		= 87301 OR sjj_kbli_value
		= 88101 OR sjj_kbli_value
		= 88901 OR sjj_kbli_value
		= 91111 OR sjj_kbli_value
		= 91121 OR sjj_kbli_value
		= 91211 OR sjj_kbli_value
		= 91221) 
AND sjj_emprel_value IS NOT NULL
AND (sjj_emprel_value
           = 2 OR sjj_emprel_value
           = 3)
),

anomali_3 AS (
 SELECT 
	root.assignment_id,
	root.nks,
        root.no_dsrt,
        art.ppno,
        art.dem_name,
	',A3' AS anomali
FROM tok_3fd42e0e.art_roster art
         LEFT JOIN tok_3fd42e0e.root_table root
                   ON root.assignment_id = art.assignment_id
         LEFT JOIN tok_3fd42e0e.base_table_assignment base
                   ON base.id = art.assignment_id

WHERE base.is_active = 1
  AND dem_age >= 5
  AND mpk_kbli_value IS NOT NULL
  AND (mpk_kbli_value
		= 59111 OR mpk_kbli_value
		= 59121 OR mpk_kbli_value
		= 59131 OR mpk_kbli_value
		= 60311 OR (mpk_kbli_value
					>=84111 AND mpk_kbli_value
					<=84300) OR mpk_kbli_value
		= 85101 OR mpk_kbli_value
		= 85201 OR mpk_kbli_value
		= 85311 OR mpk_kbli_value
		= 85315 OR mpk_kbli_value
		= 85321 OR mpk_kbli_value
		= 85401 OR mpk_kbli_value
		= 85403 OR mpk_kbli_value
		= 85550 OR mpk_kbli_value
		= 85560 OR mpk_kbli_value
		= 86101 OR mpk_kbli_value
		= 86102 OR mpk_kbli_value
		= 86104 OR mpk_kbli_value
		= 87101 OR mpk_kbli_value
		= 87201 OR mpk_kbli_value
		= 87301 OR mpk_kbli_value
		= 88101 OR mpk_kbli_value
		= 88901 OR mpk_kbli_value
		= 91111 OR mpk_kbli_value
		= 91121 OR mpk_kbli_value
		= 91211 OR mpk_kbli_value
		= 91221)
AND mpk_status_value IS NOT NULL
AND (mpk_status_value
		= 1 OR mpk_status_value
		= 2 OR mpk_status_value
		= 3 OR mpk_status_value
		= 7)
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
       mjj_kbli_value,
       mjj_emprel_value,
       mju_ins_value,
       sjj_kbli_value,
       sjj_emprel_value,
       mpk_kbli_value,
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

WITH 

anomali_1 AS (
 SELECT 
	root.assignment_id,
	root.nks,
        root.no_dsrt,
        art.ppno,
        art.dem_name,
	',B1' AS anomali
FROM tok_3fd42e0e.art_roster art
         LEFT JOIN tok_3fd42e0e.root_table root
                   ON root.assignment_id = art.assignment_id
         LEFT JOIN tok_3fd42e0e.base_table_assignment base
                   ON base.id = art.assignment_id

WHERE base.is_active = 1
  AND dem_age >= 5
  AND mjj_kbji_value IS NOT NULL
  AND (mjj_kbji_value
    = 1111 OR mjj_kbji_value
    = 1112 OR mjj_kbji_value
    = 2141 OR mjj_kbji_value
    = 2142 OR mjj_kbji_value
    = 2143 OR mjj_kbji_value
    = 2144 OR mjj_kbji_value
    = 2145 OR mjj_kbji_value
    = 2146 OR mjj_kbji_value
    = 2149 OR mjj_kbji_value
    = 2151 OR mjj_kbji_value
    = 2152 OR mjj_kbji_value
    = 2153 OR mjj_kbji_value
    = 2161 OR mjj_kbji_value
    = 2162 OR mjj_kbji_value
    = 2163 OR mjj_kbji_value
    = 2211 OR mjj_kbji_value
    = 2212 OR mjj_kbji_value
    = 2250 OR mjj_kbji_value
    = 2261 OR mjj_kbji_value
    = 2262 OR mjj_kbji_value
    = 2263 OR mjj_kbji_value
    = 2264 OR mjj_kbji_value
    = 2265 OR mjj_kbji_value
    = 2266 OR mjj_kbji_value
    = 2267 OR mjj_kbji_value
    = 2310 OR mjj_kbji_value
    = 2330 OR mjj_kbji_value
    = 2411 OR mjj_kbji_value
    = 2611 OR mjj_kbji_value
    = 2612 OR mjj_kbji_value
    = 2619 OR mjj_kbji_value
    = 2631 OR mjj_kbji_value
    = 2632 OR mjj_kbji_value
    = 2634)
  AND dem_edl_value IS NOT NULL
  AND dem_edl_value < 8
),

anomali_2 AS (
 SELECT 
	root.assignment_id,
	root.nks,
        root.no_dsrt,
        art.ppno,
        art.dem_name,
	',B2' AS anomali
FROM tok_3fd42e0e.art_roster art
         LEFT JOIN tok_3fd42e0e.root_table root
                   ON root.assignment_id = art.assignment_id
         LEFT JOIN tok_3fd42e0e.base_table_assignment base
                   ON base.id = art.assignment_id

WHERE base.is_active = 1
  AND dem_age >= 5
  AND sjj_kbji_value IS NOT NULL
  AND (sjj_kbji_value
    = 1111 OR sjj_kbji_value
    = 1112 OR sjj_kbji_value
    = 2141 OR sjj_kbji_value
    = 2142 OR sjj_kbji_value
    = 2143 OR sjj_kbji_value
    = 2144 OR sjj_kbji_value
    = 2145 OR sjj_kbji_value
    = 2146 OR sjj_kbji_value
    = 2149 OR sjj_kbji_value
    = 2151 OR sjj_kbji_value
    = 2152 OR sjj_kbji_value
    = 2153 OR sjj_kbji_value
    = 2161 OR sjj_kbji_value
    = 2162 OR sjj_kbji_value
    = 2163 OR sjj_kbji_value
    = 2211 OR sjj_kbji_value
    = 2212 OR sjj_kbji_value
    = 2250 OR sjj_kbji_value
    = 2261 OR sjj_kbji_value
    = 2262 OR sjj_kbji_value
    = 2263 OR sjj_kbji_value
    = 2264 OR sjj_kbji_value
    = 2265 OR sjj_kbji_value
    = 2266 OR sjj_kbji_value
    = 2267 OR sjj_kbji_value
    = 2310 OR sjj_kbji_value
    = 2330 OR sjj_kbji_value
    = 2411 OR sjj_kbji_value
    = 2611 OR sjj_kbji_value
    = 2612 OR sjj_kbji_value
    = 2619 OR sjj_kbji_value
    = 2631 OR sjj_kbji_value
    = 2632 OR sjj_kbji_value
    = 2634) 
  AND dem_edl_value IS NOT NULL
  AND dem_edl_value < 8
),

anomali_3 AS (
 SELECT 
	root.assignment_id,
	root.nks,
        root.no_dsrt,
        art.ppno,
        art.dem_name,
	',B3' AS anomali
FROM tok_3fd42e0e.art_roster art
         LEFT JOIN tok_3fd42e0e.root_table root
                   ON root.assignment_id = art.assignment_id
         LEFT JOIN tok_3fd42e0e.base_table_assignment base
                   ON base.id = art.assignment_id

WHERE base.is_active = 1
  AND dem_age >= 5
  AND mpk_kbji_value IS NOT NULL
  AND (mpk_kbji_value
    =1111 OR mpk_kbji_value
    =1112 OR mpk_kbji_value
    =2141 OR mpk_kbji_value
    =2142 OR mpk_kbji_value
    =2143 OR mpk_kbji_value
    =2144 OR mpk_kbji_value
    =2145 OR mpk_kbji_value
    =2146 OR mpk_kbji_value
    =2149 OR mpk_kbji_value
    =2151 OR mpk_kbji_value
    =2152 OR mpk_kbji_value
    =2153 OR mpk_kbji_value
    =2161 OR mpk_kbji_value
    =2162 OR mpk_kbji_value
    =2163 OR mpk_kbji_value
    =2211 OR mpk_kbji_value
    =2212 OR mpk_kbji_value
    =2250 OR mpk_kbji_value
    =2261 OR mpk_kbji_value
    =2262 OR mpk_kbji_value
    =2263 OR mpk_kbji_value
    =2264 OR mpk_kbji_value
    =2265 OR mpk_kbji_value
    =2266 OR mpk_kbji_value
    =2267 OR mpk_kbji_value
    =2310 OR mpk_kbji_value
    =2330 OR mpk_kbji_value
    =2411 OR mpk_kbji_value
    =2611 OR mpk_kbji_value
    =2612 OR mpk_kbji_value
    =2619 OR mpk_kbji_value
    =2631 OR mpk_kbji_value
    =2632 OR mpk_kbji_value
    =2634)
  AND dem_edl_value IS NOT NULL
  AND dem_edl_value < 8
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
       mjj_kbji_value,
       sjj_kbji_value,
       mpk_kbji_value,
       dem_edl_value,
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

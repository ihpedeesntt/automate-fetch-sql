SELECT 
  a.level_2_name,
  a.level_2_code,
  a.level_6_full_code,
  
  -- Breakdown berdasarkan daftar status kamu
  SUM(CASE WHEN a.assignment_status_alias = 'OPEN' THEN 1 ELSE 0 END) AS total_open,
  SUM(CASE WHEN a.assignment_status_alias = 'DRAFT' THEN 1 ELSE 0 END) AS total_draft,
  SUM(CASE WHEN a.assignment_status_alias = 'SUBMITTED BY Pencacah' THEN 1 ELSE 0 END) AS total_submitted_pencacah,
  SUM(CASE WHEN a.assignment_status_alias = 'SUBMITTED RESPONDENT' THEN 1 ELSE 0 END) AS total_submitted_respondent,
  SUM(CASE WHEN a.assignment_status_alias = 'APPROVED BY Pengawas' THEN 1 ELSE 0 END) AS total_approved_pengawas,
  SUM(CASE WHEN a.assignment_status_alias = 'REJECTED BY Pengawas' THEN 1 ELSE 0 END) AS total_rejected_pengawas,
  SUM(CASE WHEN a.assignment_status_alias = 'REJECTED BY Admin Kabupaten' THEN 1 ELSE 0 END) AS total_rejected_admin_kab,
  SUM(CASE WHEN a.assignment_status_alias = 'EDITED BY Pengawas' THEN 1 ELSE 0 END) AS total_edited_pengawas,
  SUM(CASE WHEN a.assignment_status_alias = 'EDITED BY Admin Kabupaten' THEN 1 ELSE 0 END) AS total_edited_admin_kab,
  SUM(CASE WHEN a.assignment_status_alias = 'REVOKED BY Pengawas' THEN 1 ELSE 0 END) AS total_revoked_pengawas,
  SUM(CASE WHEN a.assignment_status_alias = 'REVOKED BY Admin Kabupaten' THEN 1 ELSE 0 END) AS total_revoked_admin_kab,
  SUM(CASE WHEN a.assignment_status_alias = 'COMPLETED BY Admin Kabupaten' THEN 1 ELSE 0 END) AS total_completed_admin_kab,
  
  -- Kolom Total & Kontrol Selain OPEN
  SUM(CASE WHEN a.assignment_status_alias != 'OPEN' THEN 1 ELSE 0 END) AS total_selain_open,
  COUNT(a.assignment_id) AS total_assignment

FROM
  base_table_assignment a
WHERE
  a.is_active = 1
GROUP BY
  a.level_2_name,
  a.level_2_code,
  a.level_6_full_code
ORDER BY 
  a.level_2_code ASC, 
  a.level_6_full_code ASC
LIMIT 0, 9000;
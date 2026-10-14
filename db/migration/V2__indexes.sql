-- V2: Indexes supporting common filters, joins, and reports.
CREATE INDEX app_users_tenant_role_idx ON app_users (tenant_id, role);
CREATE INDEX courses_tenant_active_title_idx ON courses (tenant_id, is_active, title);
CREATE INDEX enrollments_tenant_course_status_idx ON enrollments (tenant_id, course_id, status);
CREATE INDEX enrollments_tenant_student_idx ON enrollments (tenant_id, student_id);
CREATE INDEX attendance_tenant_date_status_idx ON attendance (tenant_id, class_date, status);
CREATE INDEX attendance_tenant_enrollment_date_idx ON attendance (tenant_id, enrollment_id, class_date DESC);
CREATE INDEX audit_logs_tenant_changed_at_idx ON audit_logs (tenant_id, changed_at DESC);

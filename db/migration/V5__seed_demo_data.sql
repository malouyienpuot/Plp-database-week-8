-- V5: Synthetic data only. No real student records or credentials.
INSERT INTO tenants (id, name) VALUES
    (1, 'Demo Learning Centre'),
    (2, 'Sample Partner Centre')
ON CONFLICT (id) DO NOTHING;

SELECT set_config('app.tenant_id', '1', false);

INSERT INTO app_users (id, tenant_id, full_name, email, role) VALUES
    (1, 1, 'Amina Demo', 'amina.student@example.test', 'student'),
    (2, 1, 'Peter Trainer', 'peter.trainer@example.test', 'trainer'),
    (3, 1, 'Admin Demo', 'admin@example.test', 'admin')
ON CONFLICT (id) DO NOTHING;

INSERT INTO courses (id, tenant_id, title, description, is_active) VALUES
    (1, 1, 'Computer Basics', 'Introduction to computers and digital skills.', TRUE),
    (2, 1, 'Web Development', 'HTML, CSS, JavaScript, and project practice.', TRUE)
ON CONFLICT (id) DO NOTHING;

INSERT INTO enrollments (id, tenant_id, student_id, course_id, status) VALUES
    (1, 1, 1, 1, 'enrolled'),
    (2, 1, 1, 2, 'enrolled')
ON CONFLICT (id) DO NOTHING;

INSERT INTO attendance (id, tenant_id, enrollment_id, class_date, status) VALUES
    (1, 1, 1, CURRENT_DATE - 2, 'present'),
    (2, 1, 1, CURRENT_DATE - 1, 'late'),
    (3, 1, 2, CURRENT_DATE - 1, 'present')
ON CONFLICT (id) DO NOTHING;

-- Switch tenant context before inserting the second tenant's records.
SELECT set_config('app.tenant_id', '2', false);

INSERT INTO app_users (id, tenant_id, full_name, email, role) VALUES
    (4, 2, 'Sam Student', 'sam.student@example.test', 'student')
ON CONFLICT (id) DO NOTHING;

INSERT INTO courses (id, tenant_id, title, description, is_active) VALUES
    (3, 2, 'Digital Literacy', 'Foundational digital literacy course.', TRUE)
ON CONFLICT (id) DO NOTHING;

INSERT INTO enrollments (id, tenant_id, student_id, course_id, status) VALUES
    (3, 2, 4, 3, 'enrolled')
ON CONFLICT (id) DO NOTHING;

INSERT INTO attendance (id, tenant_id, enrollment_id, class_date, status) VALUES
    (4, 2, 3, CURRENT_DATE - 1, 'present')
ON CONFLICT (id) DO NOTHING;

-- Advance identity sequences after explicit demo IDs.
SELECT setval(pg_get_serial_sequence('tenants', 'id'), GREATEST((SELECT COALESCE(MAX(id), 1) FROM tenants), 1));
SELECT setval(pg_get_serial_sequence('app_users', 'id'), GREATEST((SELECT COALESCE(MAX(id), 1) FROM app_users), 1));
SELECT setval(pg_get_serial_sequence('courses', 'id'), GREATEST((SELECT COALESCE(MAX(id), 1) FROM courses), 1));
SELECT setval(pg_get_serial_sequence('enrollments', 'id'), GREATEST((SELECT COALESCE(MAX(id), 1) FROM enrollments), 1));
SELECT setval(pg_get_serial_sequence('attendance', 'id'), GREATEST((SELECT COALESCE(MAX(id), 1) FROM attendance), 1));

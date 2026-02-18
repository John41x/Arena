-- Seed roles and sample domain data for local development/demo

INSERT INTO roles (name) VALUES
    ('ADMIN'),
    ('COACH'),
    ('MANAGER'),
    ('PLAYER')
ON CONFLICT (name) DO NOTHING;

INSERT INTO teams (name, sport) VALUES
    ('Lakers', 'Basketball'),
    ('Warriors', 'Basketball')
ON CONFLICT (name) DO NOTHING;

INSERT INTO players (team_id, name, position, jersey_number)
SELECT t.id, p.name, p.position, p.jersey_number
FROM (
    VALUES
        ('Lakers', 'Alice Smith', 'Forward', 23),
        ('Lakers', 'Bob Jones', 'Guard', 7),
        ('Warriors', 'Carol Lee', 'Center', 34)
) AS p(team_name, name, position, jersey_number)
JOIN teams t ON t.name = p.team_name
WHERE NOT EXISTS (
    SELECT 1
    FROM players existing
    WHERE existing.name = p.name
      AND existing.team_id = t.id
);

INSERT INTO games (team_id, opponent, game_date, game_time, location)
SELECT t.id, g.opponent, g.game_date, g.game_time, g.location
FROM (
    VALUES
        ('Lakers', 'Celtics', CURRENT_DATE + 1, '19:00', 'Home'),
        ('Lakers', 'Heat', CURRENT_DATE + 7, '20:00', 'Away'),
        ('Warriors', 'Bulls', CURRENT_DATE + 2, '18:30', 'Home')
) AS g(team_name, opponent, game_date, game_time, location)
JOIN teams t ON t.name = g.team_name
WHERE NOT EXISTS (
    SELECT 1
    FROM games existing
    WHERE existing.team_id = t.id
      AND existing.opponent = g.opponent
      AND existing.game_date = g.game_date
);

INSERT INTO announcements (team_id, title, content)
SELECT t.id, a.title, a.content
FROM (
    VALUES
        ('Lakers', 'Practice Time', 'Practice is at 6 PM Tuesday.'),
        ('Warriors', 'Game Day', 'Arrive 90 minutes before tip-off.')
) AS a(team_name, title, content)
JOIN teams t ON t.name = a.team_name
WHERE NOT EXISTS (
    SELECT 1
    FROM announcements existing
    WHERE existing.team_id = t.id
      AND existing.title = a.title
);

-- Demo users (password hashes are placeholders until Spring Security is wired)
INSERT INTO users (username, password_hash, team_id)
SELECT 'coach@arena.demo', 'TEMP_HASH_REPLACE_IN_AUTH_STEP', t.id
FROM teams t
WHERE t.name = 'Lakers'
  AND NOT EXISTS (SELECT 1 FROM users u WHERE u.username = 'coach@arena.demo');

INSERT INTO users (username, password_hash, team_id)
SELECT 'manager@arena.demo', 'TEMP_HASH_REPLACE_IN_AUTH_STEP', t.id
FROM teams t
WHERE t.name = 'Lakers'
  AND NOT EXISTS (SELECT 1 FROM users u WHERE u.username = 'manager@arena.demo');

INSERT INTO users (username, password_hash, player_id, team_id)
SELECT 'alice@arena.demo', 'TEMP_HASH_REPLACE_IN_AUTH_STEP', p.id, p.team_id
FROM players p
WHERE p.name = 'Alice Smith'
  AND NOT EXISTS (SELECT 1 FROM users u WHERE u.username = 'alice@arena.demo');

INSERT INTO user_roles (user_id, role_id)
SELECT u.id, r.id
FROM users u
JOIN roles r ON r.name = 'COACH'
WHERE u.username = 'coach@arena.demo'
ON CONFLICT DO NOTHING;

INSERT INTO user_roles (user_id, role_id)
SELECT u.id, r.id
FROM users u
JOIN roles r ON r.name = 'MANAGER'
WHERE u.username = 'manager@arena.demo'
ON CONFLICT DO NOTHING;

INSERT INTO user_roles (user_id, role_id)
SELECT u.id, r.id
FROM users u
JOIN roles r ON r.name = 'PLAYER'
WHERE u.username = 'alice@arena.demo'
ON CONFLICT DO NOTHING;

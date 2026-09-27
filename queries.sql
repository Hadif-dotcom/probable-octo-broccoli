-- ================================================
-- W4 Database Fundamentals - Activity 06
-- TODOs: Golden Boot, Standings, Goals-per-Match
-- ================================================
-- Complete the three TODO queries below. Reference
-- expected results in Activity 06 MDX (Verify Results).

-- ============================================
-- WARM-UP (already works — just run to confirm
-- your DB is loaded)
-- ============================================
SELECT COUNT(*)            AS total_goals       FROM goals;
SELECT AVG(home_score + away_score) AS avg_goals_per_match FROM matches;
SELECT MAX(home_score + away_score) AS highest_score FROM matches;


-- ============================================
-- TODO 1: Golden Boot Leaderboard
-- ============================================
-- Top 10 scorers with their team and a sequential rank column.
-- Verify: rank 1 has the most goals; row count <= 10.

-- Your query here
SELECT
 players.name AS player_name,
 COUNT(goals.player_id) AS goal
FROM players
INNER JOIN goals
 ON goals.player_id = players.player_id
GROUP BY players.name
ORDER BY goal DESC LIMIT 10;

-- ============================================
-- TODO 2: Group Stage Standings
-- ============================================
-- For every team, compute played / won / drawn / lost / goals_for /
-- goals_against / goal_difference / points (Win=3, Draw=1, Loss=0).
-- Only count matches where stage = 'Group'.
-- Output ordered by points DESC, then goal_difference DESC.
-- Verify: Argentina and Brazil tie on 6 points; Argentina is listed first by GD (+4 vs +3).

-- Your query here
SELECT teams.name AS team_name, COUNT(matches.match_id) AS played, SUM(CASE WHEN teams.team_id = matches.home_team_id AND matches.home_score > matches.away_score THEN 1 WHEN teams.team_id = matches.away_team_id AND matches.away_score > matches.home_score THEN 1 ELSE 0 END) AS wins, SUM(CASE WHEN matches.home_score = matches.away_score THEN 1 ELSE 0 END) AS draws, SUM(CASE WHEN teams.team_id = matches.home_team_id AND matches.home_score < matches.away_score THEN 1 WHEN teams.team_id = matches.away_team_id AND matches.away_score < matches.home_score THEN 1 ELSE 0 END) AS lose, SUM(CASE WHEN teams.team_id = matches.home_team_id THEN matches.home_score ELSE matches.away_score END) AS goals_for,
SUM(CASE WHEN teams.team_id = matches.home_team_id THEN matches.away_score ELSE matches.home_score END) AS goals_against, SUM(CASE WHEN (teams.team_id = matches.home_team_id AND matches.home_score > matches.away_score) OR (teams.team_id = matches.away_team_id AND matches.away_score > matches.home_score) THEN 3 WHEN matches.home_score = matches.away_score THEN 1 ELSE 0 END) AS points, SUM(CASE WHEN teams.team_id = matches.home_team_id THEN matches.home_score - matches.away_score ELSE matches.away_score - matches.home_score END) AS goal_difference FROM teams INNER JOIN matches ON matches.away_team_id = teams.team_id OR matches.home_team_id = teams.team_id WHERE matches.stage = 'Group' GROUP BY teams.name ORDER BY points DESC, goal_difference DESC;
-- ============================================
-- TODO 3: Goals-per-Match by Position
-- ============================================
-- For players with at least 2 matches played, rank within their position
-- (Forwards ranked separately from Midfielders) by goals_per_match.
-- Verify: Forwards and Midfielders each restart at rank 1; top forward(s) tied at 2.0 gpm.

-- Your query here
 SELECT
 players.name,
 players.age,
 players.jersey_number,
  COUNT(DISTINCT goals.goal_id) AS player_goals, 
    COUNT(DISTINCT matches.match_id) AS player_matches, 
    CAST(COUNT(DISTINCT goals.goal_id) AS FLOAT) / COUNT(DISTINCT matches.match_id) AS goals_per_match 
 FROM players
 INNER JOIN matches
 ON matches.away_team_id = players.team_id OR matches.home_team_id = players.team_id
 LEFT JOIN goals
 ON goals.player_id = players.player_id
 GROUP BY players.player_id,
 players.name,
 players.age,
 players.jersey_number
 ORDER BY goals_per_match DESC;

-- ============================================
-- BONUS: Running total of tournament goals by date
-- ============================================
-- Try this if you finish early.
SELECT
    m.match_date,
    COUNT(g.goal_id)                          AS daily_goals,
    SUM(COUNT(g.goal_id)) OVER (ORDER BY m.match_date) AS cumulative_goals
FROM goals  g
JOIN matches m ON g.match_id = m.match_id
GROUP BY m.match_date
ORDER BY m.match_date;

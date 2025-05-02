with game_elo as (SELECT 
    game_id,
    avg(duration)::INTEGER as game_time,
    SUM(CASE
        WHEN solo_tier = 'IRON' THEN 0
        WHEN solo_tier = 'BRONZE' THEN 1
        WHEN solo_tier = 'SILVER' THEN 2
        WHEN solo_tier = 'GOLD' THEN 3
        WHEN solo_tier = 'PLATINUM' THEN 4
        WHEN solo_tier = 'EMERALD' THEN 5
        WHEN solo_tier = 'DIAMOND' THEN 6
        WHEN solo_tier = 'MASTER' THEN 7
        WHEN solo_tier = 'GRANDMASTER' THEN 8
        WHEN solo_tier = 'CHALLENGER' THEN 9
    ELSE 0
    END) AS elo
FROM lol_ranked_matches
GROUP BY game_id
)

SELECT
    LPAD((avg(game_time) / 60)::TEXT, 2, '0') || ':' || LPAD((avg(game_time) % 60)::TEXT, 2, '0') AS game_time_formatted,
    COUNT(*) as total_games,
    CASE
        WHEN elo BETWEEN 0 AND 44 THEN 'LOW'
        WHEN elo >= 45 THEN 'HIGH'
    END AS elo_category
FROM game_elo
GROUP BY elo_category

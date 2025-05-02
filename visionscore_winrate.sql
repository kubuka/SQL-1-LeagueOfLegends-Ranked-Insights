WITH team_vision AS (
    SELECT
        game_id,
        CASE 
            WHEN participant_id BETWEEN 1 AND 5 THEN 'blue'
            WHEN participant_id BETWEEN 6 AND 10 THEN 'red'
        END AS team,
        win::INTEGER AS win,
        vision_score
    FROM lol_ranked_matches
),
team_summary AS (
    SELECT
        game_id,
        team,
        AVG(win)::INTEGER AS win,
        AVG(vision_score) AS avg_vision
    FROM team_vision
    GROUP BY game_id, team
    ORDER BY game_id
)
SELECT
    ROUND(AVG(CASE WHEN win = 1 THEN avg_vision END), 2) AS vision_win,
    ROUND(AVG(CASE WHEN win = 0 THEN avg_vision END), 2) AS vision_lose
FROM team_summary;
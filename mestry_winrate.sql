WITH team_tokens AS (
    SELECT
        game_id,
        CASE 
            WHEN participant_id BETWEEN 1 AND 5 THEN 'blue'
            WHEN participant_id BETWEEN 6 AND 10 THEN 'red'
        END AS team,
        win::INTEGER AS win,
        mastery_tokens
    FROM lol_ranked_matches
),
team_summary AS (
    SELECT
        game_id,
        team,
        ROUND(AVG(win::NUMERIC), 0) AS win,
        SUM(mastery_tokens) AS mastery_tokens
    FROM team_tokens
    GROUP BY game_id, team
    ORDER BY game_id
)
SELECT
    ROUND(AVG(CASE WHEN win = 1 THEN mastery_tokens END), 2) AS tokens_win,
    ROUND(AVG(CASE WHEN win = 0 THEN mastery_tokens END), 2) AS tokens_lose
FROM team_summary;
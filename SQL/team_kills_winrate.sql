WITH team_kills AS (
    SELECT
        game_id,
        CASE 
            WHEN participant_id BETWEEN 1 AND 5 THEN 'blue'
            WHEN participant_id BETWEEN 6 AND 10 THEN 'red'
        END AS team,
        SUM(kills) AS kills,
        ROUND(AVG(win::INTEGER),0) as win
    FROM lol_ranked_matches
    GROUP BY game_id, team
)

SELECT 
    COUNT(*) AS total_games,
    SUM(
        CASE 
            WHEN tk1.kills > tk2.kills  AND tk1.win = 1 THEN 1
            WHEN tk1.kills < tk2.kills  AND tk1.win = 0 THEN 1
            ELSE 0
        END
    ) as more_kills_win,
    ROUND(
        SUM(
        CASE 
            WHEN tk1.kills > tk2.kills  AND tk1.win = 1 THEN 1
            WHEN tk1.kills < tk2.kills  AND tk1.win = 0 THEN 1
            ELSE 0
        END
    )/ COUNT(*)::numeric,2) * 100 || '%' as winrate
    
FROM
    team_kills tk1
JOIN
    team_kills tk2
    ON tk1.game_id = tk2.game_id AND tk1.team != tk2.team
WHERE
    tk1.team = 'blue';
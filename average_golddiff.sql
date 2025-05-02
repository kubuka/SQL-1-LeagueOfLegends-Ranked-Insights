WITH team_gold AS (
    SELECT
        game_id,
        CASE 
            WHEN participant_id BETWEEN 1 AND 5 THEN 'blue'
            WHEN participant_id BETWEEN 6 AND 10 THEN 'red'
        END AS team,
        SUM(gold_earned) AS gold
    FROM lol_ranked_matches
    GROUP BY game_id, team
)

SELECT 
    ROUND(AVG(ABS(t1.gold - t2.gold)),2) AS avg_gold_diff
FROM team_gold as t1
JOIN team_gold as t2
    ON t1.game_id = t2.game_id AND t1.team != t2.team
WHERE
    t1.team = 'blue'

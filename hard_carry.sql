WITH kills AS (
    SELECT
        game_id,
        participant_id,
        sum(kills) as kills,
        CASE 
            WHEN participant_id BETWEEN 1 AND 5 THEN 'blue'
            WHEN participant_id BETWEEN 6 AND 10 THEN 'red'
        END AS team
    FROM lol_ranked_matches
    GROUP BY game_id, participant_id
),

kills_with_team_total AS (
    SELECT
        *,
        SUM(kills) OVER (PARTITION BY game_id, team) AS team_kills
    FROM kills
),

hardcarry_games AS (
    SELECT game_id
    FROM kills_with_team_total
    WHERE kills > team_kills / 2
),
all_games AS (
    SELECT game_id FROM lol_ranked_matches
)

SELECT 
    (SELECT COUNT(game_id) FROM hardcarry_games) AS hardcarried_games,
    (SELECT COUNT(game_id) FROM all_games) AS total_games,
    ROUND(100.0 * (SELECT COUNT(game_id) FROM hardcarry_games) / (SELECT COUNT(game_id) FROM all_games), 2) AS percent_hardcarried
;
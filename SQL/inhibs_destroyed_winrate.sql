SELECT
    win,
    ROUND(avg(team_inhibitorKills) ,2) AS avg_inhibs_destroyed
FROM lol_ranked_matches
WHERE win  = TRUE
GROUP BY win
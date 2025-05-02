SELECT
    position,
    ROUND(avg(win::INTEGER) * 100,2)::varchar || '%' as winrate
FROM lol_ranked_matches
GROUP BY position
ORDER BY winrate DESC;


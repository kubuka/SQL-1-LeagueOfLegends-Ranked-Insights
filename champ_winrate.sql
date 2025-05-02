SELECT
    champion_name,
    ROUND(avg(win::INTEGER) * 100,2)::varchar || '%' as winrate
FROM lol_ranked_matches
GROUP BY champion_name
HAVING COUNT(*) > 100
ORDER BY winrate DESC
LIMIT 100;


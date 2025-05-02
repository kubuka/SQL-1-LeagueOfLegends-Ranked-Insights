SELECT
    CASE 
        WHEN EXTRACT(HOUR FROM start_utc) BETWEEN 0 AND 5 THEN 'night'
        WHEN EXTRACT(HOUR FROM start_utc) BETWEEN 6 AND 11 THEN 'morning'
        WHEN EXTRACT(HOUR FROM start_utc) BETWEEN 12 AND 17 THEN 'afternoon'
        WHEN EXTRACT(HOUR FROM start_utc) BETWEEN 18 AND 23 THEN 'evening'
    END AS time_of_day,
    COUNT(*) AS total_games,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS percentage_of_total
FROM lol_ranked_matches
GROUP BY time_of_day
ORDER BY total_games DESC
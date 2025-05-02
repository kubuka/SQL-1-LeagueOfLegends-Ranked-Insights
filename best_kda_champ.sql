SELECT
    champion_name,
    ROUND(avg(kda_ratio)::numeric, 2)as avg_champ_kda_ratio
FROM lol_ranked_matches
WHERE solo_tier in /*('IRON', 'BRONZE', 'SILVER', 'GOLD')*/('PLATINUM', 'DIAMOND', 'MASTER', 'GRANDMASTER', 'CHALLENGER')
GROUP BY champion_name
ORDER BY avg_champ_kda_ratio DESC
LIMIT 100;
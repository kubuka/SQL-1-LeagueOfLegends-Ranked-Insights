# LeagueOfLegends-Ranked-Insights 🎮📊
This project explores key metrics from ranked *League of Legends* matches to uncover insights about win conditions, player behavior, and game dynamics. The analysis uses PostgreSQL to query a dataset (`lol_ranked_matches`) containing match details such as roles, champion performance, vision scores, and more. Below is a breakdown of each SQL script, its purpose, and improvements applied.

# 📝Scripts Overview

## Champion Win Rate 🏆

This script (`champ_winrate.sql`) calculates the win rate (%) for each champion by averaging match outcomes. Only champions with more than 100 games are included to ensure statistical significance. The query returns the top 100 champions sorted by 
win rate.

### SQL
```sql
SELECT
    champion_name,
    ROUND(avg(win::INTEGER) * 100,2)::varchar || '%' as winrate
FROM lol_ranked_matches
GROUP BY champion_name
HAVING COUNT(*) > 100
ORDER BY winrate DESC
LIMIT 100;
```

| champion_name  | winrate |
|----------------|---------|
| Vex            | 59.32%  |
| Nunu           | 58.02%  |
| Kog'Maw        | 58.00%  |
| Amumu          | 56.84%  |
| Anivia         | 56.69%  |
| Heimerdinger   | 55.37%  |
| Rammus         | 54.86%  |
| Janna          | 54.77%  |
| Kennen         | 54.55%  |
| Yorick         | 54.48%  |

**💡Insights:**  
Champions like **Vex**, **Nunu**, and **Kog'Maw** top the win rate chart with over 58%, suggesting strong effectiveness in the current meta.

## Highest KDA Champions 🥇

`best_kda_champ.sql` calculates the average KDA ratio (kills + assists / deaths) for each champion in ranked solo queue games, then identifies the top 100 champions by KDA performance.

### SQL
```sql
SELECT
    champion_name,
    ROUND(avg(kda_ratio)::numeric, 2)as avg_champ_kda_ratio
FROM lol_ranked_matches
WHERE solo_tier in /*('IRON', 'BRONZE', 'SILVER', 'GOLD')*/('PLATINUM', 'DIAMOND', 'MASTER', 'GRANDMASTER', 'CHALLENGER')
GROUP BY champion_name
ORDER BY avg_champ_kda_ratio DESC
LIMIT 100;
```

| champion_name | avg_champ_kda_ratio |
|---------------|---------------------|
| Yuumi         | 6.93                |
| Rek'Sai       | 6.10                |
| Ivern         | 5.87                |
| Janna         | 5.71                |
| Milio         | 5.58                |

**💡Insights:**  
Champions like **Yuumi**, **Rek'Sai**, and **Ivern** achieve the highest average KDA ratios, reflecting strong survivability and team utility rather than raw damage output. The list is dominated by supports and junglers, indicating their central role in coordinated ranked play.

## Win Rate by Role 👥

`role_winrate.sql` calculates the average win rate for each in-game role based on the `position` field. It aggregates results across all ranks to reveal which roles tend to have the highest overall impact on match outcomes.

### SQL
```sql
SELECT
    position,
    ROUND(avg(win::INTEGER) * 100,2)::varchar || '%' as winrate
FROM lol_ranked_matches
GROUP BY position
ORDER BY winrate DESC;
```

| position | winrate |
|----------|---------|
| SUPPORT  | 50.04%  |
| BOTTOM   | 50.03%  |
| MIDDLE   | 50.01%  |
| TOP      | 49.99%  |
| JUNGLE   | 49.95%  |

**💡Insights:**  
Differences are minimal, but **Support**, **Bottom**, and **Mid** roles slightly outperform **Top** and **Jungle** in average win rate. This suggests a relatively balanced game state, with a marginal edge for utility and scaling roles.

## Mastery Tokens vs. Win Rate ⚖️

This script (`mastery_winrate.sql`) compares the average number of mastery tokens earned by winning and losing teams. It aggregates match data by team, associating mastery tokens with match outcomes.

### SQL
```sql
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
```

| outcome | avg_mastery_tokens |
|---------|--------------------|
| Win     | 15.30              |
| Lose    | 13.03              |

**💡Insights:**  
Winning teams have a noticeably higher average token count (**15.30**) compared to losing teams (**13.03**). This suggests that champion mastery — reflecting experience — correlates positively with match success.




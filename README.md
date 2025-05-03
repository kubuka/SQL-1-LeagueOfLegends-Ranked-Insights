# LeagueOfLegends-Ranked-Insights 🎮📊
This project explores key metrics from ranked *League of Legends* matches to uncover insights about win conditions, player behavior, and game dynamics. The analysis uses PostgreSQL to query a dataset (`lol_ranked_matches`) containing match details such as roles, champion performance, vision scores, and more. Below is a breakdown of each SQL script, its purpose, and improvements applied.

# 📝Scripts Overview
1. [Champion Win Rate 🏆](#champion-win-rate)
2. [Highest KDA Champions 🥇](#highest-kda-champions)
3. [Win Rate by Role 👥](#win-rate-by-role)
4. [Mastery Tokens vs. Win Rate ⚖️](#mastery-tokens-vs-win-rate)
5. [Vision Score and Match Outcomes 👀](#vision-score-and-match-outcomes)
6. [Team Kills and Win Probability ⚔️](#team-kills-and-win-probability)
7. [Average Gold Difference Between Teams 💰](#average-gold-difference-between-teams)
8. [Game Duration by ELO Tier ⏳](#game-duration-by-elo-tier)
9. [Ranked Match Distribution by Time of Day 🕰️](#ranked-match-distribution-by-time-of-day)


## Champion Win Rate

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

## Highest KDA Champions

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

## Win Rate by Role

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

![role_winrate](https://github.com/user-attachments/assets/90187910-aea7-498b-ab17-996b674cfacf)


**💡Insights:**  
Differences are minimal, but **Support**, **Bottom**, and **Mid** roles slightly outperform **Top** and **Jungle** in average win rate. This suggests a relatively balanced game state, with a marginal edge for utility and scaling roles.

## Mastery Tokens vs. Win Rate

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

## Vision Score and Match Outcomes

`visionscore_winrate.sql` analyzes the relationship between team vision control and match results by calculating the average vision score of winning and losing teams.

### SQL
```sql
WITH team_vision AS (
    SELECT
        game_id,
        CASE 
            WHEN participant_id BETWEEN 1 AND 5 THEN 'blue'
            WHEN participant_id BETWEEN 6 AND 10 THEN 'red'
        END AS team,
        win::INTEGER AS win,
        vision_score
    FROM lol_ranked_matches
),
team_summary AS (
    SELECT
        game_id,
        team,
        AVG(win)::INTEGER AS win,
        AVG(vision_score) AS avg_vision
    FROM team_vision
    GROUP BY game_id, team
    ORDER BY game_id
)
SELECT
    ROUND(AVG(CASE WHEN win = 1 THEN avg_vision END), 2) AS vision_win,
    ROUND(AVG(CASE WHEN win = 0 THEN avg_vision END), 2) AS vision_lose
FROM team_summary;
```

| outcome | avg_vision_score |
|---------|------------------|
| Win     | 27.34            |
| Lose    | 25.63            |

**💡Insights:**  
Winning teams have a higher average vision score (**27.34**) compared to losing teams (**25.63**), highlighting the strategic importance of map awareness and warding in securing victories.

## Team Kills and Win Probability

`team_kills_winrate.sql` evaluates how often the team with more kills ends up winning the match by comparing total team kills and outcomes across all games.

### SQL
```sql
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
```

| total_games | more_kills_win | winrate |
|-------------|----------------|---------|
| 6830        | 6346           | 93.00%  |

**💡Insights:**  
In a striking **93%** of matches, the team with more kills also wins. This strongly suggests that teamfight success is a key indicator of victory, though it's worth noting that some wins still occur despite a kill deficit.

## Average Gold Difference Between Teams

`average_golddiff.sql` calculates the average gold difference between the two teams at the end of each match, reflecting how lopsided matches tend to be in terms of economy.

### SQL
```sql
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
```

| avg_gold_diff |
|----------------|
| 8808.06        |

**💡Insights:**  
The average gold gap between teams at the end of a game is **8808.06** gold. This highlights how significant gold leads are by the time matches conclude, often pointing to dominant performances by the winning team.

## Game Duration by ELO Tier

`elo_gametime.sql` examines the average game duration based on the overall ELO tier of players in each match. ELO is estimated by assigning numerical values to each rank and summing them across the match.

### SQL
```sql
with game_elo as (SELECT 
    game_id,
    avg(duration)::INTEGER as game_time,
    SUM(CASE
        WHEN solo_tier = 'IRON' THEN 0
        WHEN solo_tier = 'BRONZE' THEN 1
        WHEN solo_tier = 'SILVER' THEN 2
        WHEN solo_tier = 'GOLD' THEN 3
        WHEN solo_tier = 'PLATINUM' THEN 4
        WHEN solo_tier = 'EMERALD' THEN 5
        WHEN solo_tier = 'DIAMOND' THEN 6
        WHEN solo_tier = 'MASTER' THEN 7
        WHEN solo_tier = 'GRANDMASTER' THEN 8
        WHEN solo_tier = 'CHALLENGER' THEN 9
    ELSE 0
    END) AS elo
FROM lol_ranked_matches
GROUP BY game_id
)

SELECT
    LPAD((avg(game_time) / 60)::TEXT, 2, '0') || ':' || LPAD((avg(game_time) % 60)::TEXT, 2, '0') AS game_time_formatted,
    COUNT(*) as total_games,
    CASE
        WHEN elo BETWEEN 0 AND 44 THEN 'LOW'
        WHEN elo >= 45 THEN 'HIGH'
    END AS elo_category
FROM game_elo
GROUP BY elo_category
```

| elo_category | game_time_formatted | total_games |
|--------------|---------------------|--------------|
| HIGH         | 29:14               | 3895         |
| LOW          | 30:13               | 2935         |

**💡Insights:**  
- Matches involving **lower ELO** players (Iron to Gold) last on average **30 minutes and 13 seconds**.  
- **Higher ELO** matches (Platinum and above) tend to be slightly shorter, averaging **29 minutes and 14 seconds**.  
This suggests that higher-ranked players may play more decisively or efficiently, leading to quicker game conclusions.

## Ranked Match Distribution by Time of Day

`day_time_played_games.sql` analyzes when ranked matches are most frequently played, based on the UTC start time of each game. It segments games into four time-of-day periods.

### SQL
```sql
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
```
![games_by_time_of_day](https://github.com/user-attachments/assets/e23a1815-75e0-43bb-8486-c82cef3103c8)

**💡Insights:**
- The majority of ranked games are played in the **evening** (42.81%) and **afternoon** (34.04%).
- **Morning** and **night** hours account for significantly fewer games, totaling just over 23% combined.
- This distribution likely reflects typical player activity aligned with free time outside of work or school hours.

## Hard Carry: How Often Does One Player Win the Game?

`hard_carry.sql` examins how often a single player achieved **more than 50% of their team’s total kills** — the classic definition of a *hard carry*. This performance indicates an unusually dominant impact by one player compared to their teammates.

### SQL
```sql
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
```

| Games with Hard Carry | Total Games | Percentage of Hard Carry Games |
|------------------------|-------------|--------------------------------|
| 1,185                  | 68,297      | **1.74%**                      |

**💡Insights:** Hard carries are rare — occurring in just **1 out of every 57 games**. Despite common beliefs, individual players **rarely win games alone**. League of Legends remains a team-based game where cooperation is key to success.

## 📊 Project Summary

- **Top KDA Champions**: Support-oriented champions like **Yuumi**, **Janna**, and **Ivern** dominated the highest average KDA ratios, highlighting their sustained influence without frequent deaths.
- **Role Winrates**: The **Support** and **Bottom (ADC)** roles slightly outperformed others in winrate, while **Jungle** showed the lowest average winrate, possibly due to its higher strategic complexity.
- **Mastery and Vision Impact**: Winning teams had **more mastery tokens** (avg. 15.3 vs. 13.0) and **higher vision scores** (avg. 27.34 vs. 25.63), reinforcing the idea that experience and map control are critical to victory.
- **Team Kills Correlation**: In 93% of the games, the team with more kills ended up winning, showing a strong correlation between aggression and outcome.
- **Gold Difference**: Average gold difference between teams was **8,808**, which suggests that economic leads are often substantial and likely decisive.
- **Game Duration vs. Elo**: Higher ELO games were slightly shorter (avg. 29:14) than lower ELO ones (30:13), likely due to better coordination and fewer mistakes.
- **Time of Day Trends**: Most games were played in the **evening** (42.8%), with **afternoon** (34.0%) being the second most popular period.
- **Hard Carry Instances**: Only **1.74%** of matches featured a "hard carry" (a player with over 50% of their team's total kills), showing that most wins are team-driven rather than solo efforts.

## 🧠 What I Learned

Through this project, I significantly improved my data analysis workflow and deepened my understanding of:

- 🛠 **Advanced SQL techniques**: including window functions, CTEs, joins, subqueries, and performance-oriented filtering.
- 📈 **Data storytelling**: converting raw numbers into clear insights using visualizations.
- 🗃 **Relational data structures**: understanding how player- and game-level data can be combined to yield meaningful team-level metrics.
- 🧩 **Statistical reasoning**: interpreting averages, ratios, and trends to support real gameplay conclusions.
- 📄 **Documentation best practices**: writing readable, maintainable, and informative project summaries.
















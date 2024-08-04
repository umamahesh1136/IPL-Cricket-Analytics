create database ipl_database;
use ipl_database;
show tables;
select * from ipl_2024;
desc ipl_2024;

-- Batting Strike Rate
-- Indicates how quickly a batsman scores runs, crucial for identifying explosive players.
select striker,count(*) as balls_faced,(sum(runs_of_bat) * 100.0 / count(*)) as strike_rate
from ipl_2024
group by striker
having count(*) >= 100
order by strike_rate desc;

-- Boundary Percentage
-- Shows a player's ability to hit big shots, useful for finding power hitters.
select striker,
(sum(case when runs_of_bat in (4, 6) then 1 else 0 end) * 100.0 / count(*)) as boundary_percentage
from ipl_2024
group by striker
order by boundary_percentage desc;

-- Dot Ball Percentage
-- Reveals a batsman's consistency in scoring and ability to rotate strike.
with playerstats as (
select striker,count(*) as total_balls,
sum(case when runs_of_bat = 0 and extras = 0 then 1 else 0 end) as dot_balls
from ipl_2024
group by striker
)
select striker,total_balls,dot_balls,(dot_balls * 100.0 / total_balls) as dot_ball_percentage
from playerstats
where total_balls >= 100
order by dot_ball_percentage;

-- Average Runs per Over
-- Helps identify players who can maintain a high scoring rate throughout their innings.
select striker,
       (sum(runs_of_bat) * 6.0 / count(*)) as avg_runs_per_over
from ipl_2024
group by striker
having count(*) >= 60
order by avg_runs_per_over desc;

-- Dismissal Rate
-- Indicates a batsman's ability to stay at the crease, important for finding reliable anchors.
with playerstats as (
select striker,count(*) as total_balls,
 (sum(case when wicket_type is not null then 1 else 0 end) * 100.0 / count(*)) as dismissal_rate
 -- (percentage of balls on which a batsman gets out) 
from ipl_2024
group by striker
)
select striker,total_balls,dismissal_rate
from playerstats
order by dismissal_rate;

-- Performance Against Specific Bowlers
-- Look for batsmen who consistently perform well against certain types of bowlers
With MatchupStats as (
	select
        striker, 
        bowler,
        count(*) as balls_faced,
        sum(runs_of_bat) as runs_scored,
        sum(CASE WHEN wicket_type IS NOT NULL THEN 1 ELSE 0 END) AS dismissals
    from ipl_2024
    group by striker, bowler
)
select striker, bowler,balls_faced,runs_scored,dismissals,
(runs_scored * 100.0 / balls_faced) as strike_rate
from MatchupStats
order by striker, runs_scored desc, balls_faced desc;


-- Performance in Different Phases of the Innings
-- Shows a player's versatility and effectiveness in various match situations.
select striker,
case 
	when `over` < 6 then 'Powerplay'
	when `over` >= 6 and `over` < 16 then 'Middle Overs'
	else 'Death Overs'
end as phase,
count(*) as balls_faced,sum(runs_of_bat) as runs_scored,
(sum(runs_of_bat) * 100.0 / count(*)) as strike_rate
from ipl_2024
group by striker,
(case 
	when `over` < 6 then 'Powerplay'
	when `over` >= 6 and `over` < 16 then 'Middle Overs'
	else 'Death Overs'end)
having count(*) >= 10
order by striker, phase;

-- For Bowlers
-- Economy rate:Identifies bowlers who are good at restricting runs.
select bowler,(sum(runs_of_bat + extras) * 6.0 / count(*)) AS economy_rate
from ipl_2024
group by bowler
order by economy_rate;

-- Bowling Strike Rate: Highlights the bowlers who take wickets frequently.
select 
bowler,count(*) as balls_bowled,
sum(case when wicket_type is not null and wicket_type != 'runout' then 1 else 0 end) as wickets,
(count(*) * 1.0 / sum(case when wicket_type is not null and wicket_type != 'runout' then 1 else 0 end)) as strike_rate
from ipl_2024
group by bowler
having strike_rate > 0
order by strike_rate;

-- Bowling Average: Gives a more precise Number of runs conceded per wicket taken by the bowler.
select 
bowler,count(*) as balls_bowled,sum(runs_of_bat + extras) as runs_given,
sum(case when wicket_type is not null and wicket_type != 'runout' then 1 else 0 end) as wickets,
(sum(runs_of_bat + extras) * 1.0 /sum(case when wicket_type is not null and wicket_type != 'runout' then 1 else 0 end)) as bowling_average
from ipl_2024
group by bowler
having bowling_average > 0
order by bowling_average;

-- Dot Ball Percentage:Shows bowlers who can build pressure by bowling dot balls.
select bowler,count(*) as balls_bowled,
(sum(case when runs_of_bat = 0 and extras = 0 then 1 else 0 end) * 100.0 / count(*)) as dot_ball_percentage
from ipl_2024
group by bowler
order by dot_ball_percentage desc;

-- Boundary Percentage: Identifies bowlers who are good at preventing boundaries.
select bowler, count(*) as balls_bowled,
(sum(case when runs_of_bat in (4, 6) then 1 else 0 end) * 100.0 / count(*)) as boundary_percentage
from ipl_2024
group by bowler
order by boundary_percentage;

-- Performance Against Specific Batsmen:Understanding matchups against specific batsmen
select bowler,striker,count(*) as balls_bowled,
sum(runs_of_bat + extras) as runs_conceded,
sum(case when wicket_type is not null and wicket_type != 'runout' then 1 else 0 end)   as wickets_taken,
(sum(runs_of_bat + extras) * 6.0 / count(*)) as economy_rate
from ipl_2024
group by bowler, striker
order by bowler, runs_conceded desc;

-- Performance in Different Phases: Helps identify specialists for different parts of the innings.
select bowler,
case 
	when `over` < 6 then 'Powerplay'
	when `over` >= 6 and `over` < 16 then 'Middle Overs'
	else 'Death Overs'
end as phase,
count(*) as balls_bowled,
sum(runs_of_bat + extras) as runs_conceded,
sum(case when wicket_type is not null and wicket_type != 'runout' then 1 else 0 end)   as wickets_taken,
(sum(runs_of_bat + extras) * 6.0 / count(*)) as economy_rate,
(sum(case when runs_of_bat = 0 and extras = 0 then 1 else 0 end) * 100.0 / count(*)) as dot_ball_percentage
from ipl_2024
group by bowler, phase
order by bowler, phase;



-- BY VENUE :  Identifies batsmen or Bowler who excel at particular grounds.

-- For Batsmen
select venue,striker as batsman,count(*) as balls_faced,
sum(runs_of_bat) as runs_scored,
(sum(runs_of_bat) * 100.0 / count(*)) as strike_rate,
sum(case when runs_of_bat in (4, 6) then 1 else 0 end) as boundaries,
(sum(runs_of_bat) * 100.0 / count(*)) as strike_rate,
(sum(case when runs_of_bat = 0 and extras = 0 then 1 else 0 end) * 100.0 / count(*)) as dot_ball_percentage
from ipl_2024
group by venue, striker
order by venue, runs_scored desc;

-- For Bowler
select venue,bowler,count(*) as balls_bowled,
sum(runs_of_bat + extras) as runs_conceded,
(sum(runs_of_bat + extras) * 6.0 / count(*)) as economy_rate,
sum(case when wicket_type is not null and wicket_type != 'runout' then 1 else 0 end) as wickets,
(sum(case when runs_of_bat = 0 and extras = 0 then 1 else 0 end) * 100.0 / count(*)) as dot_ball_percentage
from ipl_2024
group by venue, bowler
order by venue, economy_rate;



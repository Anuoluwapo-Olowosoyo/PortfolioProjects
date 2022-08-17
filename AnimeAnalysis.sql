--SKIMMING THE DATASET 
SELECT anime_id, "name", genre, "type", episodes, rating, members
FROM public.anime;


--THE GENRE/TYPE WITH RATINGS GREATER THAN OR EQUALS TO (>=)7
select "name", genre, "type", episodes, rating, members 
FROM public.anime
where rating >= '7'
order by rating desc

--THE NAME,GENRE,TYPE AND NUMBER OF EPISODES WITH THE HIGHEST RATING
select anime_id, "name", genre, "type", episodes, rating, members 
FROM public.anime
where rating > '9.50'
--order by rating desc

--ANIME WITH THE MOST MEMBER WHO HAVE RATED
select anime_id, "name", genre, "type", episodes--, max (rating, members) 
FROM public.anime
--where rating > '9.50'
group by anime_id,"name", genre, "type", episodes, rating, members 
order by max(members) desc

--ANIME MOVIES WITH THE MOST HIGEST RATINGS
select *
from public.anime
where type = 'Movie'
and rating is not null 
order by rating desc
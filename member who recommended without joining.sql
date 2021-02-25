-- How can you output a list of all members, including the individual who recommended them (if any), without using any joins? Ensure that there are no duplicates in the list, and that each firstname + surname pairing is formatted as a column and ordered.

select distinct 
concat(mems.firstname,' ',mems.surname) as member,
(select concat(recs.firstname,' ',recs.surname) as recommender 
	from cd.members recs 
	where recs.memid = mems.recommendedby)
from cd.members mems
order by member;
--How can you produce a list of all members who have used a tennis court? Include in your output the name of the court, and the name of the member formatted as a single column. Ensure no duplicate data, and order by the member name followed by the facility name.

select distinct 
mems.firstname || ' ' || mems.surname as member, 
facs.name as facility
from cd.members mems
inner join cd.bookings bks
	on mems.memid = bks.memid
inner join cd.facilities facs
	on bks.facid = facs.facid
where lower(facs.name) like 'tennis court'
order by member, facility   
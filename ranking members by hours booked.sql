--Produce a list of members (including guests), along with the number of hours they've booked in facilities, rounded to the nearest ten hours. Rank them by this rounded figure, producing output of first name, surname, rounded hours, rank. Sort by rank, surname, and first name.


select 
firstname, 
surname,
--the /2 here is because I'm counting slots booked but each slot is 30 minutes but the aggregate is wanting hours
round((sum(bks.slots),-1)/2 as hours,
rank() over (order by round((sum(bks.slots),-1) desc) as rank
from cd.bookings bks
inner join cd.members mems
	on bks.memid = mems.memid
group by mems.memid
order by rank, surname, firstname;  




select p.titulo , count(*) 
from rentado r  
inner join pelicula p ON r.id_pelicula = p.id 
where p.titulo = 'SUGAR WONKA'
group by p.titulo ;


select c.

from cliente c ;
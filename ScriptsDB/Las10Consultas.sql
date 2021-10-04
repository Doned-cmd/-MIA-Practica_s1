

-----------------1)Saber cuantas veces se rento la pelicula sugar wonka

select p.titulo , count(*) 
from rentado r  
inner join pelicula p ON r.id_pelicula = p.id 
where p.titulo = 'SUGAR WONKA'
group by p.titulo ;



-----------------2)Mostrar nombre, apellido y pago total de todos los clientes que han rentado 	por lo menos 40 veces
select nombrecillo, apellidillo, sumatoria, contado
from (
	select c.nombre nombrecillo, c.apellido apellidillo, count(*) contado , sum(r.cantidad_pagar) sumatoria
	from rentado r 
	inner join cliente c on c.id = r.id_cliente 
	group by c.nombre , c.apellido  
) contadorrentas
where cast(contado as integer) > 40
group by nombrecillo , apellidillo, sumatoria, contado ;


-----------------3)Mostrar nombre y apellido de los actores que contienen la palabra son en su apellido ordenados por su primer nombre
select concat(a.nombre, ' ', a.apellido)
from actor a 
where lower(a.apellido) like '%son%'
order by a.nombre ;

-----------------4)Mostrar nombre y apellido de los actores que participaron en una pelicula con descripcion que incluya la palabra
------- crocodile y shark junto con el año de lanzamiento de la pelicula, ordenados por el apellido del actor en forma ascendente
select a.apellido , a.nombre ,p.anio 
from actor_detalle ad 
inner join actor a on a.id = ad.id_actor 
inner join pelicula p on p.id = ad.id_pelicula 
where lower(p.descripcion) like '%crocodile%' or  lower(p.descripcion) like '%shark%'
order by a.apellido ;


-----------------5)Mostrar el pais y el nombre del cliente que màs peliculas rento asi como tambien el porcentaje
---que representa la cantidad de peliculas que rento con respecto de clientes del pais

with agrupado as (
	select p2.nombre As paisito, c.nombre As nombrecito, c.apellido AS apellidito, count(*) conteo
	from rentado r 
	inner join cliente c ON r.id_cliente = c.id 
	inner join pelicula p ON r.id_pelicula = p.id 
	inner join ciudad c2 on c.id_ciudad = c2.id 
	inner join pais p2 on c2.id_pais = p2.id 
	group by paisito , nombrecito, apellidito
), agrupado2 as (
	select p2.nombre paisito, count(*) conteo2
	from rentado r 
	inner join cliente c ON r.id_cliente = c.id 
	inner join pelicula p ON r.id_pelicula = p.id 
	inner join ciudad c2 on c.id_ciudad = c2.id 
	inner join pais p2 on c2.id_pais = p2.id 
	group by paisito 
), maximomax as (
	select max(agrupado.conteo) maxim
	from agrupado
),  idpaisdemax as(
	select agrupado.paisito maximo3
	from agrupado, maximomax
	where agrupado.conteo = maxim
),agrupado2dato as(
	select  agrupado2.conteo2 maximo2
	from agrupado2,idpaisdemax
	where agrupado2.paisito = idpaisdemax.maximo3  
)
	
select agrupado.paisito, agrupado.nombrecito, agrupado.apellidito, (cast(agrupado.conteo as float)*100)/cast(agrupado2dato.maximo2 as float) Porcentaje
from agrupado, agrupado2dato
where agrupado.conteo = (
	select maxim from maximomax
);

-------------6)Total de clientes y porcentajes de clientes por ciudad y pais. 
with agrupadopaises as (
	select p.nombre As paisito, p.id as paisid, count(*) conteo_pais1
	from cliente c 
	inner join ciudad c2 ON c2.id = c.id_ciudad 
	inner join pais p on p.id = c2.id_pais 
	group by paisito, paisid
), agrupadociudad as(
	select c2.nombre Ciudad_t, AP.paisito pais ,count(*) conteo_ciudad, AP.conteo_pais1 conteo_pais
	from cliente c 
	inner join ciudad c2 ON c2.id = c.id_ciudad 
	inner join pais p on p.id = c2.id_pais 
	inner join agrupadopaises AP on AP.paisid = c2.id_pais 
	group by  Ciudad_t, AP.paisito ,AP.conteo_pais1
), totalclientes as(
	select sum(conteo_pais1) somatoria
	from agrupadopaises 
)

select agrupadociudad.Ciudad_t, agrupadociudad.pais,  agrupadociudad.conteo_ciudad, agrupadociudad.conteo_pais , 
(cast(agrupadociudad.conteo_ciudad as float)*100 / cast(agrupadociudad.conteo_pais as float)) Porcentaje_ciudad_sobrepais,
(cast( agrupadociudad.conteo_pais as float )*100 / cast(totalclientes.somatoria as float)  ) Porcentaje_pais_sobretotal
from agrupadociudad, totalclientes
group by  agrupadociudad.Ciudad_t, agrupadociudad.pais,  agrupadociudad.conteo_ciudad , agrupadociudad.conteo_pais, totalclientes.somatoria


------7)Nombre del pais, la ciudad y el promedio  de rentas por ciudad
with agrupacion_rentas_ciudad as (
	select p.id pais_id ,p.nombre nombre_pais,c.id ciudad_id,c.nombre nombre_ciudad, count(*) conteo
	from rentado r 
	inner join cliente t ON t.id = r.id_cliente 
	inner join ciudad c on c.id = t.id_ciudad 
	inner join pais p on p.id = c.id_pais 
	group by pais_id , nombre_pais, nombre_ciudad, ciudad_id
) , agrupacion_conteo_ciudades as (
	select c2.id_pais id_pais , count(*) cantidad_ciudades_pais 
	from ciudad c2 
	group by c2.id_pais 
)
select ARC.pais_id , ARC.nombre_pais, ARC.nombre_ciudad, ARC.ciudad_id , 
(cast(ARC.conteo as float) / cast(ACC.cantidad_ciudades_pais as float) ) promedio 
from agrupacion_rentas_ciudad ARC
inner join agrupacion_conteo_ciudades ACC on ACC.id_pais = ARC.pais_id
group by pais_id , nombre_pais, nombre_ciudad, ciudad_id, ARC.conteo , ACC.cantidad_ciudades_pais

-------8) Mostrar el nombre del pais y el porcentaje de rentas de peliculas de la categoria 'Sports'

with agrupacion_rentas_pais as (
	select p.id pais_id ,p.nombre nombre_pais, count(*) conteo_pais
	from rentado r 
	inner join cliente t ON t.id = r.id_cliente 
	inner join ciudad c on c.id = t.id_ciudad 
	inner join pais p on p.id = c.id_pais 
	group by pais_id , nombre_pais
) , rentas_pais_cond as(
	select p.id pais_id ,p.nombre nombre_pais, count(*) conteo_condicion
	from rentado r 
	inner join cliente t ON t.id = r.id_cliente 
	inner join ciudad c on c.id = t.id_ciudad 
	inner join pais p on p.id = c.id_pais 
	inner join pelicula p2 on p2.id = r.id_pelicula 
	inner join categoria_detalle cd on cd.id_pelicula = p2.id 
	inner join categoria c2 on c2.id = cd.id_categoria 
	where lower(c2.nombre) = 'sports'
	group by pais_id , nombre_pais
)
select RPC.pais_id , RPC.nombre_pais, 
( cast( RPC.conteo_condicion as float)  /  cast(ARP.conteo_pais as float)  ) promedio
from rentas_pais_cond RPC 
inner join  agrupacion_rentas_pais ARP on RPC.pais_id = ARP.pais_id
group by RPC.pais_id , RPC.nombre_pais, RPC.conteo_condicion, ARP.conteo_pais


------- 9) Mostrar la lista de ciudades de Estados Unidos y el numero de rentas
---- de peliculas para las ciudades que obtuvieron mas rentas que la ciudad 'Dayton'
with condicion_dayton as (
	select c.id ciudad_id, c.nombre nombre_ciudad ,count(*) conteo_dayton
	from rentado r 
	inner join cliente t ON t.id = r.id_cliente 
	inner join ciudad c on c.id = t.id_ciudad 
	inner join pais p on p.id = c.id_pais 
	where lower(c.nombre) =  'dayton'
	group by ciudad_id , nombre_ciudad  
), Ciudades_USA as(
	select p.id idpais, p.nombre paisnombre, c.id idciudad, c.nombre nombreciudad, count(*) conteoUSA
	from rentado r2 
	inner join cliente t ON t.id = r2.id_cliente 
	inner join ciudad c on c.id = t.id_ciudad 
	inner join pais p on p.id = c.id_pais 
	where  lower(p.nombre) = 'united states'
	group by idpais, paisnombre, idciudad, nombreciudad
)
select CU.idciudad , CU.nombreciudad , CU.conteoUSA
from Ciudades_USA CU 
where CU.conteoUSA > (select CD.conteo_dayton from condicion_dayton CD);

-------10) Mostrar todas las ciudades por pais en las que predomina la renta de peli-
---culas de categoria 'Horror', es decir hay mas rentas que en las otras categorias









'


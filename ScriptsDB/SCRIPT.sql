-------------------------------------------------PAIS
insert into pais (Nombre) 
select distinct 
t.pais_tienda 
from temporal t
where t.pais_tienda <> '-' and t.pais_cliente <> '';

--------------------------------------------------------------CIUDAD
insert into ciudad (Nombre, id_pais)
select distinct
t.ciudad_tienda, (select p.id from pais p where lower(p.nombre) = lower(t.pais_tienda)) 
from temporal t
where t.ciudad_tienda <> '' and t.ciudad_tienda  <> '-' and t.pais_tienda  <> '-';
------------------------------------------------------------------------CLASIFICACION
insert into clasificacion values (1,'A');
insert into clasificacion values (2,'A+');
insert into clasificacion values (3,'B');
insert into clasificacion values (4,'B+15');
insert into clasificacion values (5,'C');
-----------------------------------------------------CATEGORIA
insert into categoria (nombre)
select distinct
t.categoria_pelicula 
from temporal t
where t.categoria_pelicula <> '' and t.categoria_pelicula  <> '-';

--------------------------------------ACTOR
insert into actor (nombre,apellido)
select distinct
split_part (t.actor_pelicula, ' ',1) , split_part (t.actor_pelicula, ' ',2) 
from temporal t
where t.actor_pelicula <> '' and t.actor_pelicula  <> '-';

-----------------------------------------------IDIOMA

insert into idioma (nombre)
select distinct 
t.lenguaje_pelicula 
from temporal t 
where t.actor_pelicula <> '' and t.actor_pelicula  <> '-';

---------------------------------------------------------------------TIENDA 
insert into tienda (direccion,nombre,id_ciudad)
select distinct
t.direccion_tienda , t.nombre_tienda , (select c.id from ciudad c inner join pais on pais.id = c.id_pais where lower(c.nombre) = lower(t.ciudad_tienda) and lower(pais.nombre) = lower(t.pais_tienda)) 
from temporal t
where t.direccion_tienda <> '-' and t.nombre_tienda  <> '-' and t.pais_tienda <> '-' and t.ciudad_tienda <> '-';

--select * from ciudad c inner join pais on pais.id = c.id_pais where c.nombre  = 'Lethbridge' and pais.nombre = 'Canada';
------------------------------------------------------------------------------------------------------------- CLIENTE

insert into cliente (nombre,apellido,email,direccion, distrito ,fecha_registro,activo,codigo_postal,id_ciudad,id_tienda_favorita)
select distinct 
split_part (t.nombre_cliente , ' ',1) , split_part (t.nombre_cliente , ' ',2) , t.correo_cliente ,split_part (t.direccion_cliente , ' ',1),
split_part (t.direccion_cliente , ' ',2),to_date( t.fecha_creacion, 'DD/MM/YYYY'),
t.cliente_activo,cast( t.codigo_postal_cliente as integer),  
(select c.id from ciudad c inner join pais on pais.id = c.id_pais where c.nombre = t.ciudad_cliente and pais.nombre = t.pais_cliente),
(select tie.id from tienda tie where lower(tie.nombre) = lower(t.tienda_preferida) )
from temporal t
where t.nombre_cliente <> '-' and t.correo_cliente  <> '-' and t.direccion_cliente <> '-' and t.fecha_creacion <> '-'
and t.cliente_activo <> '-' and t.codigo_postal_cliente <> '-' and t.ciudad_cliente <> '-' and  t.pais_cliente <> '-';



--------------------------------------------------------------------------------------------------------PELICULA
insert into pelicula (descripcion,anio,cantidad_dias_renta,costo_renta,costo_reposicion,
titulo,duracion,id_clasificacion)
select distinct 
t.descripcion_pelicula , cast (t."aÑo_lanzamiento" as integer) ,cast ( t.dias_renta as integer) , cast (t.costo_renta as float8), 
cast (t."costo_por_daÑo" as float8), t.nombre_pelicula , cast (t.duracion as integer) , (select c.id from clasificacion c where c.nombre = t.clasificacion)
from temporal t
where t.descripcion_pelicula <> '-' and t."aÑo_lanzamiento" <> '-' and t.dias_renta <> '-' and t.costo_renta <> '-' and t."costo_por_daÑo" <> '-' 
and  t.nombre_pelicula  <> '-' and t.duracion <> '-' and t.clasificacion <> '-';



-------------------------------------------------------------------------------- Empleado
insert into empleado (nombre,apellido,email,direccion, distrito,activo,username, contrasenia,jefe,id_tienda)
select distinct 
split_part (t.nombre_empleado , ' ', 1), split_part (t.nombre_empleado , ' ', 2), t.correo_empleado , split_part (t.direccion_empleado, ' ', 1), split_part (t.direccion_empleado, ' ', 2),
t.empleado_activo , t.usuario_empleado ,  t."contraseÑa_empleado" , 'Si'  as jefe , (select tie.id from tienda tie where t.tienda_empleado = tie.nombre)
from temporal t 
where t.nombre_empleado <> '-' and t.nombre_empleado <> '-' and t.correo_empleado <> '-' and t.direccion_empleado <> '-' and t.empleado_activo <> '-'
and t.usuario_empleado <> '-'  and t."contraseÑa_empleado" <> '-' and t.encargado_tienda <> '-' and t.encargado_tienda = t.nombre_empleado  
and t.tienda_empleado <> '-';



insert into empleado (nombre,apellido,email,direccion, distrito,activo,username,contrasenia,jefe,id_tienda)
select distinct 
split_part (t.nombre_empleado , ' ', 1), split_part (t.nombre_empleado , ' ', 2), t.correo_empleado , split_part (t.direccion_empleado, ' ', 1), split_part (t.direccion_empleado, ' ', 2),
t.empleado_activo , t.usuario_empleado , t."contraseÑa_empleado" , 'No'  as jefe , (select tie.id from tienda tie where t.tienda_empleado = tie.nombre)
from temporal t 
where t.nombre_empleado <> '-' and t.nombre_empleado <> '-' and t.correo_empleado <> '-' and t.direccion_empleado <> '-' and t.empleado_activo <> '-'
and t.usuario_empleado <> '-'  and t."contraseÑa_empleado" <> '-' and t.encargado_tienda <> '-' and t.encargado_tienda <> t.nombre_empleado and 
t.tienda_empleado <> '-';

--############################------Query para ingresar codigo postal tambien---------------------------- ahora mismo no funciona porque siempre tiene '-' en el campo de codigo postal
insert into empleado (nombre,apellido,email,direccion, distrito,activo,username, codigo_postal,contrasenia,jefe,id_tienda)
select distinct 
split_part (t.nombre_empleado , ' ', 1), split_part (t.nombre_empleado , ' ', 2), t.correo_empleado , split_part (t.direccion_empleado, ' ', 1), split_part (t.direccion_empleado, ' ', 2),
t.empleado_activo , t.usuario_empleado , cast(t.codigo_postal_empleado as integer), t."contraseÑa_empleado" , 'Si'  as jefe , (select tie.id from tienda tie where t.tienda_empleado = tie.nombre)
from temporal t 
where t.nombre_empleado <> '-' and t.nombre_empleado <> '-' and t.correo_empleado <> '-' and t.direccion_empleado <> '-' and t.empleado_activo <> '-'
and t.usuario_empleado <> '-' and t.codigo_postal_empleado <> '-' and t."contraseÑa_empleado" <> '-' and t.encargado_tienda <> '-' and t.encargado_tienda = t.nombre_empleado 
and t.tienda_empleado <> '-';

------------------------------------------------------------------------------------Categoria detalle
insert into categoria_detalle (id_pelicula,id_categoria)
select distinct 
(select p.id from pelicula p where t.nombre_pelicula = p.titulo),(select c.id from categoria c where t.categoria_pelicula = c.nombre) 
from temporal t 
where t.nombre_pelicula <> '-' and t.categoria_pelicula <> '-'


------------------------------------------------------------------------------------Actor detalle

insert into actor_detalle (id_pelicula ,id_actor)
select distinct 
(select p.id from pelicula p where lower(t.nombre_pelicula) = lower(p.titulo)),(select c.id from actor c where lower(t.actor_pelicula) = lower(concat( c.nombre, ' ',c.apellido)) )
from temporal t 
where t.nombre_pelicula <> '-' and t.actor_pelicula <> '-' 

------------------------------------------------------------------------------------Idioma detalle
insert into idioma_detalle (id_pelicula,id_idioma)
select distinct 
(select p.id from pelicula p where t.nombre_pelicula = p.titulo),(select c.id from idioma c where t.lenguaje_pelicula = c.nombre) 
from temporal t 
where t.nombre_pelicula <> '-' and t.lenguaje_pelicula <> '-'

-----------------------------------------------------------------------------------Inventario
insert into inventario (id_pelicula,id_tienda)
select distinct 
(select p.id from pelicula p where t.nombre_pelicula = p.titulo),(select tie.id from tienda tie where tie.nombre = t.tienda_pelicula)
from temporal t 
where t.nombre_pelicula <> '-' and t.tienda_pelicula <> '-'

-----------------------------------------------------------------------------------Rentado
insert into rentado (cantidad_pagar,fecha_pago,fecha_regreso,id_empleado,id_cliente,id_pelicula,id_tienda,fecha_renta)
select distinct  
cast(t.monto_a_pagar as float8), to_date( t.fecha_pago , 'DD/MM/YYYY'), to_date( t.fecha_retorno , 'DD/MM/YYYY'),
(select e.id from empleado e where lower(t.nombre_empleado) = lower(concat( e.nombre , ' ',e.apellido)) ) , 
(select e.id from cliente e where lower(t.nombre_cliente) = lower(concat( e.nombre , ' ',e.apellido)) ) , 
(select p.id from pelicula p where t.nombre_pelicula = p.titulo),
(select tie.id from tienda tie where tie.nombre = t.tienda_pelicula),
to_date( t.fecha_renta , 'DD/MM/YYYY') 
from temporal t
where t.monto_a_pagar <> '-' and t.fecha_pago <> '-' and t.fecha_retorno <> '-' and t.nombre_empleado <> '-' and t.nombre_cliente <> '-' 
and t.nombre_pelicula <> '-' and t.tienda_pelicula <> '-' and fecha_renta <> '-'



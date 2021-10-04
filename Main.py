from flask import Flask, jsonify, request
from flask_cors import CORS
import psycopg2
import os


app = Flask(__name__)

#IMPLEMENTAR CORS PARA NO TENER ERRORES AL TRATAR ACCEDER AL SERVIDOR DESDE OTRO SERVER EN DIFERENTE LOCACIÓN
CORS(app)

DB_HOST = "localhost"
DB_NAME = "Practica"
DB_USER = "postgres"
DB_PASS = "1234"

try:
    con = psycopg2.connect(
        dbname=DB_NAME,
        user=DB_USER,
        password=DB_PASS,
        host=DB_HOST)
    
    cur = con.cursor()
    
    print(con.status)

except:
    print('Error')    


@app.route("/")
def hello():
    return "<h1 style='color:blue'>ESTAMOS EN EL LABORATORIO DE ARCHIVOS !</h1>"




@app.route('/consulta1', methods=['GET'])
def consulta1():
    cur.execute(
        """
        select to_json(res) from(

            select p.titulo , count(*) 
            from rentado r  
            inner join pelicula p ON r.id_pelicula = p.id 
            where p.titulo = 'SUGAR WONKA'
            group by p.titulo 
        ) res;

        """
    )
    rows = cur.fetchall()
    print(rows)
    return jsonify(rows)


@app.route('/consulta2', methods=['GET'])
def consulta2():
    cur.execute(
        """
        select to_json(res) from(

            select nombrecillo, apellidillo, sumatoria, contado
            from (
                select c.nombre nombrecillo, c.apellido apellidillo, count(*) contado , sum(r.cantidad_pagar) sumatoria
                from rentado r 
                inner join cliente c on c.id = r.id_cliente 
                group by c.nombre , c.apellido  
            ) contadorrentas
            where cast(contado as integer) > 40
            group by nombrecillo , apellidillo, sumatoria, contado


        ) res;

        """
    )
    rows = cur.fetchall()
    print(rows)
    return jsonify(rows)


@app.route('/consulta3', methods=['GET'])
def consulta3():
    cur.execute(
        """
        select to_json(res) from(

            select concat(a.nombre, ' ', a.apellido)
            from actor a 
            where lower(a.apellido) like '%son%'
            order by a.nombre 
        ) res;

        """
    )
    rows = cur.fetchall()
    print(rows)
    return jsonify(rows)



@app.route('/consulta4', methods=['GET'])
def consulta4():
    cur.execute(
        """
        select to_json(res) from(

            select a.apellido , a.nombre ,p.anio 
            from actor_detalle ad 
            inner join actor a on a.id = ad.id_actor 
            inner join pelicula p on p.id = ad.id_pelicula 
            where lower(p.descripcion) like '%crocodile%' or  lower(p.descripcion) like '%shark%'
            order by a.apellido 


        ) res;

        """
    )
    rows = cur.fetchall()
    print(rows)
    return jsonify(rows)

@app.route('/consulta5', methods=['GET'])
def consulta5():
    cur.execute(
        """
        select to_json(res) from(

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
        )


        ) res;

        """
    )
    rows = cur.fetchall()
    print(rows)
    return jsonify(rows)

@app.route('/consulta6', methods=['GET'])
def consulta6():
    cur.execute(
        """
        select to_json(res) from(

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


        ) res;

        """
    )
    rows = cur.fetchall()
    print(rows)
    return jsonify(rows)

@app.route('/consulta7', methods=['GET'])
def consulta7():
    cur.execute(
        """
        select to_json(res) from(
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
          


        ) res;

        """
    )
    rows = cur.fetchall()
    print(rows)
    return jsonify(rows)


@app.route('/consulta8', methods=['GET'])
def consulta8():
    cur.execute(
        """
        select to_json(res) from(

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


        ) res;

        """
    )
    rows = cur.fetchall()
    print(rows)
    return jsonify(rows)


@app.route('/consulta9', methods=['GET'])
def consulta9():
    cur.execute(
        """
        select to_json(res) from(

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
            where CU.conteoUSA > (select CD.conteo_dayton from condicion_dayton CD)


        ) res;

        """
    )
    rows = cur.fetchall()
    print(rows)
    return jsonify(rows)


@app.route('/eliminarModelo', methods=['GET'])
def eliminarModelo():
    cur.execute(
        """
        BEGIN;
        drop table actor, actor_detalle , categoria , categoria_detalle , ciudad , clasificacion , cliente , empleado , idioma , 
        idioma_detalle , inventario, pais , pelicula , rentado  , tienda  ;
        COMMIT;
        """
    )
    return "<h1 style='color:blue'>Terminado eliminar modelo !</h1>"
    



@app.route('/eliminarTemporal', methods=['GET'])
def eliminarTemporal():
    cur.execute(
        """
        BEGIN;

        delete from temporal;
        
        COMMIT;
        """
    )
    return "<h1 style='color:blue'>Terminado eliminar temporal !</h1>"


@app.route('/cargarTemporal', methods=['GET'])
def cargarTemporal():
    cur.execute(
        """
        BEGIN;

           copy Temporal(
   		NOMBRE_CLIENTE  , 
	     CORREO_CLIENTE  , 
	     CLIENTE_ACTIVO  , 
	     FECHA_CREACION , 
	     TIENDA_PREFERIDA  , 
	     DIRECCION_CLIENTE  , 
	     CODIGO_POSTAL_CLIENTE  , 
	     CIUDAD_CLIENTE  , 
	     PAIS_CLIENTE  , 
	     FECHA_RENTA , 
	     FECHA_RETORNO , 
	     MONTO_A_PAGAR  , 
	     FECHA_PAGO , 
	     NOMBRE_EMPLEADO  , 
	     CORREO_EMPLEADO  , 
	     EMPLEADO_ACTIVO  , 
	     TIENDA_EMPLEADO  , 
	     USUARIO_EMPLEADO  , 
	     CONTRASEÑA_EMPLEADO  , 
	     DIRECCION_EMPLEADO , 
	     CODIGO_POSTAL_EMPLEADO  , 
	     CIUDAD_EMPLEADO  , 
	     PAIS_EMPLEADO , 
	     NOMBRE_TIENDA , 
	     ENCARGADO_TIENDA  , 
	     DIRECCION_TIENDA  , 
	     CODIGO_POSTAL_TIENDA  , 
	     CIUDAD_TIENDA  , 
	     PAIS_TIENDA , 
	     TIENDA_PELICULA  , 
	     NOMBRE_PELICULA  , 
	     DESCRIPCION_PELICULA  , 
	     AÑO_LANZAMIENTO , 
	     DIAS_RENTA , 
	     COSTO_RENTA , 
	     DURACION , 
	     COSTO_POR_DAÑO , 
	     CLASIFICACION  , 
	     LENGUAJE_PELICULA  , 
	     CATEGORIA_PELICULA  , 
	     ACTOR_PELICULA 
   )
	from '/home/doned/Documentos/Archivos/Practica/Practica/nuevaEnt.csv' (FORMAT csv, HEADER, DELIMITER ';');
        
        COMMIT;
        """
    )
    return "<h1 style='color:blue'>Terminado cargar temporal !</h1>"



@app.route('/cargarModelo', methods=['GET'])
def cargarModelo():
    cur.execute(
        """
           begin;




CREATE TABLE Actor 
    (
    
     Id SERIAL  primary key, 
     Nombre VARCHAR (100) NOT NULL ,
     Apellido VARCHAR (100) NOT NULL 
    );
   
CREATE table Categoria 
    (
     Id SERIAL  primary key, 
     Nombre VARCHAR (100) NOT NULL      
    );
   
CREATE table Idioma 
    (
     Id SERIAL  primary key, 
     Nombre VARCHAR (100) NOT NULL     
    );
   

create table Pais(
	Id SERIAL primary key,
	Nombre varchar(100)
);

create table Ciudad(
	Id SERIAL primary key,
	Nombre varchar(100),
	Id_Pais integer,
	foreign key (Id_pais) references Pais(id)
);

create table Tienda(
	Id SERIAL primary key,
	Direccion varchar(200),
	Nombre varchar(100),
	Id_ciudad integer,
	foreign key (Id_ciudad) references Ciudad(Id)
);

create table Cliente 
(
	Id SERIAL primary key,
	Nombre varchar(100),
	Apellido varchar(100),
	Email varchar(100),
	Direccion varchar(200),
	Fecha_registro Date,
	Activo varchar(2),
	Distrito	varchar(100),
	Codigo_postal varchar(100),
	Id_Ciudad integer,
	Id_tienda_favorita  integer,
	foreign key (Id_ciudad) references Ciudad(Id),
	foreign key (Id_tienda_favorita) references Tienda(Id)
);

create table Clasificacion 
(
	Id SERIAL primary key,
	Nombre varchar(10) 
);

create table Pelicula 
(
	Id SERIAL primary key,
	Descripcion varchar(200),
	Anio integer,
	Cantidad_dias_renta integer,
	Costo_renta	float,
	Costo_reposicion float,
	Titulo varchar (100),
	Duracion integer,
	Id_clasificacion integer,
	foreign key (Id_clasificacion) references Clasificacion(Id)
);


create table Empleado
(
	Id SERIAL primary key,
	Nombre varchar(100),
	Apellido varchar(100),
	Email varchar(100),
	Direccion varchar(200),
	Activo varchar(2),
	Username varchar(100),
	Distrito varchar(100),
	Codigo_postal integer,
	Contrasenia varchar(100),
	Jefe varchar(2),
	Id_tienda integer,
	foreign key (Id_tienda) references Tienda(id)
);
   
create table Rentado
(
	Id SERIAL primary key,
	Cantidad_pagar float,
	Fecha_pago DATE,
	Fecha_regreso DATE,
	Fecha_renta DATE,
	Id_empleado  integer,
	Id_cliente   integer,
	Id_pelicula  integer,
	Id_tienda    integer,
	foreign key (Id_empleado) references Empleado(id),
	foreign key (Id_cliente) references Cliente(id),
	foreign key (Id_pelicula) references Pelicula(id),
	foreign key (Id_tienda) references Tienda(id)
);
   
create table Inventario
(
	Id SERIAL primary key,
	Id_pelicula integer,
	Id_tienda integer,
	foreign key (Id_pelicula) references Pelicula(id),
	foreign key (Id_tienda) references Tienda(id)
);

create table Categoria_detalle
(
	Id SERIAL primary key,
	Id_pelicula integer,
	Id_categoria integer,
	foreign key (Id_pelicula) references Pelicula(id),
	foreign key (Id_categoria) references Categoria(id)
);

create table Actor_detalle
(
	Id SERIAL primary key,
	Id_actor integer,
	Id_pelicula integer,
	foreign key (Id_actor) references Actor(id),
	foreign key (Id_pelicula) references Pelicula(id)
);

create table Idioma_detalle
(
	Id SERIAL primary key,
	Id_pelicula integer,
	Id_idioma integer,
	foreign key (Id_pelicula) references Pelicula(id),
	foreign key (Id_idioma) references Idioma(id)
);




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


------------------------------------------------------------------------------------Categoria detalle
insert into categoria_detalle (id_pelicula,id_categoria)
select distinct 
(select p.id from pelicula p where t.nombre_pelicula = p.titulo),(select c.id from categoria c where t.categoria_pelicula = c.nombre) 
from temporal t 
where t.nombre_pelicula <> '-' and t.categoria_pelicula <> '-';


------------------------------------------------------------------------------------Actor detalle

insert into actor_detalle (id_pelicula ,id_actor)
select distinct 
(select p.id from pelicula p where lower(t.nombre_pelicula) = lower(p.titulo)),(select c.id from actor c where lower(t.actor_pelicula) = lower(concat( c.nombre, ' ',c.apellido)) )
from temporal t 
where t.nombre_pelicula <> '-' and t.actor_pelicula <> '-' ;

------------------------------------------------------------------------------------Idioma detalle
insert into idioma_detalle (id_pelicula,id_idioma)
select distinct 
(select p.id from pelicula p where t.nombre_pelicula = p.titulo),(select c.id from idioma c where t.lenguaje_pelicula = c.nombre) 
from temporal t 
where t.nombre_pelicula <> '-' and t.lenguaje_pelicula <> '-';

-----------------------------------------------------------------------------------Inventario
insert into inventario (id_pelicula,id_tienda)
select distinct 
(select p.id from pelicula p where t.nombre_pelicula = p.titulo),(select tie.id from tienda tie where tie.nombre = t.tienda_pelicula)
from temporal t 
where t.nombre_pelicula <> '-' and t.tienda_pelicula <> '-';

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
and t.nombre_pelicula <> '-' and t.tienda_pelicula <> '-' and fecha_renta <> '-';


commit ;



        """
    )
    return "<h1 style='color:blue'>Terminado eliminar temporal !</h1>"



if __name__ == "__main__":
     app.run(host='0.0.0.0', port=5000)
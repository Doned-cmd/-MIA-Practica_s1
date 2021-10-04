CREATE TABLE Temporal 
    (
     NOMBRE_CLIENTE VARCHAR (200) , 
     CORREO_CLIENTE VARCHAR (100) , 
     CLIENTE_ACTIVO VARCHAR (2) , 
     FECHA_CREACION VARCHAR (100), 
     TIENDA_PREFERIDA VARCHAR (50) , 
     DIRECCION_CLIENTE VARCHAR (200) , 
     CODIGO_POSTAL_CLIENTE VARCHAR (50) , 
     CIUDAD_CLIENTE VARCHAR (100) , 
     PAIS_CLIENTE VARCHAR (100) , 
     FECHA_RENTA VARCHAR (100), 
     FECHA_RETORNO VARCHAR (100), 
     MONTO_A_PAGAR VARCHAR (100) , 
     FECHA_PAGO VARCHAR (100), 
     NOMBRE_EMPLEADO VARCHAR (200) , 
     CORREO_EMPLEADO VARCHAR (200) , 
     EMPLEADO_ACTIVO VARCHAR (2) , 
     TIENDA_EMPLEADO VARCHAR (50) , 
     USUARIO_EMPLEADO VARCHAR (200) , 
     CONTRASEÑA_EMPLEADO VARCHAR (100) , 
     DIRECCION_EMPLEADO VARCHAR (200) , 
     CODIGO_POSTAL_EMPLEADO VARCHAR (50) , 
     CIUDAD_EMPLEADO VARCHAR (100) , 
     PAIS_EMPLEADO VARCHAR (100) , 
     NOMBRE_TIENDA VARCHAR (50) , 
     ENCARGADO_TIENDA VARCHAR (200) , 
     DIRECCION_TIENDA VARCHAR (200) , 
     CODIGO_POSTAL_TIENDA VARCHAR (50) , 
     CIUDAD_TIENDA VARCHAR (100) , 
     PAIS_TIENDA VARCHAR (100) , 
     TIENDA_PELICULA VARCHAR (50) , 
     NOMBRE_PELICULA VARCHAR (100) , 
     DESCRIPCION_PELICULA VARCHAR (500) , 
     AÑO_LANZAMIENTO VARCHAR (100), 
     DIAS_RENTA VARCHAR (100), 
     COSTO_RENTA VARCHAR (100), 
     DURACION VARCHAR (100), 
     COSTO_POR_DAÑO VARCHAR (100), 
     CLASIFICACION VARCHAR (10) , 
     LENGUAJE_PELICULA VARCHAR (50) , 
     CATEGORIA_PELICULA VARCHAR (50) , 
     ACTOR_PELICULA VARCHAR (200) 
    );

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

   


        delete from temporal;
        

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




  



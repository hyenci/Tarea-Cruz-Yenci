# Productos CRUD con CodeIgniter 3

App web para crear, ver, editar y eliminar productos.

## Stack

PHP, CodeIgniter 3, MySQL, Composer y Bootstrap.

## Requisitos

- PHP 8.1 o superior
- MySQL (Laragon o XAMPP)
- Composer
- Git

## Instalación

```bash
git clone https://github.com/hyenci/Tarea-Cruz-Yenci.git
composer install --no-dev
```

## Configuración

Copiar `.env.example` como `.env` y poner los datos de MySQL.

## Base de datos

Importar el archivo `database/schema.sql` en MySQL o en phpMyAdmin.

## Ejecución

```bash
php -S localhost:8000
```

Abrir: http://localhost:8000/index.php/productos

En Windows también se puede dar doble clic a `iniciar.bat`.

## Estructura

- Rutas: `application/config/routes.php`
- Controlador: `application/controllers/Productos.php`
- Modelo: `application/models/Producto_model.php`
- Vistas: `application/views/productos/`
- Configuración: `application/config/` y `.env`

## Flujo de una petición

Usuario → Controlador → Modelo → Base de datos → Vista → Usuario

## CRUD

- **Crear:** `crear()` guarda un producto nuevo.
- **Consultar:** `index()` muestra la lista.
- **Actualizar:** `editar()` guarda los cambios.
- **Eliminar:** `eliminar()` borra el producto.

## Problemas encontrados

1. **No conectaba a MySQL.** Se cambió `getenv()` por `$_ENV` en `database.php`.
2. **Los botones daban "Not Found".** Se agregó `APP_URL` al `.env`.
3. **Composer daba error.** Se instaló con `--no-dev`.
4. **Laragon pedía licencia.** Usé su PHP y su MySQL desde la terminal.

## Buenas prácticas

1. Usar MVC para ordenar el código.
2. Guardar las contraseñas en `.env` y no subirlas.
3. Validar los datos en el servidor.

## Reflexión

1. **Lo que más me costó:** entender cómo la URL llega al controlador.
2. **Lo más importante:** la carpeta `application/`.
3. **Cómo funciona una petición:** el usuario hace clic, el controlador pide los datos al modelo y la vista los muestra.
4. **Buenas prácticas:** MVC, `.env` y validar los datos.
5. **Un problema:** la app no conectaba a MySQL; lo arreglé leyendo el `.env` con `$_ENV`.
6. **Lo que aprendí:** a instalar y ejecutar CodeIgniter y a usar Git.


- Yenci María Hernández Martínez
- Carné: 0905-23-6756
- Desarrollo Web, Universidad Mariano Gálvez de Guatemala
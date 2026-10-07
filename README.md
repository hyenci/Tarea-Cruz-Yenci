# Productos CRUD: CodeIgniter 3

Prueba de concepto para familiarizarme con el stack asignado antes del proyecto del módulo.
Es una aplicación web que permite **crear, listar, editar y eliminar productos** (CRUD) usando
CodeIgniter 3 y MySQL/MariaDB.

---

## 1. Nombre del proyecto

**codeigniter-productos-crud**: CRUD de una tabla `productos` (nombre, precio, stock) con
listado, formulario de alta, formulario de edición y botón de eliminar.

## 2. Stack utilizado

| Tecnología | Versión | Uso |
|---|---|---|
| PHP | 8.1 o superior (probado en 8.3) | Lenguaje del servidor |
| CodeIgniter | **3.1.13** (incluido en la carpeta `system/`) | Framework MVC |
| Composer | 2.x | Gestor de dependencias |
| vlucas/phpdotenv | 5.6 | Lee las variables del archivo `.env` |
| MySQL / MariaDB | cualquiera reciente | Base de datos (driver `mysqli`) |
| Bootstrap | 5.3 (por CDN) | Estilos de las vistas |
| Git + GitHub | | Control de versiones |

> **Ojo:** es CodeIgniter **3**, no 4. CI3 no trae `spark` ni migraciones activadas; la base de
> datos se crea con un script SQL y el servidor se levanta con el servidor embebido de PHP.

## 3. Requisitos

- **PHP 8.1 o superior** con la extensión `mysqli` habilitada (se recomienda también `mbstring`).
  Verificar con `php -v` y `php -m`.
- **Composer** (`composer -V`).
- **MySQL o MariaDB** corriendo (XAMPP, Laragon o instalado aparte).
- **Git**.
- Conexión a internet en el navegador (Bootstrap se carga desde CDN).

## 4. Instalación

```bash
git clone https://github.com/<tu-usuario>/codeigniter-productos-crud.git
cd codeigniter-productos-crud

composer install --no-dev
```

- `composer install` lee `composer.json` y `composer.lock` y crea la carpeta `vendor/`.
  Esa carpeta **no se sube** a GitHub (está en `.gitignore`).
- Se usa `--no-dev` porque solo se necesita `vlucas/phpdotenv` para ejecutar la app. Las
  dependencias de desarrollo (PHPUnit) vienen del `composer.json` original del framework y una
  de ellas exige PHP 8.4 (ver [Problemas encontrados](#11-problemas-encontrados-y-soluciones)).
- El núcleo de CodeIgniter **no** se instala con Composer: ya viene dentro de `system/`.

## 5. Configuración

La configuración de la base de datos se lee desde un archivo `.env` en la raíz. Se crea a
partir de la plantilla:

```bash
# Linux / macOS / Git Bash
cp .env.example .env

# Windows (CMD)
copy .env.example .env
```

Contenido (ajustar a tu MySQL local):

```env
DB_HOSTNAME=localhost
DB_USERNAME=root
DB_PASSWORD=
DB_DATABASE=productos_crud
APP_URL=http://localhost:8000/
```

`APP_URL` es la dirección base de la app. CodeIgniter la usa para armar los enlaces y las
redirecciones; si cambias el puerto del servidor, cámbiala aquí también (con la `/` al final).

| Archivo | Qué configura |
|---|---|
| `.env` | Credenciales de la BD. **No se sube** a GitHub (está en `.gitignore`) |
| `index.php` (raíz) | Carga `vendor/autoload.php`, lee el `.env` con phpdotenv y define el entorno (`development` por defecto) |
| `application/config/database.php` | Conexión a la BD; toma los valores del `.env` |
| `application/config/config.php` | `base_url` (tomado de `APP_URL`), `index_page`, sesiones, **protección CSRF activada** |
| `application/config/autoload.php` | Carga automática de `database`, `session` y los helpers `url` y `form` |
| `application/config/routes.php` | Rutas; `productos` es el controlador por defecto |

## 6. Base de datos

El proyecto no usa migraciones (`migration_enabled = FALSE` en `application/config/migration.php`).
La estructura está en `database/schema.sql`, que crea la base `productos_crud` y la tabla:

```sql
CREATE TABLE IF NOT EXISTS productos (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    precio DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL DEFAULT 0,
    created_at TIMESTAMP NULL DEFAULT NULL,
    updated_at TIMESTAMP NULL DEFAULT NULL
);
```

Para importarlo:

```bash
mysql -u root -p < database/schema.sql
```

También se puede hacer desde **phpMyAdmin**: pestaña *Importar* y seleccionar `database/schema.sql`.

## 7. Ejecución

```bash
php -S localhost:8000
```

Abrir en el navegador: **http://localhost:8000/index.php/productos**

El `index.php` en la URL es normal: CodeIgniter 3 solo lo oculta si se configura un `.htaccess`
con `mod_rewrite` en Apache. Con el servidor embebido de PHP se deja así.

---

## 8. Estructura del proyecto

```
codeigniter-productos-crud/
├── index.php                  → punto de entrada: TODA petición pasa por aquí
├── .env.example               → plantilla de variables de entorno
├── composer.json / .lock      → dependencias (phpdotenv)
├── database/schema.sql        → creación de la base de datos y la tabla
├── system/                    → núcleo de CodeIgniter 3 (no se modifica)
└── application/               → el código de la aplicación
    ├── config/                → configuración (database, routes, autoload, config)
    ├── controllers/
    │   └── Productos.php      → acciones del CRUD
    ├── models/
    │   └── Producto_model.php → consultas a la tabla productos
    └── views/
        ├── templates/         → header.php y footer.php (Bootstrap, mensajes flash)
        └── productos/         → index.php, crear.php, editar.php
```

| Pregunta | Respuesta |
|---|---|
| ¿Dónde están las rutas? | `application/config/routes.php`. Además, CI3 enruta solo por segmentos de URL: `controlador/método/parámetro` |
| ¿Dónde están los controladores? | `application/controllers/` (`Productos.php`) |
| ¿Dónde están los modelos? | `application/models/` (`Producto_model.php`) |
| ¿Dónde están las vistas? | `application/views/productos/` y `application/views/templates/` |
| ¿Dónde está la configuración? | `application/config/` y el archivo `.env` |
| ¿Dónde están las migraciones? | No hay; la estructura está en `database/schema.sql` |
| ¿Dónde se administran las dependencias? | `composer.json` y `composer.lock` (se instalan en `vendor/`) |

## 9. Flujo de una petición

```
Usuario → index.php → Router (URL) → Controlador → Modelo → MySQL
                                          ↓
Usuario ← HTML ← Vistas (header + página + footer)
```

Ejemplo: el usuario da clic en **Editar** del producto 5.

1. El navegador pide `GET /index.php/productos/editar/5`.
2. `index.php` carga Composer, lee el `.env`, define el entorno y arranca el framework
   (`system/core/CodeIgniter.php`).
3. El **Router** separa la URL en segmentos: `productos` → clase `Productos`, `editar` → método
   `editar()`, `5` → parámetro `$id`.
4. El **controlador** `Productos` ya cargó en su constructor el modelo `Producto_model` y la
   librería `form_validation`. Llama a `$this->Producto_model->obtener(5)`.
5. El **modelo** usa el Query Builder: `$this->db->where('id', 5)->get('productos')->row()`, que
   genera y ejecuta `SELECT * FROM productos WHERE id = 5`.
6. Si no existe, el controlador responde `show_404()`. Si existe, carga tres vistas:
   `templates/header`, `productos/editar` (con el producto) y `templates/footer`.
7. Las vistas generan el HTML y CodeIgniter lo envía al navegador.

Cuando el usuario envía el formulario, se repite el flujo con `POST`: el controlador valida, el
modelo hace `UPDATE`, se guarda un mensaje *flash* en la sesión y se redirige al listado.

## 10. Base de datos y CRUD

- **Motor:** MySQL/MariaDB con el driver `mysqli`.
- **Conexión:** `application/config/database.php`, con los valores del `.env`. La librería
  `database` se carga automáticamente en `autoload.php`, por eso existe `$this->db` en los modelos.
- **Estructura de la tabla:** `database/schema.sql`.
- **Acceso a datos:** Query Builder de CodeIgniter (no hay SQL escrito a mano en el código PHP).

| Operación | ¿Dónde se implementa? | ¿Cómo funciona? |
|---|---|---|
| **Crear** | `Productos::crear()` → `Producto_model::crear()` · vista `productos/crear.php` | Con `GET` muestra el formulario. Con `POST` valida (`nombre` requerido y máx. 100; `precio` numérico ≥ 0; `stock` entero ≥ 0). Si pasa, ejecuta `$this->db->insert('productos', $datos)`, guarda el mensaje flash y redirige a `productos` |
| **Consultar** | `Productos::index()` → `Producto_model::obtener_todos()` · vista `productos/index.php` | `$this->db->order_by('nombre','ASC')->get('productos')->result()` devuelve todos los productos ordenados por nombre; la vista los recorre con `foreach` en una tabla |
| **Actualizar** | `Productos::editar($id)` → `Producto_model::obtener()` y `actualizar()` · vista `productos/editar.php` | Busca el producto (404 si no existe). Con `POST` aplica las mismas validaciones y ejecuta `$this->db->where('id',$id)->update('productos',$datos)`. Si la validación falla, el formulario conserva lo que escribió el usuario |
| **Eliminar** | `Productos::eliminar($id)` → `Producto_model::eliminar()` · botón en `productos/index.php` | El botón es un formulario `POST` con `confirm()` en JavaScript. Ejecuta `$this->db->where('id',$id)->delete('productos')` y redirige con mensaje |

Detalles que encontré al leer el código:

- `form_open()` agrega automáticamente un campo oculto con el **token CSRF**, porque
  `csrf_protection` está en `TRUE`. Probé enviar un formulario sin token y la respuesta fue
  **403 (prohibido)**.
- `set_value()` en las vistas vuelve a llenar el formulario cuando hay errores de validación.
- En el listado, `html_escape()` evita que un nombre con HTML o JavaScript se ejecute (XSS).

---

## 11. Problemas encontrados y soluciones

| # | Problema | Causa | Solución |
|---|---|---|---|
| 1 | Al abrir `/index.php/productos` salía: **`Access denied for user ''@'localhost'`**, aunque el `.env` tenía `root` | `database.php` leía las variables con `getenv()`, pero phpdotenv 5 con `createImmutable()` solo las guarda en `$_ENV` y `$_SERVER`, no en `getenv()`. Por eso el usuario llegaba vacío | En `application/config/database.php` se cambió a `($_ENV['DB_USERNAME'] ?? getenv('DB_USERNAME'))` (igual para host, password y base de datos). Así lee primero `$_ENV`, que es lo que recomienda phpdotenv |
| 2 | `composer install` fallaba: *doctrine/instantiator 2.1.0 requires php ^8.4* | El `composer.lock` incluye PHPUnit (dependencia de **desarrollo** del framework) y una de sus subdependencias exige PHP 8.4 | Instalar solo lo necesario para ejecutar: `composer install --no-dev` |
| 3 | Al terminar `composer install` aparecía un error de `sed` | El `composer.json` es el del repositorio oficial de CodeIgniter y trae un script `post-install-cmd` que usa `sed` para parchear una librería de pruebas. En Windows no existe `sed` y en macOS funciona distinto | Se eliminó la sección `scripts` de `composer.json`; no tiene que ver con la aplicación |
| 4 | El `composer.lock` no se subía al repositorio | Estaba listado en `.gitignore` (también heredado del repositorio del framework) | Se quitó de `.gitignore`. En una aplicación el `.lock` sí se versiona, para que todos instalen las mismas versiones |
| 5 | Sin la carpeta `vendor/` la aplicación da error fatal al cargar `vendor/autoload.php` | `index.php` requiere el autoload de Composer para leer el `.env` | Ejecutar `composer install --no-dev` antes de levantar el servidor |
| 6 | En Linux, MySQL/MariaDB rechazaba a `root` sin contraseña | En algunas instalaciones `root` usa autenticación por socket (`unix_socket`) | Crear un usuario propio para la app o asignar contraseña a `root` y ponerla en `.env`. En XAMPP/Laragon con Windows, `root` sin contraseña funciona por defecto |
| 7 | Los botones **Nuevo producto** y **Editar** llevaban a `http://localhost/productos/crear` (sin `:8000`) y salía *Not Found* | `base_url` estaba vacío en `config.php`. Así, CodeIgniter 3 adivina la dirección, y con el servidor embebido de PHP la arma como `http://localhost/`, sin el puerto. El enlace terminaba en el Apache de Laragon (puerto 80) | En `application/config/config.php` se cambió a `$config['base_url'] = $_ENV['APP_URL'] ?? '';` y se agregó `APP_URL=http://localhost:8000/` al `.env`. La guía de CI3 recomienda definir siempre `base_url` |
| 8 | Avisos *Deprecated* en PHP 8.2+ | CodeIgniter 3 es anterior a PHP 8.2 y usa propiedades dinámicas | Ya resuelto en `index.php`: en `development` se usa `error_reporting(E_ALL & ~E_DEPRECATED)` |

### Pruebas realizadas

Con la corrección aplicada, probé contra MariaDB: listado vacío, crear un producto, editarlo,
enviar datos inválidos (aparecieron los 3 mensajes de validación), enviar un formulario sin token
CSRF (rechazado con 403) y eliminar. Las cuatro operaciones funcionaron.

### Aspectos a mejorar (observados, no modificados)

- **Eliminar acepta `GET`.** El botón usa `POST`, pero `Productos::eliminar()` no revisa el
  método, así que abrir `/index.php/productos/eliminar/2` en el navegador borra el producto sin
  token CSRF. Lo comprobé. En el proyecto conviene validar `if ($this->input->method() !== 'post') show_404();`.
- Las columnas `created_at` y `updated_at` existen pero el modelo nunca las llena.
- Las reglas de validación están repetidas en `crear()` y `editar()`; podrían ir en un solo método
  o en `application/config/form_validation.php`.
- Los mensajes de validación salen en inglés porque el idioma configurado es `english`.

---

## 12. Buenas prácticas investigadas

1. **Separación de responsabilidades (MVC).** El controlador coordina, el modelo solo habla con la
   base de datos y la vista solo muestra. Si cambia la tabla, se toca el modelo; si cambia el
   diseño, solo las vistas.
2. **Configuración fuera del código (`.env`).** Las credenciales no se escriben en
   `database.php` ni se suben a GitHub; cada integrante usa su propio `.env`.
3. **Validación del lado del servidor** con la librería `form_validation`. Los atributos
   `required` y `min` del HTML se pueden saltar; la validación en PHP no.
4. **Protección CSRF** (`csrf_protection = TRUE` + `form_open()`), para que otro sitio no pueda
   enviar formularios en nombre del usuario.
5. **Escapar la salida** con `html_escape()` en las vistas, para evitar XSS.
6. **Query Builder en lugar de concatenar SQL.** Escapa los valores automáticamente y previene
   inyección SQL.
7. **Patrón POST → redirect → GET** con mensajes *flash*: después de guardar se redirige, así que
   recargar la página no duplica el registro.
8. **Convenciones de nombres de CI3:** clases con mayúscula inicial y nombre de archivo igual a la
   clase (`Productos.php`, `Producto_model.php`), modelos con sufijo `_model`.
9. **No modificar `system/`.** El núcleo del framework se trata como librería; el código propio va
   en `application/`.
10. **Entorno `production` al publicar.** Se define con la variable `CI_ENV`; oculta los errores
    internos (`db_debug` se desactiva solo).
11. **Versionar `composer.lock` y no `vendor/` ni `.env`.** Se garantiza que todos instalen lo
    mismo sin subir miles de archivos ni contraseñas.

Fuentes:
- [Guía de usuario de CodeIgniter 3](https://codeigniter.com/userguide3/): Routing, Models, Query Builder, Form Validation, Security
- [Documentación de vlucas/phpdotenv](https://github.com/vlucas/phpdotenv)
- [Documentación de Composer: commit del lock file](https://getcomposer.org/doc/01-basic-usage.md#commit-your-composer-lock-file-to-version-control)

---

## 13. Reflexión técnica

**1. ¿Qué fue lo que más me costó entender del framework?**
Cómo una URL llega a un método sin que exista una ruta escrita para cada acción. En CI3 el
router toma los segmentos de la URL (`productos/editar/5`) y los convierte en clase, método y
parámetro; `routes.php` solo define el controlador por defecto. También me costó entender por qué
el `.env` no funcionaba: había que saber cómo phpdotenv carga las variables.

**2. ¿Qué parte de la estructura del proyecto me pareció más importante?**
La carpeta `application/`, en especial `config/`, `controllers/`, `models/` y `views/`. Con esas
cuatro se puede seguir cualquier funcionalidad. También entendí que `index.php` es la puerta de
entrada de todo.

**3. ¿Cómo funciona una petición?**
Cuando el usuario da clic o envía un formulario, el navegador manda la petición a `index.php`.
CodeIgniter lee la URL y decide qué controlador y método ejecutar. El controlador valida los
datos y le pide al modelo lo que necesita; el modelo arma la consulta con el Query Builder y la
ejecuta en MySQL. Con el resultado, el controlador carga las vistas, que generan el HTML, y eso
es lo que el usuario ve. Si fue un guardado, primero redirige al listado con un mensaje.

**4. Tres buenas prácticas y por qué son importantes.**
- Usar `.env` para las credenciales, porque así no se suben contraseñas a GitHub y cada quien
  configura su propia base de datos.
- Validar en el servidor con `form_validation`, porque la validación del navegador se puede
  saltar y la base de datos debe recibir solo datos correctos.
- Activar CSRF y usar `form_open()`, porque impide que otra página envíe formularios a nombre
  del usuario. Al ver que eliminar acepta `GET` entendí que la protección solo sirve si todas las
  acciones que modifican datos usan `POST`.

**5. Un problema técnico y cómo lo solucioné.**
La aplicación daba `Access denied for user ''@'localhost'` aunque el `.env` tenía el usuario
`root`. El usuario aparecía vacío, así que revisé de dónde lo leía `database.php`: usaba
`getenv()`. Al probar en la consola, `getenv('DB_DATABASE')` devolvía `false` pero
`$_ENV['DB_DATABASE']` sí tenía el valor. La documentación de phpdotenv explica que
`createImmutable()` no usa `putenv()`. Cambié `database.php` para leer de `$_ENV` y la conexión
funcionó.

**6. ¿Qué aprendí que me servirá para el proyecto del módulo?**
A instalar un proyecto CodeIgniter 3 desde cero, a ubicar dónde va cada parte del código, a
seguir el flujo controlador → modelo → vista, a leer los mensajes de error en lugar de
adivinar, y a usar Git con commits pequeños que expliquen cada cambio.

---

## Autor

- Nombre:
- Carné:
- Curso / Sección:
- Universidad Mariano Gálvez de Guatemala

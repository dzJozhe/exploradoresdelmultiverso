# Plan de trabajo — Exploradores del Multiverso

## 1. Análisis del problema

Realizar una aplicación para Android con inicio de sesion a través del numero de celular, autenticación simulada de verificación por codigo, pantalla de listado de personajes con opción de almacenarlos localmente, visualizar detalles del personaje, asi como ver sus episodios en donde aparece y ubicación del personaje. Validar conexión a internet y errores.

Personajes *  episodios * ubicaciones

## 2. Requerimientos

* Flutter + Dart, con datos de https://rickandmortyapi.com
* Investigadores consultan.
* Indexación por nombre de personaje. Para encontrar rápidamente sus registros (Búsqueda por nombre).
* Inicio de sesion (para reconocer su espacio de trabajo) por numero de celular (Sesión persistente ).
* Identificar en que pantalla se quedo al iniciar sesion, guardar index de pantalla en  BD locales para recordar donde se quedo el usuario.
* Guardado de registros de sesion.
* Guardar en sqlite los datos descargados del API.
* Posible pantallas de sin conexión a internet.
* Verificación simulada sms.
* favoritos separados por número.


## 3. Decisiones de arquitectura
MVVM organizada por features.

MVVM se adaptaria idealmente al proyecto para separar por características, servicios como lo son la conexión al API, SQLite para favoritos y shared Preferences para almacenamiento de la sesion, tambien permitirá separar la lógica de conexión y consulta de datos, se adapta bien a un proyecto de tamaño medio .

data/services       -> acceso a la fuente (API HTTP, SQLite, SharedPreferences)
data/repositories   -> envuelve a los servicios; es lo que usa el view model
ui/view_models      -> estado de la pantalla (Riverpod Notifier)
ui/views            -> widgets


Librerias:
Dio o http, sqlite, Shared preferences, riverpod, go_router.

Navegación:
Router.

Recursos.
https://rickandmortyapi.com

BD:
Sqlite.

## 4. Plan de tareas
Pasos:
1. Análisis del problema .
2. Análisis de requerimientos.
3. Análisis de arquitectura (apoyo con claude). 
4. Generar interfaces en función del análisis de requerimientos (apoyo con figma y claude).
5. Generar estructura basica del proyecto. (Crear proyecto)
6. Generar arquitectura  del proyecto establecida.
7. Login + verificación simulada.
8. Sesión persistente + implementación de router para redireccionamiento.
9. Diseño pantalla de personajes (Apoyo con claude).
10. Diseño pantalla de detalle (Apoyo con claude).
11. Diseño pantalla de favoritos (Apoyo con claude).
12. Implementacion del servicio de sqlite.
13. Implementacion del sercicio de API y modelos.
14. Implementacion de la capa de personajes.
15. Implementacion de la capa de guardados.

## 5. Uso de herramientas de IA
Claude como apoyo para:
* diagnosticar errores;
* generar parte del código de la API, SQLite y la búsqueda.
* Diseño de algunas interfaces. 

## 6. Decisiones técnicas.
* Verificación simulada - el codigo de 6 se genera en el dispositivo con la función AuthRepositorie.getAccessCode.
* El inicio de sesion funciona sin conexión.
* La sesion es el numero de teléfono, se guarda en Shared_preferences.
* go_router manda a la pantalla de guardados si no hay connexion si existe sesion guardada.
* go_router manda a la pantalla de personajes si existe conexión a internet si también existe sesion guardada.
* Los favoritos son guardados en sqlite a través de la clave primaria con indice (phone y personaje_id).


Entregables.
1. Repositorio Git: https://github.com/dzJozhe/exploradoresdelmultiverso.git
2. APK release.
3. README.MD (INSTRUCCIONES) y decisiones técnicas.
4. PLAN_DE_TRABAJO.md
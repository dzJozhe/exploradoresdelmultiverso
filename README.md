# Exploradores del Multiverso

Aplicación Flutter para consultar personajes, episodios y ubicaciones de la [API de Rick and Morty](https://rickandmortyapi.com/). Cada investigador entra con su número de celular y guarda sus personajes favoritos en una base de datos local, separada por número y disponible sin conexión.

## Funcionalidades

- **Inicio de sesión con número de celular** y verificación simulada con un código de 6 dígitos (no se envía SMS).
- **Sesión persistente**: al reabrir la app, el usuario sigue dentro. El botón junto a su número cierra la sesión.
- **Listado de personajes** con paginación al llegar al final de la lista.
- **Búsqueda por nombre**.
- **Detalle del personaje**: estado, especie, género, origen, última ubicación y episodios en los que aparece.
- **Favoritos por número** guardados en SQLite: cada número solo ve los suyos. Se guarda el detalle completo (ubicaciones y episodios), así que la lista y el detalle se consultan sin internet.
- **Modo sin conexión**: si al abrir la app no hay internet y el usuario tiene guardados, se abre directamente la pestaña Guardados con el aviso "Sin conexión".
- **Validación del código de verificación**: avisa si el campo está vacío, si el código no tiene 6 dígitos o si es incorrecto.
- **Mensajes claros** cuando no hay conexión, cuando una búsqueda no tiene resultados o cuando falla la API, cada uno con su acción (Reintentar, Ir a guardados o Limpiar búsqueda).

## Requisitos

- Flutter 3.47 o superior (Dart 3.13 o superior). Desarrollado con Flutter 3.47.6, canal stable.
- Android SDK para generar el APK.

## Instalación y ejecución

```bash
git clone https://github.com/dzJozhe/exploradoresdelmultiverso.git
cd rickandmorty
flutter pub get
flutter run
```

### Generar el APK

```bash
flutter build apk --release
```

El APK queda en `build/app/outputs/flutter-apk/app-release.apk`.

El permiso de internet (`android.permission.INTERNET`) está declarado en `android/app/src/main/AndroidManifest.xml`. Sin él, la versión de release no podría consultar la API.

## Cómo usar la app

1. Escribe un número de celular de 10 dígitos y pulsa **Continuar**.
2. En la pantalla de verificación aparece el código simulado. Escríbelo en el campo de código y pulsa **Verificar y entrar**.
3. Busca personajes por nombre. Toca el corazón para guardar uno y toca la tarjeta para ver su detalle.
4. En **Guardados** están los personajes de tu número. Si cierras sesión y entras con otro número, verás solo los de ese número.

## Arquitectura

**MVVM organizada por features**, con Riverpod para el estado.

```
lib/
├── main.dart                 # Abre SharedPreferences y SQLite; los inyecta en ProviderScope
├── app/
│   ├── app.dart              # MaterialApp.router
│   └── router.dart           # Rutas y redirect según la sesión
├── core/
│   ├── providers.dart        # Todos los providers (servicios, repositorios, view models)
│   ├── database/app_database.dart
│   └── widgets/              # Barra inferior, avatar, encabezado con sesión
└── features/
    ├── auth/                 # Login, verificación y sesión
    ├── characters/           # API, modelos, listado, búsqueda y detalle
    └── saved/                # Favoritos en SQLite
```

Cada feature sigue el mismo flujo:

```
View  ->  ViewModel (Notifier)  ->  Repository  ->  Service (API / SQLite / SharedPreferences)
```

### Rutas

| Ruta | Pantalla |
|------|----------|
| `/login` | Número de celular |
| `/verify` | Código de verificación |
| `/characters` | Listado y búsqueda |
| `/characters/:id` | Detalle del personaje |
| `/saved` | Favoritos del número con sesión |

Sin sesión, cualquier ruta redirige a `/login`. Con sesión, `/login` y `/verify` redirigen a `/characters`.

## Decisiones técnicas

| Decisión | Motivo |
|----------|--------|
| **Riverpod** (`Notifier`, `AsyncNotifier`, `.family`) | Separa el estado de la UI. Los servicios se inyectan con providers.
| **go_router** con `redirect` | Protege las rutas según la sesión desde un solo lugar. |
| **http** | Solo se necesitan peticiones GET.
| **shared_preferences** para la sesión | Es un único valor: el número con sesión activa. |
| **SQLite** (`sqflite`) para favoritos | Es el requisito de base de datos local. La tabla `favorites` usa la clave `(phone, character_id)`, así que cada número tiene sus propios registros sin duplicados. |
| Personaje y detalle completo en JSON | La columna `data` guarda el personaje y `detail` sus ubicaciones y episodios. Se guarda al marcar el favorito (si se marca desde la lista, el detalle se descarga en segundo plano) y se actualiza cada vez que se abre el detalle con conexión. Sin conexión, el detalle se lee de SQLite. |
| Estado de conexión según la última petición | `networkStatusProvider` se actualiza con el resultado real de la API, en lugar de solo revisar si hay red. Lo usan el aviso "Sin conexión" y la apertura automática de Guardados. |
| Verificación generada en el dispositivo | El enunciado permite simularla; además, el login funciona sin internet. |
| Búsqueda con *debounce* de 400 ms | Evita una petición por cada letra; las respuestas de búsquedas anteriores se descartan. |
| Errores tipados (`CharactersApiException`) | La UI distingue "sin internet" de "error del servicio" y muestra el mensaje adecuado. Un 404 en la búsqueda se trata como "sin resultados". |

## Limitaciones conocidas

- Al reabrir la app se conserva la sesión, pero se abre en Personajes (o en Guardados si no hay conexión), no en la última pantalla visitada.
- Si un favorito se guardó sin conexión, solo tiene los datos básicos; sus ubicaciones y episodios se guardan la próxima vez que se abra su detalle con internet.
- Sin conexión, las imágenes de los personajes se reemplazan por sus iniciales, y en los episodios no se muestran los "otros personajes".

Más detalle en [PLAN_DE_TRABAJO.md](PLAN_DE_TRABAJO.md).

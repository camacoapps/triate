# Triate

Triate es una web app orientativa para ayudar a decidir el siguiente paso ante un problema de salud. No sustituye la valoracion de un profesional sanitario ni esta disenada para diagnosticar.

La app no usa cuentas, historial, almacenamiento de respuestas ni geolocalizacion propia. El localizador de hospital o PAC abre una busqueda externa en el mapa del dispositivo.

## Desarrollo local

```bash
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
```

Para crear la version estatica lista para publicar:

```bash
flutter build web --release
```

El resultado queda en `build/web`.

No abras `web/index.html` con doble clic: es la plantilla fuente de Flutter y se quedará en la pantalla de carga. Para una vista local, sirve `build/web` mediante HTTP, por ejemplo con `python3 -m http.server 8080` desde esa carpeta, y abre `http://localhost:8080`. En GitHub Pages este servidor ya lo proporciona la plataforma.

## Publicacion en GitHub Pages

El flujo [deploy-web.yml](.github/workflows/deploy-web.yml) compila, analiza, prueba y publica la web al hacer `push` a `main` o `master`.

En GitHub, activa **Settings > Pages > Build and deployment > Source: GitHub Actions**. Despues del primer flujo completado, la URL estara disponible en el resumen de la ejecucion de la accion.

La accion calcula automaticamente la ruta base tanto para repositorios de proyecto (`usuario.github.io/triate/`) como para repositorios de usuario (`usuario.github.io/`).

## Seguridad clinica

Las reglas de triaje estan en `lib/triage_engine.dart` y tienen pruebas de regresion en `test/triage_engine_test.dart`. Antes de considerar el servicio como producto sanitario o usarlo en un entorno asistencial, las reglas y todos los textos deben validarse formalmente por profesionales sanitarios y responsables legales.

# FitNexus

**Tu compañero inteligente de entrenamiento fitness**

FitNexus es una aplicación móvil multiplataforma desarrollada con Flutter y Firebase que permite a los usuarios crear, gestionar y seguir rutinas de ejercicio personalizadas, con soporte para smartwatch Wear OS.

---

## Características Principales

### Autenticación Segura
- Login y registro con email/contraseña (Firebase Auth)
- Recuperación de contraseña por email
- Persistencia de sesión automática
- Manejo de errores en español

### Gestión de Rutinas (CRUD)
- Crear rutinas de **Fuerza** o **Cardio**
- Seleccionar ejercicios de un catálogo de **86 ejercicios predefinidos**
- Configurar series, repeticiones y tiempo de descanso
- Editar nombre, ejercicios y eliminar rutinas
- Filtrar por tipo de rutina
- Cálculo automático de duración estimada

### Sesión de Entrenamiento en Vivo
- Cronómetro en tiempo real
- Estimación de calorías quemadas (~8 cal/min)
- Registro de peso y repeticiones reales por serie
- Timer automático de descanso entre series
- GIF demostrativo de cada ejercicio
- Indicador "EN VIVO"
- Guardado automático del historial al completar

### Catálogo de Ejercicios
- **86 ejercicios** organizados por grupo muscular
- Grupos: Pecho, Espalda, Hombros, Bíceps, Tríceps, Piernas, Abdomen, Cardio, Antebrazo
- Tipos de equipo: Barra, Mancuerna, Máquina, Polea, Peso corporal
- **GIFs animados** para demostración visual (CDN jsdelivr)
- Filtros por grupo muscular y búsqueda

### Progreso y Estadísticas
- Gráfico de barras semanal (minutos por día)
- Estadísticas: minutos semanales, sesiones, total workouts, racha de días
- Historial de workouts recientes (últimos 50)
- Cálculo de racha de días consecutivos

### Perfil de Usuario
- Avatar con foto (galería, guardada en Base64)
- Configurar peso objetivo y calorías diarias
- Seleccionar días de entrenamiento (1-7 días/semana)
- Asignar rutina a cada día de la semana

### Wear OS (Smartwatch)
- Entry point separado para smartwatch
- 5 pantallas con navegación por swipe:
  1. **Watch Face:** Hora actual + iniciar rutina
  2. **Ejercicio:** Nombre, series, tiempo, reps
  3. **BPM:** Frecuencia cardíaca simulada (60-130 BPM)
  4. **Descanso:** Timer circular de descanso
  5. **Resumen:** Estadísticas post-entreno

---

## Arquitectura del Proyecto

### Estructura de Directorios

```
lib/
├── main.dart                    # Entry point principal (móvil/web)
├── main_wear.dart               # Entry point para Wear OS
├── firebase_options.dart        # Configuración Firebase
├── core/
│   ├── data/                    # Catálogo semilla de ejercicios y GIFs
│   ├── models/                  # Modelos de dominio
│   ├── providers/               # Riverpod providers
│   ├── router/                  # GoRouter con rutas protegidas
│   ├── services/                # AuthService + FirestoreService
│   ├── theme/                   # Tema oscuro Material 3
│   └── widgets/                 # Componentes reutilizables
└── features/
    ├── auth/                    # Login/Registro
    ├── home/                    # Dashboard y navegación tabs
    ├── workout/                 # Sesión de entrenamiento
    ├── routines/                # Gestión CRUD rutinas
    ├── exercises/               # Catálogo visual
    ├── profile/                 # Perfil de usuario
    ├── progress/                # Estadísticas y progreso
    ├── settings/                # Configuración
    ├── splash/                  # Splash animado
    └── wear/                    # Wear OS smartwatch
```

### Stack Tecnológico

| Componente | Tecnología |
|---|---|
| Framework | Flutter (Dart ^3.12.0) |
| Backend/BaaS | Firebase |
| Autenticación | Firebase Auth |
| Base de datos | Cloud Firestore |
| Estado | Flutter Riverpod ^2.5.1 |
| Navegación | GoRouter ^14.3.0 |
| Tipografías | Google Fonts (Inter, Zen Dots) |
| Imágenes | image_picker ^1.1.2 |

### Plataformas Soportadas

- Android
- iOS
- Web
- Wear OS (Smartwatch)
- Smart TV

---

## Diseño Visual

### Paleta de Colores

| Constante | Color | Hex | Uso |
|---|---|---|---|
| `primaryColor` | Verde lima | `#C8F135` | Botones principales, acentos |
| `backgroundColor` | Negro profundo | `#0D0D0F` | Fondo general |
| `surfaceColor` | Gris oscuro | `#16161A` | Superficies secundarias |
| `cardColor` | Gris claro | `#1E1E24` | Tarjetas, contenedores |
| `textPrimary` | Blanco suave | `#E8E8F0` | Texto principal |
| `textMuted` | Gris medio | `#6B6B80` | Texto secundario |
| `dangerColor` | Rojo | `#FF4D6D` | Errores, eliminar |
| `strokeColor` | Gris borde | `#2A2A35` | Bordes de tarjetas |

---

## Estructura de Firestore

```
usuarios/{uid}
  ├── uid: string
  ├── nombre: string
  ├── email: string
  ├── fotoBase64: string
  ├── pesoObjetivo: double
  ├── caloriasObjetivo: int
  ├── diasPorSemana: int
  ├── fechaRegistro: Timestamp
  ├── diasEntrenamiento: [int]              # [1,3,5] = Lun, Mié, Vie
  ├── diasActivos: int
  ├── rutinaPorDia: {"1": "routineId"}     # Mapa día -> rutina
  ├── rutinas/{routineId}
  │     ├── nombre: string
  │     ├── tipo: string                   # "Fuerza" | "Cardio"
  │     └── ejercicios: [RoutineExercise]
  └── historial/{docId}
        ├── nombreRutina: string
        ├── duracionMinutos: int
        ├── ejerciciosCompletados: int
        └── fecha: Timestamp

catalogo_ejercicios/{docId}
  ├── nombre: string
  ├── musculo: string
  ├── equipo: string
  └── gifUrl: string
```

---

## Rutas de la Aplicación

| Ruta | Pantalla | Descripción |
|---|---|---|
| `/splash` | SplashScreen | Pantalla de carga animada |
| `/login` | LoginScreen | Login/Registro |
| `/home` | MainScreen | Dashboard con 4 tabs |
| `/workout` | WorkoutScreen | Sesión de entrenamiento |
| `/progress` | ProgressScreen | Estadísticas y progreso |
| `/settings/:section` | SettingsScreen | Configuración |
| `/exercise-selection` | ExerciseSelectionScreen | Selector de ejercicios |

**Protección de rutas:** No autenticado → `/login`; Autenticado + en splash/login → `/home`

---

## Instalación y Configuración

### Prerrequisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (>=3.12.0)
- [Dart SDK](https://dart.dev/get-dart)
- [Firebase CLI](https://firebase.google.com/docs/cli)
- [FlutterFire CLI](https://firebase.google.com/docs/flutter/setup?platform=android)

### Pasos

1. **Clonar el repositorio**
   ```bash
   git clone <url-del-repositorio>
   cd FitNexus
   ```

2. **Instalar dependencias**
   ```bash
   flutter pub get
   ```

3. **Configurar Firebase**
   ```bash
   flutterfire configure
   ```
   > Nota: El proyecto Firebase ID es `fitnexus-app-61488`

4. **Ejecutar la aplicación**
   ```bash
   # En desarrollo (móvil/emulador)
   flutter run

   # En web (Chrome)
   flutter run -d chrome
   ```

---

## Comandos Disponibles

```bash
# Ejecutar en desarrollo
flutter run

# Ejecutar en Web
flutter run -d chrome

# Ejecutar tests
flutter test

# Analizar código
flutter analyze

# Construir APK (Android)
flutter build apk

# Construir para Web
flutter build web

# Configurar Firebase
flutterfire configure
```

---

## Tests

El proyecto incluye tests unitarios y de integración:

- **`test/models_test.dart`**: Serialización/deserialización de modelos (ExerciseCatalogItem, RoutineExercise, Routine) y cálculo de duración estimada.
- **`test/exercise_gif_mapping_test.dart`**: Verifica que todos los ejercicios tengan un GIF asignado y URLs válidas del CDN.

```bash
flutter test
```

---

## Dependencias Principales

| Paquete | Versión | Propósito |
|---|---|---|
| `flutter` | SDK | Framework UI |
| `firebase_core` | ^3.6.0 | Inicialización Firebase |
| `firebase_auth` | ^5.3.1 | Autenticación |
| `cloud_firestore` | ^5.4.4 | Base de datos Firestore |
| `flutter_riverpod` | ^2.5.1 | Gestión de estado |
| `go_router` | ^14.3.0 | Navegación declarativa |
| `google_fonts` | ^6.2.1 | Tipografías |
| `image_picker` | ^1.1.2 | Selección de imágenes |

---

## Licencia

Este proyecto es privado. Todos los derechos reservados.

---

## Contacto

Para preguntas o soporte, contactar al equipo de desarrollo.

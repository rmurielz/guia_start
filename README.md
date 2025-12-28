# 🎯 GUIA Start

App Flutter para gestionar participaciones en ferias comerciales.

## 📱 Funcionalidades

- ✅ Autenticación con Firebase Auth
- ✅ Gestión de ferias y ediciones
- ✅ Registro de participaciones
- ✅ Control de contactos, ventas y visitantes
- ✅ Búsqueda de organizadores
- ✅ Persistencia offline con Firestore

## 🛠️ Stack Tecnológico

- Flutter 3.x
- Firebase (Auth + Firestore)
- Provider (Gestión de estado)

## 📂 Arquitectura
```
lib/
├── models/          # Modelos de datos
├── repositories/    # Acceso a Firestore
├── services/        # Auth y Firestore genérico
├── providers/       # Estado global
├── screens/         # Pantallas UI
└── constants/       # Constantes
```

## 🚀 Instalación
```bash
# Clonar
git clone https://github.com/rmurielz/guia_start.git

# Instalar dependencias
flutter pub get

# Configurar Firebase
flutterfire configure

# Ejecutar
flutter run
```

## 📝 Progreso

- ✅ Arquitectura base
- ✅ CRUD completo
- ✅ Refactoring con `_executeAsync`
- 🔄 Widget de búsqueda reutilizable (en desarrollo)

## 🔐 Nota de Seguridad

Las credenciales de Firebase (`firebase_options.dart`) no están en el repo.
Configurar localmente después de clonar.

---

Proyecto de aprendizaje Flutter/Dart
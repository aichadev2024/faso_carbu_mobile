# FasoCarbu — application mobile

Application Flutter (Android / iOS) des chauffeurs et du personnel de station.
Les gestionnaires utilisent le tableau de bord web (`faso_carbu_web`).

| Rôle | Ce qu'il fait dans l'appli |
|------|----------------------------|
| Chauffeur | Consulte ses tickets et présente le QR code en station, voit l'historique de ses pleins |
| Agent de station | Scanne le QR code d'un ticket, vérifie et valide le plein, voit ses validations |
| Admin de station | Gère les agents de sa station et le prix des carburants |

## Lancer l'appli

Prérequis : Flutter 3.32+, le backend `faso-carbu-backend` démarré (port 9090).

```bash
flutter pub get
flutter run                                              # émulateur Android -> http://10.0.2.2:9090
flutter run --dart-define=API_URL=http://192.168.1.20:9090   # téléphone réel sur le même réseau
```

Aperçu rapide dans le navigateur (sans caméra ni notifications push) :

```bash
flutter run -d chrome --dart-define=API_URL=http://localhost:9090
```

Build de production :

```bash
flutter build apk --release --dart-define=API_URL=https://api.votre-domaine.bf
```

Comptes de démo (profil `dev` du backend), mot de passe `Demo@2026` :
`chauffeur@demo.fasocarbu.bf`, `agent.station@demo.fasocarbu.bf`, `admin.station@demo.fasocarbu.bf`.

## Organisation du code

```
lib/
├── main.dart              # démarrage, notifications push, routes
├── core/
│   ├── api.dart           # client HTTP (token, JSON, messages d'erreur)
│   ├── config/            # URL du backend (--dart-define=API_URL)
│   ├── session.dart       # utilisateur connecté (SharedPreferences)
│   ├── notification_store.dart  # historique local des notifications
│   ├── theme/             # couleurs et thème, identiques au web
│   └── widgets/           # composants partagés
├── screens/               # un fichier par écran
├── services/              # enregistrement du token push
├── models/  db/           # stockage local SQLite
```

La charte (`core/theme`, `core/widgets/app_widgets.dart`) est la même que celle
du tableau de bord web : toute évolution doit être reportée dans les deux projets.

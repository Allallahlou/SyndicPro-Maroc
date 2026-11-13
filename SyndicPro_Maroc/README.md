# SyndicPro Maroc

A starter application for managing Moroccan residential buildings and syndic operations.

## Start the backend (Windows)
Double-click `START_BACKEND_WINDOWS.bat`, or from PowerShell:

```powershell
cd .\backend
py -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install -r requirements.txt
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

Verify `http://127.0.0.1:8000/health` and open API documentation at `http://127.0.0.1:8000/docs`.

## Start Flutter
Open a second PowerShell window:

```powershell
cd .\mobile_app
flutter pub get
flutter run -d chrome
```

On Chrome/Edge/Windows, the app uses `http://127.0.0.1:8000` automatically. Android Emulator uses `http://10.0.2.2:8000`. For a physical phone, configure the PC's LAN IPv4 address in `mobile_app/lib/core/api_config.dart`.

## Current features
- Buildings and apartments: create and list, with optional public image URL.
- Payments and expenses: create and list.
- Complaints: create and list, with status stored in the API.
- Dashboard totals and open complaints.
- Arabic RTL interface, loading/error/retry states.

## MVP limitations
- No login, user roles, or access control yet.
- No local image picker or file upload; images use a URL.
- Complaint status editing, general editing, and full accounting exports are not yet implemented.
- SQLite is suitable for local testing; deploy with PostgreSQL, backups, authentication, and restricted CORS before real-world use.
- Financial/legal workflows need validation against the building's governing documents and current Moroccan law before production use.

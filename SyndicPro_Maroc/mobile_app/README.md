# SyndicPro Maroc — Flutter

## Run on Chrome / Edge
1. Start the FastAPI backend first.
2. From this directory run `flutter pub get`.
3. Run `flutter run -d chrome` (or `flutter run -d edge`).

The app automatically uses `http://127.0.0.1:8000` on web and Windows, and `http://10.0.2.2:8000` on Android Emulator.
For a physical Android phone, change the Android URL in `lib/core/api_config.dart` to your computer's local IPv4 address and allow port 8000 through Windows Firewall.

Images are currently supplied as public image URLs when creating buildings or apartments. Local file upload and cloud image storage are not included in this MVP.

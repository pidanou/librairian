dev/server:
	cd api && wgo go run librairian.go

dev/app:
	cd app && flutter run --dart-define-from-file dotenv-dev -d web-server --web-hostname=0.0.0.0 --web-port=3000

dev/flutter:
	cd app && dart run build_runner watch

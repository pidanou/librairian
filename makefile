dev/server:
	cd api && wgo go run librairian.go

dev/app:
	cd app && flutter run --dart-define-from-file dotenv-dev

dev/flutter:
	cd app && dart run build_runner watch

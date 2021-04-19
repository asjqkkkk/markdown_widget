
EX=example

fix-create:
	cd $(EX) && flutter create .
fix-clean:
	cd $(EX) && flutter clean

run-web:
	cd $(EX) && flutter run -d chrome --release
run-web-debug:
	cd $(EX) && flutter run -d chrome
run-mac:
	cd $(EX) && flutter run -d macos

run-ios:
	# runs, blank screen
	#cd $(EX) && open ./ios/Runner.xcodeproj
	cd $(EX) && flutter run -d bdf90dc799709a013a25d0fc2df80e441df026f3 --release

serve-web:
	# works and is easy way to run locally
	cd $(EX) && flutter run -d web-server --release --web-port=7357
	#cd $(EX) && flutter run -d headless-server --web-port=1234
	
	# http://localhost:7357

serve-public:
	# works and easy way to test via remote.
	ngrok http 7357
	# https://b89725841d38.ngrok.io

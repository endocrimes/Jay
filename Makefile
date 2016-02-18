build:
	@echo "Building Jay"
	@swift build

debug: build
	@echo "Debugging Jay"
	@lldb .build/debug/Jay

build-release:
	@echo "Building Jay in Release"
	@swift build --configuration release

xctest: xctest-osx xctest-ios xctest-tvos #TODO: watchOS when test bundles are available

xctest-osx:
	set -o pipefail && \
	xcodebuild \
	  -project XcodeProject/Jay.xcodeproj \
	  -scheme JayTests \
	  -destination 'platform=OS X,arch=x86_64' \
	  test \
	| xcpretty

xctest-ios:
	set -o pipefail && \
	xcodebuild \
	  -project XcodeProject/Jay.xcodeproj \
	  -scheme JayTests-iOS \
	  -destination 'platform=iOS Simulator,name=iPhone 6s,OS=9.3' \
	  test \
	| xcpretty

xctest-tvos:
	set -o pipefail && \
	xcodebuild \
	  -project XcodeProject/Jay.xcodeproj \
	  -scheme JayTests-tvOS \
	  -destination 'platform=tvOS Simulator,name=Apple TV 1080p,OS=9.2' \
	  test \
	| xcpretty

example: build-release
	@echo "Running example parsing"
	.build/release/JayExample

validate_spec:
	@echo "Validating podspec"
	pod lib lint Jay.podspec

clean:
	rm -fr .build Packages
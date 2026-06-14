# make only accept argument format: xxxx=xxxx, other format will treat as a target.
# add [enable-split-platform enable-debug enable-gpl] to .PHONY can ignore target not exist error.
.PHONY: help build gpl clean verify-dv enable-split-platform enable-debug enable-gpl

help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  build [arguments]     Build the project for iOS and macOS"
	@echo "                        Arguments:"
	@echo "                            platform=ios,macos        Only build specified platform (ios,macos,tvos,tvsimulator,isimulator,maccatalyst,xros,xrsimulator)"
	@echo "                            enable-gpl                Complile to GPL version"
	@echo "  clean                 Clean the build artifacts"
	@echo "  verify-dv             Verify standard artifacts are LGPL-clean and Dolby Vision-ready"
	@echo "  help                  Display this help message"

build:
	swift run --build-path ./.build --package-path Sources/BuildScripts build $(filter-out $@,$(MAKECMDGOALS)) $(MAKEFLAGS)

gpl:
	swift run --build-path ./.build --package-path Sources/BuildScripts build enable-gpl $(filter-out $@,$(MAKECMDGOALS)) $(MAKEFLAGS)

verify-dv:
	Scripts/verify-dolby-vision-artifacts.sh $(ARTIFACT_ROOT)

clean:
	@find . -name '.build' -type d -exec rm -rf {} +
	@find . -name '.swiftpm' -type d -exec rm -rf {} +
	@rm -rf ./dist
	@rm -rf ./*.log
	@swift package reset
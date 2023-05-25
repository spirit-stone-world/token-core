SOURCE_FOLDER=./src
MAIN = spirit_stone

test: 
	cairo-test --starknet $(SOURCE_FOLDER)

format:
	cairo-format --recursive $(SOURCE_FOLDER) --print-parsing-errors

compile:
	mkdir -p artifacts && \
		starknet-compile $(SOURCE_FOLDER)/$(MAIN).cairo artifacts/$(MAIN).json

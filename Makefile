SOURCE_FOLDER=./src

test: 
	cairo-test --starknet $(SOURCE_FOLDER)

format:
	cairo-format --recursive $(SOURCE_FOLDER) --print-parsing-errors

FORCE:

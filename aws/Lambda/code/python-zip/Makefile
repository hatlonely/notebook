NAME ?= test-lambda-zip

zip:
	zip ${NAME}.zip lambda_function.py

deploy:
	aws lambda update-function-code --function-name ${NAME} --zip-file fileb://${NAME}.zip

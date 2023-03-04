#!/bin/sh

/usr/local/bin/duckling-example-exe -p 8000 --no-access-log --no-error-log &
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start duckling: $status"
  exit $status
fi

if [ -z "${AWS_LAMBDA_RUNTIME_API}" ]; then
  exec /usr/bin/aws-lambda-rie /usr/bin/python3 -m awslambdaric $1
else
  exec /usr/bin/python3 -m awslambdaric $1
fi
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start lambda: $status"
  exit $status
fi

while sleep 5; do
  ps aux | grep duckling-example-exe | grep -q -v grep
  status=$?
  if [ $status -ne 0 ]; then
    echo "duckling has already exited."
    exit 1
  fi
done

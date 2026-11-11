FROM python:3.15-slim@sha256:65a65fc7b30b06cb6df4930fd4650697cb23f4c2698ab81fc87e4b031bc36928 AS builder

WORKDIR /build

COPY applications/payment-api/requirements.lock ./requirements.lock

RUN python -m pip install \
    --only-binary=:all: \
    --no-cache-dir \
    --timeout 120 \
    --retries 10 \
    --require-hashes \
    --prefix=/install \
    -r requirements.lock


FROM python:3.15-slim@sha256:65a65fc7b30b06cb6df4930fd4650697cb23f4c2698ab81fc87e4b031bc36928

WORKDIR /app

COPY --from=builder /install /usr/local

# Remove packaging tools not required by the runtime application.
RUN rm -rf \
    /usr/local/lib/python3.11/site-packages/pip \
    /usr/local/lib/python3.11/site-packages/pip-*.dist-info \
    /usr/local/lib/python3.11/site-packages/setuptools \
    /usr/local/lib/python3.11/site-packages/setuptools-*.dist-info \
    /usr/local/lib/python3.11/site-packages/wheel \
    /usr/local/lib/python3.11/site-packages/wheel-*.dist-info \
    /usr/local/bin/pip \
    /usr/local/bin/pip3 \
    /usr/local/bin/pip3.11

COPY applications/payment-api/app/__init__.py ./app/__init__.py
COPY applications/payment-api/app/main.py ./app/main.py

RUN chgrp -R 0 /app \
    && chmod -R g=u /app

USER 10001:0

EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]

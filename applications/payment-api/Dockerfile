FROM python:3.11-slim AS builder

WORKDIR /build

COPY applications/payment-api/requirements.lock ./requirements.lock

RUN python -m pip install \
    --no-cache-dir \
    --require-hashes \
    --prefix=/install \
    -r requirements.lock

FROM python:3.11-slim

WORKDIR /app

COPY --from=builder /install /usr/local

COPY applications/payment-api/app/__init__.py ./app/__init__.py
COPY applications/payment-api/app/main.py ./app/main.py

RUN chgrp -R 0 /app \
    && chmod -R g=u /app

USER 10001:0

EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]

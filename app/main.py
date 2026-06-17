from fastapi import FastAPI
from fastapi.responses import JSONResponse
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST
from starlette.responses import Response
import time
import os

app = FastAPI(
    title="COTI Fintech Payment API",
    description="Production-aligned fintech microservice",
    version=os.getenv("APP_VERSION", "1.0.0")
)

# Prometheus metrics
REQUEST_COUNT = Counter(
    "http_requests_total",
    "Total HTTP requests",
    ["method", "endpoint", "status"]
)
REQUEST_LATENCY = Histogram(
    "http_request_duration_seconds",
    "HTTP request latency",
    ["endpoint"]
)


@app.middleware("http")
async def metrics_middleware(request, call_next):
    start = time.time()
    response = await call_next(request)
    duration = time.time() - start
    REQUEST_COUNT.labels(
        method=request.method,
        endpoint=request.url.path,
        status=response.status_code
    ).inc()
    REQUEST_LATENCY.labels(endpoint=request.url.path).observe(duration)
    return response


@app.get("/health")
async def health():
    return JSONResponse(
        status_code=200,
        content={
            "status": "healthy",
            "version": os.getenv("APP_VERSION", "1.0.0"),
            "environment": os.getenv("ENV", "staging")
        }
    )


@app.get("/metrics")
async def metrics():
    return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST)


@app.get("/")
async def root():
    return {"message": "COTI Fintech Payment API", "status": "running"}


@app.get("/api/v1/status")
async def status():
    return {
        "service": "payment-api",
        "version": os.getenv("APP_VERSION", "1.0.0"),
        "uptime": "ok"
    }

# Stage 1: Build a clean base environment
FROM python:3.11-slim AS base

# Install Node.js/npm for the npm package test case
RUN apt-get update && apt-get install -y nodejs npm && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# --- Python Mock Packages ---
# 1. Mock 'akobo' (0.0.4)
RUN mkdir -p /usr/local/lib/python3.11/site-packages/akobo-0.0.4.dist-info && \
    echo 'Metadata-Version: 2.1\nName: akobo\nVersion: 0.0.4' > /usr/local/lib/python3.11/site-packages/akobo-0.0.4.dist-info/METADATA && \
    echo 'akobo' > /usr/local/lib/python3.11/site-packages/akobo-0.0.4.dist-info/top_level.txt

# 2. Mock 'litellm' (1.82.8)
RUN mkdir -p /usr/local/lib/python3.11/site-packages/litellm-1.82.8.dist-info && \
    echo 'Metadata-Version: 2.1\nName: litellm\nVersion: 1.82.8' > /usr/local/lib/python3.11/site-packages/litellm-1.82.8.dist-info/METADATA && \
    echo 'litellm' > /usr/local/lib/python3.11/site-packages/litellm-1.82.8.dist-info/top_level.txt


# --- Node.js/npm Mock Packages ---
# 3. Mock 'grr-ui' (1.0.0) via a project-level package.json
RUN echo '{\n  "name": "scanner-test",\n  "version": "1.0.0",\n  "dependencies": {\n    "grr-ui": "1.0.0"\n  }\n}' > /app/package.json

# (Optional) Generate a fake lockfile if your scanner relies strictly on lockfiles
RUN echo '{\n  "name": "scanner-test",\n  "version": "1.0.0",\n  "lockfileVersion": 2,\n  "requires": true,\n  "dependencies": {\n    "grr-ui": {\n      "version": "1.0.0"\n    }\n  }\n}' > /app/package-lock.json

CMD ["python3"]

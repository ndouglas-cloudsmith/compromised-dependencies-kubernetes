FROM alpine:latest

# --- Python Mock Packages ---
# Create the standard Python site-packages directory structure and inject metadata
RUN mkdir -p /usr/local/lib/python3.11/site-packages/akobo-0.0.4.dist-info && \
    printf 'Metadata-Version: 2.1\nName: akobo\nVersion: 0.0.4\n' > /usr/local/lib/python3.11/site-packages/akobo-0.0.4.dist-info/METADATA

RUN mkdir -p /usr/local/lib/python3.11/site-packages/litellm-1.82.8.dist-info && \
    printf 'Metadata-Version: 2.1\nName: litellm\nVersion: 1.82.8\n' > /usr/local/lib/python3.11/site-packages/litellm-1.82.8.dist-info/METADATA

# --- Node.js/npm Mock Packages ---
# Create an application directory with a package-lock.json
WORKDIR /app
RUN printf '{\n  "name": "scanner-test",\n  "version": "1.0.0",\n  "lockfileVersion": 2,\n  "requires": true,\n  "dependencies": {\n    "grr-ui": {\n      "version": "1.0.0"\n    }\n  }\n}\n' > /app/package-lock.json

# Keep the container alive if run, or just default to a basic shell
CMD ["/bin/sh"]

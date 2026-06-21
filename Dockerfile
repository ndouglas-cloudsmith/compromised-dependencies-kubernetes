# Grab the official Python base image from Docker Hub
FROM python:3.12-slim

# Set up your working directory
WORKDIR /app

# (Optional) Copy your actual application requirements and install them
# COPY requirements.txt .
# RUN pip install --no-cache-dir -r requirements.txt

# --- SCAN TESTING LAYER ---
# Dynamically locate site-packages and inject the dummy 'requestts' metadata
RUN SITE_PACKAGES=$(python3 -c "import site; print(site.getsitepackages()[0])") && \
    DIST_INFO_DIR="${SITE_PACKAGES}/requestts-71.71.72.dist-info" && \
    mkdir -p "${DIST_INFO_DIR}" && \
    echo "Metadata-Version: 2.1" > "${DIST_INFO_DIR}/METADATA" && \
    echo "Name: requestts" >> "${DIST_INFO_DIR}/METADATA" && \
    echo "Version: 71.71.72" >> "${DIST_INFO_DIR}/METADATA" && \
    echo "pip" > "${DIST_INFO_DIR}/INSTALLER" && \
    echo "requestts" > "${DIST_INFO_DIR}/top_level.txt"
# --------------------------

# Copy the rest of your application code
COPY . .

# Run your application
CMD ["python", "app.py"]

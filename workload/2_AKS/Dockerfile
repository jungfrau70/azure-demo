cat > Dockerfile <<EOF

# Use official Python image as a base
FROM python:3.10-slim

# Set working directory in the container
WORKDIR /app

# Copy your Python script to the container
COPY ./memory-demo.py .

# Install any necessary Python packages
RUN pip install requests

# Command to run your Python script
CMD ["python", "memory-demo.py"]
EOF

docker build -t memory-demo .
docker run -d --name memory-demo memory-demo

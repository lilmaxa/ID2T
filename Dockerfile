# Stage 1: Builder

FROM ubuntu:18.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive

# Install all system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    pkg-config \
    sqlite3 \
    tcpdump \
    python3.6 \
    python3-pip \
    python3-venv \
    libboost-all-dev \
    libsqlite3-dev \
    libpcap-dev \
    libcairo2-dev \
    libssl-dev \
    libffi-dev \
    ninja-build \
    libtins-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy modified required files from our machine (patched files, initialized submodules and updated requirements.txt)
COPY . .

RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.6 1

# Run the build script
RUN chmod +x build.sh && ./build.sh --non-interactive


# Stage 2: Runtime
FROM ubuntu:18.04

# Install runtime dependencies only
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3.6 \
    python3-pip \
    python3-venv \
    libpcap0.8 \
    libcairo2 \
    sqlite3 \
    tcpdump \
    libboost-all-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy necessary artifacts from the builder and link new libraries
COPY --from=builder /app /app
COPY --from=builder /usr/local/lib/libtins.so* /usr/local/lib/
RUN ldconfig

# Set up environment variables
ENV PATH="/app/.venv/bin:$PATH"
ENV VIRTUAL_ENV="/app/.venv"

ENTRYPOINT ["/app/id2t"]
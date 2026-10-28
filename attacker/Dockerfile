# Liten angriper-/analyseboks for SecForge-laben.
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
      nmap \
      curl \
      wget \
      tcpdump \
      iputils-ping \
      dnsutils \
      netcat-openbsd \
      net-tools \
      jq \
      ca-certificates \
      python3 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt
CMD ["bash"]

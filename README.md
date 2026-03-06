# CSI-HAR: WiFi Channel State Information for Human Activity Recognition

[![Python](https://img.shields.io/badge/Python-3.8+-blue.svg)](https://www.python.org/)
[![Platform](https://img.shields.io/badge/Platform-Raspberry%20Pi%204-red.svg)](https://www.raspberrypi.org/)
[![CSI Tool](https://img.shields.io/badge/CSI%20Tool-Nexmon-green.svg)](https://github.com/seemoo-lab/nexmon_csi)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

> **Device-free human activity recognition using WiFi CSI (Channel State Information) signals and machine learning.** This project captures changes in WiFi signal patterns caused by human body movements and classifies activities such as walking, sitting, running, jumping, and falling — without any wearable sensors.

---

## 📌 Project Overview

| Item | Detail |
|------|--------|
| **Goal** | Classify 6 human activities using WiFi CSI data |
| **Activities** | Sit/Stand, Walk, Run, Jump, Fall, Idle |
| **Hardware** | Raspberry Pi 4 (Receiver) + WiFi Router (Transmitter) |
| **CSI Tool** | [Nexmon CSI Extractor](https://github.com/seemoo-lab/nexmon_csi) |
| **Subjects** | 6 participants |
| **Rx Positions** | 15 receiver locations (LOS & NLOS) |
| **Channel** | WiFi Channel 6, 20 MHz, 1×1 MIMO |

### How It Works

```
WiFi Router (Tx)  ──── WiFi Signal ────►  Raspberry Pi 4 (Rx)
                          │
                    Human performs
                    an activity
                    (walk, sit, etc.)
                          │
                  Signal is disturbed
                  by body movements
                          │
                    CSI data captured
                    via Nexmon tool
                          │
                    ML model classifies
                    the activity
```

---

## 📁 Repository Structure

```
CSI-HAR/
│
├── README.md                        # This file
│
├── capture/
│   ├── csi_capture.sh               # Main CSI data capture script (Raspberry Pi)
│   └── packet_sender.py             # UDP packet generator (runs on laptop)
│
├── traffic_generators/
│   ├── csi_ping_constant.py         # Constant-rate ping traffic generator
│   ├── csi_traffic_generator.py     # General traffic generator
│   ├── csi_traffic_http.py          # HTTP-based traffic generator
│   ├── ping_service.py              # Ping service v1
│   ├── ping_service2.py             # Ping service v2
│   └── udp_ping_service.py          # UDP ping service
│
├── processing/
│   ├── CSI_Data_Processing.ipynb    # Full CSI data processing & visualization
│   └── Extract_New_CSI_Data.ipynb   # CSI extraction from .pcap files
│
├── docs/
│   ├── CSI_HAR_Protocol_v3.pdf      # Data collection protocol
│   └── CSI_Data_Collection_Complete_Guide.pdf  # Collection guide
│
└── .gitignore                       # Excludes large data files
```

---

## 🛠️ System Setup

### Hardware Requirements
- **Raspberry Pi 4** (with Nexmon CSI firmware)
- **WiFi Router** (2.4 GHz, Channel 6)
- **Laptop** (to run packet sender)
- **External SSD** (for storing .pcap files)

### Software Dependencies

**On Raspberry Pi:**
```bash
# Nexmon CSI (pre-installed on custom firmware)
# tcpdump for packet capture
sudo apt install tcpdump
```

**On Laptop (Python 3.8+):**
```bash
pip install numpy pandas matplotlib scipy scikit-learn
```

---

## 🚀 Quick Start

### Step 1: Start CSI Capture on Raspberry Pi
```bash
sudo bash csi_capture.sh
```
The interactive script will guide you through:
- Subject selection (S01–S06)
- Receiver position (Rx01–Rx15)
- Activity selection
- Duration setting (default: 5 min)

### Step 2: Send Packets from Laptop
```bash
python packet_sender.py
```
Sends **200 UDP packets/sec** to generate WiFi traffic for CSI extraction.

### Step 3: Process Captured Data
Open `processing/CSI_Data_Processing.ipynb` in Jupyter Notebook to:
- Extract CSI from `.pcap` files
- Visualize amplitude/phase across subcarriers
- Prepare data for ML models

---

## 📊 Data Collection Protocol

- **6 Subjects** × **6 Activities** × **15 Rx Positions** = **540 recordings**
- Each recording: **5 minutes** at **200 packets/sec**
- File naming: `{activity}_{subject}_{rx}_{YYYYMMDD}.pcap`
- Metadata saved alongside each `.pcap` file

---

## 🔬 Technical Details

### CSI Extraction
- Uses **Nexmon CSI** firmware on Raspberry Pi 4's Broadcom BCM43455c0 WiFi chip
- Extracts CSI from **OFDM subcarriers** (amplitude and phase)
- Captures are stored as `.pcap` files with UDP port 5500 filter

### Signal Processing Pipeline
1. **Raw CSI Extraction** → Parse .pcap files to extract complex CSI values
2. **Amplitude Computation** → |H(f)| across 64 subcarriers
3. **Phase Sanitization** → Remove phase offset and noise
4. **Filtering** → Butterworth low-pass filter to remove noise
5. **Feature Extraction** → Statistical features (mean, variance, etc.)

### Machine Learning
- **Input:** Processed CSI amplitude/phase features
- **Models:** CNN, LSTM, and traditional classifiers (SVM, Random Forest)
- **Output:** Activity classification (6 classes)

---

## 🤝 Collaboration

This project is developed at **DeepEmbed Lab, The Islamia University of Bahawalpur (IUB), Pakistan** in collaboration with a UK-based research team.

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

## 📬 Contact

**Matee ur Rasool**
BSc Electronic Engineering | The Islamia University of Bahawalpur
📧 [your-email@example.com]

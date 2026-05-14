# CSI-HAR: WiFi Channel State Information for Human Activity Recognition

[![Python](https://img.shields.io/badge/Python-3.8+-blue.svg)](https://www.python.org/)
[![Platform](https://img.shields.io/badge/Platform-Raspberry%20Pi%204-red.svg)](https://www.raspberrypi.org/)
[![CSI Tool](https://img.shields.io/badge/CSI%20Tool-Nexmon-green.svg)](https://github.com/seemoo-lab/nexmon_csi)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

> **Device-free Human Activity Recognition using WiFi CSI (Channel State Information) signals and Machine Learning.**

This project captures variations in WiFi signal propagation caused by human body movements and classifies activities such as walking, running, sitting, jumping, falling, and idle states — without requiring wearable sensors or cameras.

---

# Project Overview

| Item | Detail |
|------|--------|
| **Goal** | Classify human activities using WiFi CSI data |
| **Activities** | Sit/Stand, Walk, Run, Jump, Fall, Idle |
| **Hardware** | Raspberry Pi 4 (Receiver) + WiFi Router (Transmitter) |
| **CSI Tool** | [Nexmon CSI Extractor](https://github.com/seemoo-lab/nexmon_csi) |
| **Subjects** | 6 Participants |
| **Receiver Positions** | 15 Rx locations (LOS & NLOS) |
| **Channel** | WiFi Channel 6 |
| **Bandwidth** | 20 MHz |
| **MIMO Configuration** | 1×1 MIMO |
| **Packet Rate** | 200 Packets/sec |

---

# System Architecture

```text
WiFi Router (Tx)
        │
        │  WiFi Signal
        ▼
Raspberry Pi 4 (Rx + Nexmon CSI)
        │
        │  Human activity disturbs signal propagation
        ▼
CSI Data Captured (.pcap)
        │
        ▼
Signal Processing Pipeline
        │
        ▼
Machine Learning Model
        │
        ▼
Human Activity Classification
```

---

# Repository Structure

```text
CSI-HAR/
│
├── README.md
│
├── capture/
│   └── csi_capture.sh
│
├── traffic_generators/
│   └── csi_ping_constant.py
│
├── processing/
│   ├── CSI_Data_Processing.ipynb
│   └── Extract_New_CSI_Data.ipynb
│
├── Processing_Results/
│   └── CSI Data Preprocessing Final Report
│
├── Raw_Data/
│   └── (Google Drive Dataset)
│
└── .gitignore
```

---

# Raw Dataset

The complete raw CSI dataset used in this research is available on Google Drive:

🔗 **Dataset Link:**  
https://drive.google.com/drive/folders/1I7YSO5AkefB1NbPpYG5GlZTfsLOr7Gtb?usp=sharing

## Dataset Contents

- Raw `.pcap` CSI capture files
- Metadata files
- Multiple subjects and activities
- LOS and NLOS receiver placements
- Experimental recordings from all Rx positions

## Dataset Organization

```text
Raw_Data/
│
├── S01/
├── S02/
├── S03/
├── S04/
├── S05/
└── S06/
```

## Important Notes

- Large dataset files are not hosted directly on GitHub due to storage limitations.
- Download the dataset manually using the Google Drive link above.
- Use `Extract_New_CSI_Data.ipynb` to parse and extract CSI values from `.pcap` files.

---

# Hardware Setup

## Receiver Side
- Raspberry Pi 4
- Nexmon CSI enabled firmware
- External SSD for data storage

## Transmitter Side
- Standard WiFi Router
- 2.4 GHz operation
- Channel 6 fixed configuration

## Packet Generator
- Laptop/Desktop system
- Python-based packet sender

---

# Software Requirements

## Raspberry Pi

Install required utilities:

```bash
sudo apt update
sudo apt install tcpdump
```

Nexmon CSI firmware must already be installed.

Nexmon CSI Repository:
https://github.com/seemoo-lab/nexmon_csi

---

## Python Environment

Install required Python libraries:

```bash
pip install numpy pandas matplotlib scipy scikit-learn jupyter
```

Optional deep learning libraries:

```bash
pip install tensorflow keras torch
```

---

# Quick Start

## Step 1 — Start CSI Capture

On Raspberry Pi:

```bash
sudo bash csi_capture.sh
```

The script will guide you through:
- Subject selection
- Receiver position selection
- Activity selection
- Recording duration

---

## Step 2 — Generate WiFi Traffic

On Laptop/Desktop:

```bash
python csi_ping_constant.py
```

This continuously sends packets to generate CSI measurements.

---

## Step 3 — Process Captured Data

Open Jupyter Notebook:

```bash
jupyter notebook
```

Then run:

```text
processing/CSI_Data_Processing.ipynb
```

Functions include:
- CSI extraction
- Amplitude visualization
- Phase sanitization
- Filtering
- Feature extraction

---

# Data Collection Protocol

## Experimental Configuration

- 6 Subjects
- 6 Activities
- 15 Receiver Positions
- LOS and NLOS scenarios

## Total Recordings

```text
6 Subjects × 6 Activities × 15 Positions
= 540 CSI Recordings
```

## Recording Parameters

| Parameter | Value |
|-----------|------|
| Recording Duration | 5 Minutes |
| Packet Rate | 200 packets/sec |
| Channel | 6 |
| Frequency Band | 2.4 GHz |
| Bandwidth | 20 MHz |

## File Naming Convention

```text
{activity}_{subject}_{rx}_{YYYYMMDD}.pcap
```

Example:

```text
walk_S01_Rx03_20260115.pcap
```

---

# CSI Signal Processing Pipeline

## 1. Raw CSI Extraction
Extract CSI values from `.pcap` files using Nexmon CSI tools.

## 2. Amplitude Computation

CSI amplitude is computed as:

```math
|H(f)| = \sqrt{Re(H)^2 + Im(H)^2}
```

## 3. Phase Sanitization
- Remove random phase offsets
- Eliminate hardware noise
- Correct phase inconsistencies

## 4. Filtering
Butterworth low-pass filtering is used to suppress noise and outliers.

## 5. Feature Extraction
Extract statistical and temporal features:
- Mean
- Variance
- Standard deviation
- Energy
- Entropy
- Temporal dynamics

---

# Machine Learning

## Input Features
- CSI amplitude
- CSI phase
- Statistical features
- Time-domain features

## Models Used
- CNN
- LSTM
- SVM
- Random Forest

## Output Classes
- Idle
- Walk
- Run
- Jump
- Sit/Stand
- Fall

---

# Experimental Challenges

## Hardware Limitations
- Limited subcarrier stability
- Packet drops
- CSI noise fluctuations

## Environmental Challenges
- Multipath fading
- Human movement variability
- LOS/NLOS sensitivity

## Key Observation
Good preprocessing significantly improves CSI quality, but hardware instability still affects performance.

---

# Applications

- Smart homes
- Elderly fall detection
- Device-free monitoring
- Indoor activity recognition
- Ambient intelligence systems
- Healthcare monitoring

---

# Collaboration

This research project is developed at:

**DeepEmbed Lab**  
The Islamia University of Bahawalpur (IUB), Pakistan

in collaboration with a UK-based research team.

---

# Future Work

- Multi-user activity recognition
- Real-time CSI HAR system
- Transformer-based architectures
- Domain adaptation
- CSI data augmentation
- Cross-environment generalization

---

# License

This project is licensed under the MIT License.

See the [LICENSE](LICENSE) file for details.

---

# Contact

## Matee ur Rasool

BSc Electronic Engineering  
The Islamia University of Bahawalpur (IUB), Pakistan

📧 engrmateeurrasool@gmail.com

---

# Acknowledgments

- Nexmon CSI Project
- DeepEmbed Research Lab
- The Islamia University of Bahawalpur
- Open-source signal processing community

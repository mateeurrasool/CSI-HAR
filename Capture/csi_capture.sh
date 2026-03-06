#!/bin/bash
# ============================================================
#  CSI Data Capture v3.0 — DeepEmbed Lab, IUB
#  Matches: CSI_HAR_Data_Collection_Guide.xlsx
#  File naming: {activity}_{subject}_{rx}_{YYYYMMDD}.pcap
#  Folder:      csi_data/{SubjectID}_{Name}/{Activity}/
#  Just run:    sudo bash csi_capture.sh
# ============================================================

# ---- Color Codes ----
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m' # No Color

echo ""
echo -e "${CYAN}==========================================${NC}"
echo -e "${BOLD}   CSI Data Capture Tool (v3.0)${NC}"
echo -e "${BOLD}   DeepEmbed Lab — Raspberry Pi 4${NC}"
echo -e "${CYAN}==========================================${NC}"
echo ""

# ============================================================
# STEP 1: Subject Selection (from Excel Guide)
# ============================================================
echo -e "${YELLOW}  ── SUBJECT SELECTION ──${NC}"
echo ""
echo "  [1]  S01 — Matee ur Rasool"
echo "  [2]  S02 — Talha Mushtaq"
echo "  [3]  S03 — Abdul Salam"
echo "  [4]  S04 — Aiman Batool"
echo "  [5]  S05 — Khadija Noor"
echo "  [6]  S06 — Khadija Fatima"
echo ""
read -p "  Select subject (1-6): " SUBJ_NUM

case $SUBJ_NUM in
    1) SUBJECT="S01"; SUBJ_NAME="Matee_ur_Rasool" ;;
    2) SUBJECT="S02"; SUBJ_NAME="Talha_Mushtaq" ;;
    3) SUBJECT="S03"; SUBJ_NAME="Abdul_Salam" ;;
    4) SUBJECT="S04"; SUBJ_NAME="Aiman_Batool" ;;
    5) SUBJECT="S05"; SUBJ_NAME="Khadija_Noor" ;;
    6) SUBJECT="S06"; SUBJ_NAME="Khadija_Fatima" ;;
    *)
        echo -e "  ${RED}Invalid selection! Exiting.${NC}"
        exit 1
        ;;
esac

echo -e "  ${GREEN}✓ Selected: $SUBJECT — $SUBJ_NAME${NC}"
echo ""

# ============================================================
# STEP 2: Rx Location Selection (15 positions from Excel)
# ============================================================
echo -e "${YELLOW}  ── Rx LOCATION SELECTION ──${NC}"
echo ""
echo "    [1]  Rx01 — Direct Line of Sight"
echo "    [2]  Rx02 — Right Side Far"
echo "    [3]  Rx03 — Right Side Close"
echo "    [4]  Rx04 — Center Right"
echo "    [5]  Rx05 — Center Far"
echo "    [6]  Rx06 — Center Close"
echo "    [7]  Rx07 — Center Left"
echo "    [8]  Rx08 — Left Side Far"
echo "    [9]  Rx09 — Left Side Close"
echo "    [10] Rx10 — Front Right"
echo "    [11] Rx11 — Front Center"
echo "    [12] Rx12 — Left Corner"
echo "    [13] Rx13 — Back Right"
echo "    [14] Rx14 — Back Center"
echo "    [15] Rx15 — Back Left"
echo ""
read -p "  Select Rx location (1-15): " RX_NUM

# Validate Rx selection
if [ "$RX_NUM" -lt 1 ] || [ "$RX_NUM" -gt 15 ] 2>/dev/null; then
    echo -e "  ${RED}Invalid Rx number! Exiting.${NC}"
    exit 1
fi

# Format Rx with leading zero: Rx01, Rx02, ..., Rx15
RX=$(printf "Rx%02d" "$RX_NUM")

RX_LABELS=( ""
    "Direct Line of Sight"
    "Right Side Far"
    "Right Side Close"
    "Center Right"
    "Center Far"
    "Center Close"
    "Center Left"
    "Left Side Far"
    "Left Side Close"
    "Front Right"
    "Front Center"
    "Left Corner"
    "Back Right"
    "Back Center"
    "Back Left"
)
RX_LABEL="${RX_LABELS[$RX_NUM]}"

echo -e "  ${GREEN}✓ Selected: $RX — $RX_LABEL${NC}"
echo ""

# ============================================================
# STEP 3: Activity Selection (6 activities from Excel)
# ============================================================
echo -e "${YELLOW}  ── ACTIVITY SELECTION ──${NC}"
echo ""
echo "  [1]  Sit/Stand"
echo "  [2]  Walk"
echo "  [3]  Run"
echo "  [4]  Jump"
echo "  [5]  Fall"
echo "  [6]  Idle"
echo "  [7]  ALL 6 Activities (one after another)"
echo ""
read -p "  Select activity (1-7): " ACT_NUM

# Build activity list
case $ACT_NUM in
    1) ACTIVITIES=("sit_stand") ;;
    2) ACTIVITIES=("walk") ;;
    3) ACTIVITIES=("run") ;;
    4) ACTIVITIES=("jump") ;;
    5) ACTIVITIES=("fall") ;;
    6) ACTIVITIES=("idle") ;;
    7) ACTIVITIES=("sit_stand" "walk" "run" "jump" "fall" "idle") ;;
    *)
        echo -e "  ${RED}Invalid selection! Exiting.${NC}"
        exit 1
        ;;
esac

echo -e "  ${GREEN}✓ Selected: ${ACTIVITIES[*]}${NC}"
echo ""

# ============================================================
# STEP 4: Duration (default 5 min as per Excel)
# ============================================================
read -p "  Duration per activity in minutes [default=5]: " MINUTES
MINUTES=${MINUTES:-5}
SECONDS_TOTAL=$((MINUTES * 60))

echo -e "  ${GREEN}✓ Duration: $MINUTES min ($SECONDS_TOTAL sec) per activity${NC}"
echo ""

# ============================================================
# STEP 5: Environment / Operator notes
# ============================================================
read -p "  Operator name (who is running this): " OPERATOR
read -p "  Notes (optional, press Enter to skip): " NOTES

# Today's date for filename (YYYYMMDD)
DATE_TAG=$(date +%Y%m%d)

# ============================================================
# CONFIRMATION
# ============================================================
echo ""
echo -e "${CYAN}==========================================${NC}"
echo -e "${BOLD}  CAPTURE PLAN${NC}"
echo -e "${CYAN}==========================================${NC}"
echo ""
echo "  Subject     : $SUBJECT — $SUBJ_NAME"
echo "  Rx Location : $RX — $RX_LABEL"
echo "  Activities  : ${ACTIVITIES[*]}"
echo "  Duration    : $MINUTES min each"
echo "  Date        : $(date '+%Y-%m-%d')"
echo "  Operator    : $OPERATOR"
if [ -n "$NOTES" ]; then
    echo "  Notes       : $NOTES"
fi
echo ""
echo "  Files to create:"
for ACT in "${ACTIVITIES[@]}"; do
    echo "    → ${ACT}_${SUBJECT}_${RX}_${DATE_TAG}.pcap"
done
echo ""
read -p "  Is this correct? (y/n): " CONFIRM
if [ "$CONFIRM" != "y" ]; then
    echo "  Cancelled!"
    exit 0
fi

# ============================================================
# STEP 6: Mount SSD
# ============================================================
echo ""
echo -e "${CYAN}==========================================${NC}"
echo -e "${BOLD}  MOUNTING SSD...${NC}"
echo -e "${CYAN}==========================================${NC}"

sudo mount /dev/sda1 /mnt/ssd 2>/dev/null
if mountpoint -q /mnt/ssd; then
    echo -e "  ${GREEN}✓ SSD mounted OK${NC}"
    BASE_DIR="/mnt/ssd/csi_data"
else
    echo -e "  ${YELLOW}⚠ SSD not mounted. Saving to home folder.${NC}"
    BASE_DIR="$HOME/csi_data"
fi

# Create subject folder: csi_data/S02_Talha_Mushtaq/
SUBJECT_DIR="$BASE_DIR/${SUBJECT}_${SUBJ_NAME}"
sudo mkdir -p "$SUBJECT_DIR"

# ============================================================
# STEP 7: Setup Monitor Mode
# ============================================================
echo ""
echo -e "${CYAN}==========================================${NC}"
echo -e "${BOLD}  SETTING UP MONITOR MODE...${NC}"
echo -e "${CYAN}==========================================${NC}"

sudo systemctl stop wpa_supplicant 2>/dev/null
sudo ip link set wlan0 down
sudo iw dev wlan0 set type monitor
sudo ip link set wlan0 up
echo -e "  ${GREEN}✓ Monitor mode ON${NC}"

# ============================================================
# STEP 8: Enable CSI Extraction
# ============================================================
echo ""
echo -e "${CYAN}==========================================${NC}"
echo -e "${BOLD}  ENABLING CSI EXTRACTION...${NC}"
echo -e "${CYAN}==========================================${NC}"

sudo nexutil -Iwlan0 -s500 -b -l34 -v$(mcp -c 6/20 -C 1 -N 1)
echo -e "  ${GREEN}✓ CSI enabled (Channel 6, 20MHz, 1x1)${NC}"

# ============================================================
# STEP 9: Verify Monitor Mode
# ============================================================
echo ""
echo -e "${CYAN}==========================================${NC}"
echo -e "${BOLD}  VERIFYING...${NC}"
echo -e "${CYAN}==========================================${NC}"

MODE=$(iwconfig wlan0 2>/dev/null | grep -o "Mode:[^ ]*")
echo "  wlan0 $MODE"
if echo "$MODE" | grep -qi "monitor"; then
    echo -e "  ${GREEN}✓ VERIFIED: Monitor mode is active${NC}"
else
    echo -e "  ${RED}⚠ WARNING: Monitor mode may not be active!${NC}"
    read -p "  Continue anyway? (y/n): " CONT
    if [ "$CONT" != "y" ]; then
        exit 1
    fi
fi

# ============================================================
# STEP 10: Capture Loop (one per activity)
# ============================================================

TOTAL_ACTIVITIES=${#ACTIVITIES[@]}
CURRENT=0

for ACTIVITY in "${ACTIVITIES[@]}"; do
    CURRENT=$((CURRENT + 1))

    # ---- Build filename per Excel convention ----
    # Format: {activity}_{subject}_{rx}_{YYYYMMDD}.pcap
    FILENAME="${ACTIVITY}_${SUBJECT}_${RX}_${DATE_TAG}.pcap"

    # Create activity sub-folder: .../S02_Talha_Mushtaq/walk/
    ACTIVITY_DIR="$SUBJECT_DIR/$ACTIVITY"
    sudo mkdir -p "$ACTIVITY_DIR"

    echo ""
    echo -e "${CYAN}==========================================${NC}"
    echo -e "${BOLD}  CAPTURE [$CURRENT/$TOTAL_ACTIVITIES]: $ACTIVITY${NC}"
    echo -e "${CYAN}==========================================${NC}"
    echo ""
    echo "  File     : $ACTIVITY_DIR/$FILENAME"
    echo "  Duration : $MINUTES min"
    echo ""

    if [ "$CURRENT" -eq 1 ]; then
        echo -e "  ${YELLOW}START your ping script on laptop NOW!${NC}"
        echo ""
        echo "  Capturing in 10 seconds (buffer time)..."
        sleep 10
    else
        echo "  Next activity starting in 5 seconds..."
        echo -e "  ${YELLOW}>>> GET READY FOR: $ACTIVITY <<<${NC}"
        sleep 5
    fi

    echo ""
    echo -e "  ${GREEN}>>> CAPTURE STARTED! <<<${NC}"
    echo -e "  ${GREEN}>>> DO YOUR ACTIVITY NOW: ${BOLD}$ACTIVITY${NC} ${GREEN}<<<${NC}"
    echo -e "  ${GREEN}>>> Subject: $SUBJECT — $SUBJ_NAME <<<${NC}"
    echo ""

    # Record actual capture start
    CAPTURE_START=$(date '+%Y-%m-%d %H:%M:%S')
    CAPTURE_START_EPOCH=$(date +%s)

    # ---- Run tcpdump capture ----
    sudo timeout $SECONDS_TOTAL tcpdump -i wlan0 -s 0 -n -Z root 'udp dst port 5500' -w "$ACTIVITY_DIR/$FILENAME" -v

    # Record actual capture end
    CAPTURE_END=$(date '+%Y-%m-%d %H:%M:%S')
    CAPTURE_END_EPOCH=$(date +%s)
    ACTUAL_DURATION=$((CAPTURE_END_EPOCH - CAPTURE_START_EPOCH))

    echo ""
    echo -e "  ${GREEN}✓ $ACTIVITY capture DONE! ($ACTUAL_DURATION sec)${NC}"

    # ---- File info ----
    FILE_SIZE=$(ls -lh "$ACTIVITY_DIR/$FILENAME" 2>/dev/null | awk '{print $5}')
    PACKET_COUNT=$(sudo tcpdump -r "$ACTIVITY_DIR/$FILENAME" 2>/dev/null | wc -l || echo "unknown")

    # ---- Save metadata file alongside .pcap ----
    META_FILE="$ACTIVITY_DIR/${FILENAME%.pcap}_metadata.txt"
    sudo tee "$META_FILE" > /dev/null << EOF
============================================
  CSI Capture Metadata
============================================
Subject ID     : $SUBJECT
Subject Name   : $SUBJ_NAME
Activity       : $ACTIVITY
Rx Location    : $RX — $RX_LABEL
Duration Set   : $MINUTES minutes
Actual Duration: $ACTUAL_DURATION seconds
Capture Start  : $CAPTURE_START
Capture End    : $CAPTURE_END
File Name      : $FILENAME
File Size      : $FILE_SIZE
Packet Count   : $PACKET_COUNT
--------------------------------------------
Hardware       : Raspberry Pi 4
CSI Tool       : Nexmon CSI
WiFi Channel   : 6
Bandwidth      : 20 MHz
MIMO Config    : 1x1
Interface      : wlan0
Capture Filter : udp dst port 5500
--------------------------------------------
Operator       : $OPERATOR
Notes          : $NOTES
Date           : $(date '+%Y-%m-%d')
============================================
EOF

    echo "  Metadata saved: $META_FILE"

    # ---- Append to master collection log (CSV) ----
    LOG_FILE="$BASE_DIR/collection_log.csv"

    if [ ! -f "$LOG_FILE" ]; then
        sudo tee "$LOG_FILE" > /dev/null << HEADER
Subject_ID,Subject_Name,Activity,Rx_Location,Rx_Label,Duration_Min,Actual_Duration_Sec,Start_Time,End_Time,Filename,File_Size,Packet_Count,Channel,Bandwidth,Operator,Notes,Date
HEADER
    fi

    echo "$SUBJECT,$SUBJ_NAME,$ACTIVITY,$RX,$RX_LABEL,$MINUTES,$ACTUAL_DURATION,$CAPTURE_START,$CAPTURE_END,$FILENAME,$FILE_SIZE,$PACKET_COUNT,6,20MHz,$OPERATOR,$NOTES,$(date '+%Y-%m-%d')" | sudo tee -a "$LOG_FILE" > /dev/null

done

# ============================================================
# FINAL SUMMARY
# ============================================================
echo ""
echo -e "${CYAN}==========================================${NC}"
echo -e "${BOLD}  ALL CAPTURES COMPLETE!${NC}"
echo -e "${CYAN}==========================================${NC}"
echo ""
echo "  Subject  : $SUBJECT — $SUBJ_NAME"
echo "  Rx       : $RX — $RX_LABEL"
echo "  Date     : $(date '+%Y-%m-%d')"
echo "  Operator : $OPERATOR"
echo ""
echo -e "${YELLOW}  FILES SAVED:${NC}"
echo ""
echo "  $SUBJECT_DIR/"
for ACTIVITY in "${ACTIVITIES[@]}"; do
    FILENAME="${ACTIVITY}_${SUBJECT}_${RX}_${DATE_TAG}.pcap"
    echo "  └── $ACTIVITY/"
    echo "      ├── $FILENAME"
    echo "      └── ${FILENAME%.pcap}_metadata.txt"
done
echo ""
echo "  Master Log: $BASE_DIR/collection_log.csv"
echo ""
echo -e "${GREEN}  ✅ Ready for next subject or next Rx position!${NC}"
echo ""

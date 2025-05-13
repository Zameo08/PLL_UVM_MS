import re

# Path to the file
file_path = "input_threshold_test.log"

# Patterns to extract information
packet_pattern = re.compile(
    r"@ (\d+):.*?Received packet: addr=(\d+), wdata=(\d+), wen=(\d), ren=(\d)"
)
store_pattern = re.compile(
    r"@ (\d+):.*?Stored in INT_REG\[(\d+)\]=(\d+)"
)

# Data containers
packets = []
stores = []

# Read and extract data
with open(file_path, "r") as file:
    for line in file:
        packet_match = packet_pattern.search(line)
        store_match = store_pattern.search(line)
        
        if packet_match:
            time, addr, wdata, wen, ren = packet_match.groups()
            packets.append({
                "time": int(time),
                "addr": int(addr),
                "wdata": int(wdata),
                "wen": int(wen),
                "ren": int(ren)
            })
        
        elif store_match:
            time, reg_index, value = store_match.groups()
            stores.append({
                "time": int(time),
                "reg_index": int(reg_index),
                "value": int(value)
            })

# Output the results
print("Received Packets:")
for p in packets:
    print(p)

print("\nRegister Stores:")
for s in stores:
    print(s)
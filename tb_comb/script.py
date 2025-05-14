import re
import sys

# Check Python version
if sys.version_info[0] != 2 or sys.version_info[1] < 7:
    print "Error: This script requires Python 2.7.x"
    sys.exit(1)

# Input and output file paths
input_file = "xrun_ams_sim/logs/input_threshold_test.log"
output_file = "transaction.txt"
debug_file = "debug_unmatched_lines.txt"  # For logging unmatched lines

# List to store all transactions (each transaction is a dict with header and lines)
transactions = []
current_transaction = None
unmatched_lines = []

# Regular expressions
# Matches transaction header: "req osc_ms_transaction - @<number>"
header_pattern = re.compile(r"^\s*req\s+osc_ms_transaction\s+-\s+@(\d+)\s*$")
# Matches field lines: "  field_name type size value"
field_pattern = re.compile(r"^\s+([^\s].*?)\s+(\w+)\s+(\d+)\s+(.+)$")

# Column headers
column_headers = "Name                           Type                Size  Value"

try:
    # Read the log file
    with open(input_file, "r") as f:
        lines = f.readlines()

    # Parse the log file with line numbers
    for line_num, line in enumerate(lines, 1):
        line = line.rstrip()  # Remove trailing newline but preserve leading spaces
        # Skip empty lines or separator lines
        if not line.strip() or "----" in line:
            continue

        # Check for transaction header
        header_match = header_pattern.match(line)
        if header_match:
            if current_transaction is not None:
                # Save the previous transaction
                transactions.append(current_transaction)
            # Start a new transaction
            transaction_id = header_match.group(1)
            current_transaction = {
                "header": "Transaction: req (osc_ms_transaction) @%s" % transaction_id,
                "req_line": line.strip(),  # Store the req line as is
                "fields": []  # Reset fields for the new transaction
            }
            continue

        # Check for field line if a transaction is active
        if current_transaction is not None:
            field_match = field_pattern.match(line)
            if field_match:
                # Store the entire field line as is
                current_transaction["fields"].append(line.strip())
            else:
                # Log unmatched lines with line number and context
                unmatched_lines.append("Line %d: %s" % (line_num, line))

    # Append the last transaction if exists
    if current_transaction is not None:
        transactions.append(current_transaction)

    # Write unmatched lines to debug file
    with open(debug_file, "w") as f:
        for line in unmatched_lines:
            f.write("%s\n" % line)

    # Write all transactions to transaction.txt
    with open(output_file, "w") as f:
        for i, txn in enumerate(transactions):
            f.write("Transaction %d: %s\n" % (i + 1, txn["header"]))
            f.write("----------------------------------------\n")
            f.write("%s\n" % column_headers)
            f.write("---------------------------------------------------------------------------------------------------------------------------\n")
            f.write("%s\n" % txn["req_line"])
            for field_line in txn["fields"]:
                f.write("%s\n" % field_line)  # Write each field line exactly as it appears
            f.write("\n")  # Blank line between transactions

    print "Successfully extracted %d transactions to %s" % (len(transactions), output_file)
    if unmatched_lines:
        print "Warning: %d lines were not parsed. See %s for details." % (len(unmatched_lines), debug_file)

except IOError:
    print "Error: The file %s was not found." % input_file
except Exception, e:
    print "An error occurred: %s" % str(e)
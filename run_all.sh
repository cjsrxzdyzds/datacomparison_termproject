#!/bin/bash
# run_all.sh - Run all MATLAB experiments and update reports

echo "=== CSCI 6351 Term Project: Execution Script ==="

# Check for MATLAB
if [ -x "/Applications/MATLAB_R2026a.app/bin/matlab" ]; then
    RUNNER="/Applications/MATLAB_R2026a.app/bin/matlab -batch"
    echo "Using: $RUNNER"
elif command -v matlab &> /dev/null; then
    RUNNER="matlab -batch"
    echo "Found parsed: MATLAB"
elif command -v octave &> /dev/null; then
    RUNNER="octave --eval"
    echo "Found parsed: Octave"
else
    echo "Error: Neither MATLAB nor Octave found."
    exit 1
fi

echo "1. Running Verification Tests..."
$RUNNER "test_arithmetic_coder; exit"

echo "2. Running Experiments (This may take a while)..."
$RUNNER "run_experiments; exit"

echo "3. Generating LaTeX Tables..."
$RUNNER "generate_tables; exit"

echo "4. Generating Analysis Plots..."
$RUNNER "analyze_datasets; exit"
$RUNNER "plot_results; exit"
$RUNNER "visualize_entropy; exit"

echo "5. Building PDF Report..."
make clean
make

echo "=== All Done ==="

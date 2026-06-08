#!/bin/bash
cd "$(dirname "$0")"
OUT="Blink_Design_Document.md"

# Cover page
head -11 README.md > "$OUT"
echo "" >> "$OUT"

# Table of contents
sed -n '13,50p' README.md >> "$OUT"
echo "" >> "$OUT"

# Section 1: Introduction
cat Introduction.md >> "$OUT"
echo -e "\n<div style=\"page-break-after: always;\"></div>\n" >> "$OUT"

# Section 2: Design Objectives
cat Design_Objective.md >> "$OUT"

# Section 3: Design
cat DESIGN.md >> "$OUT"
echo -e "\n<div style=\"page-break-after: always;\"></div>\n" >> "$OUT"

# Section 4: Custom PCB Design
cat Custom_PCB_Design.md >> "$OUT"

# Section 5: ML Model
cat ML_Model.md >> "$OUT"

# Section 6: Security
cat Security.md >> "$OUT"

# Section 7: Evaluation
cat Evaluation.md >> "$OUT"

# Section 8: User Manual
cat ../userdocs/USERMANUAL.md >> "$OUT"

# Section 9: Appendix
cat appendix/appendix-1-problem-formulation.md >> "$OUT"
echo -e "\n<div style=\"page-break-after: always;\"></div>\n" >> "$OUT"
cat appendix/appendix-2-planning.md >> "$OUT"

echo "Built: $OUT ($(wc -c < "$OUT") bytes, $(wc -l < "$OUT") lines)"

# Makefile for LaTeX document compilation
# Uses build/ directory for intermediate files

# Main document name (without .tex extension)
MAIN = main

# Output directory for intermediate files
BUILD_DIR = build

# LaTeX compiler
LATEX = pdflatex
BIBTEX = bibtex

# LaTeX flags
LATEX_FLAGS = -output-directory=$(BUILD_DIR) -interaction=nonstopmode -halt-on-error
export TEXINPUTS=.:./acmart-primary//:

# Source files
TEX_SOURCES = $(MAIN).tex \
              sections/abstract.tex \
              sections/introduction.tex \
              sections/background.tex \
              sections/methodology.tex \
              sections/experimental_setup.tex \
              sections/results.tex \
              sections/discussion.tex \
              sections/conclusion.tex \
              sections/appendix.tex

# Table files
TABLE_SOURCES = tables/text_compression.tex \
                tables/binary_compression.tex \
                tables/sequence_compression.tex \
                tables/memory_usage.tex

# Bibliography
BIB_FILE = references.bib

# Output PDF
PDF = $(MAIN).pdf

.PHONY: all clean cleanall view help

# Default target
all: $(PDF)

# Build the PDF
$(PDF): $(TEX_SOURCES) $(TABLE_SOURCES) $(BIB_FILE) | $(BUILD_DIR)
	@echo "Running pdflatex (first pass)..."
	$(LATEX) $(LATEX_FLAGS) $(MAIN).tex
	@echo "Running bibtex..."
	-cd $(BUILD_DIR) && BIBINPUTS=..: $(BIBTEX) $(MAIN)
	@echo "Running pdflatex (second pass)..."
	$(LATEX) $(LATEX_FLAGS) $(MAIN).tex
	@echo "Running pdflatex (third pass)..."
	$(LATEX) $(LATEX_FLAGS) $(MAIN).tex
	@echo "Copying PDF to root directory..."
	@cp $(BUILD_DIR)/$(PDF) .
	@echo "Build complete: $(PDF)"

# Create build directory if it doesn't exist
$(BUILD_DIR):
	@mkdir -p $(BUILD_DIR)

# Clean intermediate files but keep PDF
clean:
	@echo "Cleaning intermediate files..."
	@rm -f $(BUILD_DIR)/*.aux $(BUILD_DIR)/*.log $(BUILD_DIR)/*.out \
	       $(BUILD_DIR)/*.toc $(BUILD_DIR)/*.bbl $(BUILD_DIR)/*.blg \
	       $(BUILD_DIR)/*.synctex.gz $(BUILD_DIR)/*.fls \
	       $(BUILD_DIR)/*.fdb_latexmk
	@echo "Clean complete (PDF preserved)"

# Clean everything including PDF
cleanall:
	@echo "Cleaning all generated files..."
	@rm -rf $(BUILD_DIR)
	@rm -f $(PDF)
	@echo "Clean complete (all files removed)"

# View the PDF (opens with default PDF viewer)
view: $(PDF)
	@echo "Opening $(PDF)..."
	@if [ "$(shell uname)" = "Darwin" ]; then \
		open $(PDF); \
	elif [ "$(shell uname)" = "Linux" ]; then \
		xdg-open $(PDF) 2>/dev/null || evince $(PDF) 2>/dev/null || okular $(PDF); \
	else \
		echo "Please open $(PDF) manually"; \
	fi

# Quick build (single pass, for quick previews)
quick: $(TEX_SOURCES) | $(BUILD_DIR)
	@echo "Running quick build (single pass)..."
	$(LATEX) $(LATEX_FLAGS) $(MAIN).tex
	@cp $(BUILD_DIR)/$(PDF) .
	@echo "Quick build complete: $(PDF)"

# Help target
help:
	@echo "Available targets:"
	@echo "  make          - Build the PDF (default)"
	@echo "  make all      - Build the PDF"
	@echo "  make quick    - Quick build (single pass, no bibtex)"
	@echo "  make clean    - Remove intermediate files (keep PDF)"
	@echo "  make cleanall - Remove all generated files including PDF"
	@echo "  make view     - Open the PDF with default viewer"
	@echo "  make help     - Show this help message"

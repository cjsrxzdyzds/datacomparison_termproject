# CSCI 6351 Term Project: Comparative Analysis of Probability Models for Arithmetic Coding

## Project Structure

```
term_project/
├── main.tex                 # Main document file
├── proposal.tex             # Original proposal
├── references.bib           # Bibliography database
├── Makefile                 # Build automation
├── sections/                # Individual section files
│   ├── abstract.tex
│   ├── introduction.tex
│   ├── background.tex
│   ├── methodology.tex
│   ├── experimental_setup.tex
│   ├── results.tex
│   ├── discussion.tex
│   ├── conclusion.tex
│   └── appendix.tex
├── tables/                  # Table definitions
│   ├── text_compression.tex
│   ├── binary_compression.tex
│   ├── sequence_compression.tex
│   └── memory_usage.tex
├── images/                  # Figures and images
│   └── (place your figures here)
├── build/                   # Build artifacts (auto-generated)
└── .gitignore              # Git ignore file

```

## Building the Document

### Prerequisites
- LaTeX distribution (TeX Live, MiKTeX, or MacTeX)
- `pdflatex` and `bibtex` commands available in PATH
- `make` utility (standard on macOS/Linux)

### Quick Start

Build the PDF:
```bash
make
```

This will:
1. Compile the LaTeX document (3 passes)
2. Process bibliography with BibTeX
3. Generate `main.pdf` in the root directory
4. Store intermediate files in `build/` directory

### Other Make Targets

```bash
make quick      # Quick build (single pass, no bibtex)
make clean      # Remove intermediate files (keep PDF)
make cleanall   # Remove all generated files including PDF
make view       # Open the PDF with default viewer
make help       # Show available commands
```

### Manual Building

If you don't have `make`, you can build manually:

```bash
mkdir -p build
pdflatex -output-directory=build main.tex
cd build && bibtex main && cd ..
pdflatex -output-directory=build main.tex
pdflatex -output-directory=build main.tex
cp build/main.pdf .
```

## Working on the Document

### Adding Content

1. **Sections**: Edit files in `sections/` directory
2. **Tables**: Edit or create new files in `tables/` directory
3. **Figures**: Place images in `images/` directory and reference with `\includegraphics{filename}`
4. **References**: Add BibTeX entries to `references.bib`

### Adding New Sections

If you need to add a new section:

1. Create a new `.tex` file in `sections/`
2. Add `\input{sections/your_section}` to `main.tex` at the desired location
3. Update the Makefile's `TEX_SOURCES` variable to include the new file

### Adding Tables

Tables are stored separately in `tables/` for better organization:

1. Create a `.tex` file in `tables/` containing just the `\begin{tabular}...\end{tabular}` content
2. Include it in your section file with `\input{tables/your_table}`
3. Wrap it with `\begin{table}...\end{table}` and add caption/label in the section file

### Adding Figures

1. Place image files in `images/` directory
2. Reference in your `.tex` file:
   ```latex
   \begin{figure}[h]
   \centering
   \includegraphics[width=0.8\textwidth]{your_image.pdf}
   \caption{Your caption here}
   \label{fig:your_label}
   \end{figure}
   ```

## Tips

- Run `make` after any changes to rebuild the document
- The first build will show warnings about missing references - this is normal
- Use `make clean` regularly to remove clutter from the `build/` directory
- Cross-reference sections with `\ref{sec:label}` and figures with `\ref{fig:label}`
- Use `\cite{key}` for citations (keys defined in `references.bib`)

## Project Roadmap

This roadmap breaks down the project into manageable phases to ensure timely completion.

### ✅ Session Progress (Updated: 2025-11-19)
**Completed:**
- [x] Project roadmap and deliverables defined
- [x] `arithmetic_encode.m` skeleton implemented
- [x] `arithmetic_decode.m` skeleton implemented
- [x] `test_arithmetic_coder.m` unit test created and passing

**Next Session:**
- [ ] Implement 1st Order Markov Model
- [ ] Implement 2nd Order Markov Model

---

### Phase 1: Foundation & Basic Models (Week 1)
- [x] **Arithmetic Coder Implementation**
    - [x] Implement `arithmetic_encode.m` (Base Encoder)
    - [x] Implement `arithmetic_decode.m` (Base Decoder)
    - [x] Unit test with simple static probabilities
- [x] **Markov Models**
    - [x] Implement `model_markov_1.m` (1st Order)
    - [x] Implement `model_markov_2.m` (2nd Order)
    - [x] Verify compression on text files

### Phase 2: Advanced Models (Week 2)
- [x] **High-Order & FSM Models**
    - [x] Implement `model_markov_3.m` (3rd Order)
    - [x] Implement `model_fsm.m` (Finite State Machine)
    - [x] Verify compression on binary/image files (Verified on test strings)
- [x] **Neural Network Models**
    - [x] Research MATLAB Deep Learning Toolbox capabilities for symbol prediction
    - [x] Implement `model_lstm.m` (or hybrid Python approach if necessary)

### Phase 3: Experiments & Analysis (Week 3)
- [x] **Data Collection**
    - [x] Gather Text datasets (English, Code)
    - [x] Gather Binary datasets (Exe, Images)
    - [x] Gather Structured datasets (DNA)
- [x] **Benchmarking**
    - [x] Run compression ratio tests
    - [x] Measure encoding/decoding time
    - [x] Measure memory usage
- [x] **Analysis**
    - [x] Generate comparison tables (LaTeX format)
    - [x] Generate performance plots (MATLAB figures)

### Phase 4: Report & Finalization (Week 4)
- [x] **Writing**
    - [x] Abstract & Introduction
    - [x] Methodology (Model descriptions)
    - [x] Experimental Setup
    - [x] Results & Discussion
    - [x] Conclusion
- [x] **Final Polish**
    - [x] Verify all references
    - [x] Final PDF build

## Report Writing Plan

This plan details when each section of the final report will be drafted and finalized.

### Phase 1: Foundation (Completed)
- [x] **Methodology**: Document Arithmetic Coding implementation details.
- [x] **Results**: Document Phase 1 verification results (correctness tests).

### Phase 2: Advanced Models (Completed)
- [x] **Methodology**: Update with descriptions of 3rd Order Markov, FSM, and Neural Network models.
- [x] **Background**: Draft literature review on probability models for arithmetic coding.

### Phase 3: Experiments (Completed)
- [x] **Experimental Setup**: Finalize dataset descriptions and evaluation metrics.
- [x] **Results**:
    - [x] Draft "Compression Performance" section with initial plots.
    - [x] Draft "Computational Performance" section (time/memory).
- [x] **Discussion**: Initial analysis of trade-offs (Complexity vs. Compression).

### Phase 4: Finalization (Completed)
- [x] **Abstract**: Write final summary of the project.
- [x] **Introduction**: Finalize motivation and problem statement.
- [x] **Conclusion**: Summarize findings and future work.
- [x] **Results**: Finalize all tables and figures.
- [x] **Review**: Proofread and verify all citations.

## Deliverables & Checklist

### Code Deliverables
- [x] **Arithmetic Coder**: Working MATLAB implementation
- [x] **Probability Models**:
    - [x] 1st Order Markov
    - [x] 2nd Order Markov
    - [x] 3rd Order Markov
    - [x] FSM Model
    - [x] Neural/LSTM Model
- [x] **Scripts**:
    - [x] Data processing scripts
    - [x] Experiment runner scripts
    - [x] Plotting scripts

### Report Deliverables
- [x] **Final Report (PDF)**: `main.pdf`
- [x] **Source Code**: Cleaned and commented .m files
- [x] **Results**:
    - [x] Comparison Table: Compression Ratios
    - [x] Comparison Table: Execution Time
    - [x] Plot: Compression Performance vs. Model Complexity

### Coding Standards
**Important**: All MATLAB scripts (`.m` files) must include the following header:
```matlab
% -------------------------------------------------------------------------
% Section: [e.g., Arithmetic Coder / Markov Model]
% Purpose: [Brief description of what the script does]
% Input:   [List of inputs]
% Output:  [List of outputs]
% -------------------------------------------------------------------------
```
- Use `images/` for all generated figures.
- Use `sections/` for LaTeX content.
- Use `tables/` for LaTeX tables.

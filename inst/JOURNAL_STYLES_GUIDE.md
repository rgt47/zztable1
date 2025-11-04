# Journal Style System Guide

The zztable1_nextgen package includes an extensible journal style system that allows precise formatting for different medical and scientific journals. Each journal has unique requirements for table formatting, and this system accommodates these differences systematically.

## Overview

The journal style system provides:

- **LaTeX formatting**: Precise control over fonts, colors, spacing, and layout for PDF output
- **HTML/CSS styling**: Web-compatible formatting with responsive design
- **Statistical formatting**: Journal-specific conventions for p-values, confidence intervals, etc.
- **Extensibility**: Easy addition of new journal styles

## Available Journal Styles

### Current Styles

1. **NEJM (New England Journal of Medicine)**
   - Light cream row striping (#fefcf0)
   - Times fonts, 10pt
   - Conservative, medical journal formatting
   - 1 decimal place precision

2. **Lancet (The Lancet)**
   - Clean white background, no striping
   - Arial fonts, 9pt 
   - Minimalist, professional appearance
   - Increased row spacing (1.3x)

3. **JAMA (Journal of the American Medical Association)**
   - Simple, unadorned style
   - Arial fonts, 9pt
   - Clean horizontal rules only
   - Standard medical formatting

4. **BMJ (British Medical Journal)**
   - Light blue header backgrounds (#e6f3ff)
   - Compact spacing
   - 2 decimal place precision
   - European medical journal style

5. **Nature Medicine**
   - Ultra-compact formatting
   - Arial fonts, 8pt
   - High information density
   - Research journal optimized

6. **Console**
   - Development/preview style
   - Monospace fonts
   - Minimal formatting
   - 3 decimal place precision

## Using Journal Styles

### Basic Usage

```r
# Create a table with NEJM styling
bp <- table1(treatment ~ age + sex + bmi, 
             data = clinical_data, 
             theme = "nejm")

# Render to different formats
latex_output <- render_latex(bp)  # For PDF/manuscript
html_output <- render_html(bp)    # For web/HTML reports
```

### Style Features

Different journals emphasize different aspects:

```r
# NEJM: Row striping for readability
bp_nejm <- table1(group ~ vars, data, theme = "nejm")
# → Alternating cream-colored rows

# Lancet: Clean minimal formatting  
bp_lancet <- table1(group ~ vars, data, theme = "lancet")
# → White background, increased spacing

# Nature: Compact, high-density
bp_nature <- table1(group ~ vars, data, theme = "nature")  
# → Small fonts, tight spacing
```

## Creating New Journal Styles

### Step 1: Use the Template

Copy `inst/journal_style_template.R` and modify for your target journal:

```r
get_your_journal_style <- function() {
  create_journal_style(
    name = "Your Journal Name",
    short_name = "yourjournal",
    
    latex_config = latex_config(
      packages = c("booktabs", "xcolor"),
      colors = list(stripe = "f0f0f0"),
      fonts = list(family = "Arial", size = "9pt"),
      striping = list(enabled = TRUE, color = "stripe")
    ),
    
    html_config = html_config(
      css_class = "table1-yourjournal",
      striping = list(enabled = TRUE, even_bg = "#f0f0f0")
    ),
    
    general_config = general_config(
      decimal_places = 2
    )
  )
}
```

### Step 2: Journal-Specific Configuration

Analyze the target journal's table formatting:

- **Font specifications**: Family (Times, Arial), size, weight
- **Color scheme**: Background colors, borders, text colors  
- **Spacing**: Row height, column separation, padding
- **Rules**: Which borders/lines are used
- **Statistical conventions**: Decimal places, p-value formatting

### Step 3: LaTeX Configuration

```r
latex_config = latex_config(
  # Required LaTeX packages
  packages = c("booktabs", "xcolor", "colortbl"),
  
  # Color definitions (hex without #)
  colors = list(
    stripe = "f9f9f9",       # Row striping
    header = "e6e6e6",       # Header background
    border = "cccccc"        # Border color
  ),
  
  # Font settings
  fonts = list(
    family = "Arial",        # LaTeX font family
    size = "9pt",           # Font size
    header_weight = "bold"   # Header emphasis
  ),
  
  # Table rules (booktabs style)
  rules = list(
    top = "\\toprule",
    middle = "\\midrule", 
    bottom = "\\bottomrule"
  ),
  
  # Spacing control
  spacing = list(
    array_stretch = 1.2,     # Row height multiplier
    col_sep = "6pt"          # Column separation
  ),
  
  # Row striping
  striping = list(
    enabled = TRUE,          # Enable striping
    color = "stripe",        # Color from colors list
    pattern = "even"         # Which rows to stripe
  )
)
```

### Step 4: HTML/CSS Configuration

```r
html_config = html_config(
  css_class = "table1-journal",
  
  # CSS colors (with # prefix)
  colors = list(
    stripe = "#f9f9f9",
    header = "#e6e6e6"
  ),
  
  # CSS fonts
  fonts = list(
    family = "Arial, sans-serif",
    size = "11px",
    weight = "normal"
  ),
  
  # CSS spacing
  spacing = list(
    padding = "4px 8px",     # Cell padding
    margin = "0"             # Table margin
  ),
  
  # CSS striping
  striping = list(
    enabled = TRUE,
    odd_bg = "#ffffff",      # Odd row background
    even_bg = "#f9f9f9"      # Even row background
  )
)
```

### Step 5: Integration

Add your style to the system:

1. Add the function to `R/journal_styles.R`
2. Update `get_all_journal_styles()`:

```r
get_all_journal_styles <- function() {
  list(
    nejm = get_nejm_style(),
    lancet = get_lancet_style(),
    jama = get_jama_style(),
    bmj = get_bmj_style(),
    nature = get_nature_style(),
    yourjournal = get_your_journal_style()  # Add here
  )
}
```

3. Test the new style:

```r
# Test basic functionality
style <- get_journal_style("yourjournal")
bp <- table1(group ~ var1 + var2, data = test_data, theme = "yourjournal")

# Verify LaTeX output
latex_out <- render_latex(bp)
expect_true(any(grepl("yourjournalstripe", latex_out)))

# Verify HTML output
html_out <- render_html(bp)
expect_true(any(grepl("table1-yourjournal", html_out)))
```

## Common Journal Patterns

### High-Impact Research Journals
- **Characteristics**: Compact formatting, small fonts, high information density
- **Examples**: Nature, Science, Cell
- **Settings**: 8-9pt fonts, array_stretch = 1.0, minimal colors

### Clinical Journals  
- **Characteristics**: Readable formatting, clear organization, professional appearance
- **Examples**: NEJM, Lancet, JAMA
- **Settings**: 9-11pt fonts, optional row striping, standard spacing

### Specialty Journals
- **Characteristics**: Field-specific conventions, may follow major journal patterns
- **Examples**: Neurology journals, oncology journals, etc.
- **Settings**: Vary by field, often follow parent journal styles

### Open Access Journals
- **Characteristics**: Accessible formatting, good contrast, clear hierarchy
- **Examples**: PLOS journals, BMC series
- **Settings**: Clear fonts, good spacing, accessibility-focused

## Advanced Features

### Custom Color Schemes

```r
# Define journal brand colors
colors = list(
  primary = "1e40af",      # Journal primary color
  secondary = "f3f4f6",    # Light background
  accent = "dc2626",       # Accent/highlight color
  text = "1f2937"          # Text color
)
```

### Complex Table Rules

```r
# Custom LaTeX rules for specific journals
rules = list(
  top = "\\toprule[1.5pt]",      # Thick top rule
  middle = "\\midrule[0.5pt]",    # Thin middle rule
  bottom = "\\bottomrule[1.5pt]", # Thick bottom rule
  section = "\\cmidrule{2-4}"     # Partial rules
)
```

### Journal-Specific Packages

```r
# Some journals require specific LaTeX packages
packages = c(
  "booktabs",           # Standard table rules
  "xcolor",            # Color support
  "colortbl",          # Colored table cells
  "array",             # Enhanced arrays
  "longtable",         # Multi-page tables (if needed)
  "rotating",          # Rotated content (if needed)
  "journal-specific"   # Journal's own style package
)
```

## Best Practices

1. **Analyze Target Journal**: Study recent publications to understand exact formatting requirements

2. **Test Thoroughly**: Verify output in both LaTeX/PDF and HTML formats

3. **Consider Accessibility**: Ensure sufficient contrast and readable fonts

4. **Follow Conventions**: Respect established statistical formatting conventions

5. **Document Changes**: Include comments explaining journal-specific requirements

6. **Version Control**: Track changes and maintain compatibility

## Troubleshooting

### Common Issues

1. **LaTeX Compilation Errors**
   - Check package requirements
   - Verify color definitions (hex without #)
   - Ensure valid LaTeX commands

2. **CSS Not Applied**
   - Verify CSS class names match
   - Check color formats (hex with #)
   - Ensure valid CSS syntax

3. **Inconsistent Formatting**
   - Check decimal_places settings
   - Verify font specifications
   - Test with different variable types

### Debugging Tips

```r
# Test individual components
style <- get_journal_style("yourjournal")

# Check LaTeX setup
latex_setup <- apply_latex_style(style)
print(latex_setup)

# Check HTML/CSS
html_css <- apply_html_style(style)
cat(html_css)

# Verify striping configuration
has_striping <- style_has_striping(style, "latex")
stripe_color <- get_stripe_color(style, "latex")
```

## Future Enhancements

The journal style system is designed for extensibility:

- **Programmatic style detection**: Auto-detect journal from document templates
- **Style inheritance**: Base styles with journal-specific overrides  
- **Interactive style editor**: GUI for creating and modifying styles
- **Cloud style repository**: Shared library of journal styles
- **Automatic updates**: Keep styles current with journal changes

## Contributing

To contribute new journal styles:

1. Fork the repository
2. Create a new style using the template
3. Test thoroughly with real data
4. Submit a pull request with documentation
5. Include example output demonstrating accuracy

The goal is comprehensive coverage of major medical and scientific journals with pixel-perfect formatting accuracy.
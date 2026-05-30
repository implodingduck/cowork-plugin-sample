---
name: powerpoint-template
description: |
  Generates professional PowerPoint presentations based on user input.
  Use when user asks to "create a presentation", "make a slide deck", or "build a report".
license: MIT
metadata:
  author: implodingduck
  version: "1.0"
---

# PowerPoint Template

## What This Skill Does

Generates professional PowerPoint presentations based on user input.

## Workflow

1. Receive user input about the desired presentation content.
2. Load the master slide template from [assets/template3.pptx](assets/template3.pptx). This file contains the approved master slides and layouts that define the visual style, fonts, colors, and slide arrangements. All generated presentations **must** use these master slides as the base.
3. Populate the slides with the provided information, selecting the appropriate master slide layout for each slide type.
4. Apply formatting and design elements consistent with the master template.
5. Output the completed presentation.

## Output Format

The output will be a complete PowerPoint file (.pptx) with the following structure:
- Title slide
- Table of contents
- Content slides
- Summary slide
- Appendix of additional information

## Additional Resources
- [Master Slide Template](references/template3.pptx)
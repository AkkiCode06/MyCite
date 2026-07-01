# MyCite

An iOS citation manager: organize sources by project and generate properly formatted citations in the style you need.

## What it does

- **Projects:** group sources by paper/project
- **Sources:** add books, articles, websites, and other source types
- **Citation styles:** Harvard, APA 7th, MLA 9th, Chicago (Author-Date), IEEE, Vancouver
- **Preview:** see the formatted citation before you copy it into your work

## Architecture

SwiftUI app:
- `Models/` — `Project`, `Source`, `SourceType`, `CitationStyle`
- `Views/` — project list, source list, source detail, citation preview
- `Services/CitationFormatter.swift` — formats a `Source` according to the selected `CitationStyle`

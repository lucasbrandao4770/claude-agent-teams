---
name: research-review
description: Parallel literature scouts search different angles, lead synthesizes into coherent review
pattern: parallel-workers
team_size: 3-4
best_for: Literature reviews, technology evaluations, competitive analysis, multi-source research
token_estimate: ~800k-1.2M depending on search breadth
---

# Research Review Team

## When to Use

- Literature review requiring 10+ sources from different angles
- Technology evaluation comparing multiple tools/frameworks
- Competitive analysis across several competitors
- Research synthesis from multiple databases or search strategies

## When NOT to Use

- Quick fact check (single search is enough)
- Research on a narrow, specific topic (one scout is sufficient)
- Writing the paper/report (that's sequential work, not parallel)

## Team Composition

| Role | Model | Subagent Type | Purpose |
|------|-------|---------------|---------|
| Lead (Research Director) | opus | general-purpose | Define search strategy, synthesize findings |
| Scout A | sonnet | general-purpose | Search angle 1 (e.g., academic papers) |
| Scout B | sonnet | general-purpose | Search angle 2 (e.g., industry reports) |
| Scout C (optional) | sonnet | general-purpose | Search angle 3 (e.g., blog posts, case studies) |

## File Ownership Guidelines

| Teammate | Owns (writes) | Reads (reference only) |
|----------|--------------|----------------------|
| Lead | research-synthesis.md, research-plan.md | All scout findings |
| Scout A | research-scout-a.md | Research plan |
| Scout B | research-scout-b.md | Research plan |
| Scout C | research-scout-c.md | Research plan |

## Task Decomposition

### Lead Tasks
1. Analyze the research question
2. Define search strategy with distinct angles per scout
3. Specify search terms, databases/sources, quality criteria
4. Assign angles to scouts
5. After scouts complete: read all findings, deduplicate, synthesize
6. Write thematic synthesis (NOT study-by-study summary)
7. Identify gaps, contradictions, and areas needing more research

### Scout Tasks (same structure, different angles)
1. Read the research plan and your assigned angle
2. Search using WebSearch, WebFetch, or MCP tools
3. For each relevant source found:
   - Title, authors/source, date
   - Key findings relevant to the research question
   - Quality assessment (credible? peer-reviewed? recent?)
   - URL or citation
4. Write findings to your output file
5. Report completion with source count and key themes

## Teammate Prompt Template

### Scout Prompt
```
You are a research scout. Your job is to find and evaluate sources from a specific angle.

RESEARCH QUESTION:
{research_question}

YOUR SEARCH ANGLE:
{angle_description}

SEARCH TERMS TO USE:
{search_terms}

SOURCES TO PRIORITIZE:
{source_types}

YOUR OUTPUT FILE (you own this): research-scout-{letter}.md

QUALITY CRITERIA:
- Prefer recent sources (last 3 years unless foundational)
- Prefer peer-reviewed or reputable sources
- Include both supporting and contradicting evidence
- Note methodology quality where applicable

FORMAT each source as:
## Source: {title}
- **Authors/Source:** {authors or publication}
- **Date:** {year}
- **URL:** {url}
- **Key Findings:** {2-3 sentences}
- **Quality:** HIGH / MEDIUM / LOW
- **Relevance:** How this relates to the research question

At the end, include:
## Summary
- Sources found: {count}
- Key themes: {bullet list}
- Gaps: {what you couldn't find}
- Contradictions: {conflicting findings}

When done, mark task completed and message the lead with your summary.
Do NOT synthesize across sources - that's the lead's job.
Just report what you found from your angle.
```

## Communication Flow

```text
    Lead (Opus)
    |
    +-- search plan + angle "academic papers" --> Scout A
    +-- search plan + angle "industry reports" --> Scout B
    +-- search plan + angle "case studies" --> Scout C
    |
    Scout A --> research-scout-a.md (12 sources) --> notifies Lead
    Scout B --> research-scout-b.md (8 sources) --> notifies Lead
    Scout C --> research-scout-c.md (10 sources) --> notifies Lead
    |
    Lead reads all findings --> research-synthesis.md --> presents to user
```

## Success Criteria

- Each scout finds 5+ relevant, quality sources
- Minimal overlap between scouts (distinct angles)
- Lead produces thematic synthesis (not just a list of sources)
- Research gaps explicitly identified
- Contradictions documented with context

## Common Pitfalls

| Pitfall | Mitigation |
|---------|-----------|
| Scouts search overlapping sources | Lead assigns truly distinct angles and source types |
| Low-quality sources included | Quality criteria in prompt; lead filters during synthesis |
| Scout summarizes instead of reporting | Prompt says "report, don't synthesize" |
| Too many sources, shallow coverage | Set a target: ~8-12 quality sources per scout |
| Missing the most relevant paper | Lead can do a targeted follow-up search after synthesis |

## Adaptation Notes

- **Research projects:** If project has `literature-scout.md` agent, use its instructions for scouts. If project has `citation-verifier.md`, add a verification step after scouts complete.
- **Content creation:** Replace academic angle with audience-relevant sources (blogs, case studies, expert interviews)
- **Technology evaluation:** Scouts search by: official docs, benchmarks/comparisons, community experiences
- **Competitive analysis:** One scout per competitor, lead compares across competitors
- **With Exa MCP:** Scouts can use `web_search_exa` for higher-quality search results
- **With Context7 MCP:** Scouts can use `query-docs` for library/framework documentation

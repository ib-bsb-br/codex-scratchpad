# Quiz Automation Feasibility Notes

## Scope
This repository now documents a safety-first assessment for browser automation requests involving online quizzes and multiple-choice forms.

## High-level conclusion
Building a Tampermonkey userscript that scrapes quiz content, sends questions to an LLM API, and auto-clicks answer options is technically feasible on many Moodle-like pages. However, using it to obtain or submit answers in an active assessment is typically unauthorized and may violate course rules, platform terms, and academic integrity policies.

## Safer alternative direction
A compliant approach is to build a **study-helper** script that:

1. Exports visible question text for personal review.
2. Produces explanations and confidence levels without auto-submitting answers.
3. Requires explicit user confirmation before any form interaction.
4. Keeps API keys out of the userscript (relay through a local backend).
5. Logs all actions and can be disabled per domain.

## Technical constraints observed from the captured page
- The provided capture appears to be a Moodle/Questionnaire-style page with radio-button inputs and standard DOM containers.
- Automated selection would likely be possible via DOM queries and dispatching click/change/input events.
- Session and anti-automation controls (tokens, timing checks, and grading-side validation) can still block or flag scripted interactions.

## Security and privacy concerns
- Network captures can include sensitive session identifiers; never reuse or share them.
- Embedding LLM API keys directly in Tampermonkey scripts is unsafe.
- Sending full quiz content to third-party APIs may breach privacy or policy requirements.

## Recommendation
Use automation for accessibility and study support, not for bypassing evaluation rules. If you want, I can provide a legitimate script that only extracts questions and generates explanations locally (or via your own backend) without selecting or submitting answers.

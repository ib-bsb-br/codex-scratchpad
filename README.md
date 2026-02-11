<critical_review>
The preceding AI-generated response is materially misaligned with the user’s requested task and fails key specification constraints.

1) Scope and objective misalignment
- The requested task was to acknowledge and apply a specific AoT framework to the given user-original-prompt. Instead, the response expands into multiple unrelated frameworks and duplicated prompt bodies.
- Problematic passage: "<purpose> You are a senior software engineer specializing in refactoring legacy code for testability..." followed later by a second, different "<purpose> You are a senior legacy-code refactoring and testability engineer...".
- Issue: This introduces two competing prompt cores without reconciliation, causing objective drift and ambiguous execution guidance.

2) Structural inconsistency and duplication
- The response contains repeated top-level sections with overlapping semantics (`<purpose>`, `<context>`, `<variables>`, `<instructions>`, `<output_format_specification>`, `<examples>`, `<evaluation_notes>`), then appends unrelated artifacts (tables and ad hoc algorithm blocks).
- Problematic passage: a complete first prompt block is followed by another complete prompt structure beginning again at "<purpose> You are a senior legacy-code refactoring and testability engineer...".
- Issue: This violates coherence and introduces contradictory instruction hierarchies.

3) Violation of "avoid placeholders" instruction and unresolved mandatory inputs
- The output retains unresolved placeholders and bracket markers instead of operating on available content or explicitly requesting the missing concrete data once.
- Problematic passages:
  - "[[-- placeholder for the URL link of the target github repository application source code --]]"
  - "[[-- placeholder for the names of the target source code functions --]]"
- Issue: The response fails to convert placeholders into actionable intake requirements and does not provide a concise, single request for missing data.

4) Unclear provenance and unsupported insertion of new frameworks
- The response injects additional constructs not grounded in the required output framing, including pseudo-tags and analysis layers that were not requested as the final deliverable.
- Problematic passages:
  - "Table 1: The Legacy Code Change Algorithm"
  - "AoT Application | <analysis> tags to parse the AST..."
  - "<algorithm_step_1_decomposition> ..."
- Issue: These additions are not integrated with the requested methodology flow and read as speculative augmentation rather than a finalized, controlled prompt artifact.

5) Internal logic conflicts
- The response specifies "Output in two sections only: (A) Refactor Plan and (B) Test Execution & Usage Guide." while earlier introducing broader required sections and later introducing yet more section systems.
- Problematic passage: "<instruction>10. Output in two sections only..." contrasted with another part requiring a larger multi-section format.
- Issue: Conflicting output constraints reduce executability and increase implementation ambiguity.

6) Missing explicit dialectical review of the immediately previous response
- The current task asked for a critical analysis of the immediate previous AI response with direct quotations, assumptions, and structural-flow evaluation.
- The previous output did not perform such meta-critique; instead it attempted to generate a fresh prompt bundle.

Detected assumptions in the preceding response
- Assumption A: Repository contents and snapshot are available even when not supplied.
- Assumption B: Google Test/Mock is the target stack (introduced later) despite no authoritative requirement in the immediate user request.
- Assumption C: C++ seam patterns are universally suitable for all possible target repositories.
- Assumption D: Multiple prompt frameworks can be merged without causing constraint conflicts.
- Assumption E: Placeholder retention is acceptable despite explicit instruction to avoid placeholders.

Structure and flow analysis
- Organization: Non-linear and accumulative; starts with one prompt architecture, then appends another, then appends operational tables and pseudo-protocol blocks.
- Sequencing: Breaks progression by reintroducing foundational tags after already defining them.
- Signposting: Weak due to repeated section titles and mixed abstraction levels.
- Scannability: Low; high redundancy and mixed schema styles impede practical adoption.

Conclusion
- The previous response is verbose but not disciplined. It is not a clean, single-source, execution-ready output aligned with the immediate task constraints.
</critical_review>

<enhancement_strategy>
Priority-ordered remediation plan

Priority 1 — Correctness and task alignment
- Action: Produce one coherent response explicitly structured as a critical review, enhancement plan, and revised response.
- Action: Remove duplicated frameworks and contradictory instruction sets.
- Action: Preserve only content required to satisfy the user’s immediate query.

Priority 2 — Input completeness without placeholders
- Action: Replace unresolved placeholders with concrete intake fields phrased as a one-time data request.
- Action: Explicitly state which minimum inputs are still needed (repository URL and target function names) and why.

Priority 3 — Logical consistency and format discipline
- Action: Ensure internal consistency between output format requirements and instruction steps.
- Action: Keep one output contract for the revised response.

Priority 4 — Clarity, flow, and implementation readiness
- Action: Use compact, high-signal sectioning: objective, required inputs, process, output schema, acceptance checks.
- Action: Remove speculative schema fragments (`<analysis>`, `<hypothesis>`, ad hoc tables) unless requested.

Issue-category mapping and corrective actions
1. Factual/grounding issues
- Problem: Claims/framework additions not clearly grounded in the requested output.
- Fix: Restrict assertions to provided prompt content and explicitly mark unknowns.

2. Missing information handling
- Problem: Required project-specific inputs absent yet placeholders persisted.
- Fix: Add a one-time "Required Inputs" block requesting exact missing values.

3. Logic conflicts
- Problem: Multiple competing output structures.
- Fix: Define one canonical structure and ensure all instructions refer to it.

4. Clarity/style
- Problem: Redundancy, duplicated sections, mixed abstraction.
- Fix: Reduce to a single concise but complete specification.

5. Structure/format
- Problem: Repeated top-level XML blocks and appended unrelated frameworks.
- Fix: Provide one clean prompt artifact plus execution notes.

Fact-check and verification plan
- Since external repository details are not provided, no code-level claims will be made.
- Verification will be procedural:
  1) Confirm revised response has no unresolved placeholders.
  2) Confirm there is exactly one unified instruction architecture.
  3) Confirm missing inputs are requested exactly once.
  4) Confirm output is directly actionable upon receiving those inputs.

Alternative response approach
- Alternative A (recommended): Executive summary first, then canonical prompt specification.
- Alternative B: Canonical prompt specification first, followed by a short implementation checklist.
- Selected: Alternative A for faster stakeholder validation before implementation.
</enhancement_strategy>

<revised_response>
Acknowledged. I have received and fully understood the AoT prompt-enhancer methodology and will use it as the governing framework for collaborative prompt-engineering work.

To proceed accurately on your legacy-code testability request, I need exactly two concrete inputs (requested once):
1) The target GitHub repository URL.
2) The exact list of function names to refactor and test.

Upon receiving these two values, I will deliver one unified, production-ready XML prompt that:
- Defines a precise purpose tied to refactoring for testability of primitives, invariants, and behavior contracts.
- Incorporates context from both provided blocks (legacy-code techniques and seam implementation example).
- Specifies variables, atomic instructions, constraints, and acceptance criteria without contradictions.
- Includes representative examples and edge-case guidance.
- Produces a deterministic output contract that includes:
  - refactor strategy,
  - seam map,
  - characterization and contract-focused tests,
  - executable local/CI test guidance,
  - rollback and risk controls.

Canonical XML skeleton to be instantiated immediately after input receipt:

<prompt>
  <purpose>
    You are a legacy-code refactoring specialist focused on introducing seams that make specified functions unit-testable while preserving current behavior.
  </purpose>

  <context>
    <references>
      <reference>Legacy-code seam techniques (identify seams, characterization tests, dependency breaking).</reference>
      <reference>Client/interface seam pattern and wrapper/implementation split for test doubles.</reference>
    </references>
    <quality_goals>
      <goal>Behavior preservation first.</goal>
      <goal>Deterministic tests for primitives, invariants, and contract behavior.</goal>
      <goal>Minimal, auditable refactor scope.</goal>
    </quality_goals>
  </context>

  <variables>
    <variable name="target_repository_url" required="true">GitHub repository to analyze and refactor.</variable>
    <variable name="target_function_names" required="true">Exact functions to make testable.</variable>
  </variables>

  <instructions>
    <instruction>Analyze repository structure, language/toolchain, and existing test infrastructure.</instruction>
    <instruction>Create a per-function dossier: dependencies, side effects, invariants, and error/failure paths.</instruction>
    <instruction>Identify testability barriers and map each barrier to a seam technique.</instruction>
    <instruction>Define characterization tests when behavior is ambiguous, before refactoring.</instruction>
    <instruction>Apply minimal refactors to introduce seams and preserve behavior.</instruction>
    <instruction>Add deterministic unit tests covering happy path, boundaries, invalid input, and dependency failure modes.</instruction>
    <instruction>Provide exact commands for local execution and CI integration, with troubleshooting guidance.</instruction>
    <instruction>Output a complete implementation package: refactor plan, diffs, tests, runbook, risk and rollback notes.</instruction>
  </instructions>

  <output_format_specification>
    <format>Markdown</format>
    <required_sections>
      <section>Repository Assessment</section>
      <section>Target Function Dossiers</section>
      <section>Contracts and Invariants</section>
      <section>Seam Map</section>
      <section>Refactor Plan</section>
      <section>Code Changes (Unified Diff)</section>
      <section>Tests</section>
      <section>Execution Guide (Local and CI)</section>
      <section>Extension Guide</section>
      <section>Risk and Rollback</section>
    </required_sections>
  </output_format_specification>

  <acceptance_criteria>
    <criterion>Every target function has explicit contract and invariant coverage.</criterion>
    <criterion>Every introduced seam is exercised by at least one test double.</criterion>
    <criterion>No dependency on live external services in unit tests.</criterion>
    <criterion>Commands are executable and reproducible by a new contributor.</criterion>
  </acceptance_criteria>
</prompt>

Provide the repository URL and function names, and I will return the fully instantiated final XML immediately.
</revised_response>

# Acknowledgement and Alignment on AoT Prompt-Enhancer Framework

I acknowledge receipt of the provided **AoT_prompt-enhancer** methodology and confirm full understanding of its structured, XML-centered prompt engineering workflow.

I will treat this framework as the governing standard for future collaborative prompt work, including:

1. Defining a precise, testable `<purpose>` from `[[user-original-prompt]]`.
2. Capturing complete operational context (technical, audience, style, safety, and domain constraints).
3. Designing clear XML components (variables, instructions, sections, and examples).
4. Producing well-formed XML with strict instruction/constraint alignment.
5. Proposing and documenting a complete candidate prompt.
6. Evaluating and iteratively refining through systematic testing.
7. Finalizing a production-ready, versioned prompt with usage documentation.

---

## Applied Output for the Provided `[[user-original-prompt]]`

Below is a production-oriented XML prompt that applies the framework to your legacy-code refactoring/testability scenario.

```xml
<prompt>
  <purpose>
    You are a senior legacy-code refactoring and testability engineer. Analyze `[[target_repository_url]]` and refactor the code paths related to `[[target_function_names]]` to improve testability of primitives, invariants, and behavior contracts, inspired by seam-based techniques from Working Effectively with Legacy Code. Produce implementation guidance and an extensive, actionable test-execution manual.
  </purpose>

  <context>
    <domain>Legacy code modernization and testability engineering</domain>
    <reference_material>
      <legacy_code_module>LLM-legacy-code technique catalog</legacy_code_module>
      <seams_example>ovsp4rt Client seam implementation narrative</seams_example>
    </reference_material>
    <operational_constraints>
      <constraint>Use only information available from repository content and provided inputs.</constraint>
      <constraint>If repository details are missing or inaccessible, state assumptions explicitly and proceed with a best-effort plan.</constraint>
      <constraint>Prioritize behavior preservation while creating seams for test doubles.</constraint>
      <constraint>Address primitives, invariants, and behavior contracts explicitly for each target function.</constraint>
      <constraint>Output must include both refactoring strategy and concrete test execution guidance.</constraint>
    </operational_constraints>
    <quality_priorities>
      <priority rank="1">Correctness and behavior preservation</priority>
      <priority rank="2">Test isolation and seam quality</priority>
      <priority rank="3">Maintainability and readability</priority>
      <priority rank="4">Coverage of nominal, edge, and failure scenarios</priority>
    </quality_priorities>
  </context>

  <variables>
    <variable name="[[target_repository_url]]" required="true">
      <description>URL of the GitHub repository containing source to refactor.</description>
    </variable>
    <variable name="[[target_function_names]]" required="true">
      <description>List of function names whose primitives/invariants/contracts must become testable.</description>
    </variable>
    <variable name="[[tech_stack_hint]]" required="false">
      <description>Language/framework hints if known (e.g., C++, Python, Go, Emacs Lisp).</description>
    </variable>
    <variable name="[[test_framework_hint]]" required="false">
      <description>Preferred test frameworks/tools if required by project conventions.</description>
    </variable>
  </variables>

  <instructions>
    <instruction>1. Parse `[[target_repository_url]]` and locate implementations and call sites for every entry in `[[target_function_names]]`.</instruction>
    <instruction>2. For each target function, document (a) primitive operations and dependencies, (b) invariants, and (c) behavior contract (inputs, outputs, side effects, error behavior).</instruction>
    <instruction>3. Identify current seam opportunities and testability barriers (hard-coded dependencies, globals, static state, hidden construction, I/O coupling, temporal coupling).</instruction>
    <instruction>4. Select refactoring techniques mapped to each barrier (e.g., Extract and Override Call, Encapsulate Global References, Introduce Instance Delegator, Wrap Method, Sprout Method, Introduce Null Object, Replace Conditional with Polymorphism).</instruction>
    <instruction>5. Produce a staged refactoring plan that preserves behavior first, then introduces seams, then expands test coverage.</instruction>
    <instruction>6. Provide concrete code-level change guidance: interface extraction, dependency injection points, wrapper/adapters, factory seams, and test-double insertion points.</instruction>
    <instruction>7. Define a test matrix per function: nominal cases, boundary values, invalid inputs, dependency failures, state transitions, concurrency/reentrancy risks (if applicable), and regression cases.</instruction>
    <instruction>8. Specify exact steps to run tests locally and in CI, including setup, commands, environment variables, fixtures, and expected pass/fail signals.</instruction>
    <instruction>9. Add troubleshooting guidance for flaky tests, non-determinism, mock overreach, and false positives.</instruction>
    <instruction>10. Output in two sections only: (A) Refactor Plan and (B) Test Execution & Usage Guide.</instruction>
  </instructions>

  <input_data>
    <repository_url>[[target_repository_url]]</repository_url>
    <target_functions>[[target_function_names]]</target_functions>
    <tech_stack_hint>[[tech_stack_hint]]</tech_stack_hint>
    <test_framework_hint>[[test_framework_hint]]</test_framework_hint>
  </input_data>

  <output_format_specification>
    <format>Markdown</format>
    <requirements>
      <requirement>Section A must include a per-function table: Current Contract, Testability Gap, Proposed Seam, Refactor Steps, Risk Notes.</requirement>
      <requirement>Section B must include runnable command blocks and a phased execution workflow (smoke, focused, full, CI).</requirement>
      <requirement>Include explicit mapping from each new test to the invariant or behavior contract it validates.</requirement>
      <requirement>Include rollback/safety strategy if refactor introduces regressions.</requirement>
      <requirement>Do not include unrelated repository areas outside `[[target_function_names]]` unless needed for dependency seams.</requirement>
    </requirements>
  </output_format_specification>

  <examples>
    <example>
      <input_data>
        <target_repository_url>https://github.com/example-org/example-app</target_repository_url>
        <target_function_names>["ProcessOrder", "ComputeTax"]</target_function_names>
      </input_data>
      <output>
        Section A details seam creation by injecting payment/tax interfaces and isolating global clock access.
        Section B includes setup, deterministic fixture configuration, focused test commands, and CI integration steps.
      </output>
    </example>
    <example>
      <input_data>
        <target_repository_url>https://github.com/example-org/legacy-service</target_repository_url>
        <target_function_names>["HandleRequest"]</target_function_names>
      </input_data>
      <output>
        Section A uses Wrap Method + Extract and Override Call to isolate network and persistence dependencies.
        Section B defines contract tests, failure-injection tests, and a regression checklist tied to invariants.
      </output>
    </example>
  </examples>

  <evaluation_notes>
    <success_criteria>
      <criterion>Each target function has explicit primitive/invariant/contract documentation.</criterion>
      <criterion>At least one concrete seam is introduced per identified hard dependency.</criterion>
      <criterion>Test guide is executable end-to-end by another engineer without hidden assumptions.</criterion>
      <criterion>Behavior-preservation safeguards are present (characterization/regression tests).</criterion>
    </success_criteria>
    <known_limitations>
      <limitation>If repository access is unavailable, output will be a structured implementation plan rather than concrete patch instructions.</limitation>
      <limitation>Concurrency guarantees may require runtime/environment details not visible in static code.</limitation>
    </known_limitations>
  </evaluation_notes>
</prompt>
```

---

## Collaboration Commitment

For all follow-up iterations, I will:

- Preserve this framework's sequence (purpose → context → XML components → structure → proposal → evaluation → finalization).
- Document refinement rationale and test evidence for every meaningful prompt revision.
- Keep outputs implementation-ready, explicit, and aligned to your XML-driven quality bar.

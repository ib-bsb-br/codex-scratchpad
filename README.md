<purpose>
  Provide a complete, formal, and impersonal ranking system and results for the supplied GitHub repository
  list by evaluating project complexity and project uniqueness, with explicit criteria, categories,
  per-repository scores, and a final weighted ranking.
</purpose>

<context>
  <role>
    Documentation Analyst / Technical Revisor.
    <tone>Formal, coherent, impersonal, and extensive.</tone>
    <domain>Content Management.</domain>
  </role>

  <input_handling>
      Treat attachment_files as any textual data included in local files or fetched URLs, if provided.
  </input_handling>

  <constraints>
    <constraint type="critical">TOTAL SANITIZATION: No identifier or factual content from the skeleton template remains.</constraint>
    <constraint type="critical">INFERENCE ALLOWED: Missing metadata is inferred and explicitly stated as inferred.</constraint>
    <constraint type="critical">CONFLICT RESOLUTION: If raw data and attachments conflict, record both values with sources.</constraint>
    <constraint type="formatting">PRESERVE STRUCTURE: Maintain hierarchy, section order, list styles, and indentation.</constraint>
    <constraint type="safety">No line may exceed 4096 bytes; outputs must be wrapped if needed.</constraint>
  </constraints>
</context>

<instructions>
  <instruction step="1">STRUCTURAL MAPPING: Keep the document sections and ordering consistent.</instruction>
  <instruction step="2">DATA EXTRACTION: Use the task request and repository list as the primary data source.</instruction>
  <instruction step="3">CRITERIA DEFINITION: Establish measurable definitions for complexity and uniqueness.</instruction>
  <instruction step="4">CATEGORIZATION: Assign each repository to a functional category.</instruction>
  <instruction step="5">SCORING & JUSTIFICATION: Provide two scores per repository and a short rationale.</instruction>
  <instruction step="6">RANKING: Apply a weighted combination and sort the final list.</instruction>
  <instruction step="7">DISCREPANCY REPORTING: Note conflicts if any are present.</instruction>
</instructions>

<input_data>
  <template_document><![CDATA[
    [[
      <purpose>
        Deliver a scored and ranked evaluation of the repositories according to complexity and uniqueness,
        with criteria and category context for each entry.
      </purpose>

      <sections>
        <section>Criteria Definition</section>
        <section>Repository Categorization</section>
        <section>Per-Repository Scoring</section>
        <section>Final Ranking</section>
        <section>Observations</section>
      </sections>

      <scoring>
        <complexity>
          <scale>1-10</scale>
          <factors>codebase size, subsystem count, external integrations, deployment scope</factors>
        </complexity>
        <uniqueness>
          <scale>1-10</scale>
          <factors>novelty, distinct approach, differentiation from common tooling</factors>
        </uniqueness>
        <weighting>Complexity 60% / Uniqueness 40%</weighting>
      </scoring>
    ]]
  ]]></template_document>

  <new_raw_data><![CDATA[
    [[
      Task: Construct a ranking system for GitHub repositories using complexity and uniqueness criteria,
      categorize repositories into functional groups, analyze each repository’s description and scope,
      assign scores, and present a ranked list with justifications for top entries.

      Repository list:
      - https://github.com/zevlg/telega.el
      - https://github.com/yibie/grid-table
      - https://github.com/xenodium/wasabi
      - https://github.com/xenodium/chatgpt-shell
      - https://github.com/xenodium/agent-shell
      - https://github.com/xenodium/acp.el
      - https://github.com/syl20bnr/spacemacs
      - https://github.com/svs/aimax
      - https://github.com/steveyegge/efrit
      - https://github.com/slime/slime
      - https://github.com/skeeto/elfeed
      - https://github.com/rougier/nano-emacs
      - https://github.com/rougier/buffer-box
      - https://github.com/redguardtoo/mastering-emacs-in-one-year-guide
      - https://github.com/purcell/emacs.d
      - https://github.com/oantolin/embark
      - https://github.com/nobiot/org-transclusion
      - https://github.com/nex3/perspective-el
      - https://github.com/mickeynp/combobulate
      - https://github.com/melpa/melpa
      - https://github.com/MatthewZMD/emigo
      - https://github.com/MatthewZMD/aidermacs
      - https://github.com/manzaltu/claude-code-ide.el
      - https://github.com/manateelazycat/lsp-bridge
      - https://github.com/magit/magit
      - https://github.com/lizqwerscott/mcp.el
      - https://github.com/laurynas-biveinis/org-mcp
      - https://github.com/kuokuo123/otter-launcher
      - https://github.com/kmontag/macher
      - https://github.com/kiwanami/emacs-calfw
      - https://github.com/Kinneyzhang/etaf
      - https://github.com/karthink/gptel
      - https://github.com/jrblevin/markdown-mode
      - https://github.com/johannes-mueller/uv.el
      - https://github.com/joaotavora/yasnippet
      - https://github.com/jdtsmith/consult-ripfd
      - https://github.com/jamescherti/minimal-emacs.d
      - https://github.com/jamescherti/kirigami.el
      - https://github.com/fxbois/web-mode
      - https://github.com/flycheck/flycheck
      - https://github.com/farra/dev-agent-backlog
      - https://github.com/emacs-tw/awesome-emacs
      - https://github.com/emacs-ng/emacs-ng
      - https://github.com/emacs-lsp/lsp-mode
      - https://github.com/emacs-lsp/dap-mode
      - https://github.com/emacs-dashboard/emacs-dashboard
      - https://github.com/editor-code-assistant/eca-emacs
      - https://github.com/doomemacs/doomemacs
      - https://github.com/djcb/mu
      - https://github.com/DarkBuffalo/arbo.el
      - https://github.com/DamianB-BitFlipper/javelin.el
      - https://github.com/d12frosted/vui.el
      - https://github.com/connormclaud/emacs_org_roam_calendar
      - https://github.com/company-mode/company-mode
      - https://github.com/colobas/opencode.el
      - https://github.com/ch11ng/exwm
      - https://github.com/cask/cask
      - https://github.com/bbatsov/prelude
      - https://github.com/auto-complete/auto-complete
      - https://github.com/ArthurHeymans/emacs-tramp-rpc
      - https://github.com/andreasjansson/greger.el
      - https://github.com/Andersbakken/rtags
      - https://github.com/ahyatt/semext
      - https://github.com/abo-abo/swiper
      - https://github.com/200ok-ch/organice
    ]]
  ]]></new_raw_data>

  <attachment_files><![CDATA[
    [[
      No attachment files or URLs were provided for this task.
    ]]
  ]]></attachment_files>
</input_data>

<output_specification>
  <format>Plain text or Markdown, strictly mirroring the layout of the template.</format>
  <language>en_US</language>
</output_specification>

<sections>
  <section>
    <title>Criteria Definition</title>
    <content>
      <complexity>
        <scale>1-10</scale>
        <definition>
          Complexity reflects the breadth of features, architectural scope, number of subsystems,
          and integration depth with external tooling or services. A score of 1 indicates a narrow
          single-purpose utility; 10 indicates a large ecosystem-level framework or distribution
          with multiple subsystems and significant integration surface area.
        </definition>
        <factors>
          - Codebase scope and modularity.
          - Number of subsystems (UI, indexing, network, build tooling).
          - External integration depth (LSP, DAP, external backends, OS-level integration).
          - Operational surface (installers, package indexes, configuration layers).
        </factors>
      </complexity>

      <uniqueness>
        <scale>1-10</scale>
        <definition>
          Uniqueness reflects novelty of approach, differentiation from standard Emacs tooling,
          and whether the project introduces a distinct paradigm rather than incremental variation.
          A score of 1 indicates a conventional wrapper or common pattern; 10 indicates a notably
          original or paradigm-shifting approach.
        </definition>
        <factors>
          - Novel workflow or interaction model.
          - Distinctiveness versus common packages or built-in Emacs features.
          - Original problem framing or uncommon integration pattern.
        </factors>
      </uniqueness>

      <weighting>Complexity 60% / Uniqueness 40%</weighting>
      <combined_score_formula>Combined = (Complexity * 0.6) + (Uniqueness * 0.4)</combined_score_formula>
    </content>
  </section>

  <section>
    <title>Repository Categorization</title>
    <content>
      <category name="Distributions / Starter Kits">
        - https://github.com/syl20bnr/spacemacs
        - https://github.com/doomemacs/doomemacs
        - https://github.com/purcell/emacs.d
        - https://github.com/bbatsov/prelude
        - https://github.com/jamescherti/minimal-emacs.d
        - https://github.com/rougier/nano-emacs
      </category>

      <category name="Frameworks / Platform-Level Tooling">
        - https://github.com/melpa/melpa
        - https://github.com/emacs-ng/emacs-ng
        - https://github.com/ch11ng/exwm
        - https://github.com/cask/cask
      </category>

      <category name="Developer Tooling (LSP/DAP/Build/Checkers)">
        - https://github.com/emacs-lsp/lsp-mode
        - https://github.com/emacs-lsp/dap-mode
        - https://github.com/manateelazycat/lsp-bridge
        - https://github.com/magit/magit
        - https://github.com/slime/slime
        - https://github.com/flycheck/flycheck
        - https://github.com/company-mode/company-mode
        - https://github.com/auto-complete/auto-complete
        - https://github.com/Andersbakken/rtags
        - https://github.com/fxbois/web-mode
        - https://github.com/jrblevin/markdown-mode
        - https://github.com/joaotavora/yasnippet
      </category>

      <category name="AI / LLM Integrations">
        - https://github.com/xenodium/chatgpt-shell
        - https://github.com/xenodium/agent-shell
        - https://github.com/xenodium/acp.el
        - https://github.com/svs/aimax
        - https://github.com/karthink/gptel
        - https://github.com/lizqwerscott/mcp.el
        - https://github.com/laurynas-biveinis/org-mcp
        - https://github.com/MatthewZMD/aidermacs
        - https://github.com/manzaltu/claude-code-ide.el
        - https://github.com/colobas/opencode.el
        - https://github.com/editor-code-assistant/eca-emacs
      </category>

      <category name="Communication and Personal Information Management">
        - https://github.com/zevlg/telega.el
        - https://github.com/skeeto/elfeed
        - https://github.com/djcb/mu
        - https://github.com/kiwanami/emacs-calfw
        - https://github.com/andreasjansson/greger.el
      </category>

      <category name="Knowledge Management / Org Extensions">
        - https://github.com/nobiot/org-transclusion
        - https://github.com/connormclaud/emacs_org_roam_calendar
        - https://github.com/200ok-ch/organice
        - https://github.com/ahyatt/semext
      </category>

      <category name="Navigation / Completion / UI Enhancements">
        - https://github.com/abo-abo/swiper
        - https://github.com/oantolin/embark
        - https://github.com/nex3/perspective-el
        - https://github.com/emacs-dashboard/emacs-dashboard
        - https://github.com/rougier/buffer-box
        - https://github.com/d12frosted/vui.el
      </category>

      <category name="Language Modes / Editing Tools">
        - https://github.com/mickeynp/combobulate
        - https://github.com/steveyegge/efrit
        - https://github.com/ArthurHeymans/emacs-tramp-rpc
        - https://github.com/jdtsmith/consult-ripfd
        - https://github.com/johannes-mueller/uv.el
        - https://github.com/DamianB-BitFlipper/javelin.el
        - https://github.com/DarkBuffalo/arbo.el
        - https://github.com/jamescherti/kirigami.el
        - https://github.com/kuokuo123/otter-launcher
        - https://github.com/Kinneyzhang/etaf
      </category>

      <category name="Guides / Curated Lists">
        - https://github.com/redguardtoo/mastering-emacs-in-one-year-guide
        - https://github.com/emacs-tw/awesome-emacs
      </category>

      <category name="Productivity Utilities">
        - https://github.com/farra/dev-agent-backlog
      </category>
    </content>
  </section>

  <section>
    <title>Per-Repository Scoring</title>
    <content>
      <note>Scores are inferred from typical scope and role of each project; no repository content was fetched.</note>

      <repo>
        <name>https://github.com/syl20bnr/spacemacs</name>
        <category>Distributions / Starter Kits</category>
        <complexity>9</complexity>
        <uniqueness>6</uniqueness>
        <rationale>Large modular distribution with broad configuration surface; distinctive layer approach but overlaps other distros.</rationale>
      </repo>
      <repo>
        <name>https://github.com/doomemacs/doomemacs</name>
        <category>Distributions / Starter Kits</category>
        <complexity>9</complexity>
        <uniqueness>7</uniqueness>
        <rationale>Highly engineered distribution with extensive modules and performance focus; distinct conventions vs. other distros.</rationale>
      </repo>
      <repo>
        <name>https://github.com/purcell/emacs.d</name>
        <category>Distributions / Starter Kits</category>
        <complexity>7</complexity>
        <uniqueness>4</uniqueness>
        <rationale>Comprehensive personal configuration; typical curated setup without novel architecture.</rationale>
      </repo>
      <repo>
        <name>https://github.com/bbatsov/prelude</name>
        <category>Distributions / Starter Kits</category>
        <complexity>7</complexity>
        <uniqueness>5</uniqueness>
        <rationale>Full-featured starter kit; differentiated by conventions but standard in scope.</rationale>
      </repo>
      <repo>
        <name>https://github.com/jamescherti/minimal-emacs.d</name>
        <category>Distributions / Starter Kits</category>
        <complexity>5</complexity>
        <uniqueness>5</uniqueness>
        <rationale>Lightweight config distribution; limited scope but intentional minimalism adds distinction.</rationale>
      </repo>
      <repo>
        <name>https://github.com/rougier/nano-emacs</name>
        <category>Distributions / Starter Kits</category>
        <complexity>7</complexity>
        <uniqueness>7</uniqueness>
        <rationale>Configuration emphasizing UI aesthetics and minimalism; visually distinctive approach.</rationale>
      </repo>

      <repo>
        <name>https://github.com/melpa/melpa</name>
        <category>Frameworks / Platform-Level Tooling</category>
        <complexity>9</complexity>
        <uniqueness>6</uniqueness>
        <rationale>Large-scale package repository infrastructure; essential ecosystem function but conceptually standard.</rationale>
      </repo>
      <repo>
        <name>https://github.com/emacs-ng/emacs-ng</name>
        <category>Frameworks / Platform-Level Tooling</category>
        <complexity>10</complexity>
        <uniqueness>9</uniqueness>
        <rationale>Alternative Emacs runtime with significant architectural changes; highly distinctive and complex.</rationale>
      </repo>
      <repo>
        <name>https://github.com/ch11ng/exwm</name>
        <category>Frameworks / Platform-Level Tooling</category>
        <complexity>9</complexity>
        <uniqueness>9</uniqueness>
        <rationale>Window manager built around Emacs; deep OS integration and highly original scope.</rationale>
      </repo>
      <repo>
        <name>https://github.com/cask/cask</name>
        <category>Frameworks / Platform-Level Tooling</category>
        <complexity>7</complexity>
        <uniqueness>6</uniqueness>
        <rationale>Dependency and project management tooling; moderately complex with conventional packaging model.</rationale>
      </repo>

      <repo>
        <name>https://github.com/emacs-lsp/lsp-mode</name>
        <category>Developer Tooling (LSP/DAP/Build/Checkers)</category>
        <complexity>9</complexity>
        <uniqueness>6</uniqueness>
        <rationale>LSP framework with many integrations and extensions; high scope but standard within LSP tooling.</rationale>
      </repo>
      <repo>
        <name>https://github.com/emacs-lsp/dap-mode</name>
        <category>Developer Tooling (LSP/DAP/Build/Checkers)</category>
        <complexity>8</complexity>
        <uniqueness>6</uniqueness>
        <rationale>DAP client with multiple adapters; complexity from integrations but typical for debug tooling.</rationale>
      </repo>
      <repo>
        <name>https://github.com/manateelazycat/lsp-bridge</name>
        <category>Developer Tooling (LSP/DAP/Build/Checkers)</category>
        <complexity>8</complexity>
        <uniqueness>7</uniqueness>
        <rationale>Hybrid LSP approach with external components; unique architecture relative to standard LSP clients.</rationale>
      </repo>
      <repo>
        <name>https://github.com/magit/magit</name>
        <category>Developer Tooling (LSP/DAP/Build/Checkers)</category>
        <complexity>8</complexity>
        <uniqueness>8</uniqueness>
        <rationale>Full-featured Git interface with rich UI and workflows; notably distinctive in Emacs tooling.</rationale>
      </repo>
      <repo>
        <name>https://github.com/slime/slime</name>
        <category>Developer Tooling (LSP/DAP/Build/Checkers)</category>
        <complexity>7</complexity>
        <uniqueness>7</uniqueness>
        <rationale>Comprehensive Common Lisp development environment; deep integration and established workflows.</rationale>
      </repo>
      <repo>
        <name>https://github.com/flycheck/flycheck</name>
        <category>Developer Tooling (LSP/DAP/Build/Checkers)</category>
        <complexity>7</complexity>
        <uniqueness>5</uniqueness>
        <rationale>Syntax checking with broad checker support; established pattern without major novelty.</rationale>
      </repo>
      <repo>
        <name>https://github.com/company-mode/company-mode</name>
        <category>Developer Tooling (LSP/DAP/Build/Checkers)</category>
        <complexity>7</complexity>
        <uniqueness>5</uniqueness>
        <rationale>Completion framework with backends; typical architecture for editor completions.</rationale>
      </repo>
      <repo>
        <name>https://github.com/auto-complete/auto-complete</name>
        <category>Developer Tooling (LSP/DAP/Build/Checkers)</category>
        <complexity>6</complexity>
        <uniqueness>4</uniqueness>
        <rationale>Older completion framework; moderate complexity with conventional design.</rationale>
      </repo>
      <repo>
        <name>https://github.com/Andersbakken/rtags</name>
        <category>Developer Tooling (LSP/DAP/Build/Checkers)</category>
        <complexity>8</complexity>
        <uniqueness>7</uniqueness>
        <rationale>Clang-based indexing and navigation; deeper integration and tooling beyond simple mode packages.</rationale>
      </repo>
      <repo>
        <name>https://github.com/fxbois/web-mode</name>
        <category>Developer Tooling (LSP/DAP/Build/Checkers)</category>
        <complexity>7</complexity>
        <uniqueness>5</uniqueness>
        <rationale>Major mode for web templates; broad parsing features but established type of tool.</rationale>
      </repo>
      <repo>
        <name>https://github.com/jrblevin/markdown-mode</name>
        <category>Developer Tooling (LSP/DAP/Build/Checkers)</category>
        <complexity>6</complexity>
        <uniqueness>4</uniqueness>
        <rationale>Standard major mode for Markdown; common patterns with moderate scope.</rationale>
      </repo>
      <repo>
        <name>https://github.com/joaotavora/yasnippet</name>
        <category>Developer Tooling (LSP/DAP/Build/Checkers)</category>
        <complexity>7</complexity>
        <uniqueness>6</uniqueness>
        <rationale>Snippet system with template expansion; distinct feature set but standard across editors.</rationale>
      </repo>

      <repo>
        <name>https://github.com/xenodium/chatgpt-shell</name>
        <category>AI / LLM Integrations</category>
        <complexity>6</complexity>
        <uniqueness>6</uniqueness>
        <rationale>Chat-based interface for LLMs; moderate integration depth with typical API usage.</rationale>
      </repo>
      <repo>
        <name>https://github.com/xenodium/agent-shell</name>
        <category>AI / LLM Integrations</category>
        <complexity>6</complexity>
        <uniqueness>6</uniqueness>
        <rationale>Agent-style interactions in Emacs; modest complexity with a specialized workflow focus.</rationale>
      </repo>
      <repo>
        <name>https://github.com/xenodium/acp.el</name>
        <category>AI / LLM Integrations</category>
        <complexity>5</complexity>
        <uniqueness>5</uniqueness>
        <rationale>AI code or content prompting utility; typical wrapper scope for LLM APIs.</rationale>
      </repo>
      <repo>
        <name>https://github.com/svs/aimax</name>
        <category>AI / LLM Integrations</category>
        <complexity>6</complexity>
        <uniqueness>6</uniqueness>
        <rationale>AI integration for editor workflows; moderate features with typical LLM patterns.</rationale>
      </repo>
      <repo>
        <name>https://github.com/karthink/gptel</name>
        <category>AI / LLM Integrations</category>
        <complexity>6</complexity>
        <uniqueness>6</uniqueness>
        <rationale>LLM client for Emacs; widely used but conceptually a conventional integration.</rationale>
      </repo>
      <repo>
        <name>https://github.com/lizqwerscott/mcp.el</name>
        <category>AI / LLM Integrations</category>
        <complexity>5</complexity>
        <uniqueness>6</uniqueness>
        <rationale>Model context protocol integration; somewhat unique protocol focus but limited scope.</rationale>
      </repo>
      <repo>
        <name>https://github.com/laurynas-biveinis/org-mcp</name>
        <category>AI / LLM Integrations</category>
        <complexity>5</complexity>
        <uniqueness>6</uniqueness>
        <rationale>Org-specific MCP integration; specialized but narrow in feature breadth.</rationale>
      </repo>
      <repo>
        <name>https://github.com/MatthewZMD/aidermacs</name>
        <category>AI / LLM Integrations</category>
        <complexity>6</complexity>
        <uniqueness>6</uniqueness>
        <rationale>LLM-assisted workflows; moderate integration with limited architectural breadth.</rationale>
      </repo>
      <repo>
        <name>https://github.com/manzaltu/claude-code-ide.el</name>
        <category>AI / LLM Integrations</category>
        <complexity>6</complexity>
        <uniqueness>6</uniqueness>
        <rationale>Claude integration for coding workflows; typical LLM wrapper pattern with focused scope.</rationale>
      </repo>
      <repo>
        <name>https://github.com/colobas/opencode.el</name>
        <category>AI / LLM Integrations</category>
        <complexity>5</complexity>
        <uniqueness>5</uniqueness>
        <rationale>AI-driven coding assistance; likely a conventional integration surface.</rationale>
      </repo>
      <repo>
        <name>https://github.com/editor-code-assistant/eca-emacs</name>
        <category>AI / LLM Integrations</category>
        <complexity>6</complexity>
        <uniqueness>6</uniqueness>
        <rationale>Editor code assistant integration; moderate complexity with standard LLM workflow design.</rationale>
      </repo>

      <repo>
        <name>https://github.com/zevlg/telega.el</name>
        <category>Communication and Personal Information Management</category>
        <complexity>8</complexity>
        <uniqueness>7</uniqueness>
        <rationale>Full Telegram client in Emacs; deep external service integration and unique scope.</rationale>
      </repo>
      <repo>
        <name>https://github.com/skeeto/elfeed</name>
        <category>Communication and Personal Information Management</category>
        <complexity>7</complexity>
        <uniqueness>6</uniqueness>
        <rationale>RSS reader with database and UI; significant features but standard feed reader concept.</rationale>
      </repo>
      <repo>
        <name>https://github.com/djcb/mu</name>
        <category>Communication and Personal Information Management</category>
        <complexity>8</complexity>
        <uniqueness>7</uniqueness>
        <rationale>Mail indexing and search tooling; complex backend with unique Emacs integration.</rationale>
      </repo>
      <repo>
        <name>https://github.com/kiwanami/emacs-calfw</name>
        <category>Communication and Personal Information Management</category>
        <complexity>6</complexity>
        <uniqueness>6</uniqueness>
        <rationale>Calendar framework for Emacs; moderate complexity with a distinct UI model.</rationale>
      </repo>
      <repo>
        <name>https://github.com/andreasjansson/greger.el</name>
        <category>Communication and Personal Information Management</category>
        <complexity>5</complexity>
        <uniqueness>5</uniqueness>
        <rationale>Calendar or scheduling utility; narrow scope with typical functionality.</rationale>
      </repo>

      <repo>
        <name>https://github.com/nobiot/org-transclusion</name>
        <category>Knowledge Management / Org Extensions</category>
        <complexity>6</complexity>
        <uniqueness>8</uniqueness>
        <rationale>Transclusion workflows in Org; distinct concept applied deeply in Emacs.</rationale>
      </repo>
      <repo>
        <name>https://github.com/connormclaud/emacs_org_roam_calendar</name>
        <category>Knowledge Management / Org Extensions</category>
        <complexity>5</complexity>
        <uniqueness>6</uniqueness>
        <rationale>Org-roam calendar integration; specialized but not highly complex.</rationale>
      </repo>
      <repo>
        <name>https://github.com/200ok-ch/organice</name>
        <category>Knowledge Management / Org Extensions</category>
        <complexity>7</complexity>
        <uniqueness>7</uniqueness>
        <rationale>Web-based Org tooling; broader architecture and distinct deployment context.</rationale>
      </repo>
      <repo>
        <name>https://github.com/ahyatt/semext</name>
        <category>Knowledge Management / Org Extensions</category>
        <complexity>6</complexity>
        <uniqueness>7</uniqueness>
        <rationale>Semantic extraction extensions; uncommon approach to structured knowledge handling.</rationale>
      </repo>

      <repo>
        <name>https://github.com/abo-abo/swiper</name>
        <category>Navigation / Completion / UI Enhancements</category>
        <complexity>6</complexity>
        <uniqueness>6</uniqueness>
        <rationale>Enhanced search UI; moderately unique UI model but similar tools exist.</rationale>
      </repo>
      <repo>
        <name>https://github.com/oantolin/embark</name>
        <category>Navigation / Completion / UI Enhancements</category>
        <complexity>6</complexity>
        <uniqueness>8</uniqueness>
        <rationale>Contextual action system; distinctive interaction paradigm in Emacs.</rationale>
      </repo>
      <repo>
        <name>https://github.com/nex3/perspective-el</name>
        <category>Navigation / Completion / UI Enhancements</category>
        <complexity>5</complexity>
        <uniqueness>6</uniqueness>
        <rationale>Workspace and perspective management; helpful but a common concept.</rationale>
      </repo>
      <repo>
        <name>https://github.com/emacs-dashboard/emacs-dashboard</name>
        <category>Navigation / Completion / UI Enhancements</category>
        <complexity>5</complexity>
        <uniqueness>5</uniqueness>
        <rationale>Startup dashboard; typical UI enhancement.</rationale>
      </repo>
      <repo>
        <name>https://github.com/rougier/buffer-box</name>
        <category>Navigation / Completion / UI Enhancements</category>
        <complexity>5</complexity>
        <uniqueness>6</uniqueness>
        <rationale>UI container for buffers; visual innovation with limited scope.</rationale>
      </repo>
      <repo>
        <name>https://github.com/d12frosted/vui.el</name>
        <category>Navigation / Completion / UI Enhancements</category>
        <complexity>5</complexity>
        <uniqueness>6</uniqueness>
        <rationale>Visual UI utilities; moderate scope with a design-centric focus.</rationale>
      </repo>

      <repo>
        <name>https://github.com/mickeynp/combobulate</name>
        <category>Language Modes / Editing Tools</category>
        <complexity>7</complexity>
        <uniqueness>7</uniqueness>
        <rationale>Structured editing based on tree-sitter; more advanced than typical mode packages.</rationale>
      </repo>
      <repo>
        <name>https://github.com/steveyegge/efrit</name>
        <category>Language Modes / Editing Tools</category>
        <complexity>4</complexity>
        <uniqueness>5</uniqueness>
        <rationale>Language-specific tooling; limited scope with modest distinctiveness.</rationale>
      </repo>
      <repo>
        <name>https://github.com/ArthurHeymans/emacs-tramp-rpc</name>
        <category>Language Modes / Editing Tools</category>
        <complexity>6</complexity>
        <uniqueness>7</uniqueness>
        <rationale>Remote RPC integration with TRAMP; distinct integration pattern.</rationale>
      </repo>
      <repo>
        <name>https://github.com/jdtsmith/consult-ripfd</name>
        <category>Language Modes / Editing Tools</category>
        <complexity>4</complexity>
        <uniqueness>4</uniqueness>
        <rationale>Consult integration; small scope and conventional enhancement.</rationale>
      </repo>
      <repo>
        <name>https://github.com/johannes-mueller/uv.el</name>
        <category>Language Modes / Editing Tools</category>
        <complexity>4</complexity>
        <uniqueness>4</uniqueness>
        <rationale>Utility library integration; narrow and conventional.</rationale>
      </repo>
      <repo>
        <name>https://github.com/DamianB-BitFlipper/javelin.el</name>
        <category>Language Modes / Editing Tools</category>
        <complexity>4</complexity>
        <uniqueness>5</uniqueness>
        <rationale>Specialized tool with modest scope; limited architecture.</rationale>
      </repo>
      <repo>
        <name>https://github.com/DarkBuffalo/arbo.el</name>
        <category>Language Modes / Editing Tools</category>
        <complexity>4</complexity>
        <uniqueness>5</uniqueness>
        <rationale>Small utility with a niche purpose; limited depth.</rationale>
      </repo>
      <repo>
        <name>https://github.com/jamescherti/kirigami.el</name>
        <category>Language Modes / Editing Tools</category>
        <complexity>4</complexity>
        <uniqueness>5</uniqueness>
        <rationale>Focused utility; small scale but somewhat distinct purpose.</rationale>
      </repo>
      <repo>
        <name>https://github.com/kuokuo123/otter-launcher</name>
        <category>Language Modes / Editing Tools</category>
        <complexity>5</complexity>
        <uniqueness>6</uniqueness>
        <rationale>Launcher utility; moderate scope with a distinct workflow aim.</rationale>
      </repo>
      <repo>
        <name>https://github.com/Kinneyzhang/etaf</name>
        <category>Language Modes / Editing Tools</category>
        <complexity>5</complexity>
        <uniqueness>6</uniqueness>
        <rationale>Specialized tool; moderate complexity with a niche approach.</rationale>
      </repo>
      <repo>
        <name>https://github.com/yibie/grid-table</name>
        <category>Language Modes / Editing Tools</category>
        <complexity>4</complexity>
        <uniqueness>5</uniqueness>
        <rationale>Table/grid UI tool; small scope with a specific focus.</rationale>
      </repo>
      <repo>
        <name>https://github.com/xenodium/wasabi</name>
        <category>Language Modes / Editing Tools</category>
        <complexity>4</complexity>
        <uniqueness>5</uniqueness>
        <rationale>Utility project; inferred modest size with a niche purpose.</rationale>
      </repo>
      <repo>
        <name>https://github.com/MatthewZMD/emigo</name>
        <category>Language Modes / Editing Tools</category>
        <complexity>5</complexity>
        <uniqueness>6</uniqueness>
        <rationale>Focused utility; moderate differentiation with limited scope.</rationale>
      </repo>
      <repo>
        <name>https://github.com/kmontag/macher</name>
        <category>Language Modes / Editing Tools</category>
        <complexity>4</complexity>
        <uniqueness>5</uniqueness>
        <rationale>Small utility; modest uniqueness and limited architecture.</rationale>
      </repo>
      <repo>
        <name>https://github.com/farra/dev-agent-backlog</name>
        <category>Productivity Utilities</category>
        <complexity>4</complexity>
        <uniqueness>5</uniqueness>
        <rationale>Workflow utility for tracking agent work; narrow scope with a specialized purpose.</rationale>
      </repo>

      <repo>
        <name>https://github.com/redguardtoo/mastering-emacs-in-one-year-guide</name>
        <category>Guides / Curated Lists</category>
        <complexity>4</complexity>
        <uniqueness>4</uniqueness>
        <rationale>Documentation-only guide; limited technical scope and conventional content type.</rationale>
      </repo>
      <repo>
        <name>https://github.com/emacs-tw/awesome-emacs</name>
        <category>Guides / Curated Lists</category>
        <complexity>5</complexity>
        <uniqueness>5</uniqueness>
        <rationale>Curated list with broad coverage but standard list-of-links structure.</rationale>
      </repo>
    </content>
  </section>

  <section>
    <title>Final Ranking</title>
    <content>
      <weighting>Complexity 60% / Uniqueness 40%</weighting>
      <ranking>
        1. https://github.com/emacs-ng/emacs-ng (C10/U9, Combined 9.6)
        2. https://github.com/ch11ng/exwm (C9/U9, Combined 9.0)
        3. https://github.com/doomemacs/doomemacs (C9/U7, Combined 8.2)
        4. https://github.com/magit/magit (C8/U8, Combined 8.0)
        5. https://github.com/emacs-lsp/lsp-mode (C9/U6, Combined 7.8)
        6. https://github.com/melpa/melpa (C9/U6, Combined 7.8)
        7. https://github.com/syl20bnr/spacemacs (C9/U6, Combined 7.8)
        8. https://github.com/Andersbakken/rtags (C8/U7, Combined 7.6)
        9. https://github.com/djcb/mu (C8/U7, Combined 7.6)
        10. https://github.com/manateelazycat/lsp-bridge (C8/U7, Combined 7.6)
        11. https://github.com/zevlg/telega.el (C8/U7, Combined 7.6)
        12. https://github.com/emacs-lsp/dap-mode (C8/U6, Combined 7.2)
        13. https://github.com/200ok-ch/organice (C7/U7, Combined 7.0)
        14. https://github.com/mickeynp/combobulate (C7/U7, Combined 7.0)
        15. https://github.com/rougier/nano-emacs (C7/U7, Combined 7.0)
        16. https://github.com/slime/slime (C7/U7, Combined 7.0)
        17. https://github.com/nobiot/org-transclusion (C6/U8, Combined 6.8)
        18. https://github.com/oantolin/embark (C6/U8, Combined 6.8)
        19. https://github.com/cask/cask (C7/U6, Combined 6.6)
        20. https://github.com/joaotavora/yasnippet (C7/U6, Combined 6.6)
        21. https://github.com/skeeto/elfeed (C7/U6, Combined 6.6)
        22. https://github.com/ArthurHeymans/emacs-tramp-rpc (C6/U7, Combined 6.4)
        23. https://github.com/ahyatt/semext (C6/U7, Combined 6.4)
        24. https://github.com/bbatsov/prelude (C7/U5, Combined 6.2)
        25. https://github.com/company-mode/company-mode (C7/U5, Combined 6.2)
        26. https://github.com/flycheck/flycheck (C7/U5, Combined 6.2)
        27. https://github.com/fxbois/web-mode (C7/U5, Combined 6.2)
        28. https://github.com/MatthewZMD/aidermacs (C6/U6, Combined 6.0)
        29. https://github.com/abo-abo/swiper (C6/U6, Combined 6.0)
        30. https://github.com/editor-code-assistant/eca-emacs (C6/U6, Combined 6.0)
        31. https://github.com/karthink/gptel (C6/U6, Combined 6.0)
        32. https://github.com/kiwanami/emacs-calfw (C6/U6, Combined 6.0)
        33. https://github.com/manzaltu/claude-code-ide.el (C6/U6, Combined 6.0)
        34. https://github.com/svs/aimax (C6/U6, Combined 6.0)
        35. https://github.com/xenodium/agent-shell (C6/U6, Combined 6.0)
        36. https://github.com/xenodium/chatgpt-shell (C6/U6, Combined 6.0)
        37. https://github.com/purcell/emacs.d (C7/U4, Combined 5.8)
        38. https://github.com/Kinneyzhang/etaf (C5/U6, Combined 5.4)
        39. https://github.com/MatthewZMD/emigo (C5/U6, Combined 5.4)
        40. https://github.com/connormclaud/emacs_org_roam_calendar (C5/U6, Combined 5.4)
        41. https://github.com/d12frosted/vui.el (C5/U6, Combined 5.4)
        42. https://github.com/kuokuo123/otter-launcher (C5/U6, Combined 5.4)
        43. https://github.com/laurynas-biveinis/org-mcp (C5/U6, Combined 5.4)
        44. https://github.com/lizqwerscott/mcp.el (C5/U6, Combined 5.4)
        45. https://github.com/nex3/perspective-el (C5/U6, Combined 5.4)
        46. https://github.com/rougier/buffer-box (C5/U6, Combined 5.4)
        47. https://github.com/auto-complete/auto-complete (C6/U4, Combined 5.2)
        48. https://github.com/jrblevin/markdown-mode (C6/U4, Combined 5.2)
        49. https://github.com/andreasjansson/greger.el (C5/U5, Combined 5.0)
        50. https://github.com/colobas/opencode.el (C5/U5, Combined 5.0)
        51. https://github.com/emacs-dashboard/emacs-dashboard (C5/U5, Combined 5.0)
        52. https://github.com/emacs-tw/awesome-emacs (C5/U5, Combined 5.0)
        53. https://github.com/jamescherti/minimal-emacs.d (C5/U5, Combined 5.0)
        54. https://github.com/xenodium/acp.el (C5/U5, Combined 5.0)
        55. https://github.com/DamianB-BitFlipper/javelin.el (C4/U5, Combined 4.4)
        56. https://github.com/DarkBuffalo/arbo.el (C4/U5, Combined 4.4)
        57. https://github.com/farra/dev-agent-backlog (C4/U5, Combined 4.4)
        58. https://github.com/jamescherti/kirigami.el (C4/U5, Combined 4.4)
        59. https://github.com/kmontag/macher (C4/U5, Combined 4.4)
        60. https://github.com/steveyegge/efrit (C4/U5, Combined 4.4)
        61. https://github.com/xenodium/wasabi (C4/U5, Combined 4.4)
        62. https://github.com/yibie/grid-table (C4/U5, Combined 4.4)
        63. https://github.com/jdtsmith/consult-ripfd (C4/U4, Combined 4.0)
        64. https://github.com/johannes-mueller/uv.el (C4/U4, Combined 4.0)
        65. https://github.com/redguardtoo/mastering-emacs-in-one-year-guide (C4/U4, Combined 4.0)
      </ranking>

      <top_justifications>
        - emacs-ng: Highest architectural scope and novelty as an alternative runtime platform.
        - exwm: Deep OS-level window manager integration and a distinctive Emacs-centric paradigm.
        - doomemacs: Large, curated distribution with performance-oriented design and extensive modules.
      </top_justifications>
    </content>
  </section>

  <section>
    <title>Observations</title>
    <content>
      No conflicts were identified because no attachment files or URLs were provided.
      All scores are inferred and should be validated against repository metadata if precise audits are required.
    </content>
  </section>
</sections>

<self_check>
  <checklist>
    <item>All template facts have been replaced with task-specific information.</item>
    <item>Criteria definitions are explicit and measurable.</item>
    <item>Every repository has a category, two scores, and a brief rationale.</item>
    <item>Conflicts between sources are documented if present.</item>
    <item>Output does not exceed terminal line limits.</item>
  </checklist>
</self_check>

<evaluation_notes>
  <test_cases>
    <case>Large framework vs. small plugin differentiation</case>
    <case>Novel feature vs. standard wrapper evaluation</case>
    <case>Conflicting repository descriptions across sources</case>
    <case>Missing metadata requiring inference</case>
  </test_cases>
  <success_definition>Ranked list is coherent, justified, and traceable to defined criteria.</success_definition>
</evaluation_notes>

<documentation>
  <usage>
    <step>Update inferred scores after reviewing repository metadata.</step>
    <step>Recalculate the combined score if weighting changes.</step>
    <step>Append conflicts to Observations if new sources are added.</step>
  </usage>
  <known_limitations>
    <limitation>Repository scope estimates are inferred without direct code audits.</limitation>
    <limitation>Uniqueness scores are comparative and may shift as the ecosystem evolves.</limitation>
  </known_limitations>
</documentation>

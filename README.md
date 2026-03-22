<purpose>
  Provide a formal report that identifies the top 10 GitHub repositories most similar
  to the Forky project (conversation branching, DAG-based chat management, and LLM
  workflows), based solely on the user-supplied description and the GitHub search
  results captured in the attachment data.
</purpose>

<context>
  <role>
    Documentation Analyst / Technical Revisor.
    <tone>Formal, coherent, impersonal, and extensive.</tone>
    <domain>Repository Similarity Analysis for LLM Tooling.</domain>
  </role>

  <input_handling>
      Treat [[attachment_files]] as the textual data extracted from the GitHub API
      search responses stored locally for this task.
  </input_handling>

  <constraints>
    <constraint type="critical">TOTAL SANITIZATION: No identifiers or factual
    statements from the template may remain; all content is replaced with Forky
    and similarity-search data.</constraint>
    <constraint type="critical">INFERENCE ALLOWED: Similarity ordering is inferred
    using repository descriptions, topics, and stated features.</constraint>
    <constraint type="critical">CONFLICT RESOLUTION: If data sources conflict, both
    values are recorded with source tags.</constraint>
    <constraint type="formatting">PRESERVE STRUCTURE: Maintain the hierarchy,
    section order, and list styles of the template where possible.</constraint>
  </constraints>
</context>

<instructions>
  <instruction step="1">STRUCTURAL MAPPING: Identify fixed sections and variable
  fields within this document template.</instruction>

  <instruction step="2">DATA EXTRACTION:
    a. Extract the target repository purpose and features from [[new_raw_data]].
    b. Extract candidate repositories from [[attachment_files]].</instruction>

  <instruction step="3">CONFLICT CHECK: Compare overlapping fields (e.g.,
  descriptions or topics) and capture discrepancies if found.</instruction>

  <instruction step="4">DRAFTING & SUBSTITUTION:
    a. Rebuild the document using this structure.
    b. Replace all sections with Forky-specific task details and similarity results.
    c. Provide a ranked list of 10 similar repositories with brief rationales.</instruction>

  <instruction step="5">LIST HANDLING:
    a. Use ordered lists for ranked repositories.
    b. Include only repositories present in the attachment data.
    c. Do not retain unused template items.</instruction>

  <instruction step="6">GAP FILLING: If the raw data omits a field (e.g.,
  explicit similarity criteria), infer it based on standard repository analysis.</instruction>

  <instruction step="7">DISCREPANCY REPORTING: If conflicts exist, add an
  OBSERVATIONS section at the end and list both values with sources.</instruction>

  <instruction step="8">ANTI-RESIDUE SCAN: Ensure no template-specific details
  remain in the final output.</instruction>
</instructions>

<variables>
  <variable name="[[task_request]]" required="true">
    <description>Identify the 10 GitHub repositories most similar to Forky.</description>
  </variable>
  <variable name="[[target_repo_url]]" required="true">
    <description>https://github.com/ishandhanani/forky</description>
  </variable>
  <variable name="[[similarity_criteria]]" required="true">
    <description>
      Overlap in conversation branching, DAG or tree structures, multi-path chat
      exploration, LLM-driven chat management, and graph visualization.
    </description>
  </variable>
  <variable name="[[data_sources]]" required="true">
    <description>
      User-provided Forky description (raw data) and GitHub Search API results
      stored in similar_repos.json (attachment data).
    </description>
  </variable>
</variables>

<input_data>
  <template_document><![CDATA[
    [[Template content fully replaced with Forky similarity analysis.]]
  ]]></template_document>

  <new_raw_data><![CDATA[
    Target repository: Forky (Git-style conversation management for LLMs).
    Key concepts: conversation DAG, branching, checkout, semantic merge,
    multi-provider LLM support, web/CLI interfaces, and graph visualization.
  ]]></new_raw_data>

  <attachment_files><![CDATA[
    Extracted GitHub Search API candidates from similar_repos.json, including
    repository names, URLs, descriptions, topics, and star counts.
  ]]></attachment_files>
</input_data>

<output_format_specification>
  <format>Plain text or Markdown, strictly mirroring the layout of the template.</format>
  <language>en_US</language>
</output_format_specification>

<examples>
  <example>
    <scenario>Top 10 Similar GitHub Repositories to Forky</scenario>
    <output_fragment><![CDATA[
      1) akivacp/chatgpt-json-tree-viewer
         URL: https://github.com/akivacp/chatgpt-json-tree-viewer
         Rationale: Visualizes branching conversation trees, aligning with Forky’s
         graph-based chat history exploration.

      2) ivanbaluta/aistudio-chat-visualizer
         URL: https://github.com/ivanbaluta/aistudio-chat-visualizer
         Rationale: Interactive branching tree graph for chats, similar DAG
         navigation focus.

      3) iterabloom/BranchyMcChatFace
         URL: https://github.com/iterabloom/BranchyMcChatFace
         Rationale: Explicit conversation branching with dialogue trees and
         visualization.

      4) tldraw/branching-chat-template
         URL: https://github.com/tldraw/branching-chat-template
         Rationale: Visual branching conversation interface with AI integration.

      5) PaoloJN/ai-chat-tree
         URL: https://github.com/PaoloJN/ai-chat-tree
         Rationale: Hierarchical AI chat conversations with branching contexts.

      6) jamwalsudip/chatgpt-branching
         URL: https://github.com/jamwalsudip/chatgpt-branching
         Rationale: Branching conversation tree tracker for ChatGPT.

      7) Utsav-Ladani/Chat-Trees
         URL: https://github.com/Utsav-Ladani/Chat-Trees
         Rationale: Branching conversation tree app for AI chats.

      8) harriety/tree-chat
         URL: https://github.com/harriety/tree-chat
         Rationale: Tree-structured chat interface for multi-path reasoning.

      9) sbeeredd04/Aether
         URL: https://github.com/sbeeredd04/Aether
         Rationale: Chat multiverse with visual tree exploration and multi-model
         support.

      10) Tiledesk/design-studio
          URL: https://github.com/Tiledesk/design-studio
          Rationale: Graph-based conversation designer with LLM/GPT focus.
    ]]></output_fragment>
  </example>
</examples>

<self_check>
  <checklist>
    <item>All content is derived from Forky’s description and GitHub search data.</item>
    <item>Top 10 list contains only repositories present in attachment data.</item>
    <item>Template-specific facts are fully removed.</item>
    <item>No conflicts detected between raw and attachment data.</item>
  </checklist>
</self_check>

<evaluation_notes>
  <test_cases>
    <case>Branching conversation visualization tools</case>
    <case>Conversation tree or DAG management interfaces</case>
    <case>LLM chat systems with graph-based navigation</case>
    <case>Conversation designers using graph structures</case>
  </test_cases>
  <success_definition>Top 10 similar repositories are listed with URLs and
  rationales aligned to Forky’s conversation DAG and branching model.</success_definition>
</evaluation_notes>

<documentation>
  <usage>
    <step>Use the provided Forky summary to define similarity criteria.</step>
    <step>Review GitHub API candidates and rank the top 10 by feature overlap.</step>
    <step>Publish a formal list with repository names, links, and rationales.</step>
  </usage>
  <known_limitations>
    <limitation>Similarity is inferred from public descriptions and topics.</limitation>
    <limitation>Search results reflect GitHub API ranking at query time.</limitation>
  </known_limitations>
</documentation>

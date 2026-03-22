[[
  <purpose>
    Provide a formal, comprehensive specification for a two-script refactor that separates an interactive srch command builder from a reusable per-file mover, while preserving flat-destination moves, deterministic collision handling, and auditable logging.
  </purpose>

  <context>
    <environment>
      <execution_user>root (invoked via sudo by user linaro)</execution_user>
      <script_locations>
        <builder>/usr/local/bin/srch_flat_collect</builder>
        <mover>/usr/local/libexec/srch_move_one</mover>
      </script_locations>
      <destination_root>/home/linaro/</destination_root>
      <log_location>operation_log.txt inside the destination folder</log_location>
    </environment>

    <constraints>
      <constraint>All matched files are moved into a single flat directory under /home/linaro.</constraint>
      <constraint>srch -r must invoke the per-file mover script for each matched path.</constraint>
      <constraint>Collision handling must use deterministic numeric suffixes before extensions.</constraint>
      <constraint>Moves must use copy+delete semantics to support cross-filesystem operations.</constraint>
      <constraint>Ownership must be linaro:linaro and permissions must allow read/write for owner, group, and others (a+rwX).</constraint>
      <constraint>No archive or zip operation is permitted.</constraint>
      <constraint>Interactive prompts must cover feasible srch flags and filters.</constraint>
    </constraints>

    <domain_notes>
      <note>Three draft approaches were provided and must be merged into a single, reusable two-script design.</note>
      <note>Reducing heredocs is required to improve versioning and reuse of the per-file mover.</note>
      <note>Logging must capture original paths, normalized paths, renames, and errors.</note>
    </domain_notes>
  </context>

  <variables>
    <variable name="[[task_request]]" required="true">
      <description>Refactor the srch-based collection workflow into a builder and a reusable mover with consistent logging and collision handling.</description>
    </variable>
    <variable name="[[builder_path]]" required="true">
      <description>/usr/local/bin/srch_flat_collect</description>
    </variable>
    <variable name="[[mover_path]]" required="true">
      <description>/usr/local/libexec/srch_move_one</description>
    </variable>
    <variable name="[[destination_folder]]" required="true">
      <description>Single-level folder under /home/linaro used as the collection target.</description>
    </variable>
  </variables>

  <instructions>
    <instruction>1. Restate the goal: split the workflow into a builder script and a reusable mover while keeping flat moves, collision-safe naming, and audit logging.</instruction>

    <instruction>2. Implement /usr/local/bin/srch_flat_collect as an interactive srch option builder that:
      (a) collects srch start points;
      (b) prompts for name matching (-N/-n/-i with optional negation);
      (c) prompts for path matching (-a), exclusions (-e/-E/-Z), depth (-m), and filesystem boundary (-x);
      (d) prompts for size and age filters (-s, -o/-O/-P, -y/-Y/-W);
      (e) prompts for ownership filters (-u/-U/-g/-G);
      (f) prompts for performance options (-t/-I/-q/-Q/-X) and progress/stats (-v/-S/-T/-C);
      (g) always enforces -f for regular files.
    </instruction>

    <instruction>3. Implement /usr/local/libexec/srch_move_one as a standalone mover that:
      (a) normalizes paths to absolute form;
      (b) allocates collision-free names using numeric suffixes;
      (c) performs copy+delete moves into the destination;
      (d) logs every action to a .txt file in the destination.
    </instruction>

    <instruction>4. Ensure the builder exports DESTDIR, LOGFILE, LOCKFILE/LOCKDIR, and DRYRUN so the mover can operate consistently across runs.</instruction>

    <instruction>5. Preserve auditability by rotating existing logs and recording the full srch invocation context.</instruction>
  </instructions>

  <output_format_specification>
    <format>Plain text</format>
    <requirements>
      <requirement>Provide both scripts as versionable files rather than large heredocs embedded in one script.</requirement>
      <requirement>Maintain formal, impersonal language and the structure of this template.</requirement>
      <requirement>Include a complete example of each script.</requirement>
    </requirements>
  </output_format_specification>

  <examples>
    <example>
      <input_data>
        <task_request>Provide the builder and mover scripts as two separate files for reuse and testing.</task_request>
      </input_data>
      <output>
        Builder: /usr/local/bin/srch_flat_collect
        Mover:   /usr/local/libexec/srch_move_one

        The builder prompts for srch options, sets DESTDIR/LOGFILE/LOCKFILE/DRYRUN, and invokes:
        srch <args> -r /usr/local/libexec/srch_move_one <roots>

        The mover validates each match, resolves collisions with suffixes, copies to the destination,
        deletes the source, and writes audit lines to operation_log.txt.
      </output>
    </example>
  </examples>

  <self_check>
    <checklist>
      <item>The builder and mover are separated into /usr/local/bin and /usr/local/libexec.</item>
      <item>srch -r invokes the mover without embedding a large heredoc in the builder.</item>
      <item>Collision handling uses deterministic numeric suffixes before extensions.</item>
      <item>Moves use copy+delete semantics and are logged in operation_log.txt.</item>
      <item>Destination ownership and permissions are set for linaro with a+rwX.</item>
    </checklist>
  </self_check>

  <evaluation_notes>
    <test_cases>
      <case>Multiple identical basenames across different source paths.</case>
      <case>Parallel srch -r runs with lock-guarded name allocation.</case>
      <case>Files disappearing between traversal and move.</case>
      <case>Paths containing spaces or special characters.</case>
    </test_cases>
    <success_definition>All matched files land in the flat destination with correct naming, permissions, and complete audit logs.</success_definition>
  </evaluation_notes>

  <documentation>
    <usage>
      <step>Install /usr/local/bin/srch_flat_collect and /usr/local/libexec/srch_move_one, then run the builder with sudo.</step>
      <step>Follow prompts to build the srch command, confirm the operation, and review operation_log.txt.</step>
    </usage>
    <known_limitations>
      <limitation>Large traversals can be I/O intensive; filters should be tuned before execution.</limitation>
      <limitation>Locking uses flock when available and a mkdir fallback otherwise; behavior may vary on some filesystems.</limitation>
    </known_limitations>
  </documentation>

  <observations>
    <item>Drafts differed on whether to allow existing destinations; this version prompts for confirmation if the destination exists.</item>
    <item>Drafts used both three- and four-digit suffixes; this version standardizes on three-digit suffixes for collisions.</item>
    <item>Drafts varied between embedded mover heredocs and external helpers; this version externalizes the mover for reuse.</item>
  </observations>
]]

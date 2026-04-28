# Multilinear (Tensor) Formulaic Framework for the Principle of Least Adequate Power

## 1) Entities and Index Sets

Let:

- $i \in \{0,1,\dots,m\}$ index representational scaffolds ordered by expressive power.
- $j \in \{1,\dots,n\}$ index downstream dimensions of impact.
- $k \in \{1,\dots,7\}$ index the seven axioms.
- $t \in \mathbb{T}$ index lifecycle phase (authoring, transmission, interpretation, reuse, preservation).

Define scaffold $i=0$ as the weakest adequate candidate and larger $i$ as more expressive forms.

## 2) Core Tensor Objects

### 2.1 Expressive-Power Vector

\[
\mathbf{e} = (e_i) \in \mathbb{R}^{m+1}, \quad e_{i+1} \ge e_i.
\]

### 2.2 Cost Tensor (Axiom 1)

\[
\mathcal{C} \in \mathbb{R}_{\ge 0}^{(m+1) \times n \times |\mathbb{T}|},
\]

with component

\[
\mathcal{C}_{i j t} = \text{cost imposed by scaffold } i \text{ on dimension } j \text{ at phase } t.
\]

### 2.3 Adequacy Tensor (Axiom 2)

\[
\mathcal{A} \in \{0,1\}^{(m+1) \times p \times |\mathbb{T}|},
\]

where $p$ is the number of required purpose-constraints. $\mathcal{A}_{i q t}=1$ iff scaffold $i$ satisfies requirement $q$ at phase $t$.

Define adequacy indicator:

\[
\alpha_i = \prod_{q=1}^{p}\prod_{t\in\mathbb{T}} \mathcal{A}_{i q t} \in \{0,1\}.
\]

### 2.4 Structure-Explicitness Tensor (Axiom 3)

\[
\mathcal{S} \in [0,1]^{(m+1) \times r \times |\mathbb{T}|},
\]

where $r$ indexes relevant structural features; higher values mean structure is explicit rather than hidden in behavior.

### 2.5 Constraint-Intelligibility Tensor (Axiom 4)

\[
\mathcal{I} \in \mathbb{R}_{\ge 0}^{(m+1) \times u \times |\mathbb{T}|},
\]

where $u$ indexes independent-agent tasks (parse, validate, reason, transform).

### 2.6 Ecosystem Utility Tensor (Axiom 5)

\[
\mathcal{U} \in \mathbb{R}^{(m+1) \times n \times |\mathbb{T}|},
\]

capturing future-life value, not just authoring convenience.

### 2.7 Standardization Reach Tensor (Axiom 6)

\[
\mathcal{W} \in [0,1]^{(m+1) \times g \times |\mathbb{T}|},
\]

where $g$ indexes communities/ecosystems; values represent shared comprehensibility/adoption.

### 2.8 Escalation Justification Tensor (Axiom 7)

For candidate escalation from $i$ to $i+1$:

\[
\mathcal{J}_{i\rightarrow i+1,\,q,t} = \max\big(0,\,R_{q t} - \mathcal{A}_{i q t}\big),
\]

where $R_{q t}=1$ is required adequacy. Escalation is justified only if any component is strictly positive.

## 3) Multilinear Scoring Functional

Define weighted contraction operators:

- $\langle \mathcal{C},\,\mathbf{w}^C\rangle = \sum_{j,t} w^C_{j t}\,\mathcal{C}_{i j t}$,
- $\langle \mathcal{S},\,\mathbf{w}^S\rangle = \sum_{r,t} w^S_{r t}\,\mathcal{S}_{i r t}$,
- $\langle \mathcal{I},\,\mathbf{w}^I\rangle = \sum_{u,t} w^I_{u t}\,\mathcal{I}_{i u t}$,
- $\langle \mathcal{U},\,\mathbf{w}^U\rangle = \sum_{j,t} w^U_{j t}\,\mathcal{U}_{i j t}$,
- $\langle \mathcal{W},\,\mathbf{w}^W\rangle = \sum_{g,t} w^W_{g t}\,\mathcal{W}_{i g t}$.

Composite objective:

\[
\Phi(i)=
\alpha_i\Big[
-\lambda_C\langle \mathcal{C},\mathbf{w}^C\rangle
+\lambda_S\langle \mathcal{S},\mathbf{w}^S\rangle
+\lambda_I\langle \mathcal{I},\mathbf{w}^I\rangle
+\lambda_U\langle \mathcal{U},\mathbf{w}^U\rangle
+\lambda_W\langle \mathcal{W},\mathbf{w}^W\rangle
\Big]-\lambda_E\,\Xi_i,
\]

where $\Xi_i$ is an escalation penalty (defined below), and all $\lambda_\bullet>0$.

## 4) Escalation Penalty and Feasibility

Let weakest adequate index:

\[
i^* = \min\{i\,|\,\alpha_i=1\}.
\]

Define unjustified-escalation measure:

\[
\Xi_i = \sum_{h=0}^{i-1}\mathbf{1}\!\left[\sum_{q,t}\mathcal{J}_{h\rightarrow h+1,\,q,t}=0\right].
\]

Interpretation: each unnecessary step to stronger form incurs penalty.

## 5) Selection Rule (Least Adequate Power Principle)

Primary rule:

\[
\hat{i}=\arg\max_{i}\Phi(i)
\quad\text{subject to}\quad \alpha_i=1.
\]

Normative tie-break:

\[
\hat{i}=\min\left\{i:\,i\in\arg\max_{\alpha_i=1}\Phi(i)\right\}.
\]

This yields the least powerful scaffold among equally adequate high-scoring options.

## 6) Axiom-to-Tensor Mapping (Explicit)

1. **Expressive power has cost**: monotone risk captured via $\partial \mathcal{C}_{i j t}/\partial e_i \ge 0$ (expected trend).
2. **Adequacy precedes minimization**: hard gate $\alpha_i=1$ before optimization.
3. **Explicit structure over hidden behavior**: maximize $\mathcal{S}$ contribution.
4. **Constraint creates intelligibility**: maximize $\mathcal{I}$ under bounded expressive freedom.
5. **Downstream use matters**: include lifecycle utility tensor $\mathcal{U}$ across $t$.
6. **Standard weak forms create public power**: include adoption/comprehension tensor $\mathcal{W}$.
7. **Escalation must be justified**: penalize unjustified transitions via $\Xi_i$ and $\mathcal{J}$.

## 7) Operational Algorithm (Finite Candidate Set)

1. Enumerate candidate scaffolds $i=0..m$ from weakest to strongest.
2. Estimate tensors $\mathcal{C},\mathcal{A},\mathcal{S},\mathcal{I},\mathcal{U},\mathcal{W}$.
3. Compute adequacy gate $\alpha_i$.
4. Discard all $i$ with $\alpha_i=0$.
5. Compute escalation penalty $\Xi_i$ from pairwise justifications.
6. Compute multilinear score $\Phi(i)$.
7. Select $\hat{i}$ by constrained maximization + minimum-index tie-break.

## 8) Compact Einstein-Notation Form

Using implied summation:

\[
\Phi(i)=\alpha_i\left(-\lambda_C w^C_{jt} \mathcal{C}_{ijt}
+\lambda_S w^S_{rt} \mathcal{S}_{irt}
+\lambda_I w^I_{ut} \mathcal{I}_{iut}
+\lambda_U w^U_{jt} \mathcal{U}_{ijt}
+\lambda_W w^W_{gt} \mathcal{W}_{igt}
\right)-\lambda_E\Xi_i.
\]

This is the requested multilinear tensor framework: a constrained, lifecycle-aware, escalation-sensitive formalization of the stated phenomena.

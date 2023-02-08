---
name: Bug report
about: Create a report to help us improve
labels: bug
---
# Bug Report

<!-- Provide a general summary of the issue in the title above. -->

## Current Behavior

<!--
Tell us what is currently happening. If applicable, add screenshots to help
explain your problem.
-->

## Expected Behavior

<!--
Tell us how it should work, how it differs from the current implementation.
-->

## Possible Solution

<!--
Suggest a fix/reason for the bug, or ideas how to implement it.
Delete if not applicable/relevant.
-->

## Steps to Reproduce

<!--
Provide a link to a live example, or an unambiguous set of steps to
reproduce this bug. Include code to reproduce, if relevant.
-->

1.
2.
3.

## Context

<!--
How has this issue affected you? What are you trying to accomplish?
Providing context helps us come up with a solution that is most useful
in the real world.
-->

## Your Environment

<!--
Instructions:
  * Run the following script in a terminal
  * Paste the output in the code section at the bottom of this report
    (the output is automatically copied to your clipboard buffer)
  * Adjust the values if needed
  * If you cannot run the script for any reason, simply replace the
    values in the example

COMMIT=$(git log -1 --pretty=format:"%h %s %d")
KUBECTL=$(kubectl version)
TEKTON=$(tkn version)
OUTPUT="$(cat <<EOF
Last commit:
  ${COMMIT}
Kubernetes:
  ${KUBECTL}
Tekton:
  ${TEKTON}
EOF
)"
echo "$OUTPUT" | tee >(pbcopy)

-->

```txt
(replace the example below with the script output)
Last commit:
  d6d7647 Alternate approach for internal minikube OCI registry  (HEAD -> github-templates, upstream/main, upstream/HEAD, main)
Kubernetes:
  Client Version: version.Info{Major:"1", Minor:"22", GitVersion:"v1.22.4", GitCommit:"b695d79d4f967c403a96986f1750a35eb75e75f1", GitTreeState:"clean", BuildDate:"2021-11-17T15:41:42Z", GoVersion:"go1.16.10", Compiler:"gc", Platform:"darwin/arm64"}
Tekton:
  Client version: 0.21.0
```

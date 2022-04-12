+++
title = "Using CUE"
description = "Working with CUE in the Secure Software Factory."
sort_by = "weight"
draft = false
weight = 30
template = "docs/page.html"

[extra]
lead = "Working with CUE in the Secure Software Factory."
toc = true
top = false
+++

## CUE Module Structure

The top level of the Secure Software Factory (SSF) is structured as a
[CUE module](https://cuelang.org/docs/concepts/packages/) and follows the
[schema/policy/data](https://cuelang.org/docs/concepts/packages/#file-organization)
pattern for organizing the files.

The
[`cue.mod`](https://cuelang.org/docs/concepts/packages/#the-cuemod-directory)
directory is predominantly for CUE package management. All of the files in
`cue.mod/gen/...` are generated from the `cue get go ...` command importing go
modules and converting them to CUE. These can then be imported and used to
verify the structure of things such as `ConfigMap`. `ssf.cue` imports several of
these and creates base structures based on these imported go structs.

For the most part, CUE expects the evaluation to be done relative to the root of
the CUE module. Evaluation can be narrowed by providing a path to a subdirectory
(e.g. `cue eval ./examples/buildpacks`). CUE will then only evaluate things in
that subdirectory (`./examples/buildpacks`) or its parent directories (`.` and
`./examples`), but will not evaluate things in adjacent or sibling directories
(e.g. `./resources/...` or `./examples/sample-pipeline`).

## Adding or Modifying

Typically new `.cue` files will be added in a subdirectory similar to what has
been done in the `examples/...` directories. In the case of `examples` there is
`examples.cue` which holds some definitions that are shared across all of the
examples. Of particular note is a comprehension that creates a persistent volume
claim (PVC) for each pipeline run. A reference to the PVC is added to the
pipeline run definition by default.

```text
// generate a PVC for each pipelineRun
persistentVolumeClaim: {
 for pr in pipelineRun {
  "\(pr.metadata.generateName)source-ws-pvc": spec: {
   accessModes: ["ReadWriteOnce"]
   resources: requests: storage: "500Mi"
  }
 }
}

pipelineRun: [Name=_]: spec: workspaces: [{
 name: *"\(Name)ws" | string
 persistentVolumeClaim: claimName: "\(Name)source-ws-pvc"
}, ...]
```

## Using CUE Tool

SSF uses the `cue cmd` support (see `cue cmd --help` and
[cue tooling layer](https://blog.patapon.info/cue-tool/) for more details) for
selecting and exporting definitions. This can be seen in `ssf_tool.cue` which
defines commands for exporting things that can be used in conjunction with
`kubectl`. An example of its usage can be seen in
`examples/buildpacks/buildpacks.sh`.

```bash
pushd examples/buildpacks
cue cmd -t "repository=${REPOSITORY}" apply | kubectl apply -f -
cue cmd -t "repository=${REPOSITORY}" create | kubectl create -f -
popd
```

Here we are using the `cue apply ...` command to export definitions from
`./examples/buildpacks` that can be used with `kubectl apply ...`. And similarly
`cue create ...` exports definitions from `./examples/buildpacks` that can be
used with `kubectl create ...`.

The above example also shows the usage of a tag (`cue -t ...`) for passing
values (`repository` in this case) into the CUE definitions.

## References

- <https://cuelang.org/docs/>
- <https://cuelang.org/docs/concepts/packages/>
- <https://blog.patapon.info/cue-tool/>

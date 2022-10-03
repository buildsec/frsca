package frsca

import (
	"encoding/json"
	"encoding/yaml"
	"strings"

	"tool/cli"
	"tool/exec"
	"tool/file"
)

globYaml: file.Glob & {
	glob: "*.yaml"
}

open: {
	for _, f in globYaml.files {
		(f): file.Read & {
			filename: f
			contents: _
			data:     yaml.UnmarshalStream(contents)
		}
	}
}

// allTasks lists all tasks run to fetch the configuration. Other tasks
//
allTasks: {glob: globYaml, open}

// Put results into the object map as defined in our top-level schema.
frsca: {
	for v in open for obj in v.data if obj.kind != _|_ && obj.metadata != _|_ && (obj.metadata.name != _|_ || obj.metadata.generateName != _|_) {
		(strings.ToCamel(obj.kind)): ("\(obj.metadata.name)" | "\(obj.metadata.generateName)"): obj
	}
}

command: [string]: $after: allTasks

command: {
	apply: cli.Print & {
		text: yaml.MarshalStream([ for x in frsca for y in x if y.metadata.name != _|_ {y}])
	}
	create: cli.Print & {
		text: yaml.MarshalStream([ for x in frsca for y in x if y.metadata.generateName != _|_ {y}])
	}
	print: cli.Print & {
		text: json.MarshalStream([ for x in frsca for y in x {y}])
	}
    config: cli.Print & {
        name: string | *"cosign" @tag(configName)
        item: string | *"asset" @tag(configItem)
        n: {for k, v in frscaConfig if k == name {v}}
        i: {for k, v in n if k == item {v}}
        text: i
    }
}

// operations to support local runtime environment interrogation
_configArch: exec.Run & {
    cmd: ["bash", "-c", "uname -m"]
    stdout: string
}

_configArchSed: exec.Run & {
    cmd: ["bash", "-c", "uname -m | sed -e 's/x86_64/amd64/'"]
    stdout: string
}

_configPlatform: exec.Run & {
    cmd: ["bash", "-c", "uname"]
    stdout: string
}

_configPlatformLower: exec.Run & {
    cmd: ["bash", "-c", "uname | tr '[:upper:]' '[:lower:]'"]
    stdout: string
}

// configuration attributes that are dependent on runtime environment
frscaConfig: arch: strings.TrimSpace(_configArch.stdout)
frscaConfig: archSed: strings.TrimSpace(_configArchSed.stdout)
frscaConfig: platform: strings.TrimSpace(_configPlatform.stdout)
frscaConfig: platformLower: strings.TrimSpace(_configPlatformLower.stdout)

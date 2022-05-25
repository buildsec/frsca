package frsca

import (
	"encoding/json"
	"encoding/yaml"
	"strings"

	"tool/cli"
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
}

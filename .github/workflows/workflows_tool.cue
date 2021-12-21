package workflows

import (
    "tool/file"
    "encoding/yaml"
)

command: genworkflows: {
    for w in workflows {
        "\(w.filename)": file.Create & {
            filename: w.filename
            contents: yaml.Marshal(w.workflow)
        }
    }
}

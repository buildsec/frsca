#!/usr/bin/env bash
set -euo pipefail

# Define variables.
C_GREEN='\033[32m'
C_RED='\033[31m'
C_RESET_ALL='\033[0m'

gitea_exec() {
  kubectl exec -i -n gitea deploy/gitea -c gitea -- su - git
}
gitea_copy_repo() {
gitea_exec <<EOF
  set -ex
  if [ $# -lt 2 ]; then
    echo -e "${C_RED}missing args to gitea_copy_repo.${C_RESET_ALL}"
    exit 1
  fi
  if ! curl -sfL -H 'accept: application/json' "https://gitea-http:3000/api/v1/repos/frsca/${2}" >/dev/null; then
    echo -e "${C_GREEN}Creating ${2} repo.${C_RESET_ALL}"
    curl -sfSL -X 'POST' -u gitea_admin:FRSCAgiteaAdmin \
      'https://gitea-http:3000/api/v1/admin/users/frsca/repos' \
      -H 'accept: application/json' \
      -H 'Content-Type: application/json' \
      -d '{ "auto_init": false, "description": "${2}", "name": "${2}", "default_branch": "${3:-main}", "private": false, "trust_model": "default" }'
  fi
  # be careful around mktemp since we later do an "rm -r" on it
  tmpdir="\$(mktemp -d)"
  if [ -z "\$tmpdir" ] || [ ! -d "\$tmpdir" ]; then
    echo -e "${C_RED}mktemp failed.${C_RESET_ALL}"
    exit 1
  fi
  cd "\${tmpdir}"
  git clone "${1}" --mirror .
  # remove any pull refs
  git show-ref | cut -d' ' -f2 | grep 'refs/pull' | xargs -r git update-ref -d
  git remote add gitea "https://frsca:demo1234@gitea-http:3000/frsca/${2}.git"
  git push gitea "${3:-main}:${3:-main}" --force
  git push gitea --mirror --force
  cd -
  rm -r "\${tmpdir}"
  # create hook to trigger the tekton event listener, the id is not predictable, so patching is not possible
  cur_hooks="\$(curl -sSL "https://gitea-http:3000/api/v1/repos/frsca/${2}/hooks/" -H 'accept: application/json' -u gitea_admin:FRSCAgiteaAdmin)"
  if [ "\$cur_hooks" = "[]" ]; then
    curl -u gitea_admin:FRSCAgiteaAdmin \
      -H 'accept: application/json' \
      -H 'content-type: application/json' \
      -d '{"active":true,"type":"gitea","config":{"content_type":"json","url":"http://el-${2}-listener.default.svc.cluster.local:8080"},"events":["push"]}' \
      https://gitea-http:3000/api/v1/repos/frsca/${2}/hooks
  fi
EOF
}

gitea_exec <<EOF
  if ! curl -sfL -H 'accept: application/json' "https://gitea-http:3000/api/v1/users/frsca" >/dev/null; then
    echo -e "${C_GREEN}Creating gitea user.${C_RESET_ALL}"
    /usr/local/bin/gitea admin user create --username frsca --email frsca@example.org --password demo1234 --must-change-password=false
  fi
EOF

gitea_copy_repo https://github.com/buildsec/example-buildpacks example-buildpacks main
gitea_copy_repo https://github.com/buildsec/example-golang example-golang master
gitea_copy_repo https://github.com/buildsec/example-gradle example-gradle master
gitea_copy_repo https://github.com/buildsec/example-ibm-tutorial example-ibm-tutorial master
gitea_copy_repo https://github.com/buildsec/example-maven example-maven master
gitea_copy_repo https://github.com/buildsec/example-sample-pipeline example-sample-pipeline wolfi

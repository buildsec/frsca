import pytest


@pytest.fixture()
def kubectl():
    """Runs an arbitrary kubectl/oc command for a specific namespace and context."""

    def _kubectl(host, cmd):
        assert host.backend.NAME in ["kubectl", "openshift"]
        assert host.backend.namespace
        assert host.backend.context

        ctlmap = {"kubectl": "kubectl", "openshift": "oc"}

        kcmd = [
            f"{ctlmap[host.backend.NAME]}",
            f"--context {host.backend.context}",
            f"--namespace {host.backend.namespace}",
        ]
        kcmd.append(cmd)
        out = host.backend.run_local(" ".join(kcmd))
        return out

    return _kubectl

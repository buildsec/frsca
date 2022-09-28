import json

import pytest


# Label used by the chains controller.
APP_LABEL = "app=tekton-chains-controller"


def test_chains_installed(host):
    """Ensures chains is installed"""


@pytest.mark.chains
def test_chains_running(host, kubectl):
    """Ensures chains is running"""
    kcmd = " ".join(
        [
            "get pods",
            f"-l {APP_LABEL}",
            "--field-selector=status.phase=Running",
            "-o json",
        ]
    )
    res = kubectl(host, kcmd)

    assert res.rc == 0
    stdout_json = json.loads(res.stdout)
    assert stdout_json["items"]
    assert len(stdout_json["items"]) == 1
    assert stdout_json["items"][0]["status"]["phase"] == "Running"

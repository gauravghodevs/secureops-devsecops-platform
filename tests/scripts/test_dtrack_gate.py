import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2] / "scripts"))

from dtrack_gate import evaluate  # noqa: E402


def test_passes_when_clean():
    assert evaluate({"critical": 0, "high": 3}, max_critical=0, max_high=-1) == []


def test_fails_on_critical():
    out = evaluate({"critical": 2, "high": 0}, max_critical=0, max_high=-1)
    assert out == ["critical: found 2, allowed 0"]


def test_high_limit_enforced_when_set():
    assert evaluate({"critical": 0, "high": 6}, max_critical=0, max_high=5)
    assert evaluate({"critical": 0, "high": 5}, max_critical=0, max_high=5) == []


def test_negative_limit_disables_check():
    assert evaluate({"critical": 99}, max_critical=-1, max_high=-1) == []


def test_missing_or_null_metrics_are_treated_as_zero():
    assert evaluate({"critical": None}, max_critical=0, max_high=0) == []

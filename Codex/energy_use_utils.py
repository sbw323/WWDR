"""Utilities for naming and detecting energy-use columns."""

from __future__ import annotations

import re
from pathlib import Path
from typing import Optional, Union

ENERGY_USE_PREFIX = "energy_use"
_REACTOR_PATTERN = re.compile(r"(?:reactor[_-]?|R)(?P<index>[1-5])", re.IGNORECASE)


def derive_reactor_suffix(identifier: Union[str, Path]) -> str:
    """Return a reactor suffix (e.g., ``R1``) derived from a dataset identifier."""
    text = identifier.name if isinstance(identifier, Path) else str(identifier)
    match = _REACTOR_PATTERN.search(text)
    if not match:
        raise ValueError(f"Unable to derive reactor suffix from '{identifier}'.")
    return f"R{match.group('index')}"


def build_energy_use_column_name(identifier: Union[str, Path]) -> str:
    """Construct the energy-use column name for a dataset, e.g., ``energy_use_R3``."""
    suffix = derive_reactor_suffix(identifier)
    return f"{ENERGY_USE_PREFIX}_{suffix}"


def energy_use_suffix_from_column(column_name: str) -> Optional[str]:
    """Extract the reactor suffix from an energy-use column name when present."""
    if not column_name.lower().startswith(ENERGY_USE_PREFIX):
        return None
    match = _REACTOR_PATTERN.search(column_name)
    if not match:
        return None
    return f"R{match.group('index')}"

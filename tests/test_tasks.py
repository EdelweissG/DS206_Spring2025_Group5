# tests/test_tasks.py

import os
import sys
import types
import importlib
import pytest

# -----------------------------------------------------------------------------
# 1) Stub out pyodbc so tasks.py can import without error
# -----------------------------------------------------------------------------
sys.modules['pyodbc'] = types.ModuleType('pyodbc')

# -----------------------------------------------------------------------------
# 2) Ensure the project root is on sys.path
# -----------------------------------------------------------------------------
ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), os.pardir))
if ROOT not in sys.path:
    sys.path.insert(0, ROOT)

# -----------------------------------------------------------------------------
# 3) Import your tasks module
# -----------------------------------------------------------------------------
tasks = importlib.import_module("pipeline_dimensional_data.tasks")

# -----------------------------------------------------------------------------
# 4) Patch execute_sql on the tasks module itself
# -----------------------------------------------------------------------------
@pytest.fixture(autouse=True)
def patch_execute_sql(monkeypatch):
    calls = []
    monkeypatch.setattr(
        tasks,
        "execute_sql",
        lambda conn_str, sql_command, params=None: (calls.append(sql_command) or {'success': True})
    )
    return calls

# -----------------------------------------------------------------------------
# 5) Test create_tables emits CREATE statements
# -----------------------------------------------------------------------------
def test_create_tables_emits_create(tmp_path, patch_execute_sql):
    # Prepare a dummy config file
    cfg = tmp_path / "cfg.ini"
    cfg.write_text(
        "[SQLServer]\n"
        "Driver=DRV\n"
        "Server=SVR\n"
        "Database=DB\n"
        "Trusted_Connection=yes\n"
    )

    result = tasks.create_tables(
        config_path=str(cfg),
        database_name="DB",
        schema_name="dbo"
    )
    assert result.get("success") is True, f"Expected success, got {result}"
    sqls = [s.upper() for s in patch_execute_sql]
    assert any("CREATE TABLE" in s for s in sqls), f"Expected CREATE TABLE, got {sqls}"

# -----------------------------------------------------------------------------
# 6) Test ingest_data emits INSERT statements
# -----------------------------------------------------------------------------
def test_ingest_data_emits_insert(tmp_path, patch_execute_sql):
    # Prepare a dummy config file
    cfg = tmp_path / "cfg.ini"
    cfg.write_text(
        "[SQLServer]\n"
        "Driver=DRV\n"
        "Server=SVR\n"
        "Database=DB\n"
        "Trusted_Connection=yes\n"
    )

    # Supply one source→dest mapping
    mappings = [("source_tbl", "dest_tbl")]

    result = tasks.ingest_data(
        config_path=str(cfg),
        database_name="DB",
        schema_name="dbo",
        table_mappings=mappings,
        start_date="2025-01-01",
        end_date="2025-01-31"
    )
    assert result.get("success") is True, f"Expected success, got {result}"
    sqls = [s.upper() for s in patch_execute_sql]
    assert any("INSERT INTO DBO.DEST_TBL" in s for s in sqls), f"Expected INSERT, got {sqls}"

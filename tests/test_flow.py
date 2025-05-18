import os, sys, types, importlib, pytest

# Stub pyodbc
sys.modules['pyodbc'] = types.ModuleType('pyodbc')

# Put project root on path
ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), os.pardir))
sys.path.insert(0, ROOT)

tasks   = importlib.import_module("pipeline_dimensional_data.tasks")
flow_mod = importlib.import_module("pipeline_dimensional_data.flow")

@pytest.fixture(autouse=True)
def patch_tasks(monkeypatch):
    called = []
    def make_stub(name):
        def stub(*args, **kwargs):
            called.append(name)
            return {"success": True}
        return stub
    monkeypatch.setattr(tasks, "create_tables", make_stub("create_tables"))
    monkeypatch.setattr(tasks, "ingest_data",   make_stub("ingest_data"))
    return called

def test_flow_executes_create_and_ingest(tmp_path, patch_tasks):
    # 4a) Dummy config file
    cfg = tmp_path / "cfg.ini"
    cfg.write_text(
        "[SQLServer]\n"
        "Driver=DRV\n"
        "Server=SVR\n"
        "Database=DB\n"
        "Trusted_Connection=yes\n"
    )

    # 4b) Table mappings
    mappings = [("src_tbl", "dst_tbl")]

    # 4c) Instantiate with all required args
    flow = flow_mod.DimensionalDataFlow(
        config_path=str(cfg),
        database_name="DB",
        schema_name="dbo",
        table_mappings=mappings
    )
    result = flow.exec(
        start_date="2025-01-01",
        end_date="2025-01-31"
    )

    # 4d) Assertions
    assert result.get("success") is True
    assert "execution_id" in result
    assert patch_tasks == ["create_tables", "ingest_data"]

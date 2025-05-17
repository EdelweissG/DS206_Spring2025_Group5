import os
import importlib.util

def _load_config_module():
    # 1. Compute the path to your config.py
    root = os.path.abspath(os.path.join(os.path.dirname(__file__), os.pardir))
    cfg_path = os.path.join(root, "pipeline_dimensional_data", "config.py")
    # 2. Load it as a fresh module
    spec = importlib.util.spec_from_file_location("cfgmod", cfg_path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module

def test_load_config_exists_and_callable():
    config = _load_config_module()
    # Verify the function exists
    assert hasattr(config, "load_config"), "config.py missing load_config()"
    assert callable(config.load_config), "load_config is not callable"

def test_load_config_behavior(tmp_path):
    config = _load_config_module()
    # Create a dummy .cfg file
    cfg_file = tmp_path / "dummy.cfg"
    cfg_file.write_text(
        "[SQL_SERVER]\n"
        "server=srv\n"
        "database=db\n"
        "username=usr\n"
        "password=pw\n"
    )
    # Call and verify
    result = config.load_config(str(cfg_file))
    assert isinstance(result, dict), "Expected dict"
    for key in ("server", "database", "username", "password", "schema"):
        assert key in result, f"Missing key '{key}'"
    assert result["schema"] == "dbo", "Default schema should be 'dbo'"

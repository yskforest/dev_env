# dev_env

```powershell
python -m venv dev_env
dev_env\Scripts\activate
python -m pip install --upgrade pip
pip install -r requirements.txt
```

```bash
python -m venv dev_env
source dev_env\bin\activate
python -m pip install --upgrade pip
pip install -r requirements.txt
```

```bash
# save env
pip freeze > requirements_snap.txt
```
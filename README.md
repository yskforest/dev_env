# dev_env

## setup
- Windows
```powershell
python -m venv dev_env
dev_env\Scripts\activate
python -m pip install --upgrade pip
pip install -r requirements.txt
```
- Linux
```bash
bash setup.sh
```
- Docker
```bash
docker compose build
docker compose run --rm cpu
```

## memo
```bash
# save env
pip freeze > requirements_snap.txt
```

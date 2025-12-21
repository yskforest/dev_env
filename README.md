# dev_env

## 前提条件

- Python 3.8+
- Docker (Dockerでのセットアップを行う場合)

## setup

- Windows

PowerShellで以下のコマンドを実行します。
```powershell
# 初回実行時、スクリプトの実行ポリシーの変更が必要な場合があります。
# Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
./setup.ps1
```
- Linux
```bash
bash setup.sh
```
- Docker

Build the image with host UID/GID to avoid permission issues:

```bash
# Build with current user's UID/GID
UID=$(id -u) GID=$(id -g) docker compose build cpu

# Run
docker compose run --rm cpu
```

The Python environment inside the container is managed by `uv`.
- Virtual environment: `/home/ubuntu/.venv`
- Dependencies: Managed via `requirements.txt` (imported by `uv add -r` during build)

## memo
```bash
# save env
pip freeze > requirements_snap.txt
```

## uv
```bash
# install
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"

uv init -p 3.12
uv add -r requirements.txt
uv pip list
```

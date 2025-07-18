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
```bash
docker compose build
docker compose run --rm cpu
```

## memo
```bash
# save env
pip freeze > requirements_snap.txt
```

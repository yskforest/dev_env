$VenvDir = "dev_env"

if (-not (Test-Path -Path $VenvDir)) {
    Write-Host "Creating virtual environment in '$VenvDir'..."
    python -m venv $VenvDir
}

Write-Host "Activating virtual environment and installing dependencies..."
& ".\$VenvDir\Scripts\activate.ps1"
python -m pip install --upgrade pip
pip install -r requirements.txt

Write-Host "Setup complete. To activate the environment, run: .\$VenvDir\Scripts\activate"
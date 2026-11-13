Set-Location $PSScriptRoot
if (!(Test-Path ".venv\Scripts\python.exe")) { py -m venv .venv }
.\.venv\Scripts\Activate.ps1
python -m pip install -r requirements.txt
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload

#!/bin/zsh

OPEN_VSCODE=false
FILES=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    -v)
      OPEN_VSCODE=true
      shift
      ;;
    -f)
      FILES+=("$2")
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

while true; do
  read "FOLDER_NAME?Please input repo name: "
  if [ -d "$FOLDER_NAME" ]; then
    echo "Please reinput, it's already a folder: $FOLDER_NAME"
  else
    break
  fi
done

while true; do
  read "PYTHON_VERSION?Please input Python version (e.g. 3.12): "
  PYTHON_EXEC="python$PYTHON_VERSION"
  if command -v $PYTHON_EXEC &> /dev/null; then
    break
  else
    echo "Python version $PYTHON_VERSION not found. Please try again."
  fi
done

read "PACKAGES?Please input packages: "
read "INTERNAL_PORT?Container internal port (e.g. 8000 for FastAPI): "
read "EXTERNAL_PORT?Expose to which host port (e.g. 8001): "
read "COMMAND?Docker run command (e.g. uvicorn src.main:app --host 0.0.0.0 --port $INTERNAL_PORT): "

git init "$FOLDER_NAME"
cd "$FOLDER_NAME" || exit

$PYTHON_EXEC -m venv venv
source venv/bin/activate

if [[ -n "$PACKAGES" ]]; then
  pip install $=PACKAGES
fi

pip freeze > requirements.txt

cat <<EOF > .gitignore
venv/
.env
__pycache__/
EOF

mkdir src

for f in "${FILES[@]}"; do
  touch "src/$f"
done

{
  echo "FROM python:$PYTHON_VERSION-slim"
  echo
  echo "WORKDIR /app"
  echo
  echo "COPY requirements.txt ."
  echo "RUN pip install --no-cache-dir -r requirements.txt"
  echo
  for f in "${FILES[@]}"; do
    echo "COPY src/$f ."
  done
} > Dockerfile

cat <<EOF > docker-compose.yml
services:
  app:
    build: .
    volumes:
      - ./src:/app/src
    ports:
      - "${EXTERNAL_PORT}:${INTERNAL_PORT}"
    command: ${COMMAND}
EOF

if $OPEN_VSCODE; then
  code .
fi

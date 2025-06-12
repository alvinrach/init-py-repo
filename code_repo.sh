#!/bin/zsh

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

git init "$FOLDER_NAME"
cd "$FOLDER_NAME" || exit

$PYTHON_EXEC -m venv venv
source venv/bin/activate

if [[ -n "$PACKAGES" ]]; then
  pip install $=PACKAGES
fi

cat <<EOF > .gitignore
venv/
.env
__pycache__/
EOF

code .

#!/bin/zsh

while true; do
  read "FOLDER_NAME?Please input repo name: "
  if [ -d "$FOLDER_NAME" ]; then
    echo "Please reinput, it's already a folder: $FOLDER_NAME"
  else
    break
  fi
done

read "PACKAGES?Please input packages: "

git init "$FOLDER_NAME"
cd "$FOLDER_NAME" || exit

python3.12 -m venv venv
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

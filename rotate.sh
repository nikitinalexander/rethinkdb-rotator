#!/bin/bash
set -e

if [[ -z "${KUSTOMIZE_ENV}" ]]; then
    echo "KUSTOMIZE_ENV missing"
    exit 1
fi

if [[ -z "${REPO_OWNER}" ]]; then
    echo "REPO_OWNER missing"
    exit 1
fi

if [[ -z "${REPO_NAME}" ]]; then
    echo "REPO_NAME missing"
    exit 1
fi

if [[ -z "${GIT_TOKEN}" ]]; then
    REPO_URL="https://github.com/$REPO_OWNER/$REPO_NAME.git"
else
    REPO_URL="https://oauth2:$GIT_TOKEN@github.com/$REPO_OWNER/$REPO_NAME.git"
fi

python pg.py > password.txt

# Run python code to update client in password in database
python update.py

rm -rf $REPO_NAME

# Clone the repository
echo "Clonning $REPO_URL"
git clone $REPO_URL

cp password.txt $REPO_NAME/base/password.txt

# Change to the repository directory
cd $REPO_NAME

# Apply the changes using kubectl apply -k on the client environment
kubectl apply -k overlays/$KUSTOMIZE_ENV
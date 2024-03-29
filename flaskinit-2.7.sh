#!/bin/bash
echo "This will setup a Flask project using python2.7"
read -p "Enter project path: " path
mkdir $path
cd $path
virtualenv venv --python=/usr/bin/python
source venv/bin/activate
pip install flask
pip install flake8
pip install pymysql
pip install requests
pip install python-dotenv
pip install gunicorn
pip freeze > requirements.txt
modules_path = ""
# construct python project modules path
if [[ "${str: -1}" != '/' ]]
then
        modules_path = "$path"+"/modules"
else
        modules_path = "$path"+"modules"
fi

cat <<EOF >__init__.py
from flask import Flask, request, render_template, Response, abort, send_file, jsonify, redirect, url_for, send_from_directory, session, make_response, flash, g, send_from_directory
import pymysql.cursors
import json, os, requests
sys.path.append("$modules_path")  # change that if you upload this to remote (path will differ most likely)
from db import DB

app = Flask(__name__)

@app.route("/")
def index():
        output = {
                "result": "success"
        }
        response = make_response(json.dumps(output,indent=4,sort_keys=True))
        response.headers['Access-Control-Allow-Origin'] = "*"
        response.headers[ 'Content-Type']='application/json'
        return response

if __name__ == "__main__":
        app.secret_key = 'secret123'
        app.run(debug=True)

EOF


cat <<EOF >.env
# Doc: https://github.com/theskumar/python-dotenv
export DATABASE_NAME = <enter_database_name>
EOF
cat <<EOF >settings.py
import os
from dotenv import load_dotenv
load_dotenv()

# OR, the same with increased verbosity:
#load_dotenv(verbose=True)
EOF




mkdir modules
mkdir sql
mkdir templates
mkdir static
mkdir bin

cd modules
touch __init__.py
cat <<EOF >db.py
import pymysql.cursors
import os
# Insert database name inside the .env file. (and as many other env variables you want, like password, you dog's name, etc)
class DB:
    def __init__(self,host="localhost",user='root', password='secret',port=3306):
        DATABASE_NAME = os.getenv("DATABASE_NAME")
        self.connection = pymysql.connect(host='localhost',user=user, password=password,db=DATABASE_NAME,cursorclass=pymysql.cursors.DictCursor)


EOF
echo ".env file will be included inside .gitignore. remove that line if you actually want that file in the repo."
cd ..
git init
cat <<EOF >.gitignore
.vscode
venv
_labs
*.pyc
__pycache__
.env
EOF

cat <<EOF >README.md
# Welcome to flaskinit

## Description

Flask init is a shell script that creates a basic project structure, with a few dependencies within a virtualenv folder, using python2.7 (which you need to have installed previously, along with virtualenv)
If you can't execute the script, use $ \`chmod +x ./flaskinit.sh\` to provide the script with executable permissions. No sudo permissions are required.

## Requirements

* virtualenv
* python2.7 installed on /usr/bin/python  (new versions of this script will accept the python path as arguement before initializing the project)
* MySQL server

## Usage

After you execute the script, you will have a folder containing all the project structure and files. The file \`__init__.py\` on the root folder will be the "flask app file". It comes with a default route and some basic stuff to get you started quickly into adding more routes. Even if the script is meant to generate a squeleton for a Rest API, the templates and static folders are also created just in case you want to do a HTML response application.

The structure is made so that you include all your custom classes inside the modules folder, and all your "execute" files inside the bin folder.

To start the flask app, just activate the virtualenv by doing \`source venv/bin/activate\` and then starting the flask app with \`python __init__.py\`

## Notes

* This script uses pymysql as a connector driver for MySQL db. If you dont want to use it, remove it from the virtualenv
EOF
read -p "Press enter to exit" continue
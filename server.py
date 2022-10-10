import os
from flask import Flask, request, url_for
from werkzeug.utils import secure_filename
import random
import string
import subprocess
import json
from zipfile import ZipFile
from flask import send_from_directory

app = Flask(__name__)
data_dir = "upload_txt"

def get_all_file_paths(directory):
    file_paths = []
    for root, directories, files in os.walk(directory):
        for filename in files:
            # join the two strings in order to form the full filepath.
            filepath = os.path.join(root, filename)
            file_paths.append(filepath)
    return file_paths

@app.route('/upload', methods=['PUT','GET','POST'])
def upload():
        session_id = ''.join(random.choices(string.ascii_lowercase, k=5))
        if not os.path.exists(data_dir+"/"+session_id):
                os.makedirs(data_dir+"/"+session_id)
        if 'file' not in request.files:
                return "No file part"
        file_ = request.files['file']
        filename = secure_filename(file_.filename)
        file_.save(data_dir+"/"+session_id+"/data.txt")
        subprocess.run(["bash", "run_english_api.sh", data_dir+"/"+session_id+"/data.txt" ,data_dir+"/"+session_id])
        model_dir = data_dir+"/"+session_id+"/model_lh"
        file_paths = get_all_file_paths(model_dir)
        with ZipFile(data_dir+"/"+session_id+'/model.zip','w') as zip:
                for file in file_paths:
                        zip.write(file)
        dict1 = {}
        dict1["path"] = session_id
        return json.dumps(dict1)

@app.route('/download/<path:filename>', methods=['GET', 'POST'])
def download(filename):
        return send_from_directory(directory=data_dir+"/"+filename, filename="model.zip")

app.run(host='0.0.0.0', port=8888, debug=True)

from flask import Flask, request, jsonify
import werkzeug
import db

accepted_extensions = {'jpg', 'png'}

app = Flask(__name__)
@app.route('/upload', methods = ["POST"])

def upload():
    if request.method == "POST":
        imagefile = request.files['image']
        file_name = werkzeug.utils.secure_filename(imagefile.filename)   
        print("\nFile name : " + imagefile.filename)
        imagefile.save("./uploads/" + file_name)
    
    return jsonify({"message": "Image uploaded",})

@app.route('/search', methods = ["POST"])

def search(name): #returns of class Company if found, 0 if not found
    if request.method == "POST":
        for company in (db.Company.get(company.name in name)): #if the name appears in all the text read from the tag, 
            return company
        return 0

if __name__ == "__main__":
    app.run()
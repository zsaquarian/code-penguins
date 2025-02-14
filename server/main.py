from flask import Flask, request, jsonify
import werkzeug

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

if __name__ == "__main__":
    app.run()
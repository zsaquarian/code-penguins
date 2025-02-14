from flask import Flask, request, jsonify
import werkzeug
import db

accepted_extensions = {"jpg", "png"}

app = Flask(__name__)


@app.route("/upload", methods=["POST"])
def upload():
    if request.method == "POST":
        imagefile = request.files["image"]
        file_name = werkzeug.utils.secure_filename(imagefile.filename)
        print("\nFile name : " + imagefile.filename)
        imagefile.save("./uploads/" + file_name)

    return jsonify(
        {
            "message": "Image uploaded",
        }
    )


@app.route("/search/<name>", methods=["POST"])
def search(name):  # returns of class Company if found, 0 if not found
    if request.method == "POST":
        query = db.Company.select().where(db.Company.name == name)
        company = query[0]
        return {
            "name": company.name,
            "sustainability_score": company.sustainability_score,
            "sustainability_description": company.sustainability_description,
            "ethics_score": company.ethics_score,
            "ethics_description": company.ethics_description,
        }


@app.route("/alternatives", methods=["POST"])
def alternatives(category):
    ls_alt = [
        company.name
        for company in db.Company.select().where(
            (category in db.Company.categories)
            and (db.Company.sustainability_score > 70 or db.Company.ethics_score > 70)
        )
    ]
    return jsonify(ls_alt)


@app.route("/get_all_names")
def get_all_names():
    ls_all = {}
    for company in db.Company.select():
        ls_all.append(company.name)
    return jsonify(ls_all)


@app.route("/add_company")
def add_company(name, s_score, s_desc, e_score, e_desc, categories):
    new_company = db.Company.create(
        name=name,
        sustainability_score=s_score,
        sustainability_description=s_desc,
        ethics_score=e_score,
        ethics_description=e_desc,
        categories=categories,
        verified=False,
    )
    new_company.save()


if __name__ == "__main__":
    app.run()

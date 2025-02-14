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
            "categories": company.categories,
        }


@app.route("/alternatives", methods=["POST"])
def alternatives():
    data = request.get_json()
    if "category" in data:
        query = db.Alternatives.select().where(
            db.Alternatives.category == data["category"]
        )
        if len(query) > 0:
            alt = query[0]

            return {
                "alternatives": alt.alternatives.split(","),
                "best_alternatives": alt.best_alternatives.split(","),
            }
        else:
            return {"alternatives": [], "best_alternatives": []}
    elif "company" in data:
        query = db.Company.select().where(db.Company.name == data["company"])
        company = query[0]

        alts = []
        for category in company.categories.split(","):
            query = db.Alternatives.select().where(db.Alternatives.category == category)
            if len(query) > 0:
                alt = query[0]
                alts.extend(alt.best_alternatives.split(","))
        return {"alternatives": alts, "best_alternatives": []}

    return {"message": "failed"}


@app.route("/getAll")
def get_all_names():
    ls_all = []
    for company in db.Company.select():
        ls_all.append(company.name)
    return ls_all


@app.route("/addCompany", methods=["POST"])
def add_company():
    data = request.get_json()
    new_company = db.Company.create(
        name=data["name"],
        sustainability_score=data["sustainability_score"],
        sustainability_description=data["sustainability_description"],
        ethics_score=data["ethics_score"],
        ethics_description=data["ethics_description"],
        categories=data["categories"],
    )
    new_company.save()
    return jsonify({"message": "success"})


@app.route("/addAlternative", methods=["POST"])
def add_alt():
    data = request.get_json()
    new_alt = db.Alternatives.create(
        category=data["category"],
        alternatives=data["alternatives"],
        best_alternatives=data["best_alternatives"],
    )
    new_alt.save()
    return jsonify({"message": "success"})


if __name__ == "__main__":
    app.run()

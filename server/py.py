import db
print (db.db)

def add_company(name, s_score, s_desc, e_score, e_desc, categories):
    new_company = db.Company.create(name = name, sustainability_score = s_score, sustainability_description = s_desc, ethics_score = e_score, ethics_description = e_desc, categories = categories, verified = False)
    new_company.save()

def to_string(company):
    return[company.name, company.sustainability_score, company.sustainability_description, company.ethics_score, company.ethics_description, company.categories, company.verified]

def display_db(database):
    db_ls = db.Company.select()
    for company in db_ls:
        print(to_string(company))

add_company("a", 0, "b", 0, "c", "1, 2, 3")
display_db(db.db)
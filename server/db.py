from peewee import *

db = SqliteDatabase("companies.db")


class Company(Model):
    name = TextField()
    sustainability_score = IntegerField()
    sustainability_description = TextField()
    ethics_score = IntegerField()
    ethics_description = TextField()
    categories = TextField()

    class Meta:
        database = db


class Alternatives(Model):
    category = TextField()
    alternatives = TextField()
    best_alternatives = TextField()

    class Meta:
        database = db


class Suggestion(Model):
    name = TextField()
    number = IntegerField()

    class Meta:
        database = db


if __name__ == "__main__":
    db.connect()
    db.create_tables([Company, Alternatives, Suggestion])

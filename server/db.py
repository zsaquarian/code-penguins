from peewee import *

db = SqliteDatabase("companies.db")


class Company(Model):
    name = CharField()
    sustainability_score = IntegerField()
    sustainability_description = TextField()
    ethics_score = IntegerField()
    ethics_description = TextField()
    categories = TextField()

    class Meta:
        database = db


if __name__ == "__main__":
    db.connect()
    db.create_tables([Company])

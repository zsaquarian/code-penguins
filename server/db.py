from peewee import *
db = SqliteDatabase('companies.db')

class Company(Model):
    name = CharField()
    sustainability_score = IntegerField()
    sustainability_description = CharField()
    ethics_score = IntegerField()
    ethics_description = CharField()
    categories = TextField()
    verified = BooleanField()

    class Meta():
        database = db

db.connect()
db.create_tables([Company])
from flask import Flask, request, jsonify
import werkzeug
import db
import main

@main.app.route('/approve_or_reject/id/approve')
def approve(approve, company):
    if approve:
        

@main.app.route('add_company')
def add_company(name, s_score, s_desc, e_score, e_desc, categories, verified):
    new_company = db.Company.create(name = name, sustainability_score = s_score, sustainability_description = s_desc, ethics_score = e_score, ethics_description = e_desc, categories = categories, verified = verified)
    new_company.save()

@main.app.route('/edit_information')
def edit_information(id, field):
    db.Company.get(id)
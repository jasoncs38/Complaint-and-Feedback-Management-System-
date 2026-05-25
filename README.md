# Complaint and Feedback Management System

## Project Overview

The Complaint and Feedback Management System is a modern cross-platform application developed to streamline the process of submitting, managing, and responding to user complaints and feedback efficiently.

The system provides separate interfaces for users and administrators, enabling smooth communication, complaint tracking, status updates, and management operations in a user-friendly environment.

---

## Features

### User Side
 User registration and login
 Submit complaints and feedback
 View complaint status
 Receive notifications and updates
 User profile management

### Admin Side
 Secure admin dashboard
 View all submitted complaints
 Accept or reject complaints
 Manage users and complaint records
 Monitor complaint activities

---

## Technologies Used

### Frontend
 Flutter
 
 Dart

### Backend
 Python
 
 FastAPI

### Tools & Services
 Git & GitHub
 Ngrok
 Chrome Web Support
 Android Emulator / Physical Android Device

---

## Project Structure

Complaint-and-Feedback-Management-System/
│

├── admin/

├── backend/

├── mobile/

│

└── README.md

System Architecture

The project follows a client-server architecture:

Mobile application for end users
Web-based admin panel for administrators
Backend API service for handling requests and communication

Installation & Setup
Clone the Repository:
git clone https://github.com/jasoncs38/Complaint-and-Feedback-Management-System-.git

Backend Setup: 
cd backend 
pip install -r requirements.txt 
uvicorn main:app --reload 

Mobile App Setup: 
cd mobile 
flutter pub get 
flutter run 

Admin Panel Setup: 
cd admin 
flutter pub get 
flutter run -d chrome 

License

This project was developed for educational and academic purposes.

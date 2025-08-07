from flask import Flask, current_app, send_from_directory
from flask_jwt_extended import JWTManager
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
from flask_mail import Mail
import os
from app.config import config

db = SQLAlchemy()
mail = Mail()

def create_app(config_name=None):
    app = Flask(__name__)
    
    # Get configuration
    if config_name is None:
        config_name = os.environ.get('FLASK_ENV', 'development')
    
    app.config.from_object(config[config_name])
    
    mail.init_app(app)
    db.init_app(app)
    JWTManager(app)

    # CORS setup - dynamic based on environment
    CORS(app, resources={r"/api/*": {"origins": app.config['CORS_ORIGINS']}}, supports_credentials=True)

    # Register API routes
    from app.routes import register_routes
    register_routes(app)

    # Serve uploaded files from /uploads
    @app.route('/uploads/<path:filename>')
    def uploaded_file(filename):
        uploads_dir = os.path.abspath(os.path.join(current_app.root_path, '..', 'uploads'))
        return send_from_directory(uploads_dir, filename)

    return app

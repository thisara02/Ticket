import os

class Config:
    SECRET_KEY = os.environ.get('SECRET_KEY') or "59527df04b85a686776c91e7b2561f18d85b3f9d5f649a4468a80a37e3aad259"
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    JWT_TOKEN_LOCATION = ["headers"]
    JWT_HEADER_NAME = "Authorization"
    JWT_HEADER_TYPE = "Bearer"
    
    # Mail configuration
    MAIL_SERVER = 'smtp.gmail.com'
    MAIL_PORT = 587
    MAIL_USE_TLS = True
    MAIL_USE_SSL = False
    MAIL_USERNAME = 'cyberops.lcs@gmail.com'
    MAIL_PASSWORD = 'zieaynrupxmmgvnl'
    MAIL_DEFAULT_SENDER = 'LankaCom Support<cyberops.lcs@gmail.com>'

class DevelopmentConfig(Config):
    DEBUG = True
    SQLALCHEMY_DATABASE_URI = 'mysql+pymysql://root:8645@localhost/ticketing_db'
    CORS_ORIGINS = ["http://localhost:5173", "http://127.0.0.1:5173"]

class ProductionConfig(Config):
    DEBUG = False
    # Update with your production database credentials
    SQLALCHEMY_DATABASE_URI = os.environ.get('DATABASE_URL') or 'mysql+pymysql://root:8645@localhost/ticketing_db'
    # Update with your domain
    CORS_ORIGINS = ["https://yourdomain.com", "http://yourdomain.com"]

config = {
    'development': DevelopmentConfig,
    'production': ProductionConfig,
    'default': DevelopmentConfig
} 
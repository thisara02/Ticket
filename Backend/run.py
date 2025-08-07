from app import create_app
import os

app = create_app()

if __name__ == "__main__":
    # For production, use environment variable to set config
    config_name = os.environ.get('FLASK_ENV', 'development')
    
    if config_name == 'production':
        # Production settings
        app.run(host='0.0.0.0', port=5000, debug=False)
    else:
        # Development settings
        app.run(debug=True)

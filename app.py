import os
import json
import logging
from datetime import datetime

# Setup logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

class AppState:
    def __init__(self):
        self.start_time = datetime.now()
        self.status = "running"

    def get_health(self):
        return {
            "status": self.status,
            "uptime": str(datetime.now() - self.start_time),
            "timestamp": datetime.now().isoformat()
        }

class StaticFileServer:
    def __init__(self, root_path="/workspace"):
        self.root_path = root_path
        self.valid_paths = [
            "/workspace/templates",
            "/workspace/static/css",
            "/workspace/static/js",
            "/workspace/static/images"
        ]

    def validate_structure(self):
        """Ensure all required directories exist"""
        missing = []
        for path in self.valid_paths:
            if not os.path.exists(path):
                missing.append(path)
                logger.warning(f"Missing directory: {path}")
        return missing == 0, missing

def initialize_app():
    """Initialize application with validation"""
    app = AppState()
    server = StaticFileServer()

    # Validate structure
    valid, missing = server.validate_structure()
    if not valid:
        logger.warning(f"Missing directories: {missing}")

    # Generate deployment info
    deploy_info = {
        "frontend": "Static HTML + CSS",
        "runtime": "static",
        "backend": None,
        "validation": {
            "structure_valid": valid,
            "missing_directories": missing
        }
    }

    # Write deployment info
    with open('/workspace/orchestrator/deployment_info.json', 'w') as f:
        json.dump(deploy_info, f, indent=2)

    logger.info("Application initialized successfully")
    return app, server, deploy_info

if __name__ == "__main__":
    app, server, deploy_info = initialize_app()
    logger.info(f"Deploy info: {json.dumps(deploy_info, indent=2)}")
    logger.info("Static file server ready")

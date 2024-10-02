"""Safe! development configuration."""
import pathlib

# Root of this application, useful if it doesn't occupy an entire domain
APPLICATION_ROOT = '/'

# Secret key for encrypting cookies
SECRET_KEY = b'u\xc2\xcd\xacu\xd8\xc9\xca\xec<C'\
    b'\xd7\xf2i`\xcb}\xcd\xb7\xd5\xb0\r\x9d\xa8'
SESSION_COOKIE_NAME = 'login'

# File Upload to var/uploads/
SAFE_BACKEND_ROOT = pathlib.Path(__file__).resolve().parent.parent
UPLOAD_FOLDER = SAFE_BACKEND_ROOT/'var'/'uploads'
ALLOWED_EXTENSIONS = set(['png', 'jpg', 'jpeg', 'gif'])
MAX_CONTENT_LENGTH = 16 * 1024 * 1024

# Database file is var/insta485.sqlite3
DATABASE_FILENAME = SAFE_BACKEND_ROOT/'var'/'Safe_backend.sqlite3'
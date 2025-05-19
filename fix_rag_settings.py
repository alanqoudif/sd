#!/usr/bin/env python3
import os
import sys
import json
import sqlite3
from pathlib import Path

# Find database path
backend_dir = Path('./backend')
data_dir = backend_dir / 'data'
db_path = data_dir / 'webui.db'

if not db_path.exists():
    print(f"Database not found at {db_path}")
    sys.exit(1)

print(f"Using database at {db_path}")

# Connect to the database
conn = sqlite3.connect(str(db_path))
cursor = conn.cursor()

# Check if config table exists
cursor.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='config'")
if not cursor.fetchone():
    print("Config table not found in database")
    sys.exit(1)

# Get current config
cursor.execute("SELECT id, data FROM config ORDER BY id DESC LIMIT 1")
result = cursor.fetchone()

if not result:
    print("No config found in database")
    sys.exit(1)

config_id, config_data = result
config = json.loads(config_data)

# Update RAG settings
if 'rag' not in config:
    config['rag'] = {}

config['rag']['RAG_EMBEDDING_ENGINE'] = "ollama"
config['rag']['RAG_EMBEDDING_MODEL'] = "nomic-embed-text"
config['rag']['RAG_OLLAMA_BASE_URL'] = "http://localhost:11434"

# Save updated config
cursor.execute("UPDATE config SET data = ? WHERE id = ?", (json.dumps(config), config_id))
conn.commit()

print("Successfully updated RAG settings in database:")
print(f"  RAG_EMBEDDING_ENGINE = {config['rag']['RAG_EMBEDDING_ENGINE']}")
print(f"  RAG_EMBEDDING_MODEL = {config['rag']['RAG_EMBEDDING_MODEL']}")
print(f"  RAG_OLLAMA_BASE_URL = {config['rag']['RAG_OLLAMA_BASE_URL']}")
conn.close()

print("\nNow please restart your Caa AI server for changes to take effect.") 
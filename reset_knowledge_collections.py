#!/usr/bin/env python3
import os
import sys
import json
import shutil
import sqlite3
from pathlib import Path

print("Knowledge Collection Reset Tool")
print("==============================")
print("This script will reset your knowledge collections to fix dimension mismatches.")
print("WARNING: This will DELETE all your existing knowledge collections!")
print()

confirmation = input("Type 'DELETE' to confirm deletion of all knowledge collections: ")
if confirmation != "DELETE":
    print("Operation cancelled.")
    sys.exit(0)

# Find paths
backend_dir = Path('./backend')
data_dir = backend_dir / 'data'
vector_db_dir = data_dir / 'vector_db'
db_path = data_dir / 'webui.db'

if not db_path.exists():
    print(f"Database not found at {db_path}")
    sys.exit(1)

print(f"Using database at {db_path}")

# Connect to the database
conn = sqlite3.connect(str(db_path))
cursor = conn.cursor()

# Check if collections table exists
cursor.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='collections'")
table_exists = cursor.fetchone() is not None

if table_exists:
    # Delete all knowledge collections from the database
    print("Deleting knowledge collections from database...")
    cursor.execute("DELETE FROM collections")
    conn.commit()
    print("Successfully deleted all knowledge collections from the database.")

# Delete the ChromaDB files
if vector_db_dir.exists():
    print(f"Deleting vector database directory at {vector_db_dir}...")
    
    # First try to remove individual collection folders
    try:
        for item in vector_db_dir.iterdir():
            if item.is_dir():
                shutil.rmtree(item)
                print(f"Deleted collection directory: {item.name}")
            elif item.name == "chroma.sqlite3":
                os.remove(item)
                print("Deleted chroma.sqlite3 database file")
    except Exception as e:
        print(f"Error while deleting vector database contents: {e}")
    
    # Recreate the directory structure
    os.makedirs(vector_db_dir, exist_ok=True)

print("\nKnowledge collections have been reset.")
print("\nNow you need to restart your CAA Chat server with the following environment variables:")
print("RAG_EMBEDDING_ENGINE=ollama")
print("RAG_EMBEDDING_MODEL=nomic-embed-text")
print("RAG_OLLAMA_BASE_URL=http://localhost:11434")
print("\nExample command:")
print("cd backend && RAG_EMBEDDING_ENGINE=ollama RAG_EMBEDDING_MODEL=nomic-embed-text RAG_OLLAMA_BASE_URL=http://localhost:11434 python -m uvicorn open_webui.main:app --host 0.0.0.0 --port 8080") 
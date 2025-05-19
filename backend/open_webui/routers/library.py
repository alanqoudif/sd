import os
import time
import math
from typing import List, Dict, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, Response
from open_webui.models.users import UserModel
from open_webui.utils.auth import get_current_user

router = APIRouter(
    prefix="/api/v1/library",
    tags=["library"],
    responses={404: {"description": "Not found"}},
)

# Use relative path instead of hardcoded absolute path
DATA_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))), "data")

def format_file_size(size_bytes):
    """
    Format the file size in a human-readable format
    
    Args:
        size_bytes: File size in bytes
        
    Returns:
        str: Human-readable file size
    """
    if size_bytes == 0:
        return "0B"
    
    size_name = ("B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB")
    i = int(math.floor(math.log(size_bytes, 1024)))
    p = math.pow(1024, i)
    s = round(size_bytes / p, 2)
    
    return f"{s} {size_name[i]}"

@router.get("")
async def list_files(
    path: str = Query("/", description="Path to list files from"), 
    current_user: UserModel = Depends(get_current_user)
):
    """List files in a directory"""
    # Validate user has access (only admin users can access this endpoint for security reasons)
    if current_user.role != "admin":
        raise HTTPException(status_code=403, detail="Only administrators can access the library")
    
    # Normalize and validate path to prevent path traversal attacks
    target_path = os.path.normpath(os.path.join(DATA_DIR, path.lstrip("/")))
    
    # Ensure the path is within the data directory
    if not target_path.startswith(DATA_DIR):
        raise HTTPException(status_code=403, detail="Access to this directory is forbidden")
    
    try:
        # Print paths for debugging
        print(f"DATA_DIR: {DATA_DIR}")
        print(f"target_path: {target_path}")
        
        # Check if directory exists
        if not os.path.exists(target_path):
            print(f"Path does not exist: {target_path}")
            return {"files": []}
        
        # List all files and directories
        files_data = []
        for item in os.listdir(target_path):
            item_path = os.path.join(target_path, item)
            
            # Skip hidden files
            if item.startswith('.'):
                continue
                
            # Get file stats
            stats = os.stat(item_path)
            
            # Determine if it's a directory or file
            is_dir = os.path.isdir(item_path)
            
            files_data.append({
                "name": item,
                "type": "directory" if is_dir else "file",
                "size": "" if is_dir else format_file_size(stats.st_size),
                "modified": time.ctime(stats.st_mtime)
            })
        
        return {"files": files_data}
    
    except Exception as e:
        print(f"Error listing files: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Error listing files: {str(e)}")

@router.get("/download")
async def download_file(
    path: str = Query("/", description="Directory path"),
    filename: str = Query(..., description="File to download"),
    current_user: UserModel = Depends(get_current_user)
):
    """Download a file"""
    # Validate user has access (only admin users can access this endpoint for security reasons)
    if current_user.role != "admin":
        raise HTTPException(status_code=403, detail="Only administrators can access the library")
    
    # Normalize and validate path to prevent path traversal attacks
    target_dir = os.path.normpath(os.path.join(DATA_DIR, path.lstrip("/")))
    target_file = os.path.join(target_dir, filename)
    
    # Ensure the path is within the data directory
    if not target_file.startswith(DATA_DIR):
        raise HTTPException(status_code=403, detail="Access to this file is forbidden")
    
    try:
        # Check if file exists
        if not os.path.exists(target_file) or os.path.isdir(target_file):
            raise HTTPException(status_code=404, detail="File not found")
        
        # Read file content
        with open(target_file, "rb") as f:
            file_content = f.read()
        
        # Determine content type based on file extension
        content_type = "application/octet-stream"  # Default content type
        if filename.endswith(".pdf"):
            content_type = "application/pdf"
        elif filename.endswith((".jpg", ".jpeg")):
            content_type = "image/jpeg"
        elif filename.endswith(".png"):
            content_type = "image/png"
        elif filename.endswith(".txt"):
            content_type = "text/plain"
        elif filename.endswith(".md"):
            content_type = "text/markdown"
        
        response = Response(content=file_content, media_type=content_type)
        response.headers["Content-Disposition"] = f"attachment; filename={filename}"
        
        return response
    
    except Exception as e:
        if isinstance(e, HTTPException):
            raise e
        raise HTTPException(status_code=500, detail=f"Error downloading file: {str(e)}") 
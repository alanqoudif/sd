import os
import json
import secrets
import string
import socket
import requests
import re
import math

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
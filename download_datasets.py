import os
import urllib.request
import tarfile
import shutil

def download_canterbury_corpus():
    """
    Downloads and extracts the Canterbury Corpus.
    """
    data_dir = "data"
    target_dir = os.path.join(data_dir, "canterbury")
    url = "http://corpus.canterbury.ac.nz/resources/cantrbry.tar.gz"
    tar_path = os.path.join(data_dir, "cantrbry.tar.gz")

    # Create directories
    if not os.path.exists(target_dir):
        os.makedirs(target_dir)
        print(f"Created directory: {target_dir}")

    # Download
    if not os.path.exists(tar_path):
        print(f"Downloading Canterbury Corpus from {url}...")
        try:
            # Add user agent to avoid 403 forbidden on some servers
            req = urllib.request.Request(
                url, 
                data=None, 
                headers={
                    'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/35.0.1916.47 Safari/537.36'
                }
            )
            with urllib.request.urlopen(req) as response, open(tar_path, 'wb') as out_file:
                shutil.copyfileobj(response, out_file)
            print("Download complete.")
        except Exception as e:
            print(f"Error downloading file: {e}")
            return

    # Extract
    print("Extracting files...")
    try:
        with tarfile.open(tar_path, "r:gz") as tar:
            tar.extractall(path=target_dir)
        print(f"Extracted to {target_dir}")
    except Exception as e:
        print(f"Error extracting file: {e}")
        return

    # Cleanup tar file
    if os.path.exists(tar_path):
        os.remove(tar_path)
        print("Cleaned up temporary archive.")

    print("Canterbury Corpus ready.")

import random

def create_binary_test_file():
    """
    Creates a binary test file.
    Tries to copy /bin/ls (standard on macOS/Linux) for realistic executable structure.
    Falls back to random data if /bin/ls is not found.
    """
    data_dir = "data"
    file_bin = os.path.join(data_dir, "binary_test.bin")
    source_bin = "/bin/ls"

    if not os.path.exists(data_dir):
        os.makedirs(data_dir)

    if os.path.exists(file_bin):
        print("Binary test file already exists.")
        return

    print("Preparing Binary Data...")
    if os.path.exists(source_bin):
        try:
            shutil.copy(source_bin, file_bin)
            print(f"  [OK] Copied {source_bin} to {file_bin}")
        except Exception as e:
            print(f"  [WARN] Could not copy {source_bin}: {e}")
            _generate_random_binary(file_bin)
    else:
        print(f"  [WARN] {source_bin} not found.")
        _generate_random_binary(file_bin)

def _generate_random_binary(filepath):
    """Helper to generate random binary data."""
    print("  Generating random binary data...")
    try:
        size = 50000 # 50KB
        with open(filepath, "wb") as f:
            f.write(os.urandom(size))
        print("  [OK] Generated random binary file.")
    except Exception as e:
        print(f"  [FAIL] Could not generate random binary file: {e}")

if __name__ == "__main__":
    download_canterbury_corpus()
    create_binary_test_file()

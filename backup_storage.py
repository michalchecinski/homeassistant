from azure.storage.blob import BlobServiceClient, BlobClient, ContainerClient
from datetime import date
import os
import sys

def getListOfFiles(dirName):
    # create a list of file and sub directories 
    # names in the given directory 
    listOfFile = os.listdir(dirName)
    allFiles = list()
    # Iterate over all the entries
    for entry in listOfFile:
        # Create full path
        fullPath = os.path.join(dirName, entry)
        # If entry is a directory then get the list of files in this directory 
        if os.path.isdir(fullPath):
            allFiles = allFiles + getListOfFiles(fullPath)
        else:
            allFiles.append(fullPath)                
    return allFiles

if __name__ == '__main__':
    if len(sys.argv) < 2:
            print()
            print('Proper usage:')
            print('python backup_storage.py <account_details_file.txt> <folder_path>')
            sys.exit(0)
    
    dirName = sys.argv[2]
    if not dirName.endswith("\\") or not dirName.endswith("/"):
        if "\\" in dirName:
            dirName = dirName + "\\"
        if "/" in dirName:
            dirName = dirName + "/"

    listOfFiles = getListOfFiles(dirName)
    listOfFiles = [x for x in listOfFiles if ".git" not in x]

    account_details = open(sys.argv[1], 'r')
    connect_str    = account_details.readline()
    connect_str    = connect_str.strip()

    # Create the BlobServiceClient object which will be used to create a container client
    blob_service_client = BlobServiceClient.from_connection_string(connect_str)
    # Create a unique name for the container
    container_name = "backup-" + date.today().strftime("%Y-%m-%d")
    # Create the container
    try:
        container_client = blob_service_client.create_container(container_name)
    except Exception as ex:
        pass
    

    for file_path in listOfFiles:
        blob_client = blob_service_client.get_blob_client(container=container_name, blob=file_path.replace(dirName, ""))
        # Upload the created file
        with open(file_path, "rb") as data:
            blob_client.upload_blob(data)
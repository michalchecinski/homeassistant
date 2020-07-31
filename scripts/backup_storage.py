from azure.storage.blob import BlobServiceClient
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
            if "unifi" not in fullPath:
                allFiles = allFiles + getListOfFiles(fullPath)
        else:
            allFiles.append(fullPath)
    return allFiles


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print()
        print('Proper usage:')
        print('python backup_storage.py'
              '<connection_string_file.txt> <folder_path>')
        sys.exit(0)

    dirName = sys.argv[2]
    if not dirName.endswith("\\") or not dirName.endswith("/"):
        if "\\" in dirName:
            dirName = dirName + "\\"
        if "/" in dirName:
            dirName = dirName + "/"

    listOfFiles = getListOfFiles(dirName)
    listOfFiles = [x for x in listOfFiles if ".git" not in x]
    listOfFiles = [x for x in listOfFiles if ".sock" not in x]

    account_details = open(sys.argv[1], 'r')
    connect_str = account_details.readline()
    connect_str = connect_str.strip()

    blob_service_client = BlobServiceClient.from_connection_string(connect_str)

    container_name = "backup-" + date.today().strftime("%Y-%m-%d")

    try:
        container_client = blob_service_client.create_container(container_name)
    except Exception as e:
        print(e)

    file_number = len(listOfFiles)

    for index, file_path in enumerate(listOfFiles):
        print(str(index) + "/" + str(file_number))

        blob_client = blob_service_client.get_blob_client(
                    container=container_name,
                    blob=file_path.replace(dirName, ""))
        # Upload the created file
        try:
            with open(file_path, "rb") as data:
                blob_client.upload_blob(data)
        except Exception as ex:
            print(ex)

    print("Backup complete")

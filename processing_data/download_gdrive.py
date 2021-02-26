#!/Users/Heyseb1/anaconda3/bin/python

from pydrive.auth import GoogleAuth
from pydrive.drive import GoogleDrive
import os
import re
import pandas as pd

gauth = GoogleAuth()
gauth.LocalWebserverAuth() # Creates local webserver and auto handles authentication.
drive = GoogleDrive(gauth)

def ListFolder(parent):
  filelist=[]
  file_list = drive.ListFile({'q': "'%s' in parents and trashed=false" % parent}).GetList()
  for f in file_list:
    print(f['mimeType'])
    if f['mimeType']=='application/vnd.google-apps.folder': # if folder
        filelist.append({"id":f['id'],"title":f['title'],"list":ListFolder(f['id'])})
    else:
        filelist.append({"id":f['id'], "title":f['title']})
  return filelist

#method that opens the text file with all the scenarios we've already downloaded
#and checks if the current scenario is on there, if it is, we don't download that file
def check(scenario_name):
    with open('data_written.txt') as f:
        if scenario_name in f.read():
            print("Folder already exists")
            f.close()
            return True
        else:
            f.close()
            return False

#This method formats the data uploaded from Google Drive into a csv file that is required
#For running the matlab simulation from mahony
def txt2csv(filepath_txt, filepath_folder, name):
    data = pd.read_csv(filepath_txt, sep=",", header=None)
    start_column = 1
    for i in range(start_column, 4):
        for j in range(0, len(data.index)):
            x = str(data[i][j])
            if len(x) == 1:
                x = x + ".0"
            elif len(x) == 2:
                x = x[:-1] + "." + x[-1:]
            else:
                x = x[:-1] + "." + x[len(x)-1:]
            data[i][j] = x
            print(data[i][j])
    data.columns = ['Timestamp','Yaw', 'Pitch', 'Roll']
    data.to_csv(filepath_folder + '/' + name + '.csv', index=False)


#This method formats the data uploaded from Google Drive into a csv file that is required
#For running the matlab simulation from mahony
# def txt2csv(filepath_txt, filepath_folder, name):
#     data = pd.read_csv("/Users/Heyseb1/Desktop/3.TXT", sep=",", header=None)
#     data.columns = ['Timestamp', 'Gyroscope X (deg/s)', 'Gyroscope Y (deg/s)', 'Gyroscope Z (deg/s)',
#                              'Accelerometer X (g)', 'Accelerometer Y (g)', 'Accelerometer Z (g)',
#                              'Magnetometer X (G)', 'Magnetometer Y (G)', 'Magnetometer Z (G)']
#     data.to_csv("/Users/Heyseb1/Desktop" + '/' + name + '.csv', index=False)



#This method is used to look at all the folders in google drive, go through each one,
#And download the contents of the file to a local folder before processing occurs
def downloadFiles():
    file_list = drive.ListFile({'q': "'root' in parents and trashed=false"}).GetList()
    for file1 in file_list:
        if check(file1['title']): #Checks to see if the file has already been downloaded
            continue
        else:
            os.mkdir(file1['title'])
            print('title: %s, id: %s' % (file1['title'], file1['id']))
            scenario_name = file1['id']
            body_part_list = ListFolder(scenario_name)
            for bp in body_part_list:
                body_part = drive.CreateFile({'id': bp['id']})
                content = body_part.GetContentString(mimetype='file/txt')
                non_decimal = re.compile(r'[^\d,.\n-]+')
                content = non_decimal.sub('', content)
                file2write=open(file1['title'] + '/' + bp['title'],'w')
                file2write.write(content)
                file2write.close()
                txt2csv(file1['title'] + '/' + bp['title'],file1['title'], bp['title'][:-4])
            with open('data_written.txt', 'a') as f:
                f.write(file1['title'] + '\n')



downloadFiles()

# # file2 = drive.CreateFile({'id': file_list[0]['id']})
# print(file_list[0])
#
# file1 = drive.CreateFile({'id': file_list[0]['id']})
#
# content_with_bom = file1.GetContentString(mimetype='file/txt')
# print('Content with BOM:')
# print(bytes(content_with_bom.encode('unicode-escape')))
# print('Number of chars: %d' % len(content_with_bom))
# print('')
# #     Content with BOM:
# #     \ufeffGeneric, non-exhaustive\r\n ASCII test string.
# #     Number of chars: 45
#
#
# file2write=open('Scenario2/' + file_list[0]['title'],'w')
# file2write.write(content_with_bom)
# file2write.close()

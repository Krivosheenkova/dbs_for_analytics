import os
import re
import csv
import mariadb
from datetime import datetime
from dotenv import load_dotenv
import unicodedata

load_dotenv()

passwd = os.getenv('PASSWD')
mydb = mariadb.connect(
    user="root",
    password=passwd,
    host="localhost",
    database='orders')
cursor = mydb.cursor()

csv_data = 'Analytics_20200101_20201231.csv'
i = 0
with open(csv_data, newline='') as csvfile:
    columns = csvfile.readline()
    reader = csv.reader(csvfile, delimiter=',')
    table_name = csv_data[:csv_data.index('.')]
    cursor.execute(f'DROP TABLE IF EXISTS {table_name};')
    cursor.execute(f'''CREATE TABLE `{table_name}` (`day` DATE, `users` INT);''')
    for row in reader:
        try:
            print(columns)
            d = row[0]
            if not d:
                continue
            else:
                d = datetime.strptime(d.replace('.', '-'), '%d-%m-%Y').date()

            u = row[1]
            if not u:
                u = '0'
            else:
                u = unicodedata.normalize("NFKD", u).replace(" ", "")
            print(d, u)
            cursor.execute(f'''INSERT INTO {table_name} ({columns}) 
                               VALUES("{d}", "{u}");''')

            if not i % 1e5:
                print(f'{i} records - done')
            i += 1
        except Exception as e:
            print(columns, table_name)
            print(e)
            break
mydb.commit()
cursor.close()
print("Done")

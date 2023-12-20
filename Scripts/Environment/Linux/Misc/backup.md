#### backup mysql
```bash
mysqldump -u [username] –p[password] [database_name] > [dump_file.sql]
```
#### restore mysql local
```bash
mysql -u [username] –p[password] [database_name] < [dump_file.sql]
```
#### restore mysql remote
```bash
mysql –h [hostname] –u [username] –p[password] [database_name] < [dump_file.sql]
```

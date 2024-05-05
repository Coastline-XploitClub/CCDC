## Log2timeline.py
```bash
# list all available parsers
log2timeline.py --parsers list
```
```bash
# run parsers select UTC
log2timeline.py -z --parsers "<parsers comma delimited>" --storage <file location> <source>
```
```bash
#select a partition or volume
log2timeline.py -z UTC --partitions  <partition number> --volumes all --parsers "<parsers comma delinited>" --storage <file location> <source>
```
```bash
# automatic selection of parsers...supertimeline
log2timeline.py -z UTC --storage <file location> <source>


```

python listservers.py | grep `python getnetwork.py` | grep $1 | awk -F ':' '{ print $1 }'

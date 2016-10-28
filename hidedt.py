import subprocess
import time

found = set()

while True:
    handles = subprocess.check_output('wmctrl -l | grep -P "(Developer Tools -)|(chrome-devtools://)" | cut -f 1 -d " "', shell=True).rstrip().split('\n')
    for id_ in handles:
        if id_ in found:
            continue

        subprocess.check_output('wmctrl -i -r {0} -b add,below'.format(id_), shell=True)
        found.add(id_)
        print('Sending To Bg ' + id_)

    time.sleep(0.5)

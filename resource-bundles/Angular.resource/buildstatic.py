#!/usr/bin/env python
import os
from os.path import join
import zipfile

def zipdir(path, ziph):
    # ziph is zipfile handle
    for root, dirs, files in os.walk(path):
        if "DoNotInclude" not in root:
            for file in files:
                    ziph.write(os.path.join(root, file))

if __name__ == '__main__':

    # Create Compress Static Resource
    os.chdir('resource-bundles\\Angular.resource')
    zipFilename = 'Angular.resource'
    zipf = zipfile.ZipFile(join("..\\..\\src\\staticresources\\", zipFilename), 'w', zipfile.ZIP_DEFLATED)
    zipdir('.\\', zipf)
    zipf.close()
    os.chdir('..\\..\\')
#!/bin/sh

set -x

find /opt -name \*.deb | xargs rm -f
find /opt/MoxieLogic -type f
cd /opt/MoxieLogic/x86_64 

alien -g -k -d moxielogic-moxie-elf-gcc-fsf-man-pages*rpm
perl -p -i -e 's/^Depends.*/Depends:/' moxielogic-moxie-elf-gcc*/debian/control
perl -p -i -e 's/Maintainer.*/Maintainer: green@moxielogic.com/' moxielogic-moxie-elf-gcc*/debian/control
(cd moxielogic-moxie-elf-gcc*/debian/..;
 ./debian/rules binary)
rm -rf `find . -type d -name moxielogic-moxie-elf-gcc\*`

for target in moxie-elf moxiebox moxie-rtems; do

  alien -g -k -d moxielogic-${target}-gcc-[0-9]*rpm
  perl -p -i -e 's/^Depends.*/Depends: moxielogic-'${target}'-binutils , moxielogic-'${target}'-gcc-fsf-man-pages/' moxielogic-${target}-gcc*/debian/control
  perl -p -i -e 's/Maintainer.*/Maintainer: green@moxielogic.com/' moxielogic-${target}-gcc*/debian/control
  (cd moxielogic-${target}-gcc*/debian/..;
   ./debian/rules binary)
  rm -rf `find . -type d -name moxielogic-${target}-gcc\*`

  alien -g -k -d moxielogic-${target}-gcc-[c]*rpm
  perl -p -i -e 's/^Depends.*/Depends: moxielogic-'${target}'-gcc , moxielogic-'${target}'-gcc-libstdc++' moxielogic-${target}-gcc*/debian/control
  perl -p -i -e 's/Maintainer.*/Maintainer: green@moxielogic.com/' moxielogic-${target}-gcc*/debian/control
  (cd moxielogic-${target}-gcc*/debian/..;
   ./debian/rules binary)
  rm -rf `find . -type d -name moxielogic-${target}-gcc\*`
  
  alien -g -k -d moxielogic-${target}-gcc-[l]*rpm
  perl -p -i -e 's/^Depends.*/Depends: moxielogic-'${target}'-gcc-c++/' moxielogic-'${target}'-gcc*/debian/control
  perl -p -i -e 's/Maintainer.*/Maintainer: green@moxielogic.com/' moxielogic-${target}-gcc*/debian/control
  (cd moxielogic-${target}-gcc*/debian/..;
   ./debian/rules binary)
  rm -rf `find . -type d -name moxielogic-${target}-gcc\*`

  for tool in binutils gdb; do
    alien -g -k -d moxielogic-${target}-${tool}-[0-9]*rpm
    perl -p -i -e 's/^Depends.*/Depends:/' moxielogic-${target}-${tool}*/debian/control
    perl -p -i -e 's/Maintainer.*/Maintainer: green@moxielogic.com/' moxielogic-${target}-${tool}*/debian/control
    (cd moxielogic-${target}-${tool}*/debian/..;
     ./debian/rules binary)
    rm -rf `find . -type d -name moxielogic-${target}-${tool}\*`;
  done
  
done

cd /opt/MoxieLogic/noarch

for target in moxie-elf moxiebox moxie-rtems; do

  alien -g -k -d moxielogic-${target}-newlib*rpm
  perl -p -i -e 's/^Depends.*/Depends:/' moxielogic-${target}-newlib*/debian/control
  perl -p -i -e 's/Maintainer.*/Maintainer: green@moxielogic.com/' moxielogic-${target}-newlib*/debian/control
  (cd moxielogic-${target}-newlib*/debian/..;
   ./debian/rules binary)
  rm -rf `find . -type d -name moxielogic-${target}-newlib\*`

done

echo **************************************************************************
echo **** FINISHED CONVERSION *************************************************
echo **************************************************************************

mv `find /opt -name \*.deb` /opt/MoxieLogic-deb

mkdir /opt/MoxieLogic-deb/conf
cp /root/distributions /opt/MoxieLogic-deb/conf
reprepro -b /opt/MoxieLogic-deb createsymlinks
for PACKAGE in `find /opt/MoxieLogic-deb -name \*.deb`; do
    reprepro -b /opt/MoxieLogic-deb includedeb moxiedev $PACKAGE
done


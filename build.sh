#!/bin/sh

set -x

cat /root/build.sh

SRPMDIR=/var/www/html
REPODIR=/usr/local/MoxieLogic

# Send the build number out of the container.  We'll use this to tag
# the resulting repo container.
cp $SRPMDIR/BUILDNUM /usr/local

if ! test -f $REPODIR/x86_64; then mkdir -p $REPODIR/x86_64; fi
if ! test -f $REPODIR/noarch; then mkdir -p $REPODIR/noarch; fi

for TARGET in moxie-elf moxiebox moxie-rtems; do

  RPMCHECK=`find $REPODIR/x86_64 -name moxielogic-$TARGET-binutils*`
  if test -z "$RPMCHECK"; then
  
    rpmbuild --rebuild $SRPMDIR/moxielogic-$TARGET-binutils*src.rpm;
    rpmbuild --rebuild $SRPMDIR/moxielogic-$TARGET-gdb*src.rpm;
    mv /root/rpmbuild/RPMS/x86_64/* $REPODIR/x86_64
    createrepo $REPODIR ; exit;
    
  else
  
    RPMCHECK=`find $REPODIR/noarch -name moxielogic-$TARGET-newlib*`
    if test -z "$RPMCHECK"; then

      yum clean all;
      yum install -y moxielogic-$TARGET-binutils;

      if test "$TARGET" == "moxie-elf"; then
        rpmbuild --rebuild $SRPMDIR/bootstrap-moxie-elf-gcc*src.rpm;
        mv /root/rpmbuild/RPMS/x86_64/* $REPODIR/x86_64;
        createrepo $REPODIR;
        yum clean all;
      fi

      yum install -y bootstrap-moxie-elf-gcc
      rpmbuild --rebuild $SRPMDIR/moxielogic-$TARGET-newlib*src.rpm;
      mv /root/rpmbuild/RPMS/noarch/* $REPODIR/noarch
      createrepo $REPODIR ;
      cd $REPODIR/noarch ;
      ln -s moxielogic-repo* moxielogic-repo-latest.noarch.rpm;
      exit;
  
    else
  
      RPMCHECK=`find $REPODIR/x86_64 -name moxielogic-$TARGET-gcc-*`
      if test -z "$RPMCHECK"; then

        yum clean all;
        yum install -y moxielogic-$TARGET-newlib moxielogic-$TARGET-binutils;
        rpmbuild --rebuild $SRPMDIR/moxielogic-$TARGET-gcc*src.rpm;
	mv /root/rpmbuild/RPMS/x86_64/* $REPODIR/x86_64;

	echo ****************************************************************
	echo ****************************************************************
	echo ****************************************************************
	echo
	echo      ABOUT TO BUILD REPO
	echo
	echo ****************************************************************
	echo ****************************************************************
	echo ****************************************************************

	rpmbuild --define "_sourcedir /root" --define "_srcrpmdir /root" -ba /root/moxielogic-repo.spec
	mv /root/rpmbuild/RPMS/noarch/* $REPODIR/noarch;

	createrepo $REPODIR ;

	exit;

      fi

    fi
  fi
done
  
# Indicate that we are all done.
touch $REPODIR/.done

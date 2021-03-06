#
# CDDL HEADER START
#
# The contents of this file are subject to the terms of the
# Common Development and Distribution License (the "License").
# You may not use this file except in compliance with the License.
#
# You can obtain a copy of the license at usr/src/OPENSOLARIS.LICENSE
# or http://www.opensolaris.org/os/licensing.
# See the License for the specific language governing permissions
# and limitations under the License.
#
# When distributing Covered Code, include this CDDL HEADER in each
# file and include the License file at usr/src/OPENSOLARIS.LICENSE.
# If applicable, add the following below this CDDL HEADER, with the
# fields enclosed by brackets "[]" replaced with your own identifying
# information: Portions Copyright [yyyy] [name of copyright owner]
#
# CDDL HEADER END
#

#
# Copyright 2010 Sun Microsystems, Inc.  All rights reserved.
#

#
# ID: mvtest_006
#
# DESCRIPTION:
#        Verify can mv muti dir/files between server and local
#
# STRATEGY:
#       1. run "mount -F smbfs //server/public /export/mnt"
#       2. mv and diff can get the right message
#

mvtest006() {
tet_result PASS

tc_id="mvtest006"
tc_desc=" Verify can mv muti dir/files between server and local"
print_test_case $tc_id - $tc_desc

if [[ $STC_CIFS_CLIENT_DEBUG == 1 ]] || \
	[[ *:${STC_CIFS_CLIENT_DEBUG}:* == *:$tc_id:* ]]; then
    set -x
fi

tdir=/kernel/misc
server=$(server_name)|| return

if [[ $? != 0 ]]; then
      tet_result UNRESOLVED
      return
fi

testdir_init $TDIR
smbmount_clean $TMNT
smbmount_init $TMNT

cmd="mount -F smbfs //$TUSER:$TPASS@$server/public $TMNT"
cti_execute -i '' FAIL $cmd
if [[ $? != 0 ]]; then
	cti_fail "FAIL: smbmount can't mount the public share"
	return
else
	cti_report "PASS: smbmount can mount the public share"
fi

cti_execute_cmd "rm -rf $TMNT/*"
cti_execute_cmd "rm -rf $TDIR/*"
cti_execute_cmd "cd $TMNT"

# create mutil file/dirs on the local
cti_execute_cmd "cp -rf $tdir $TDIR/test_dir"
cti_execute_cmd "cp -rf $tdir $TDIR/test_dir_org"

# mv to server
cti_execute_cmd "mv $TDIR/test_dir test_dir"
if [[ $? != 0 ]]; then
	cti_fail "FAIL: mv $TDIR/test_dir to server failed"
	return
else
	cti_report "PASS: mv $TDIR/test_dir to server succeeded"
fi

# diff the local and server
cti_execute_cmd "diff -r $TDIR/test_dir_org test_dir"
if [[ $? != 0 ]]; then
	cti_fail "FAIL: diff -r $TDIR/test_dir_org test_dir failed"
	return
else
	cti_report "PASS: diff -r $TDIR/test_dir_org test_dir succeeded"
fi

# mv mutil dirs from the server to local
cti_execute_cmd "mv test_dir $TDIR/test_dir_mv"
if [[ $? != 0 ]]; then
	cti_fail "FAIL: mv test_dir to $TDIR/test_dir_mv failed"
	return
else
	cti_report "PASS: mv test_dir to $TDIR/test_dir_mv succeeded"
fi

# diff the server to local
cti_execute_cmd "diff -r $TDIR/test_dir_org $TDIR/test_dir_mv"
if [[ $? != 0 ]]; then
	cti_fail "FAIL: diff -r $TDIR/test_dir_org" \
	    " $TDIR/test_dir_mv failed"
	return
else
	cti_report "PASS: diff -r $TDIR/test_dir_org" \
	    " $TDIR/test_dir_mv succeeded"
fi

cti_execute_cmd "cd -"
cti_execute_cmd "rm -rf $TDIR/*"
cti_execute_cmd "rm -rf $TMNT/*"

smbmount_clean $TMNT
cti_pass "${tc_id}: PASS"
}

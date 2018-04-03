# ===========================================================================
#       https://www.gnu.org/software/autoconf-archive/ax_lib_mysql.html
# ===========================================================================
#
# SYNOPSIS
#
#   AX_LIB_MYSQL([MINIMUM-VERSION])
#
# DESCRIPTION
#
#   This macro provides tests of availability of MySQL client library of
#   particular version or newer.
#
#   AX_LIB_MYSQL macro takes only one argument which is optional. If there
#   is no required version passed, then macro does not run version test.
#
#   The --with-mysql option takes one of three possible values:
#
#   no - do not check for MySQL client library
#
#   yes - do check for MySQL library in standard locations (mysql_config
#   should be in the PATH)
#
#   path - complete path to mysql_config utility, use this option if
#   mysql_config can't be found in the PATH
#
#   This macro calls:
#
#     AC_SUBST(MYSQL_CFLAGS)
#     AC_SUBST(MYSQL_LDFLAGS)
#     AC_SUBST(MYSQL_VERSION)
#
#   And sets:
#
#     HAVE_MYSQL
#
# LICENSE
#
#   Copyright (c) 2008 Mateusz Loskot <mateusz@loskot.net>
#
#   Copying and distribution of this file, with or without modification, are
#   permitted in any medium without royalty provided the copyright notice
#   and this notice are preserved. This file is offered as-is, without any
#   warranty.

#serial 13

AC_DEFUN([AX_LIB_MYSQL],
[
    AC_ARG_WITH([mysql],
        AS_HELP_STRING([--with-mysql=@<:@ARG@:>@],
            [use MySQL client library @<:@default=yes@:>@, optionally specify path to mysql_config]
        ),
        [
        if test "$withval" = "no"; then
            want_mysql="no"
        elif test "$withval" = "yes"; then
            want_mysql="yes"
        else
            want_mysql="yes"
            MYSQL_CONFIG="$withval"
        fi
        ],
        [want_mysql="yes"]
    )
    AC_ARG_VAR([MYSQL_CONFIG], [Full path to mysql_config program])

    MYSQL_CFLAGS=""
    MYSQL_LDFLAGS=""
    MYSQL_VERSION=""

    dnl
    dnl Check MySQL libraries
    dnl

    if test "$want_mysql" = "yes"; then

        if test -z "$MYSQL_CONFIG" ; then
            AC_PATH_PROGS([MYSQL_CONFIG], [mysql_config mysql_config5], [no])
        fi

        if test "$MYSQL_CONFIG" != "no"; then
            MYSQL_CFLAGS="`$MYSQL_CONFIG --cflags`"
            MYSQL_LDFLAGS="`$MYSQL_CONFIG --libs`"

            MYSQL_VERSION=`$MYSQL_CONFIG --version`

            found_mysql="yes"
        else
            found_mysql="no"
        fi
    fi

    dnl
    dnl Check if required version of MySQL is available
    dnl


    mysql_version_req=ifelse([$1], [], [], [$1])

    if test "$found_mysql" = "yes" -a -n "$mysql_version_req"; then

        AC_MSG_CHECKING([if MySQL version is >= $mysql_version_req])

        dnl Decompose required version string of MySQL
        dnl and calculate its number representation
        mysql_version_req_major=`expr $mysql_version_req : '\([[0-9]]*\)'`
        mysql_version_req_minor=`expr $mysql_version_req : '[[0-9]]*\.\([[0-9]]*\)'`
        mysql_version_req_micro=`expr $mysql_version_req : '[[0-9]]*\.[[0-9]]*\.\([[0-9]]*\)'`
        if test "x$mysql_version_req_micro" = "x"; then
            mysql_version_req_micro="0"
        fi

        mysql_version_req_number=`expr $mysql_version_req_major \* 1000000 \
                                   \+ $mysql_version_req_minor \* 1000 \
                                   \+ $mysql_version_req_micro`

        dnl Decompose version string of installed MySQL
        dnl and calculate its number representation
        mysql_version_major=`expr $MYSQL_VERSION : '\([[0-9]]*\)'`
        mysql_version_minor=`expr $MYSQL_VERSION : '[[0-9]]*\.\([[0-9]]*\)'`
        mysql_version_micro=`expr $MYSQL_VERSION : '[[0-9]]*\.[[0-9]]*\.\([[0-9]]*\)'`
        if test "x$mysql_version_micro" = "x"; then
            mysql_version_micro="0"
        fi

        mysql_version_number=`expr $mysql_version_major \* 1000000 \
                                   \+ $mysql_version_minor \* 1000 \
                                   \+ $mysql_version_micro`

        mysql_version_check=`expr $mysql_version_number \>\= $mysql_version_req_number`
        if test "$mysql_version_check" = "1"; then
            AC_MSG_RESULT([yes])
        else
            AC_MSG_RESULT([no])
        fi
    fi

    if test "$found_mysql" = "yes" ; then
        AC_DEFINE([HAVE_MYSQL], [1],
                  [Define to 1 if MySQL libraries are available])
    fi

    AC_SUBST([MYSQL_VERSION])
    AC_SUBST([MYSQL_CFLAGS])
    AC_SUBST([MYSQL_LDFLAGS])
])

# ===========================================================================
#      https://www.gnu.org/software/autoconf-archive/ax_lib_sqlite3.html
# ===========================================================================
#
# SYNOPSIS
#
#   AX_LIB_SQLITE3([MINIMUM-VERSION])
#
# DESCRIPTION
#
#   Test for the SQLite 3 library of a particular version (or newer)
#
#   This macro takes only one optional argument, required version of SQLite
#   3 library. If required version is not passed, 3.0.0 is used in the test
#   of existence of SQLite 3.
#
#   If no installation prefix to the installed SQLite library is given the
#   macro searches under /usr, /usr/local, and /opt.
#
#   This macro calls:
#
#     AC_SUBST(SQLITE3_CFLAGS)
#     AC_SUBST(SQLITE3_LDFLAGS)
#     AC_SUBST(SQLITE3_VERSION)
#
#   And sets:
#
#     HAVE_SQLITE3
#
# LICENSE
#
#   Copyright (c) 2008 Mateusz Loskot <mateusz@loskot.net>
#
#   Copying and distribution of this file, with or without modification, are
#   permitted in any medium without royalty provided the copyright notice
#   and this notice are preserved. This file is offered as-is, without any
#   warranty.

#serial 18

AC_DEFUN([AX_LIB_SQLITE3],
[
    AC_ARG_WITH([sqlite3],
        AS_HELP_STRING(
            [--with-sqlite3=@<:@ARG@:>@],
            [use SQLite 3 library @<:@default=yes@:>@, optionally specify the prefix for sqlite3 library]
        ),
        [
        if test "$withval" = "no"; then
            WANT_SQLITE3="no"
        elif test "$withval" = "yes"; then
            WANT_SQLITE3="yes"
            ac_sqlite3_path=""
        else
            WANT_SQLITE3="yes"
            ac_sqlite3_path="$withval"
        fi
        ],
        [WANT_SQLITE3="yes"]
    )

    SQLITE3_CFLAGS=""
    SQLITE3_LDFLAGS=""
    SQLITE3_VERSION=""

    if test "x$WANT_SQLITE3" = "xyes"; then

        ac_sqlite3_header="sqlite3.h"

        sqlite3_version_req=ifelse([$1], [], [3.0.0], [$1])
        sqlite3_version_req_shorten=`expr $sqlite3_version_req : '\([[0-9]]*\.[[0-9]]*\)'`
        sqlite3_version_req_major=`expr $sqlite3_version_req : '\([[0-9]]*\)'`
        sqlite3_version_req_minor=`expr $sqlite3_version_req : '[[0-9]]*\.\([[0-9]]*\)'`
        sqlite3_version_req_micro=`expr $sqlite3_version_req : '[[0-9]]*\.[[0-9]]*\.\([[0-9]]*\)'`
        if test "x$sqlite3_version_req_micro" = "x" ; then
            sqlite3_version_req_micro="0"
        fi

        sqlite3_version_req_number=`expr $sqlite3_version_req_major \* 1000000 \
                                   \+ $sqlite3_version_req_minor \* 1000 \
                                   \+ $sqlite3_version_req_micro`

        AC_MSG_CHECKING([for SQLite3 library >= $sqlite3_version_req])

        if test "$ac_sqlite3_path" != ""; then
            ac_sqlite3_ldflags="-L$ac_sqlite3_path/lib"
            ac_sqlite3_cppflags="-I$ac_sqlite3_path/include"
        else
            for ac_sqlite3_path_tmp in /usr /usr/local /opt ; do
                if test -f "$ac_sqlite3_path_tmp/include/$ac_sqlite3_header" \
                    && test -r "$ac_sqlite3_path_tmp/include/$ac_sqlite3_header"; then
                    ac_sqlite3_path=$ac_sqlite3_path_tmp
                    ac_sqlite3_cppflags="-I$ac_sqlite3_path_tmp/include"
                    ac_sqlite3_ldflags="-L$ac_sqlite3_path_tmp/lib"
                    break;
                fi
            done
        fi

        ac_sqlite3_ldflags="$ac_sqlite3_ldflags -lsqlite3"

        saved_CPPFLAGS="$CPPFLAGS"
        CPPFLAGS="$CPPFLAGS $ac_sqlite3_cppflags"

        AC_LANG_PUSH(C)
        AC_COMPILE_IFELSE(
            [
            AC_LANG_PROGRAM([[@%:@include <sqlite3.h>]],
                [[
#if (SQLITE_VERSION_NUMBER >= $sqlite3_version_req_number)
/* Everything is okay */
#else
#  error SQLite version is too old
#endif
                ]]
            )
            ],
            [
            AC_MSG_RESULT([yes])
            success="yes"
            ],
            [
            AC_MSG_RESULT([not found])
            success="no"
            ]
        )
        AC_LANG_POP(C)

        CPPFLAGS="$saved_CPPFLAGS"

        if test "$success" = "yes"; then

            SQLITE3_CFLAGS="$ac_sqlite3_cppflags"
            SQLITE3_LDFLAGS="$ac_sqlite3_ldflags"

            ac_sqlite3_header_path="$ac_sqlite3_path/include/$ac_sqlite3_header"

            dnl Retrieve SQLite release version
            if test "x$ac_sqlite3_header_path" != "x"; then
                ac_sqlite3_version=`cat $ac_sqlite3_header_path \
                    | grep '#define.*SQLITE_VERSION.*\"' | sed -e 's/.* "//' \
                        | sed -e 's/"//'`
                if test $ac_sqlite3_version != ""; then
                    SQLITE3_VERSION=$ac_sqlite3_version
                else
                    AC_MSG_WARN([Cannot find SQLITE_VERSION macro in sqlite3.h header to retrieve SQLite version!])
                fi
            fi

            AC_SUBST(SQLITE3_CFLAGS)
            AC_SUBST(SQLITE3_LDFLAGS)
            AC_SUBST(SQLITE3_VERSION)
            AC_DEFINE([HAVE_SQLITE3], [], [Have the SQLITE3 library])
        fi
    fi
])

# ===========================================================================
#    https://www.gnu.org/software/autoconf-archive/ax_lib_postgresql.html
# ===========================================================================
#
# SYNOPSIS
#
#   AX_LIB_POSTGRESQL([MINIMUM-VERSION],[ACTION-IF-FOUND],[ACTION-IF-NOT-FOUND])
#
# DESCRIPTION
#
#   This macro provides tests of availability of PostgreSQL 'libpq' library
#   of particular version or newer.
#
#   AX_LIB_POSTGRESQL macro takes only one argument which is optional. If
#   there is no required version passed, then macro does not run version
#   test.
#
#   The --with-postgresql option takes one of three possible values:
#
#   no - do not check for PostgreSQL client library
#
#   yes - do check for PostgreSQL library in standard locations (pg_config
#   should be in the PATH)
#
#   path - complete path to pg_config utility, use this option if pg_config
#   can't be found in the PATH (You could set also PG_CONFIG variable)
#
#   This macro calls:
#
#     AC_SUBST(POSTGRESQL_CPPFLAGS)
#     AC_SUBST(POSTGRESQL_LDFLAGS)
#     AC_SUBST(POSTGRESQL_LIBS)
#     AC_SUBST(POSTGRESQL_VERSION)
#
#   And sets:
#
#     HAVE_POSTGRESQL
#
#   It execute if found ACTION-IF-FOUND (empty by default) and
#   ACTION-IF-NOT-FOUND (AC_MSG_FAILURE by default) if not found.
#
# LICENSE
#
#   Copyright (c) 2008 Mateusz Loskot <mateusz@loskot.net>
#   Copyright (c) 2014 Sree Harsha Totakura <sreeharsha@totakura.in>
#   Copyright (c) 2018 Bastien Roucaries <rouca@debian.org>
#
#   Copying and distribution of this file, with or without modification, are
#   permitted in any medium without royalty provided the copyright notice
#   and this notice are preserved. This file is offered as-is, without any
#   warranty.

#serial 21

AC_DEFUN([_AX_LIB_POSTGRESQL_OLD],[
	found_postgresql="no"
	_AX_LIB_POSTGRESQL_OLD_fail="no"
	while true; do
	  AC_CACHE_CHECK([for the pg_config program], [ac_cv_path_PG_CONFIG],
	    [AC_PATH_PROGS_FEATURE_CHECK([PG_CONFIG], [pg_config],
	      [[ac_cv_path_PG_CONFIG="";$ac_path_PG_CONFIG --includedir > /dev/null \
		&& ac_cv_path_PG_CONFIG=$ac_path_PG_CONFIG ac_path_PG_CONFIG_found=:]],
	      [ac_cv_path_PG_CONFIG=""])])
	  PG_CONFIG=$ac_cv_path_PG_CONFIG
	  AS_IF([test "X$PG_CONFIG" = "X"],[break])

	  AC_CACHE_CHECK([for the PostgreSQL libraries CPPFLAGS],[ac_cv_POSTGRESQL_CPPFLAGS],
		       [ac_cv_POSTGRESQL_CPPFLAGS="-I`$PG_CONFIG --includedir`" || _AX_LIB_POSTGRESQL_OLD_fail=yes])
	  AS_IF([test "X$_AX_LIB_POSTGRESQL_OLD_fail" = "Xyes"],[break])
	  POSTGRESQL_CPPFLAGS="$ac_cv_POSTGRESQL_CPPFLAGS"

	  AC_CACHE_CHECK([for the PostgreSQL libraries LDFLAGS],[ac_cv_POSTGRESQL_LDFLAGS],
		       [ac_cv_POSTGRESQL_LDFLAGS="-L`$PG_CONFIG --libdir`" || _AX_LIB_POSTGRESQL_OLD_fail=yes])
	  AS_IF([test "X$_AX_LIB_POSTGRESQL_OLD_fail" = "Xyes"],[break])
	  POSTGRESQL_LDFLAGS="$ac_cv_POSTGRESQL_LDFLAGS"

	  AC_CACHE_CHECK([for the PostgreSQL libraries LIBS],[ac_cv_POSTGRESQL_LIBS],
		       [ac_cv_POSTGRESQL_LIBS="-lpq"])
	  POSTGRESQL_LIBS="$ac_cv_POSTGRESQL_LIBS"

	  AC_CACHE_CHECK([for the PostgreSQL version],[ac_cv_POSTGRESQL_VERSION],
		       [
			ac_cv_POSTGRESQL_VERSION=`$PG_CONFIG --version | sed "s/^PostgreSQL[[[:space:]]][[[:space:]]]*\([[0-9.]][[0-9.]]*\).*/\1/"` \
			      || _AX_LIB_POSTGRESQL_OLD_fail=yes
		       ])
	  AS_IF([test "X$_AX_LIB_POSTGRESQL_OLD_fail" = "Xyes"],[break])
	  POSTGRESQL_VERSION="$ac_cv_POSTGRESQL_VERSION"


	  dnl
	  dnl Check if required version of PostgreSQL is available
	  dnl
	  AS_IF([test X"$postgresql_version_req" != "X"],[
	     AC_MSG_CHECKING([if PostgreSQL version $POSTGRESQL_VERSION is >= $postgresql_version_req])
	     AX_COMPARE_VERSION([$POSTGRESQL_VERSION],[ge],[$postgresql_version_req],
				[found_postgresql_req_version=yes],[found_postgresql_req_version=no])
	     AC_MSG_RESULT([$found_postgresql_req_version])
	  ])
	  AS_IF([test "Xfound_postgresql_req_version" = "Xno"],[break])

	  found_postgresql="yes"
	  break
	done
])

AC_DEFUN([_AX_LIB_POSTGRESQL_PKG_CONFIG],
[
  AC_REQUIRE([PKG_PROG_PKG_CONFIG])
  found_postgresql=no

  while true; do
    PKG_PROG_PKG_CONFIG
    AS_IF([test X$PKG_CONFIG = X],[break])

    _AX_LIB_POSTGRESQL_PKG_CONFIG_fail=no;
    AS_IF([test "X$postgresql_version_req" = "X"],
	  [PKG_CHECK_EXISTS([libpq],[found_postgresql_pkg_config=yes],[found_postgresql=no])],
	  [PKG_CHECK_EXISTS([libpq >= "$postgresql_version_req"],
			   [found_postgresql=yes],[found_postgresql=no])])
    AS_IF([test "X$found_postgresql" = "no"],[break])

    AC_CACHE_CHECK([for the PostgreSQL libraries CPPFLAGS],[ac_cv_POSTGRESQL_CPPFLAGS],
		   [ac_cv_POSTGRESQL_CPPFLAGS="`$PKG_CONFIG libpq --cflags-only-I`" || _AX_LIB_POSTGRESQL_PKG_CONFIG_fail=yes])
    AS_IF([test "X$_AX_LIB_POSTGRESQL_PKG_CONFIG_fail" = "Xyes"],[break])
    POSTGRESQL_CPPFLAGS="$ac_cv_POSTGRESQL_CPPFLAGS"


    AC_CACHE_CHECK([for the PostgreSQL libraries LDFLAGS],[ac_cv_POSTGRESQL_LDFLAGS],
		   [ac_cv_POSTGRESQL_LDFLAGS="`$PKG_CONFIG libpq --libs-only-L --libs-only-other`" || _AX_LIB_POSTGRESQL_PKG_CONFIG_fail=yes])
    AS_IF([test "X$_AX_LIB_POSTGRESQL_PKG_CONFIG_fail" = "Xyes"],[break])
    POSTGRESQL_LDFLAGS="$ac_cv_POSTGRESQL_LDFLAGS"


    AC_CACHE_CHECK([for the PostgreSQL libraries LIBS],[ac_cv_POSTGRESQL_LIBS],
		   [ac_cv_POSTGRESQL_LIBS="`$PKG_CONFIG libpq --libs-only-l`" || _AX_LIB_POSTGRESQL_PKG_CONFIG_fail=ye])
    AS_IF([test "X$_AX_LIB_POSTGRESQL_PKG_CONFIG_fail" = "Xyes"],[break])
    POSTGRESQL_LIBS="$ac_cv_POSTGRESQL_LIBS"

    dnl already checked by exist but need to be recovered
    AC_CACHE_CHECK([for the PostgreSQL version],[ac_cv_POSTGRESQL_VERSION],
		   [ac_cv_POSTGRESQL_VERSION="`$PKG_CONFIG libpq --modversion`" || _AX_LIB_POSTGRESQL_PKG_CONFIG_fail=yes])
    AS_IF([test "X$_AX_LIB_POSTGRESQL_PKG_CONFIG_fail" = "Xyes"],[break])
    POSTGRESQL_VERSION="$ac_cv_POSTGRESQL_VERSION"

    found_postgresql=yes
    break;
  done

])



AC_DEFUN([AX_LIB_POSTGRESQL],
[
    AC_ARG_WITH([postgresql],
	AS_HELP_STRING([--with-postgresql=@<:@ARG@:>@],
	    [use PostgreSQL library @<:@default=yes@:>@, optionally specify path to pg_config]
	),
	[
	AS_CASE([$withval],
		[[[nN]][[oO]]],[want_postgresql="no"],
		[[[yY]][[eE]][[sS]]],[want_postgresql="yes"],
		[
			want_postgresql="yes"
			PG_CONFIG="$withval"
		])
	],
	[want_postgresql="yes"]
    )

    AC_ARG_VAR([POSTGRESQL_CPPFLAGS],[cpp flags for PostgreSQL overriding detected flags])
    AC_ARG_VAR([POSTGRESQL_LIBFLAGS],[libs for PostgreSQL overriding detected flags])
    AC_ARG_VAR([POSTGRESQL_LDFLAGS],[linker flags for PostgreSQL overriding detected flags])

    # populate cache
    AS_IF([test "X$POSTGRESQL_CPPFLAGS" != X],[ac_cv_POSTGRESQL_CPPFLAGS="$POSTGRESQL_CPPFLAGS"])
    AS_IF([test "X$POSTGRESQL_LDFLAGS" != X],[ac_cv_POSTGRESQL_LDFLAGS="$POSTGRESQL_LDFLAGS"])
    AS_IF([test "X$POSTGRESQL_LIBS" != X],[ac_cv_POSTGRESQL_LIBS="$POSTGRESQL_LIBS"])

    postgresql_version_req=ifelse([$1], [], [], [$1])
    found_postgresql="no"

    POSTGRESQL_VERSION=""

    dnl
    dnl Check PostgreSQL libraries (libpq)
    dnl
    AS_IF([test X"$want_postgresql" = "Xyes"],[
      _AX_LIB_POSTGRESQL_PKG_CONFIG


      AS_IF([test X"$found_postgresql" = "Xno"],
	    [_AX_LIB_POSTGRESQL_OLD])

      AS_IF([test X"$found_postgresql" = Xyes],[
	  _AX_LIB_POSTGRESQL_OLD_CPPFLAGS="$CPPFLAGS"
	  CPPFLAGS="$CPPFLAGS $POSTGRESQL_CPPFLAGS"
	  _AX_LIB_POSTGRESQL_OLD_LDFLAGS="$LDFLAGS"
	  LDFLAGS="$LDFLAGS $POSTGRESQL_LDFLAGS"
	  _AX_LIB_POSTGRESQL_OLD_LIBS="$LIBS"
	  LIBS="$LIBS $POSTGRESQL_LIBS"
	  while true; do
	    dnl try to compile
	    AC_CHECK_HEADER([libpq-fe.h],[],[found_postgresql=no])
	    AS_IF([test "X$found_postgresql" = "Xno"],[break])
	    dnl try now to link
	    AC_CACHE_CHECK([for the PostgreSQL library linking is working],[ac_cv_postgresql_found],
	    [
	      AC_LINK_IFELSE([
		AC_LANG_PROGRAM(
		  [
		   #include <libpq-fe.h>
		  ],
		  [
		    char conninfo[]="dbname = postgres";
		    PGconn     *conn;
		    conn = PQconnectdb(conninfo);
		  ]
		 )
		],[ac_cv_postgresql_found=yes],
		  [ac_cv_postgresql_found=no])
	     ])
	    found_postgresql="$ac_cv_postgresql_found"
	    AS_IF([test "X$found_postgresql" = "Xno"],[break])
	    break
	done
	CPPFLAGS="$_AX_LIB_POSTGRESQL_OLD_CPPFLAGS"
	LDFLAGS="$_AX_LIB_POSTGRESQL_OLD_LDFLAGS"
	LIBS="$_AX_LIB_POSTGRESQL_OLD_LIBS"
	])


      AS_IF([test "x$found_postgresql" = "xyes"],[
		AC_DEFINE([HAVE_POSTGRESQL], [1],
			  [Define to 1 if PostgreSQL libraries are available])])
    ])

    AC_SUBST([POSTGRESQL_VERSION])
    AC_SUBST([POSTGRESQL_CPPFLAGS])
    AC_SUBST([POSTGRESQL_LDFLAGS])
    AC_SUBST([POSTGRESQL_LIBS])

    AS_IF([test "x$found_postgresql" = "xyes"],
     [ifelse([$2], , :, [$2])],
     [ifelse([$3], , AS_IF([test X"$want_postgresql" = "Xyes"],[AC_MSG_ERROR([Library requirements (PostgreSQL) not met.])],[:]), [$3])])

])

# ===========================================================================
#     https://www.gnu.org/software/autoconf-archive/ax_check_openssl.html
# ===========================================================================
#
# SYNOPSIS
#
#   AX_CHECK_OPENSSL([action-if-found[, action-if-not-found]])
#
# DESCRIPTION
#
#   Look for OpenSSL in a number of default spots, or in a user-selected
#   spot (via --with-openssl).  Sets
#
#     OPENSSL_INCLUDES to the include directives required
#     OPENSSL_LIBS to the -l directives required
#     OPENSSL_LDFLAGS to the -L or -R flags required
#
#   and calls ACTION-IF-FOUND or ACTION-IF-NOT-FOUND appropriately
#
#   This macro sets OPENSSL_INCLUDES such that source files should use the
#   openssl/ directory in include directives:
#
#     #include <openssl/hmac.h>
#
# LICENSE
#
#   Copyright (c) 2009,2010 Zmanda Inc. <http://www.zmanda.com/>
#   Copyright (c) 2009,2010 Dustin J. Mitchell <dustin@zmanda.com>
#
#   Copying and distribution of this file, with or without modification, are
#   permitted in any medium without royalty provided the copyright notice
#   and this notice are preserved. This file is offered as-is, without any
#   warranty.

#serial 10

AU_ALIAS([CHECK_SSL], [AX_CHECK_OPENSSL])
AC_DEFUN([AX_CHECK_OPENSSL], [
    found=false
    AC_ARG_WITH([openssl],
        [AS_HELP_STRING([--with-openssl=DIR],
            [root of the OpenSSL directory])],
        [
            case "$withval" in
            "" | y | ye | yes | n | no)
            AC_MSG_ERROR([Invalid --with-openssl value])
              ;;
            *) ssldirs="$withval"
              ;;
            esac
        ], [
            # if pkg-config is installed and openssl has installed a .pc file,
            # then use that information and don't search ssldirs
            AC_CHECK_TOOL([PKG_CONFIG], [pkg-config])
            if test x"$PKG_CONFIG" != x""; then
                OPENSSL_LDFLAGS=`$PKG_CONFIG openssl --libs-only-L 2>/dev/null`
                if test $? = 0; then
                    OPENSSL_LIBS=`$PKG_CONFIG openssl --libs-only-l 2>/dev/null`
                    OPENSSL_INCLUDES=`$PKG_CONFIG openssl --cflags-only-I 2>/dev/null`
                    found=true
                fi
            fi

            # no such luck; use some default ssldirs
            if ! $found; then
                ssldirs="/usr/local/ssl /usr/lib/ssl /usr/ssl /usr/pkg /usr/local /usr"
            fi
        ]
        )


    # note that we #include <openssl/foo.h>, so the OpenSSL headers have to be in
    # an 'openssl' subdirectory

    if ! $found; then
        OPENSSL_INCLUDES=
        for ssldir in $ssldirs; do
            AC_MSG_CHECKING([for openssl/ssl.h in $ssldir])
            if test -f "$ssldir/include/openssl/ssl.h"; then
                OPENSSL_INCLUDES="-I$ssldir/include"
                OPENSSL_LDFLAGS="-L$ssldir/lib"
                OPENSSL_LIBS="-lssl -lcrypto"
                found=true
                AC_MSG_RESULT([yes])
                break
            else
                AC_MSG_RESULT([no])
            fi
        done

        # if the file wasn't found, well, go ahead and try the link anyway -- maybe
        # it will just work!
    fi

    # try the preprocessor and linker with our new flags,
    # being careful not to pollute the global LIBS, LDFLAGS, and CPPFLAGS

    AC_MSG_CHECKING([whether compiling and linking against OpenSSL works])
    echo "Trying link with OPENSSL_LDFLAGS=$OPENSSL_LDFLAGS;" \
        "OPENSSL_LIBS=$OPENSSL_LIBS; OPENSSL_INCLUDES=$OPENSSL_INCLUDES" >&AS_MESSAGE_LOG_FD

    save_LIBS="$LIBS"
    save_LDFLAGS="$LDFLAGS"
    save_CPPFLAGS="$CPPFLAGS"
    LDFLAGS="$LDFLAGS $OPENSSL_LDFLAGS"
    LIBS="$OPENSSL_LIBS $LIBS"
    CPPFLAGS="$OPENSSL_INCLUDES $CPPFLAGS"
    AC_LINK_IFELSE(
        [AC_LANG_PROGRAM([#include <openssl/ssl.h>], [SSL_new(NULL)])],
        [
            AC_MSG_RESULT([yes])
            $1
        ], [
            AC_MSG_RESULT([no])
            $2
        ])
    CPPFLAGS="$save_CPPFLAGS"
    LDFLAGS="$save_LDFLAGS"
    LIBS="$save_LIBS"

    AC_SUBST([OPENSSL_INCLUDES])
    AC_SUBST([OPENSSL_LIBS])
    AC_SUBST([OPENSSL_LDFLAGS])
])

# ===========================================================================
#     https://www.gnu.org/software/autoconf-archive/ax_path_lib_pcre.html
# ===========================================================================
#
# SYNOPSIS
#
#   AX_PATH_LIB_PCRE [(A/NA)]
#
# DESCRIPTION
#
#   check for pcre lib and set PCRE_LIBS and PCRE_CFLAGS accordingly.
#
#   also provide --with-pcre option that may point to the $prefix of the
#   pcre installation - the macro will check $pcre/include and $pcre/lib to
#   contain the necessary files.
#
#   the usual two ACTION-IF-FOUND / ACTION-IF-NOT-FOUND are supported and
#   they can take advantage of the LIBS/CFLAGS additions.
#
# LICENSE
#
#   Copyright (c) 2008 Guido U. Draheim <guidod@gmx.de>
#
#   This program is free software; you can redistribute it and/or modify it
#   under the terms of the GNU General Public License as published by the
#   Free Software Foundation; either version 3 of the License, or (at your
#   option) any later version.
#
#   This program is distributed in the hope that it will be useful, but
#   WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
#   Public License for more details.
#
#   You should have received a copy of the GNU General Public License along
#   with this program. If not, see <https://www.gnu.org/licenses/>.
#
#   As a special exception, the respective Autoconf Macro's copyright owner
#   gives unlimited permission to copy, distribute and modify the configure
#   scripts that are the output of Autoconf when processing the Macro. You
#   need not follow the terms of the GNU General Public License when using
#   or distributing such scripts, even though portions of the text of the
#   Macro appear in them. The GNU General Public License (GPL) does govern
#   all other use of the material that constitutes the Autoconf Macro.
#
#   This special exception to the GPL applies to versions of the Autoconf
#   Macro released by the Autoconf Archive. When you make and distribute a
#   modified version of the Autoconf Macro, you may extend this special
#   exception to the GPL to apply to your modified version as well.

#serial 8

AC_DEFUN([AX_PATH_LIB_PCRE],[dnl
AC_MSG_CHECKING([lib pcre])
AC_ARG_WITH(pcre,
[  --with-pcre[[=prefix]]    compile xmlpcre part (via libpcre check)],,
     with_pcre="yes")
if test ".$with_pcre" = ".no" ; then
  AC_MSG_RESULT([disabled])
  m4_ifval($2,$2)
else
  AC_MSG_RESULT([(testing)])
  AC_CHECK_LIB(pcre, pcre_study)
  if test "$ac_cv_lib_pcre_pcre_study" = "yes" ; then
     PCRE_LIBS="-lpcre"
     AC_MSG_CHECKING([lib pcre])
     AC_MSG_RESULT([$PCRE_LIBS])
     m4_ifval($1,$1)
  else
     OLDLDFLAGS="$LDFLAGS" ; LDFLAGS="$LDFLAGS -L$with_pcre/lib"
     OLDCPPFLAGS="$CPPFLAGS" ; CPPFLAGS="$CPPFLAGS -I$with_pcre/include"
     AC_CHECK_LIB(pcre, pcre_compile)
     CPPFLAGS="$OLDCPPFLAGS"
     LDFLAGS="$OLDLDFLAGS"
     if test "$ac_cv_lib_pcre_pcre_compile" = "yes" ; then
        AC_MSG_RESULT(.setting PCRE_LIBS -L$with_pcre/lib -lpcre)
        PCRE_LIBS="-L$with_pcre/lib -lpcre"
        test -d "$with_pcre/include" && PCRE_CFLAGS="-I$with_pcre/include"
        AC_MSG_CHECKING([lib pcre])
        AC_MSG_RESULT([$PCRE_LIBS])
        m4_ifval($1,$1)
     else
        AC_MSG_CHECKING([lib pcre])
        AC_MSG_RESULT([no, (WARNING)])
        m4_ifval($2,$2)
     fi
  fi
fi
AC_SUBST([PCRE_LIBS])
AC_SUBST([PCRE_CFLAGS])
])

# ===========================================================================
#    https://www.gnu.org/software/autoconf-archive/ax_type_socklen_t.html
# ===========================================================================
#
# SYNOPSIS
#
#   AX_TYPE_SOCKLEN_T
#
# DESCRIPTION
#
#   Check whether sys/socket.h defines type socklen_t. Please note that some
#   systems require sys/types.h to be included before sys/socket.h can be
#   compiled.
#
# LICENSE
#
#   Copyright (c) 2008 Lars Brinkhoff <lars@nocrew.org>
#
#   This program is free software; you can redistribute it and/or modify it
#   under the terms of the GNU General Public License as published by the
#   Free Software Foundation; either version 2 of the License, or (at your
#   option) any later version.
#
#   This program is distributed in the hope that it will be useful, but
#   WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
#   Public License for more details.
#
#   You should have received a copy of the GNU General Public License along
#   with this program. If not, see <https://www.gnu.org/licenses/>.
#
#   As a special exception, the respective Autoconf Macro's copyright owner
#   gives unlimited permission to copy, distribute and modify the configure
#   scripts that are the output of Autoconf when processing the Macro. You
#   need not follow the terms of the GNU General Public License when using
#   or distributing such scripts, even though portions of the text of the
#   Macro appear in them. The GNU General Public License (GPL) does govern
#   all other use of the material that constitutes the Autoconf Macro.
#
#   This special exception to the GPL applies to versions of the Autoconf
#   Macro released by the Autoconf Archive. When you make and distribute a
#   modified version of the Autoconf Macro, you may extend this special
#   exception to the GPL to apply to your modified version as well.

#serial 7

AU_ALIAS([TYPE_SOCKLEN_T], [AX_TYPE_SOCKLEN_T])
AC_DEFUN([AX_TYPE_SOCKLEN_T],
[AC_CACHE_CHECK([for socklen_t], ac_cv_ax_type_socklen_t,
[
  AC_TRY_COMPILE(
  [#include <sys/types.h>
   #include <sys/socket.h>],
  [socklen_t len = (socklen_t) 42; return (!len);],
  ac_cv_ax_type_socklen_t=yes,
  ac_cv_ax_type_socklen_t=no)
])
  if test $ac_cv_ax_type_socklen_t != yes; then
    AC_DEFINE(socklen_t, int, [Substitute for socklen_t])
  fi
])

# ===========================================================================
#    https://www.gnu.org/software/autoconf-archive/ax_lib_socket_nsl.html
# ===========================================================================
#
# SYNOPSIS
#
#   AX_LIB_SOCKET_NSL
#
# DESCRIPTION
#
#   This macro figures out what libraries are required on this platform to
#   link sockets programs.
#
#   The common cases are not to need any extra libraries, or to need
#   -lsocket and -lnsl. We need to avoid linking with libnsl unless we need
#   it, though, since on some OSes where it isn't necessary it will totally
#   break networking. Unisys also includes gethostbyname() in libsocket but
#   needs libnsl for socket().
#
# LICENSE
#
#   Copyright (c) 2008 Russ Allbery <rra@stanford.edu>
#   Copyright (c) 2008 Stepan Kasal <kasal@ucw.cz>
#   Copyright (c) 2008 Warren Young <warren@etr-usa.com>
#
#   Copying and distribution of this file, with or without modification, are
#   permitted in any medium without royalty provided the copyright notice
#   and this notice are preserved. This file is offered as-is, without any
#   warranty.

#serial 7

AU_ALIAS([LIB_SOCKET_NSL], [AX_LIB_SOCKET_NSL])
AC_DEFUN([AX_LIB_SOCKET_NSL],
[
	AC_SEARCH_LIBS([gethostbyname], [nsl])
	AC_SEARCH_LIBS([socket], [socket], [], [
		AC_CHECK_LIB([socket], [socket], [LIBS="-lsocket -lnsl $LIBS"],
		[], [-lnsl])])
])

# ===========================================================================
#     https://www.gnu.org/software/autoconf-archive/ax_func_snprintf.html
# ===========================================================================
#
# SYNOPSIS
#
#   AX_FUNC_SNPRINTF
#
# DESCRIPTION
#
#   Checks for a fully C99 compliant snprintf, in particular checks whether
#   it does bounds checking and returns the correct string length; does the
#   same check for vsnprintf. If no working snprintf or vsnprintf is found,
#   request a replacement and warn the user about it. Note: the mentioned
#   replacement is freely available and may be used in any project
#   regardless of it's license.
#
# LICENSE
#
#   Copyright (c) 2008 Ruediger Kuhlmann <info@ruediger-kuhlmann.de>
#
#   Copying and distribution of this file, with or without modification, are
#   permitted in any medium without royalty provided the copyright notice
#   and this notice are preserved. This file is offered as-is, without any
#   warranty.

#serial 6

AU_ALIAS([AC_FUNC_SNPRINTF], [AX_FUNC_SNPRINTF])
AC_DEFUN([AX_FUNC_SNPRINTF],
[AC_CHECK_FUNCS(snprintf vsnprintf)
AC_MSG_CHECKING(for working snprintf)
AC_CACHE_VAL(ac_cv_have_working_snprintf,
[AC_TRY_RUN(
[#include <stdio.h>

int main(void)
{
    char bufs[5] = { 'x', 'x', 'x', '\0', '\0' };
    char bufd[5] = { 'x', 'x', 'x', '\0', '\0' };
    int i;
    i = snprintf (bufs, 2, "%s", "111");
    if (strcmp (bufs, "1")) exit (1);
    if (i != 3) exit (1);
    i = snprintf (bufd, 2, "%d", 111);
    if (strcmp (bufd, "1")) exit (1);
    if (i != 3) exit (1);
    exit(0);
}], ac_cv_have_working_snprintf=yes, ac_cv_have_working_snprintf=no, ac_cv_have_working_snprintf=cross)])
AC_MSG_RESULT([$ac_cv_have_working_snprintf])
AC_MSG_CHECKING(for working vsnprintf)
AC_CACHE_VAL(ac_cv_have_working_vsnprintf,
[AC_TRY_RUN(
[#include <stdio.h>
#include <stdarg.h>

int my_vsnprintf (char *buf, const char *tmpl, ...)
{
    int i;
    va_list args;
    va_start (args, tmpl);
    i = vsnprintf (buf, 2, tmpl, args);
    va_end (args);
    return i;
}

int main(void)
{
    char bufs[5] = { 'x', 'x', 'x', '\0', '\0' };
    char bufd[5] = { 'x', 'x', 'x', '\0', '\0' };
    int i;
    i = my_vsnprintf (bufs, "%s", "111");
    if (strcmp (bufs, "1")) exit (1);
    if (i != 3) exit (1);
    i = my_vsnprintf (bufd, "%d", 111);
    if (strcmp (bufd, "1")) exit (1);
    if (i != 3) exit (1);
    exit(0);
}], ac_cv_have_working_vsnprintf=yes, ac_cv_have_working_vsnprintf=no, ac_cv_have_working_vsnprintf=cross)])
AC_MSG_RESULT([$ac_cv_have_working_vsnprintf])
if test x$ac_cv_have_working_snprintf$ac_cv_have_working_vsnprintf != "xyesyes"; then
  AC_LIBOBJ(snprintf)
  AC_MSG_WARN([Replacing missing/broken (v)snprintf() with version from http://www.ijs.si/software/snprintf/.])
  AC_DEFINE(PREFER_PORTABLE_SNPRINTF, 1, "enable replacement (v)snprintf if system (v)snprintf is broken")
fi])

# ===========================================================================
#    https://www.gnu.org/software/autoconf-archive/ax_c___attribute__.html
# ===========================================================================
#
# SYNOPSIS
#
#   AX_C___ATTRIBUTE__
#
# DESCRIPTION
#
#   Provides a test for the compiler support of __attribute__ extensions.
#   Defines HAVE___ATTRIBUTE__ if it is found.
#
# LICENSE
#
#   Copyright (c) 2008 Stepan Kasal <skasal@redhat.com>
#   Copyright (c) 2008 Christian Haggstrom
#   Copyright (c) 2008 Ryan McCabe <ryan@numb.org>
#
#   This program is free software; you can redistribute it and/or modify it
#   under the terms of the GNU General Public License as published by the
#   Free Software Foundation; either version 2 of the License, or (at your
#   option) any later version.
#
#   This program is distributed in the hope that it will be useful, but
#   WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
#   Public License for more details.
#
#   You should have received a copy of the GNU General Public License along
#   with this program. If not, see <https://www.gnu.org/licenses/>.
#
#   As a special exception, the respective Autoconf Macro's copyright owner
#   gives unlimited permission to copy, distribute and modify the configure
#   scripts that are the output of Autoconf when processing the Macro. You
#   need not follow the terms of the GNU General Public License when using
#   or distributing such scripts, even though portions of the text of the
#   Macro appear in them. The GNU General Public License (GPL) does govern
#   all other use of the material that constitutes the Autoconf Macro.
#
#   This special exception to the GPL applies to versions of the Autoconf
#   Macro released by the Autoconf Archive. When you make and distribute a
#   modified version of the Autoconf Macro, you may extend this special
#   exception to the GPL to apply to your modified version as well.

#serial 9

AC_DEFUN([AX_C___ATTRIBUTE__], [
  AC_CACHE_CHECK([for __attribute__], [ax_cv___attribute__],
    [AC_COMPILE_IFELSE(
      [AC_LANG_PROGRAM(
	[[#include <stdlib.h>
	  static void foo(void) __attribute__ ((unused));
	  static void
	  foo(void) {
	      exit(1);
	  }
        ]], [])],
      [ax_cv___attribute__=yes],
      [ax_cv___attribute__=no]
    )
  ])
  if test "$ax_cv___attribute__" = "yes"; then
    AC_DEFINE([HAVE___ATTRIBUTE__], 1, [define if your compiler has __attribute__])
  fi
])

# ===========================================================================
#    https://www.gnu.org/software/autoconf-archive/ax_gcc_malloc_call.html
# ===========================================================================
#
# SYNOPSIS
#
#   AX_GCC_MALLOC_CALL
#
# DESCRIPTION
#
#   The macro will compile a test program to see whether the compiler does
#   understand the per-function postfix pragma.
#
# LICENSE
#
#   Copyright (c) 2008 Guido U. Draheim <guidod@gmx.de>
#
#   This program is free software; you can redistribute it and/or modify it
#   under the terms of the GNU General Public License as published by the
#   Free Software Foundation; either version 3 of the License, or (at your
#   option) any later version.
#
#   This program is distributed in the hope that it will be useful, but
#   WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
#   Public License for more details.
#
#   You should have received a copy of the GNU General Public License along
#   with this program. If not, see <https://www.gnu.org/licenses/>.
#
#   As a special exception, the respective Autoconf Macro's copyright owner
#   gives unlimited permission to copy, distribute and modify the configure
#   scripts that are the output of Autoconf when processing the Macro. You
#   need not follow the terms of the GNU General Public License when using
#   or distributing such scripts, even though portions of the text of the
#   Macro appear in them. The GNU General Public License (GPL) does govern
#   all other use of the material that constitutes the Autoconf Macro.
#
#   This special exception to the GPL applies to versions of the Autoconf
#   Macro released by the Autoconf Archive. When you make and distribute a
#   modified version of the Autoconf Macro, you may extend this special
#   exception to the GPL to apply to your modified version as well.

#serial 8

AC_DEFUN([AX_GCC_MALLOC_CALL],[dnl
AC_CACHE_CHECK(
 [whether the compiler supports function __attribute__((__malloc__))],
 ax_cv_gcc_malloc_call,[
 AC_TRY_COMPILE([__attribute__((__malloc__))
 int f(int i) { return i; }],
 [],
 ax_cv_gcc_malloc_call=yes, ax_cv_gcc_malloc_call=no)])
 if test "$ax_cv_gcc_malloc_call" = yes; then
   AC_DEFINE([GCC_MALLOC_CALL],[__attribute__((__malloc__))],
    [most gcc compilers know a function __attribute__((__malloc__))])
 fi
])

# ===========================================================================
#       https://www.gnu.org/software/autoconf-archive/ax_zoneinfo.html
# ===========================================================================
#
# SYNOPSIS
#
#   AX_ZONEINFO([options...])
#
# DESCRIPTION
#
#   This macro finds compiled zoneinfo files.  If successful it will define
#   HAVE_ZONEINFO per:
#
#     AC_DEFINE([HAVE_ZONEINFO], [1], [...])
#
#   and have the variable TZDIR point to the zoneinfo directory as per
#
#     AC_SUBST([TZDIR])
#     AC_DEFINE_UNQUOTED([TZDIR], [/path/to/zic/files], [...])
#
#   Optionally, OPTIONS can be `right' to trigger further tests that will
#   determine if leap second fix-ups are available.  If so the variables
#   HAVE_ZONEINFO_RIGHT, ZONEINFO_UTC_RIGHT and TZDIR_RIGHT will be
#   populated:
#
#     AC_DEFINE([HAVE_ZONEINFO_RIGHT], [1], [...])
#     AC_SUBST([TZDIR_RIGHT])
#     AC_DEFINE_UNQUOTED([TZDIR_RIGHT], [/path/to/right/zic/files], [...])
#     AC_SUBST([ZONEINFO_UTC_RIGHT])
#     AC_DEFINE_UNQUOTED([ZONEINFO_UTC_RIGHT], [$ZONEINFO_UTC_RIGHT], [...])
#
# LICENSE
#
#   Copyright (c) 2012 Sebastian Freundt <freundt@fresse.org>
#
#   Copying and distribution of this file, with or without modification, are
#   permitted in any medium without royalty provided the copyright notice
#   and this notice are preserved. This file is offered as-is, without any
#   warranty.

#serial 4

AC_DEFUN([AX_ZONEINFO_TZFILE_H], [dnl
	dnl not totally necessary (yet), as we can simply inspect the tzfiles
	dnl ourselves, but it certainly helps
	AC_CHECK_HEADER([tzfile.h])
])dnl AX_ZONEINFO_TZFILE_H

AC_DEFUN([AX_ZONEINFO_CHECK_TZFILE], [dnl
	dnl AX_ZONEINFO_CHECK_TZFILE([FILE], [ACTION-IF-VALID], [ACTION-IF-NOT])
	dnl secret switch is the 4th argument, which determines the ret code
	dnl of the leapcnt check
	pushdef([probe], [$1])
	pushdef([if_found], [$2])
	pushdef([if_not_found], [$3])

	AC_REQUIRE([AX_ZONEINFO_TZFILE_H])

	if test -z "${ax_tmp_zoneinfo_nested}"; then
		AC_MSG_CHECKING([zoneinfo file ]probe[])
	fi

	AC_LANG_PUSH([C])
	AC_RUN_IFELSE([AC_LANG_SOURCE([[
#include <unistd.h>
#include <string.h>
#include <stdio.h>
#include <fcntl.h>

]]ifelse([$4], [], [], [[
#define CHECK_LEAPCNT	]]$4[[
]])[[

/* simplified struct */
struct tzhead {
	char	tzh_magic[4];		/* TZ_MAGIC */
	char	tzh_version[1];		/* '\0' or '2' as of 2005 */
	char	tzh_reserved[15];	/* reserved--must be zero */
	char	tzh_ttisgmtcnt[4];	/* coded number of trans. time flags */
	char	tzh_ttisstdcnt[4];	/* coded number of trans. time flags */
	char	tzh_leapcnt[4];		/* coded number of leap seconds */
	char	tzh_timecnt[4];		/* coded number of transition times */
	char	tzh_typecnt[4];		/* coded number of local time types */
	char	tzh_charcnt[4];		/* coded number of abbr. chars */
};

int
main(int argc, char *argv[])
{
	struct tzhead foo;
	int f;

	if (argc <= 1) {
		return 0;
	} else if ((f = open(argv[1], O_RDONLY, 0644)) < 0) {
		return 1;
	} else if (read(f, &foo, sizeof(foo)) != sizeof(foo)) {
		return 1;
	} else if (close(f) < 0) {
		return 1;
	}

	/* inspect the header */
	if (memcmp(foo.tzh_magic, "TZif", sizeof(foo.tzh_magic))) {
		return 1;
	} else if (*foo.tzh_version && *foo.tzh_version != '2') {
		return 1;
#if defined CHECK_LEAPCNT
	} else if (!foo.tzh_leapcnt[0] && !foo.tzh_leapcnt[1] &&
		   !foo.tzh_leapcnt[2] && !foo.tzh_leapcnt[3]) {
		return CHECK_LEAPCNT;
#endif  /* CHECK_LEAPCNT */
	}

	/* otherwise everything's in order */
	return 0;
}
]])], [## call the whole shebang again with the tzfile
		if ./conftest$EXEEXT probe; then
			if test -z "${ax_tmp_zoneinfo_nested}"; then
				AC_MSG_RESULT([looking good])
			fi
			[]if_found[]
		else
			if test -z "${ax_tmp_zoneinfo_nested}"; then
				AC_MSG_RESULT([looking bad ${ax_tmp_rc}])
			fi
			[]if_not_found[]
		fi
], [
		if test -z "${ax_tmp_zoneinfo_nested}"; then
			AC_MSG_RESULT([impossible])
		fi
		[]if_not_found[]])
	AC_LANG_POP([C])

	popdef([probe])
	popdef([if_found])
	popdef([if_not_found])
])dnl AX_ZONEINFO_CHECK_TZFILE

AC_DEFUN([AX_ZONEINFO_TZDIR], [dnl
	dnl we consider a zoneinfo directory properly populated when it
	dnl provides UTC or UCT or Universal or Zulu

	pushdef([check_tzdir], [dnl
		pushdef([dir], $]1[)dnl
		test -n []dir[] && test -d []dir[] dnl
		popdef([dir])dnl
	])dnl check_tzdir

	dnl try /etc/localtime first, sometimes it's a link into TZDIR
	if test -L "/etc/localtime"; then
		TZDIR_cand="`readlink /etc/localtime` ${TZDIR_cand}"
	fi

	dnl oh, how about we try and check if there is a TZDIR already
	if check_tzdir(["${TZDIR}"]); then
		## bingo
		TZDIR_cand="${TZDIR} ${TZDIR_cand}"
	fi

	dnl often there's a tzselect util which contains the TZDIR path
	AC_PATH_PROG([TZSELECT], [tzselect])
	if test -n "${ac_cv_path_TZSELECT}"; then
		dnl snarf the value
		valtmp="`mktemp`"
		strings "${ac_cv_path_TZSELECT}" | \
			grep -F 'TZDIR=' > "${valtmp}"
		. "${valtmp}"
		TZDIR_cand="${TZDIR} ${TZDIR_cand}"
		rm -f -- "${valtmp}"
	fi

	dnl lastly, append the usual suspects
	TZDIR_cand="${TZDIR_cand} \
/usr/share/zoneinfo \
/usr/lib/zoneinfo \
/usr/local/etc/zoneinfo \
/usr/share/lib/zoneinfo \
"

	dnl go through our candidates
	AC_CACHE_CHECK([for TZDIR], [ax_cv_zoneinfo_tzdir], [dnl
		ax_tmp_zoneinfo_nested="yes"
		for c in ${TZDIR_cand}; do
			ax_cv_zoneinfo_utc=""
			for f in "UTC" "UCT" "Universal" "Zulu"; do
				AX_ZONEINFO_CHECK_TZFILE(["${c}/${f}"], [
					dnl ACTION-IF-FOUND
					ax_cv_zoneinfo_utc="${c}/${f}"
					break
				])
			done
			if test -n "${ax_cv_zoneinfo_utc}"; then
				ax_cv_zoneinfo_tzdir="${c}"
				break
			fi
		done
		ax_tmp_zoneinfo_nested=""
	])dnl ax_cv_tzdir

	TZDIR="${ax_cv_zoneinfo_tzdir}"
	AC_SUBST([TZDIR])

	if check_tzdir(["${ax_cv_zoneinfo_tzdir}"]); then
		AC_DEFINE([HAVE_ZONEINFO], [1], [dnl
Define when zoneinfo directory has been present during configuration.])
		AC_DEFINE_UNQUOTED([TZDIR], ["${ax_cv_zoneinfo_tzdir}"], [
Configuration time zoneinfo directory.])
	fi

	popdef([check_tzdir])
])dnl AX_ZONEINFO_TZDIR

AC_DEFUN([AX_ZONEINFO_RIGHT], [dnl
	AC_REQUIRE([AX_ZONEINFO_TZDIR])

	TZDIR_cand="${TZDIR} \
${TZDIR}/leapseconds \
${TZDIR}-leaps \
${TZDIR}/right \
${TZDIR}-posix \
${TZDIR}/posix \
"

	dnl go through our candidates
	AC_CACHE_CHECK([for leap second file], [ax_cv_zoneinfo_utc_right], [dnl
		ax_tmp_zoneinfo_nested="yes"
		if test -n "${ax_cv_zoneinfo_utc}"; then
			__utc_file="`basename "${ax_cv_zoneinfo_utc}"`"
			for c in ${TZDIR_cand}; do
				if test -d "${c}"; then
					c="${c}/${__utc_file}"
				fi
				AX_ZONEINFO_CHECK_TZFILE(["${c}"], [
					dnl ACTION-IF-FOUND
					ax_cv_zoneinfo_utc_right="${c}"
					break
				], [:], [2])
			done
		fi
		ax_tmp_zoneinfo_nested=""
	])dnl ax_cv_tzdir

	ZONEINFO_UTC_RIGHT="${ax_cv_zoneinfo_utc_right}"
	AC_SUBST([ZONEINFO_UTC_RIGHT])
	AC_SUBST([TZDIR_RIGHT])

	if test -n "${ax_cv_zoneinfo_utc_right}"; then
		TZDIR_RIGHT="`dirname ${ax_cv_zoneinfo_utc_right}`"

		AC_DEFINE([HAVE_ZONEINFO_RIGHT], [1], [dnl
Define when zoneinfo directory has been present during configuration.])
		AC_DEFINE_UNQUOTED([TZDIR_RIGHT],
			["${TZDIR_RIGHT}"], [
Configuration time zoneinfo directory.])
		AC_DEFINE_UNQUOTED([ZONEINFO_UTC_RIGHT],
			["${ax_cv_zoneinfo_utc_right}"], [
Leap-second aware UTC zoneinfo file.])
	fi
])dnl AX_ZONEINFO_RIGHT

AC_DEFUN([AX_ZONEINFO], [
	AC_REQUIRE([AX_ZONEINFO_TZDIR])

	ifelse([$1], [right], [
		AC_REQUIRE([AX_ZONEINFO_RIGHT])
	])

	AC_ARG_VAR([TZDIR], [Directory with compiled zoneinfo files.])
])dnl AX_ZONEINFO

dnl ax_zoneinfo.m4 ends here

# ===========================================================================
#    https://www.gnu.org/software/autoconf-archive/ax_check_link_flag.html
# ===========================================================================
#
# SYNOPSIS
#
#   AX_CHECK_LINK_FLAG(FLAG, [ACTION-SUCCESS], [ACTION-FAILURE], [EXTRA-FLAGS], [INPUT])
#
# DESCRIPTION
#
#   Check whether the given FLAG works with the linker or gives an error.
#   (Warnings, however, are ignored)
#
#   ACTION-SUCCESS/ACTION-FAILURE are shell commands to execute on
#   success/failure.
#
#   If EXTRA-FLAGS is defined, it is added to the linker's default flags
#   when the check is done.  The check is thus made with the flags: "LDFLAGS
#   EXTRA-FLAGS FLAG".  This can for example be used to force the linker to
#   issue an error when a bad flag is given.
#
#   INPUT gives an alternative input source to AC_LINK_IFELSE.
#
#   NOTE: Implementation based on AX_CFLAGS_GCC_OPTION. Please keep this
#   macro in sync with AX_CHECK_{PREPROC,COMPILE}_FLAG.
#
# LICENSE
#
#   Copyright (c) 2008 Guido U. Draheim <guidod@gmx.de>
#   Copyright (c) 2011 Maarten Bosmans <mkbosmans@gmail.com>
#
#   This program is free software: you can redistribute it and/or modify it
#   under the terms of the GNU General Public License as published by the
#   Free Software Foundation, either version 3 of the License, or (at your
#   option) any later version.
#
#   This program is distributed in the hope that it will be useful, but
#   WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
#   Public License for more details.
#
#   You should have received a copy of the GNU General Public License along
#   with this program. If not, see <https://www.gnu.org/licenses/>.
#
#   As a special exception, the respective Autoconf Macro's copyright owner
#   gives unlimited permission to copy, distribute and modify the configure
#   scripts that are the output of Autoconf when processing the Macro. You
#   need not follow the terms of the GNU General Public License when using
#   or distributing such scripts, even though portions of the text of the
#   Macro appear in them. The GNU General Public License (GPL) does govern
#   all other use of the material that constitutes the Autoconf Macro.
#
#   This special exception to the GPL applies to versions of the Autoconf
#   Macro released by the Autoconf Archive. When you make and distribute a
#   modified version of the Autoconf Macro, you may extend this special
#   exception to the GPL to apply to your modified version as well.

#serial 5

AC_DEFUN([AX_CHECK_LINK_FLAG],
[AC_PREREQ(2.64)dnl for _AC_LANG_PREFIX and AS_VAR_IF
AS_VAR_PUSHDEF([CACHEVAR],[ax_cv_check_ldflags_$4_$1])dnl
AC_CACHE_CHECK([whether the linker accepts $1], CACHEVAR, [
  ax_check_save_flags=$LDFLAGS
  LDFLAGS="$LDFLAGS $4 $1"
  AC_LINK_IFELSE([m4_default([$5],[AC_LANG_PROGRAM()])],
    [AS_VAR_SET(CACHEVAR,[yes])],
    [AS_VAR_SET(CACHEVAR,[no])])
  LDFLAGS=$ax_check_save_flags])
AS_VAR_IF(CACHEVAR,yes,
  [m4_default([$2], :)],
  [m4_default([$3], :)])
AS_VAR_POPDEF([CACHEVAR])dnl
])dnl AX_CHECK_LINK_FLAGS

# ===========================================================================
#    https://www.gnu.org/software/autoconf-archive/ax_compare_version.html
# ===========================================================================
#
# SYNOPSIS
#
#   AX_COMPARE_VERSION(VERSION_A, OP, VERSION_B, [ACTION-IF-TRUE], [ACTION-IF-FALSE])
#
# DESCRIPTION
#
#   This macro compares two version strings. Due to the various number of
#   minor-version numbers that can exist, and the fact that string
#   comparisons are not compatible with numeric comparisons, this is not
#   necessarily trivial to do in a autoconf script. This macro makes doing
#   these comparisons easy.
#
#   The six basic comparisons are available, as well as checking equality
#   limited to a certain number of minor-version levels.
#
#   The operator OP determines what type of comparison to do, and can be one
#   of:
#
#    eq  - equal (test A == B)
#    ne  - not equal (test A != B)
#    le  - less than or equal (test A <= B)
#    ge  - greater than or equal (test A >= B)
#    lt  - less than (test A < B)
#    gt  - greater than (test A > B)
#
#   Additionally, the eq and ne operator can have a number after it to limit
#   the test to that number of minor versions.
#
#    eq0 - equal up to the length of the shorter version
#    ne0 - not equal up to the length of the shorter version
#    eqN - equal up to N sub-version levels
#    neN - not equal up to N sub-version levels
#
#   When the condition is true, shell commands ACTION-IF-TRUE are run,
#   otherwise shell commands ACTION-IF-FALSE are run. The environment
#   variable 'ax_compare_version' is always set to either 'true' or 'false'
#   as well.
#
#   Examples:
#
#     AX_COMPARE_VERSION([3.15.7],[lt],[3.15.8])
#     AX_COMPARE_VERSION([3.15],[lt],[3.15.8])
#
#   would both be true.
#
#     AX_COMPARE_VERSION([3.15.7],[eq],[3.15.8])
#     AX_COMPARE_VERSION([3.15],[gt],[3.15.8])
#
#   would both be false.
#
#     AX_COMPARE_VERSION([3.15.7],[eq2],[3.15.8])
#
#   would be true because it is only comparing two minor versions.
#
#     AX_COMPARE_VERSION([3.15.7],[eq0],[3.15])
#
#   would be true because it is only comparing the lesser number of minor
#   versions of the two values.
#
#   Note: The characters that separate the version numbers do not matter. An
#   empty string is the same as version 0. OP is evaluated by autoconf, not
#   configure, so must be a string, not a variable.
#
#   The author would like to acknowledge Guido Draheim whose advice about
#   the m4_case and m4_ifvaln functions make this macro only include the
#   portions necessary to perform the specific comparison specified by the
#   OP argument in the final configure script.
#
# LICENSE
#
#   Copyright (c) 2008 Tim Toolan <toolan@ele.uri.edu>
#
#   Copying and distribution of this file, with or without modification, are
#   permitted in any medium without royalty provided the copyright notice
#   and this notice are preserved. This file is offered as-is, without any
#   warranty.

#serial 13

dnl #########################################################################
AC_DEFUN([AX_COMPARE_VERSION], [
  AC_REQUIRE([AC_PROG_AWK])

  # Used to indicate true or false condition
  ax_compare_version=false

  # Convert the two version strings to be compared into a format that
  # allows a simple string comparison.  The end result is that a version
  # string of the form 1.12.5-r617 will be converted to the form
  # 0001001200050617.  In other words, each number is zero padded to four
  # digits, and non digits are removed.
  AS_VAR_PUSHDEF([A],[ax_compare_version_A])
  A=`echo "$1" | sed -e 's/\([[0-9]]*\)/Z\1Z/g' \
                     -e 's/Z\([[0-9]]\)Z/Z0\1Z/g' \
                     -e 's/Z\([[0-9]][[0-9]]\)Z/Z0\1Z/g' \
                     -e 's/Z\([[0-9]][[0-9]][[0-9]]\)Z/Z0\1Z/g' \
                     -e 's/[[^0-9]]//g'`

  AS_VAR_PUSHDEF([B],[ax_compare_version_B])
  B=`echo "$3" | sed -e 's/\([[0-9]]*\)/Z\1Z/g' \
                     -e 's/Z\([[0-9]]\)Z/Z0\1Z/g' \
                     -e 's/Z\([[0-9]][[0-9]]\)Z/Z0\1Z/g' \
                     -e 's/Z\([[0-9]][[0-9]][[0-9]]\)Z/Z0\1Z/g' \
                     -e 's/[[^0-9]]//g'`

  dnl # In the case of le, ge, lt, and gt, the strings are sorted as necessary
  dnl # then the first line is used to determine if the condition is true.
  dnl # The sed right after the echo is to remove any indented white space.
  m4_case(m4_tolower($2),
  [lt],[
    ax_compare_version=`echo "x$A
x$B" | sed 's/^ *//' | sort -r | sed "s/x${A}/false/;s/x${B}/true/;1q"`
  ],
  [gt],[
    ax_compare_version=`echo "x$A
x$B" | sed 's/^ *//' | sort | sed "s/x${A}/false/;s/x${B}/true/;1q"`
  ],
  [le],[
    ax_compare_version=`echo "x$A
x$B" | sed 's/^ *//' | sort | sed "s/x${A}/true/;s/x${B}/false/;1q"`
  ],
  [ge],[
    ax_compare_version=`echo "x$A
x$B" | sed 's/^ *//' | sort -r | sed "s/x${A}/true/;s/x${B}/false/;1q"`
  ],[
    dnl Split the operator from the subversion count if present.
    m4_bmatch(m4_substr($2,2),
    [0],[
      # A count of zero means use the length of the shorter version.
      # Determine the number of characters in A and B.
      ax_compare_version_len_A=`echo "$A" | $AWK '{print(length)}'`
      ax_compare_version_len_B=`echo "$B" | $AWK '{print(length)}'`

      # Set A to no more than B's length and B to no more than A's length.
      A=`echo "$A" | sed "s/\(.\{$ax_compare_version_len_B\}\).*/\1/"`
      B=`echo "$B" | sed "s/\(.\{$ax_compare_version_len_A\}\).*/\1/"`
    ],
    [[0-9]+],[
      # A count greater than zero means use only that many subversions
      A=`echo "$A" | sed "s/\(\([[0-9]]\{4\}\)\{m4_substr($2,2)\}\).*/\1/"`
      B=`echo "$B" | sed "s/\(\([[0-9]]\{4\}\)\{m4_substr($2,2)\}\).*/\1/"`
    ],
    [.+],[
      AC_WARNING(
        [invalid OP numeric parameter: $2])
    ],[])

    # Pad zeros at end of numbers to make same length.
    ax_compare_version_tmp_A="$A`echo $B | sed 's/./0/g'`"
    B="$B`echo $A | sed 's/./0/g'`"
    A="$ax_compare_version_tmp_A"

    # Check for equality or inequality as necessary.
    m4_case(m4_tolower(m4_substr($2,0,2)),
    [eq],[
      test "x$A" = "x$B" && ax_compare_version=true
    ],
    [ne],[
      test "x$A" != "x$B" && ax_compare_version=true
    ],[
      AC_WARNING([invalid OP parameter: $2])
    ])
  ])

  AS_VAR_POPDEF([A])dnl
  AS_VAR_POPDEF([B])dnl

  dnl # Execute ACTION-IF-TRUE / ACTION-IF-FALSE.
  if test "$ax_compare_version" = "true" ; then
    m4_ifvaln([$4],[$4],[:])dnl
    m4_ifvaln([$5],[else $5])dnl
  fi
]) dnl AX_COMPARE_VERSION



dnl The following no longer appear to be part of autoconf-archive.
dnl TODO: Look into replacing them with something else
# ===========================================================================
#             http://autoconf-archive.cryp.to/ax_gcc_option.html
# ===========================================================================
#
# SYNOPSIS
#
#   AX_GCC_OPTION(OPTION,EXTRA-OPTIONS,TEST-PROGRAM,ACTION-IF-SUCCESSFUL,ACTION-IF-NOT-SUCCESFUL)
#
# DESCRIPTION
#
#   AX_GCC_OPTION checks wheter gcc accepts the passed OPTION. If it accepts
#   the OPTION then ACTION-IF-SUCCESSFUL will be executed, otherwise
#   ACTION-IF-UNSUCCESSFUL.
#
#   NOTE: This macro will be obsoleted by AX_C_CHECK_FLAG AX_CXX_CHECK_FLAG,
#   AX_CPP_CHECK_FLAG, AX_CXXCPP_CHECK_FLAG and AX_LD_CHECK_FLAG.
#
#   A typical usage should be the following one:
#
#     AX_GCC_OPTION([-fomit-frame-pointer],[],[],[
#       AC_MSG_NOTICE([The option is supported])],[
#       AC_MSG_NOTICE([No luck this time])
#     ])
#
#   The macro doesn't discriminate between languages so, if you are testing
#   for an option that works for C++ but not for C you should use '-x c++'
#   as EXTRA-OPTIONS:
#
#     AX_GCC_OPTION([-fno-rtti],[-x c++],[],[ ... ],[ ... ])
#
#   OPTION is tested against the following code:
#
#     int main()
#     {
#             return 0;
#     }
#
#   The optional TEST-PROGRAM comes handy when the default main() is not
#   suited for the option being checked
#
#   So, if you need to test for -fstrict-prototypes option you should
#   probably use the macro as follows:
#
#     AX_GCC_OPTION([-fstrict-prototypes],[-x c++],[
#       int main(int argc, char ** argv)
#       {
#       	(void) argc;
#       	(void) argv;
#
#       	return 0;
#       }
#     ],[ ... ],[ ... ])
#
#   Note that the macro compiles but doesn't link the test program so it is
#   not suited for checking options that are passed to the linker, like:
#
#     -Wl,-L<a-library-path>
#
#   In order to avoid such kind of problems you should think about usinguse
#   the AX_*_CHECK_FLAG family macros
#
# LAST MODIFICATION
#
#   2008-04-12
#
# COPYLEFT
#
#   Copyright (c) 2008 Francesco Salvestrini <salvestrini@users.sourceforge.net>
#   Copyright (c) 2008 Bogdan Drozdowski <bogdandr@op.pl>
#
#   This program is free software; you can redistribute it and/or modify it
#   under the terms of the GNU General Public License as published by the
#   Free Software Foundation; either version 2 of the License, or (at your
#   option) any later version.
#
#   This program is distributed in the hope that it will be useful, but
#   WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
#   Public License for more details.
#
#   You should have received a copy of the GNU General Public License along
#   with this program. If not, see <http://www.gnu.org/licenses/>.
#
#   As a special exception, the respective Autoconf Macro's copyright owner
#   gives unlimited permission to copy, distribute and modify the configure
#   scripts that are the output of Autoconf when processing the Macro. You
#   need not follow the terms of the GNU General Public License when using
#   or distributing such scripts, even though portions of the text of the
#   Macro appear in them. The GNU General Public License (GPL) does govern
#   all other use of the material that constitutes the Autoconf Macro.
#
#   This special exception to the GPL applies to versions of the Autoconf
#   Macro released by the Autoconf Macro Archive. When you make and
#   distribute a modified version of the Autoconf Macro, you may extend this
#   special exception to the GPL to apply to your modified version as well.

AC_DEFUN([AX_GCC_OPTION], [
  AC_REQUIRE([AC_PROG_CC])

  AC_MSG_CHECKING([if gcc accepts $1 option])

  AS_IF([ test "x$GCC" = "xyes" ],[
    AS_IF([ test -z "$3" ],[
      ax_gcc_option_test="int main()
{
	return 0;
}"
    ],[
      ax_gcc_option_test="$3"
    ])

    # Dump the test program to file
    cat <<EOF > conftest.c
$ax_gcc_option_test
EOF

    # Dump back the file to the log, useful for debugging purposes
    AC_TRY_COMMAND(cat conftest.c 1>&AS_MESSAGE_LOG_FD)

    AS_IF([ AC_TRY_COMMAND($CC $2 $1 -c conftest.c 1>&AS_MESSAGE_LOG_FD) ],[
   	        AC_MSG_RESULT([yes])
    	$4
    ],[
   		AC_MSG_RESULT([no])
    	$5
    ])
  ],[
    AC_MSG_RESULT([no gcc available])
  ])
])

dnl From pkg-config installation

dnl pkg.m4 - Macros to locate and utilise pkg-config.   -*- Autoconf -*-
dnl serial 11 (pkg-config-0.29.1)
dnl
dnl Copyright © 2004 Scott James Remnant <scott@netsplit.com>.
dnl Copyright © 2012-2015 Dan Nicholson <dbn.lists@gmail.com>
dnl
dnl This program is free software; you can redistribute it and/or modify
dnl it under the terms of the GNU General Public License as published by
dnl the Free Software Foundation; either version 2 of the License, or
dnl (at your option) any later version.
dnl
dnl This program is distributed in the hope that it will be useful, but
dnl WITHOUT ANY WARRANTY; without even the implied warranty of
dnl MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
dnl General Public License for more details.
dnl
dnl You should have received a copy of the GNU General Public License
dnl along with this program; if not, write to the Free Software
dnl Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
dnl 02111-1307, USA.
dnl
dnl As a special exception to the GNU General Public License, if you
dnl distribute this file as part of a program that contains a
dnl configuration script generated by Autoconf, you may include it under
dnl the same distribution terms that you use for the rest of that
dnl program.

dnl PKG_PREREQ(MIN-VERSION)
dnl -----------------------
dnl Since: 0.29
dnl
dnl Verify that the version of the pkg-config macros are at least
dnl MIN-VERSION. Unlike PKG_PROG_PKG_CONFIG, which checks the user's
dnl installed version of pkg-config, this checks the developer's version
dnl of pkg.m4 when generating configure.
dnl
dnl To ensure that this macro is defined, also add:
dnl m4_ifndef([PKG_PREREQ],
dnl     [m4_fatal([must install pkg-config 0.29 or later before running autoconf/autogen])])
dnl
dnl See the "Since" comment for each macro you use to see what version
dnl of the macros you require.
m4_defun([PKG_PREREQ],
[m4_define([PKG_MACROS_VERSION], [0.29.1])
m4_if(m4_version_compare(PKG_MACROS_VERSION, [$1]), -1,
    [m4_fatal([pkg.m4 version $1 or higher is required but ]PKG_MACROS_VERSION[ found])])
])dnl PKG_PREREQ

dnl PKG_PROG_PKG_CONFIG([MIN-VERSION])
dnl ----------------------------------
dnl Since: 0.16
dnl
dnl Search for the pkg-config tool and set the PKG_CONFIG variable to
dnl first found in the path. Checks that the version of pkg-config found
dnl is at least MIN-VERSION. If MIN-VERSION is not specified, 0.9.0 is
dnl used since that's the first version where most current features of
dnl pkg-config existed.
AC_DEFUN([PKG_PROG_PKG_CONFIG],
[m4_pattern_forbid([^_?PKG_[A-Z_]+$])
m4_pattern_allow([^PKG_CONFIG(_(PATH|LIBDIR|SYSROOT_DIR|ALLOW_SYSTEM_(CFLAGS|LIBS)))?$])
m4_pattern_allow([^PKG_CONFIG_(DISABLE_UNINSTALLED|TOP_BUILD_DIR|DEBUG_SPEW)$])
AC_ARG_VAR([PKG_CONFIG], [path to pkg-config utility])
AC_ARG_VAR([PKG_CONFIG_PATH], [directories to add to pkg-config's search path])
AC_ARG_VAR([PKG_CONFIG_LIBDIR], [path overriding pkg-config's built-in search path])

if test "x$ac_cv_env_PKG_CONFIG_set" != "xset"; then
	AC_PATH_TOOL([PKG_CONFIG], [pkg-config])
fi
if test -n "$PKG_CONFIG"; then
	_pkg_min_version=m4_default([$1], [0.9.0])
	AC_MSG_CHECKING([pkg-config is at least version $_pkg_min_version])
	if $PKG_CONFIG --atleast-pkgconfig-version $_pkg_min_version; then
		AC_MSG_RESULT([yes])
	else
		AC_MSG_RESULT([no])
		PKG_CONFIG=""
	fi
fi[]dnl
])dnl PKG_PROG_PKG_CONFIG

dnl PKG_CHECK_EXISTS(MODULES, [ACTION-IF-FOUND], [ACTION-IF-NOT-FOUND])
dnl -------------------------------------------------------------------
dnl Since: 0.18
dnl
dnl Check to see whether a particular set of modules exists. Similar to
dnl PKG_CHECK_MODULES(), but does not set variables or print errors.
dnl
dnl Please remember that m4 expands AC_REQUIRE([PKG_PROG_PKG_CONFIG])
dnl only at the first occurence in configure.ac, so if the first place
dnl it's called might be skipped (such as if it is within an "if", you
dnl have to call PKG_CHECK_EXISTS manually
AC_DEFUN([PKG_CHECK_EXISTS],
[AC_REQUIRE([PKG_PROG_PKG_CONFIG])dnl
if test -n "$PKG_CONFIG" && \
    AC_RUN_LOG([$PKG_CONFIG --exists --print-errors "$1"]); then
  m4_default([$2], [:])
m4_ifvaln([$3], [else
  $3])dnl
fi])

dnl _PKG_CONFIG([VARIABLE], [COMMAND], [MODULES])
dnl ---------------------------------------------
dnl Internal wrapper calling pkg-config via PKG_CONFIG and setting
dnl pkg_failed based on the result.
m4_define([_PKG_CONFIG],
[if test -n "$$1"; then
    pkg_cv_[]$1="$$1"
 elif test -n "$PKG_CONFIG"; then
    PKG_CHECK_EXISTS([$3],
                     [pkg_cv_[]$1=`$PKG_CONFIG --[]$2 "$3" 2>/dev/null`
		      test "x$?" != "x0" && pkg_failed=yes ],
		     [pkg_failed=yes])
 else
    pkg_failed=untried
fi[]dnl
])dnl _PKG_CONFIG

dnl _PKG_SHORT_ERRORS_SUPPORTED
dnl ---------------------------
dnl Internal check to see if pkg-config supports short errors.
AC_DEFUN([_PKG_SHORT_ERRORS_SUPPORTED],
[AC_REQUIRE([PKG_PROG_PKG_CONFIG])
if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
        _pkg_short_errors_supported=yes
else
        _pkg_short_errors_supported=no
fi[]dnl
])dnl _PKG_SHORT_ERRORS_SUPPORTED


dnl PKG_CHECK_MODULES(VARIABLE-PREFIX, MODULES, [ACTION-IF-FOUND],
dnl   [ACTION-IF-NOT-FOUND])
dnl --------------------------------------------------------------
dnl Since: 0.4.0
dnl
dnl Note that if there is a possibility the first call to
dnl PKG_CHECK_MODULES might not happen, you should be sure to include an
dnl explicit call to PKG_PROG_PKG_CONFIG in your configure.ac
AC_DEFUN([PKG_CHECK_MODULES],
[AC_REQUIRE([PKG_PROG_PKG_CONFIG])dnl
AC_ARG_VAR([$1][_CFLAGS], [C compiler flags for $1, overriding pkg-config])dnl
AC_ARG_VAR([$1][_LIBS], [linker flags for $1, overriding pkg-config])dnl

pkg_failed=no
AC_MSG_CHECKING([for $1])

_PKG_CONFIG([$1][_CFLAGS], [cflags], [$2])
_PKG_CONFIG([$1][_LIBS], [libs], [$2])

m4_define([_PKG_TEXT], [Alternatively, you may set the environment variables $1[]_CFLAGS
and $1[]_LIBS to avoid the need to call pkg-config.
See the pkg-config man page for more details.])

if test $pkg_failed = yes; then
   	AC_MSG_RESULT([no])
        _PKG_SHORT_ERRORS_SUPPORTED
        if test $_pkg_short_errors_supported = yes; then
	        $1[]_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors --cflags --libs "$2" 2>&1`
        else 
	        $1[]_PKG_ERRORS=`$PKG_CONFIG --print-errors --cflags --libs "$2" 2>&1`
        fi
	# Put the nasty error message in config.log where it belongs
	echo "$$1[]_PKG_ERRORS" >&AS_MESSAGE_LOG_FD

	m4_default([$4], [AC_MSG_ERROR(
[Package requirements ($2) were not met:

$$1_PKG_ERRORS

Consider adjusting the PKG_CONFIG_PATH environment variable if you
installed software in a non-standard prefix.

_PKG_TEXT])[]dnl
        ])
elif test $pkg_failed = untried; then
     	AC_MSG_RESULT([no])
	m4_default([$4], [AC_MSG_FAILURE(
[The pkg-config script could not be found or is too old.  Make sure it
is in your PATH or set the PKG_CONFIG environment variable to the full
path to pkg-config.

_PKG_TEXT

To get pkg-config, see <http://pkg-config.freedesktop.org/>.])[]dnl
        ])
else
	$1[]_CFLAGS=$pkg_cv_[]$1[]_CFLAGS
	$1[]_LIBS=$pkg_cv_[]$1[]_LIBS
        AC_MSG_RESULT([yes])
	$3
fi[]dnl
])dnl PKG_CHECK_MODULES


dnl PKG_CHECK_MODULES_STATIC(VARIABLE-PREFIX, MODULES, [ACTION-IF-FOUND],
dnl   [ACTION-IF-NOT-FOUND])
dnl ---------------------------------------------------------------------
dnl Since: 0.29
dnl
dnl Checks for existence of MODULES and gathers its build flags with
dnl static libraries enabled. Sets VARIABLE-PREFIX_CFLAGS from --cflags
dnl and VARIABLE-PREFIX_LIBS from --libs.
dnl
dnl Note that if there is a possibility the first call to
dnl PKG_CHECK_MODULES_STATIC might not happen, you should be sure to
dnl include an explicit call to PKG_PROG_PKG_CONFIG in your
dnl configure.ac.
AC_DEFUN([PKG_CHECK_MODULES_STATIC],
[AC_REQUIRE([PKG_PROG_PKG_CONFIG])dnl
_save_PKG_CONFIG=$PKG_CONFIG
PKG_CONFIG="$PKG_CONFIG --static"
PKG_CHECK_MODULES($@)
PKG_CONFIG=$_save_PKG_CONFIG[]dnl
])dnl PKG_CHECK_MODULES_STATIC


dnl PKG_INSTALLDIR([DIRECTORY])
dnl -------------------------
dnl Since: 0.27
dnl
dnl Substitutes the variable pkgconfigdir as the location where a module
dnl should install pkg-config .pc files. By default the directory is
dnl $libdir/pkgconfig, but the default can be changed by passing
dnl DIRECTORY. The user can override through the --with-pkgconfigdir
dnl parameter.
AC_DEFUN([PKG_INSTALLDIR],
[m4_pushdef([pkg_default], [m4_default([$1], ['${libdir}/pkgconfig'])])
m4_pushdef([pkg_description],
    [pkg-config installation directory @<:@]pkg_default[@:>@])
AC_ARG_WITH([pkgconfigdir],
    [AS_HELP_STRING([--with-pkgconfigdir], pkg_description)],,
    [with_pkgconfigdir=]pkg_default)
AC_SUBST([pkgconfigdir], [$with_pkgconfigdir])
m4_popdef([pkg_default])
m4_popdef([pkg_description])
])dnl PKG_INSTALLDIR


dnl PKG_NOARCH_INSTALLDIR([DIRECTORY])
dnl --------------------------------
dnl Since: 0.27
dnl
dnl Substitutes the variable noarch_pkgconfigdir as the location where a
dnl module should install arch-independent pkg-config .pc files. By
dnl default the directory is $datadir/pkgconfig, but the default can be
dnl changed by passing DIRECTORY. The user can override through the
dnl --with-noarch-pkgconfigdir parameter.
AC_DEFUN([PKG_NOARCH_INSTALLDIR],
[m4_pushdef([pkg_default], [m4_default([$1], ['${datadir}/pkgconfig'])])
m4_pushdef([pkg_description],
    [pkg-config arch-independent installation directory @<:@]pkg_default[@:>@])
AC_ARG_WITH([noarch-pkgconfigdir],
    [AS_HELP_STRING([--with-noarch-pkgconfigdir], pkg_description)],,
    [with_noarch_pkgconfigdir=]pkg_default)
AC_SUBST([noarch_pkgconfigdir], [$with_noarch_pkgconfigdir])
m4_popdef([pkg_default])
m4_popdef([pkg_description])
])dnl PKG_NOARCH_INSTALLDIR


dnl PKG_CHECK_VAR(VARIABLE, MODULE, CONFIG-VARIABLE,
dnl [ACTION-IF-FOUND], [ACTION-IF-NOT-FOUND])
dnl -------------------------------------------
dnl Since: 0.28
dnl
dnl Retrieves the value of the pkg-config variable for the given module.
AC_DEFUN([PKG_CHECK_VAR],
[AC_REQUIRE([PKG_PROG_PKG_CONFIG])dnl
AC_ARG_VAR([$1], [value of $3 for $2, overriding pkg-config])dnl

_PKG_CONFIG([$1], [variable="][$3]["], [$2])
AS_VAR_COPY([$1], [pkg_cv_][$1])

AS_VAR_IF([$1], [""], [$5], [$4])dnl
])dnl PKG_CHECK_VAR

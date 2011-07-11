##########################################################################
# Copyright (C) 2011 Daniel Pfeifer <daniel@pfeifer-mail.de>             #
#                                                                        #
# Distributed under the Boost Software License, Version 1.0.             #
# See accompanying file LICENSE_1_0.txt or copy at                       #
#   http://www.boost.org/LICENSE_1_0.txt                                 #
##########################################################################

boost_add_test(fail_compile FAIL COMPILE )
boost_add_test(fail_link    FAIL LINK    )
boost_add_test(fail_run     FAIL RUN     )

boost_add_test(succeed_compile COMPILE succeed.cpp )
boost_add_test(succeed_link    LINK    succeed.cpp )
boost_add_test(succeed_run     RUN     succeed.cpp )


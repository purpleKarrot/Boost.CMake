/*
 * Copyright (C) 2012 Daniel Pfeifer <daniel@pfeifer-mail.de>
 *
 * Distributed under the Boost Software License, Version 1.0.
 * See accompanying file LICENSE_1_0.txt or copy at
 *     http://www.boost.org/LICENSE_1_0.txt
 */

#include <cstdlib>
#include <sstream>

int main(int argc, char* argv[])
{
	std::stringstream stream;

	for (int i = 1; i < argc; ++i)
		stream << '\"' << argv[i] << '\"' << ' ';

	return !system(stream.str().c_str());
}

/*~--------------------------------------------------------------------------~*
 * Copyright (c) 2014 Los Alamos National Security, LLC
 * All rights reserved.
 *~--------------------------------------------------------------------------~*/

#ifndef cinchtest_h
#define cinchtest_h

#include "output.h"
#include "listener.h"

// Provide access to the output stream to allow user to capture output
#define CINCH_CAPTURE() \
  cinch::test_output_t::instance().get_stream()

// Return captured output as a std::string
#define CINCH_DUMP() \
  cinch::test_output_t::instance().get_buffer()

// Compare captured output to a blessed file
#define CINCH_EQUAL_BLESSED(f) \
  cinch::test_output_t::instance().equal_blessed((f))

// Write captured output to file
#define CINCH_WRITE(f) \
  cinch::test_output_t::instance().to_file((f))

#define CINCH_ASSERT(ASSERTION, ...) \
  ASSERT_ ## ASSERTION(__VA_ARGS__) << CINCH_DUMP()

#endif // cinchtest_h

/*~-------------------------------------------------------------------------~-*
 * vim: set tabstop=2 shiftwidth=2 expandtab :
 *~-------------------------------------------------------------------------~-*/

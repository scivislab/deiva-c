/*~--------------------------------------------------------------------------~*
 * Copyright (c) 2016 Los Alamos National Laboratory, LLC
 * All rights reserved
 *~--------------------------------------------------------------------------~*/
////////////////////////////////////////////////////////////////////////////////
/// \file
////////////////////////////////////////////////////////////////////////////////

// user includes
#include "utils/static_for.h"


// system includes
#include <cinchtest.h>
#include <iostream>

// using declarations
using std::cout;
using std::endl;
using ale::utils::static_for;

//=============================================================================
//! \brief Test the static_for function.
//=============================================================================
TEST(static_for, simple) {
  
  int cnt{0};

  static_for<5>( 
                [&cnt](auto i) { 
                  cout << i << endl; 
                  ASSERT_EQ( cnt++, i );
                } );
}


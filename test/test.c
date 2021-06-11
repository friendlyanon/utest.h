/*
   This is free and unencumbered software released into the public domain.

   Anyone is free to copy, modify, publish, use, compile, sell, or
   distribute this software, either in source code form or as a compiled
   binary, for any purpose, commercial or non-commercial, and by any
   means.

   In jurisdictions that recognize copyright laws, the author or authors
   of this software dedicate any and all copyright interest in the
   software to the public domain. We make this dedication for the benefit
   of the public at large and to the detriment of our heirs and
   successors. We intend this dedication to be an overt act of
   relinquishment in perpetuity of all present and future rights to this
   software under copyright law.

   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
   EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
   MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
   IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
   OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
   ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
   OTHER DEALINGS IN THE SOFTWARE.

   For more information, please refer to <http://unlicense.org/>
*/

#include "utest.h"

#ifdef _MSC_VER
/* disable 'conditional expression is constant' - our examples below use this!
 */
#pragma warning(disable : 4127)
#endif

UTEST(c, ASSERT_TRUE) { ASSERT_TRUE(1); }

UTEST(c, ASSERT_FALSE) { ASSERT_FALSE(0); }

UTEST(c, ASSERT_EQ) { ASSERT_EQ(1, 1); }

UTEST(c, ASSERT_NE) { ASSERT_NE(1, 2); }

UTEST(c, ASSERT_LT) { ASSERT_LT(1, 2); }

UTEST(c, ASSERT_LE) {
  ASSERT_LE(1, 1);
  ASSERT_LE(1, 2);
}

UTEST(c, ASSERT_GT) { ASSERT_GT(2, 1); }

UTEST(c, ASSERT_GE) {
  ASSERT_GE(1, 1);
  ASSERT_GE(2, 1);
}

UTEST(c, ASSERT_STREQ) { ASSERT_STREQ("foo", "foo"); }

UTEST(c, ASSERT_STRNE) { ASSERT_STRNE("foo", "bar"); }

UTEST(c, ASSERT_STRNEQ) { ASSERT_STRNEQ("foo", "foobar", strlen("foo")); }

UTEST(c, ASSERT_STRNNE) { ASSERT_STRNNE("foo", "barfoo", strlen("foo")); }

UTEST(c, EXPECT_TRUE) { EXPECT_TRUE(1); }

UTEST(c, EXPECT_FALSE) { EXPECT_FALSE(0); }

UTEST(c, EXPECT_EQ) { EXPECT_EQ(1, 1); }

UTEST(c, EXPECT_NE) { EXPECT_NE(1, 2); }

UTEST(c, EXPECT_LT) { EXPECT_LT(1, 2); }

UTEST(c, EXPECT_LE) {
  EXPECT_LE(1, 1);
  EXPECT_LE(1, 2);
}

UTEST(c, EXPECT_GT) { EXPECT_GT(2, 1); }

UTEST(c, EXPECT_GE) {
  EXPECT_GE(1, 1);
  EXPECT_GE(2, 1);
}

UTEST(c, EXPECT_STREQ) { EXPECT_STREQ("foo", "foo"); }

UTEST(c, EXPECT_STRNE) { EXPECT_STRNE("foo", "bar"); }

UTEST(c, EXPECT_STRNEQ) { EXPECT_STRNEQ("foo", "foobar", strlen("foo")); }

UTEST(c, EXPECT_STRNNE) { EXPECT_STRNNE("foo", "barfoo", strlen("foo")); }

UTEST(c, no_double_eval) {
  int i = 0;
  ASSERT_EQ(i++, 0);
  ASSERT_EQ(i, 1);
}

struct MyTestF {
  int foo;
};

UTEST_F_SETUP(MyTestF) {
  const int magic_number = 42;
  ASSERT_EQ(0, utest_fixture->foo);
  utest_fixture->foo = magic_number;
}

UTEST_F_TEARDOWN(MyTestF) { ASSERT_EQ(13, utest_fixture->foo); }

UTEST_F(MyTestF, c) {
  const int magic_number = 13;
  ASSERT_EQ(42, utest_fixture->foo);
  utest_fixture->foo = magic_number;
}

UTEST_F(MyTestF, c2) {
  const int magic_number = 13;
  ASSERT_EQ(42, utest_fixture->foo);
  utest_fixture->foo = magic_number;
}

struct MyTestI {
  size_t foo;
  size_t bar;
};

UTEST_I_SETUP(MyTestI) {
  const int magic_number = 42;
  ASSERT_EQ(0U, utest_fixture->foo);
  ASSERT_EQ(0U, utest_fixture->bar);
  utest_fixture->foo = magic_number;
  utest_fixture->bar = utest_index;
}

UTEST_I_TEARDOWN(MyTestI) {
  ASSERT_EQ(13U, utest_fixture->foo);
  ASSERT_EQ(utest_index, utest_fixture->bar);
}

UTEST_I(MyTestI, c, 2) {
  const int magic_number = 13;
  ASSERT_GT(2U, utest_fixture->bar);
  utest_fixture->foo = magic_number;
}

UTEST_I(MyTestI, c2, 128) {
  const int magic_number = 13;
  ASSERT_GT(128U, utest_fixture->bar);
  utest_fixture->foo = magic_number;
}

UTEST(c, Float) {
  float a = 1;
  float b = 2;
  EXPECT_NE(a, b);
  ASSERT_NE(a, b);
}

UTEST(c, Double) {
  double a = 1;
  double b = 2;
  EXPECT_NE(a, b);
  ASSERT_NE(a, b);
}

UTEST(c, LongDouble) {
  long double a = 1;
  long double b = 2;
  EXPECT_NE(a, b);
  ASSERT_NE(a, b);
}

UTEST(c, Char) {
  signed char a = 1;
  signed char b = 2;
  EXPECT_NE(a, b);
  ASSERT_NE(a, b);
}

UTEST(c, UChar) {
  unsigned char a = 1;
  unsigned char b = 2;
  EXPECT_NE(a, b);
  ASSERT_NE(a, b);
}

UTEST(c, Short) {
  short a = 1;
  short b = 2;
  EXPECT_NE(a, b);
  ASSERT_NE(a, b);
}

UTEST(c, UShort) {
  unsigned short a = 1;
  unsigned short b = 2;
  EXPECT_NE(a, b);
  ASSERT_NE(a, b);
}

UTEST(c, Int) {
  int a = 1;
  int b = 2;
  EXPECT_NE(a, b);
  ASSERT_NE(a, b);
}

UTEST(c, UInt) {
  unsigned int a = 1;
  unsigned int b = 2;
  EXPECT_NE(a, b);
  ASSERT_NE(a, b);
}

UTEST(c, Long) {
  long a = 1;
  long b = 2;
  EXPECT_NE(a, b);
  ASSERT_NE(a, b);
}

UTEST(c, ULong) {
  unsigned long a = 1;
  unsigned long b = 2;
  EXPECT_NE(a, b);
  ASSERT_NE(a, b);
}

UTEST(c, Ptr) {
  const char foo = 42;
  EXPECT_NE(&foo, &foo + 1);
}

UTEST(c, VoidPtr) {
  const void* foo = 0;
  /* cppcheck-suppress nullPointerArithmetic */
  EXPECT_NE(foo, (char*)foo + 1);
}

static const int data[4] = {42, 13, 6, -53};

UTEST(c, Array) { EXPECT_NE(data, data + 1); }

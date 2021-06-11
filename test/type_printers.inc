#include <limits.h>

#if __STDC_VERSION__ >= 201112L || __cplusplus >= 201103L

#ifdef __cplusplus
UTEST(type_printers, cpp) {
#elif defined(UTEST_OVERLOADABLE)
UTEST(type_printers, overloadable) {
#elif __STDC_VERSION__
UTEST(type_printers, stdc) {
#else
#error
#endif

  FILE* old = utest_state.output;
#ifdef _MSC_VER
#pragma warning(push, 1)
#pragma warning(disable : 4996)
#endif
  FILE* out = tmpfile();
#ifdef _MSC_VER
#pragma warning(pop)
#endif
  ASSERT_TRUE(!!out);
  utest_state.output = out;

  int i = INT_MIN;
  long l = LONG_MIN;
  long long ll = LLONG_MIN;
  unsigned u = UINT_MAX;
  unsigned long ul = ULONG_MAX;
  unsigned long long ull = ULLONG_MAX;
  float f = 0.F;
  double d = 0.;
  long double ld = 0.L;
  utest_type_printer(i);
  utest_type_printer(l);
  utest_type_printer(ll);
  utest_type_printer(u);
  utest_type_printer(ul);
  utest_type_printer(ull);
  utest_type_printer(f);
  utest_type_printer(d);
  utest_type_printer(ld);

#define CAPACITY (1024)
  char expected[CAPACITY] = {0};
  size_t expected_len =
      UTEST_SNPRINTF(expected, sizeof expected - 1, "%d%ld%lld%u%lu%llu%f%f%Lf",
                     i, l, ll, u, ul, ull, f, d, ld);
  fflush(out);
  rewind(out);
  char buf[CAPACITY] = {'\0'};
#undef CAPACITY
  const size_t n = fread(buf, 1, sizeof buf, out);
  fclose(out);
  utest_state.output = old;
  ASSERT_EQ(n, expected_len);
  ASSERT_STREQ(buf, expected);
}
#endif

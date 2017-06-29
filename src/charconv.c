/**
 * \file charconv.c
 *
 * \brief Character set conversion functions.
 */

#include "copyrite.h"
#include "mymalloc.h"
#include "charconv.h"
#include "mysocket.h"
#include "log.h"

#ifdef HAVE_SSE2
#include <emmintrin.h>
#endif

/**
 * Convert a latin-1 encoded string to utf-8.
 *
 *
 * \param s the latin-1 string.
 * \param latin the length of the string.
 * \param outlen the number of bytes of the returned string, NOT counting the trailing nul.
 * \param telnet true if we should skip telnet escape sequences.
 * \return a newly allocated utf-8 string.
 */
char *
latin1_to_utf8(const char *latin, int len, int *outlen, bool telnet) {
  int bytes = 1;
  int outbytes = 0;
  
  const unsigned char *s = (const unsigned char *)latin;

  /* Compute the number of bytes in the output string */
  for (int n = 0; n < len; n += 1) {

#ifdef HAVE_SSE2
    /* Handle a chunk of 16 chars all together */
    if ((len - n) >= 16) {
      __m128i chunk = _mm_loadu_si128((__m128i *)(s + n));
      unsigned int eightbits = _mm_movemask_epi8(chunk);
      /* For best results on CPUs with popcount instructions, compile
         with appropriate -march=XXX setting or -mpopcnt */
      int set = __builtin_popcount(eightbits);
      bytes += set * 2;
      bytes += 16 - set;
      n += 15;
      continue;
    }
#endif
    
    if (s[n] < 128)
      bytes += 1;
    else
      bytes += 2;
  }

  unsigned char *utf8 = mush_malloc(bytes, "string");

  unsigned char *u = utf8;

#define ENCODE_CHAR(u, c) do { \
    *u++ = 0xC0 | (c >> 6); \
    *u++ = 0x80 | (c & 0x3F); \
  } while (0)
  
  for (int n = 0; n < len; n += 1) {

#ifdef HAVE_SSE2
    // Copy a chunk of 16 ascii characters all at once
    if ((len - n) >= 16) {
      __m128i chunk = _mm_loadu_si128((__m128i *)(s + n));
      if (_mm_movemask_epi8(chunk) == 0) {
	_mm_storeu_si128((__m128i *)u, chunk);
	n += 15; // + 1 in for loop
	u += 16;
	outbytes += 16;
	continue;
      }
    }
#endif
    
    if (telnet && s[n] == IAC) {
      /* Single IAC is the start of a telnet sequence. Double IAC IAC is
       * an escape for a single byte. Either way it should never appear
       * at the end of a string by itself. */
      n += 1;
      switch (s[n]) {
      case IAC:
	ENCODE_CHAR(u, IAC);
	outbytes += 2;
	break;
      case SB:
	*u++ = IAC;
	outbytes += 1;
	while (s[n] != SE) {
	  *u++ = s[n];
	  outbytes += 1;
	  n += 1;
	}
	*u++ = SE;
	outbytes += 1;
	break;
      case DO:
      case DONT:
      case WILL:
      case WONT:
	*u++ = IAC;
	*u++ = s[n];
	*u++ = s[n + 1];
	n += 1;
	outbytes += 3;
	break;
      case NOP:
	*u++ = IAC;
	*u++ = NOP;
	outbytes += 2;
	break;
      default:
	/* This should never be reached. */
	do_rawlog(LT_ERR, "Invalid telnet sequence character %X", s[n]);
      }
    } else if (s[n] < 128) {
      *u++ = s[n];
      outbytes += 1;
    } else {
      ENCODE_CHAR(u, s[n]);
      outbytes += 2;
    }
  }
  *u = '\0';
  if (outlen)
    *outlen = outbytes;
  return (char *)utf8;
#undef ENCODE_CHAR
}

/**
 * Convert a UTF-8 encoded string to Latin-1
 * 
 * \param utf8 a valid utf-8 string
 * \param outlen the length of the returned string including trailing nul
 * \return a newly allocated latin-1 string
 */
char*
utf8_to_latin1(const char *utf8, int *outlen) {
  const unsigned char *u = (const unsigned char *)utf8;
  int bytes = 1;
  int ulen = 0;
  int n;
  
  while (*u) {
    if (*u < 128) {
      bytes += 1;
    } else if ((*u & 0xC0) == 0x80) {
      // Skip continuation bytes
    } else {
      bytes += 1;
    }
    u += 1;
    ulen += 1;
  }

  if (outlen)
    *outlen = bytes;
  
  char *s = mush_malloc(bytes, "string");
  unsigned char *p = (unsigned char *)s;
  unsigned char output = 0;
  
  for (n = 0; n < ulen;) {

#ifdef HAVE_SSE2
    // Copy a chunk of 16 ascii characters all at once.
    if ((ulen - n) >= 16) {
      __m128i chunk = _mm_loadu_si128((__m128i *)(utf8 + n));
      if (_mm_movemask_epi8(chunk) == 0) {
	_mm_storeu_si128((__m128i *)p, chunk);
	n += 16;
	p += 16;
	continue;
      }
    }
#endif
    
    if (utf8[n] < 128) {
      *p++ = utf8[n];
      n += 1;
    } else if ((utf8[n] & 0xE0) == 0xC0) {
      if ((utf8[n] & 0x1F) <= 0x03) {
	output = utf8[n] << 6;
	n += 1;
      } else {
	*p++ = '?';
	n += 2;
      }
    } else if ((utf8[n] & 0xC0) == 0x80) {
      output = output | (utf8[n] & 0x3F);
      *p++ = output;
      output = 0;
      n += 1;
    } else if ((utf8[n] & 0xF8) == 0xF0) {
      *p++ = '?';
      n += 4;
    } else if ((utf8[n] & 0xF0) == 0xE0) {
      *p++ = '?';
      n += 3;
    }
  }
  
  *p = '\0';
  return s;
}

/**
 * Check to see if a string is valid utf-8 or not.
 * \param utf8 string to validate
 * \return true or false
 */
bool
valid_utf8(const char *utf8) {
  const unsigned char *u = (const unsigned char *)utf8;

  int nconts = 0;
  
  while (*u) {
    if (*u < 128) {
      if (nconts)
	return 0;
    } else if ((*u & 0xF8) == 0xF0) {
      if (nconts)
	return 0;
      nconts = 3;
    } else if ((*u & 0xF0) == 0xE0) {
      if (nconts)
	return 0;
      nconts = 2;
    } else if ((*u & 0xE0) == 0xC0) {
      if (nconts)
	return 0;
      nconts = 1;
    } else if ((*u & 0xC0) == 0x80) {
      if (nconts > 0)
	nconts -= 1;
      else
	return 0;
    } else {
      return 0;
    }
    u += 1;
  }

  return nconts == 0;
}

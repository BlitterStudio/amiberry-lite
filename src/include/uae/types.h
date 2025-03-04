/*
 * Common types used throughout the UAE source code
 * Copyright (C) 2014 Frode Solheim
 *
 * Licensed under the terms of the GNU General Public License version 2.
 * See the file 'COPYING' for full license text.
 */

#ifndef UAE_TYPES_H
#define UAE_TYPES_H

/* This file is intended to be included by external libraries as well,
 * so don't pull in too much UAE-specific stuff. */

/* Define uae_ integer types. Prefer long long int for uae_x64 since we can
 * then use the %lld format specifier for both 32-bit and 64-bit instead of
 * the ugly PRIx64 macros. */

#include <cstdint>

typedef int8_t uae_s8;
typedef uint8_t uae_u8;

#if SIZEOF_SHORT == 2
typedef unsigned short uae_u16;
typedef short uae_s16;
#elif SIZEOF_INT == 2
typedef unsigned int uae_u16;
typedef int uae_s16;
#else
#error No 2 byte type, you lose.
#endif

#if SIZEOF_INT == 4
typedef unsigned int uae_u32;
typedef int uae_s32;
#elif SIZEOF_LONG == 4
typedef unsigned long uae_u32;
typedef long uae_s32;
#else
#error No 4 byte type, you lose.
#endif

#ifndef uae_s64
typedef long long uae_s64;
#endif
#ifndef uae_u64
typedef unsigned long long uae_u64;
#endif

#if SIZEOF_LONG_LONG == 8
#define VAL64(a) (a ## LL)
#define UVAL64(a) (a ## uLL)
#elif SIZEOF___INT64 == 8
#define uae_s64 __int64
#define uae_u64 unsigned __int64
#define VAL64(a) (a)
#define UVAL64(a) (a)
#elif SIZEOF_LONG == 8
#define uae_s64 long;
#define uae_u64 unsigned long;
#define VAL64(a) (a ## l)
#define UVAL64(a) (a ## ul)
#endif

/* Parts of the UAE/WinUAE code uses the bool type (from C++).
 * Including stdbool.h lets this be valid also when compiling with C. */

#ifndef __cplusplus
#include <stdbool.h>
#endif

/* Use uaecptr to represent 32-bit (or 24-bit) addresses into the Amiga
 * address space. This is a 32-bit unsigned int regardless of host arch. */

typedef uae_u32 uaecptr;

/* Define UAE character types. WinUAE uses TCHAR (typedef for wchar_t) for
 * many strings. FS-UAE always uses char-based strings in UTF-8 format.
 * Defining SIZEOF_TCHAR lets us determine whether to include overloaded
 * functions in some cases or not. */

typedef char uae_char;

#ifdef _WIN32
#include <tchar.h>
#ifdef UNICODE
#define SIZEOF_TCHAR 2
#else
#define SIZEOF_TCHAR 1
#endif
#else
typedef char TCHAR;
#define SIZEOF_TCHAR 1
#endif

#ifndef _T
#if SIZEOF_TCHAR == 1
#define _T(x) x
#else
#define _T(x) Lx
#endif
#endif

#ifndef FALSE
#define FALSE 0
#endif
#ifndef TRUE
#define TRUE (!FALSE)
#endif

typedef signed long long evt_t;

// Some more types from the original UAE code
typedef signed char INT8;
typedef signed short INT16;
typedef signed int INT32;
typedef signed long long INT64;
typedef signed char UINT8;
typedef unsigned short UINT16;
typedef unsigned int UINT32;
typedef unsigned long long UINT64;

#endif /* UAE_TYPES_H */

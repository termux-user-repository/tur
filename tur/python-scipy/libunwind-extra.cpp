//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//
//  This file implements the "Exception Handling APIs"
//  https://itanium-cxx-abi.github.io/cxx-abi/abi-eh.html
//
//===----------------------------------------------------------------------===//
#include <cxxabi.h>

#include <exception>

namespace __cxxabiv1 {

extern "C" {

// GNU extension
// Calls `terminate` with the current exception being caught. This function is used by GCC when a `noexcept` function
// throws an exception inside a try/catch block and doesn't catch it.
extern _LIBCXXABI_FUNC_VIS _LIBCXXABI_NORETURN void __cxa_call_terminate(void*) throw();

void __cxa_call_terminate(void* unwind_arg) throw() {
  __cxa_begin_catch(unwind_arg);
  std::terminate();
}

} // extern "C"

} // namespace __cxxabiv1

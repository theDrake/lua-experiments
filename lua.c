#include <stdio.h>
#include <lua.h>  // Lua main library (lua_*)
#include <lauxlib.h>  // Lua auxiliary library (luaL_*)

int main(void) {
  lua_State *L = luaL_newstate();

  if (luaL_dostring(L, "function foo (x, y) return x + y end")) {
    lua_close(L);

    return -1;
  }

  lua_getglobal(L, "foo");  // Push "foo" onto the stack.
  lua_pushinteger(L, 5);
  lua_pushinteger(L, 3);
  lua_call(L, 2, 1);  // Call "foo" with two arguments, one return value.
  printf("Result: %d\n", lua_tointeger(L, -1));  // Print top value from stack.
  lua_close(L);

  return 0;
}

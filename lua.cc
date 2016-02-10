extern "C" {
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>
}
#include <iostream>

// List of libs to expose for use in scripts:
static const luaL_reg lualibs[] = {
  {"base", luaopen_base},
  {"table", luaopen_table},
  {"io", luaopen_io},
  {"string", luaopen_string},
  {"math", luaopen_math},
  {"debug", luaopen_debug},
  {"loadlib", luaopen_loadlib},
  /* add more libraries here */
  {NULL, NULL}
};

// Load the list of libs:
static void openstdlibs(lua_State *l) {
  const luaL_reg *lib = lualibs;
  for (; lib->func; lib++) {
    lib->func(l);  // open library
    lua_settop(l, 0);  // discard any results
  }
}

int main() {
  int status;
  lua_State *state = lua_open();
  openstdlibs(state);
  status = luaL_loadfile(state, "args.lua");
  std::cout << "[C++] Passing 'arg' array to script" << std::endl;

  // Start array structure:
  lua_newtable(state);

  // Set value of first element to 45:
  lua_pushnumber(state, 1);
  lua_pushnumber(state, 45);
  lua_rawset(state, -3);

  // Set value of second element to 99:
  lua_pushnumber( state, 2 );
  lua_pushnumber( state, 99 );
  lua_rawset( state, -3 );

  // Set the number of elements (index to the last array element):
  lua_pushliteral( state, "n" );
  lua_pushnumber( state, 2 );
  lua_rawset( state, -3 );

  // Set the name of the array that the script will access:
  lua_setglobal( state, "arg" );

  std::cout << "[C++] Running script" << std::endl;
  int result = 0;
  if (status == 0) {
    result = lua_pcall( state, 0, LUA_MULTRET, 0 );
  } else {
    std::cout << "bad" << std::endl;
  }
  if (result != 0) {
    std::cerr << "[C++] script failed" << std::endl;
  }
  std::cout << "[C++] These values were returned from the script" << std::endl;
  while (lua_gettop( state )) {
    switch (lua_type( state, lua_gettop( state ) )) {
      case LUA_TNUMBER:
        std::cout << "script returned "
                  << lua_tonumber(state, lua_gettop(state)) << std::endl;
        break;
      case LUA_TTABLE:
        std::cout << "script returned a table" << std::endl;
        break;
      case LUA_TSTRING:
        std::cout << "script returned "
                  << lua_tostring(state, lua_gettop(state)) << std::endl;
        break;
      case LUA_TBOOLEAN:
        std::cout << "script returned "
                  << lua_toboolean(state, lua_gettop(state)) << std::endl;
        break;
      default:
        std::cout << "script returned unknown param" << std::endl;
        break;
    }
    lua_pop( state, 1 );
  }
  lua_close( state );

  return 0;
}

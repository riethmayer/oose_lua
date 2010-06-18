require("sm_loader")
require 'lspec'

LSpec:setup()

TEST("shold allow to push/pop names on a stack",
   function()
      Class{"Test", mVal = Boolean}
      s = Stack:new(Test)
      o = Test:new()
      o.mVal = false
      s:push(o)
      o = Test:new()
      o.mVal = true
      s:push(o)
      o = Test:new()
      o.mVal = false
      s:push(o)
      cond0 = s:size() == 3
      cond1 = s:pop().mVal == false
      cond2 = s:pop().mVal == true
      cond3 = s:pop().mVal == false
      cond4 = s:size() == 0
      return cond0 and cond1 and cond2 and cond3 and cond4
   end)

TEST("shold allow to push classes",
   function()
      Test = nil
      Class{"Test", mVal = Boolean}
      a = Array:new(Test)
      a:push_back(Test:new())
      cond1 = a:size() == 1
      cond2 = a:back().mVal == false
      cond3 = a:pop_back()._class == Test
      cond4 = a:size() == 0
      return cond1 and cond2 and cond3 and cond4
   end)

TEST("shold not allow to push different types",
   function()
      a = Array:new(Boolean)
      err = pcall(function() a:push_back(String:new()) end)
      return err == false
   end)

TEST("shold allow to be cleared",
   function()
      a = Array:new(Number)
      a:push_back(3)
      a:push_back(3)
      a:push_back(3)
      a:clear()
      return a:size() == 0
   end)

TEST("shold allow to be cleared",
   function()
      a = Array:new(String)
      a:push_back("black")
      a:push_back("white")
      a:push_back("white")
      return a:pop_back() == "white" and a:pop_back() == "white"
        and a:pop_back() == "black"
   end)

TEST("iterator traverses correctly",
   function()
      s = Stack:new(Number)
      s:push(2)
      s:push(7)
      s:push(5)
      s:push(1)
      it = s:iterator()

      CHECK_EQ(it(), 1, "iter")
      CHECK_EQ(it(), 5, "iter")
      CHECK_EQ(it(), 7, "iter")
      CHECK_EQ(it(), 2, "iter")
      CHECK_EQ(it(), nil, "iter")
      CHECK_EQ(s:size(), 4, "iter changed size")
      return true
   end)

TEST("fwd_iterator traverses correctly",
   function()
      a = Array:new(Number)
      a:push_back(2)
      a:push_back(7)
      a:push_back(5)
      a:push_back(1)
      it = a:fwd_iterator()
      CHECK_EQ(it(), 2, "iter")
      CHECK_EQ(it(), 7, "iter")
      CHECK_EQ(it(), 5, "iter")
      CHECK_EQ(it(), 1, "iter")
      CHECK_EQ(it(), nil, "iter")
      CHECK_EQ(s:size(), 4, "iter changed size")
      return true
   end)

TEST("rev_iterator traverses correctly",
   function()
      a = Array:new(Number)
      a:push_back(2)
      a:push_back(7)
      a:push_back(5)
      a:push_back(1)
      it = a:rev_iterator()
      CHECK_EQ(it(), 1, "iter")
      CHECK_EQ(it(), 5, "iter")
      CHECK_EQ(it(), 7, "iter")
      CHECK_EQ(it(), 2, "iter")
      CHECK_EQ(it(), nil, "iter")
      CHECK_EQ(s:size(), 4, "iter changed size")
      return true
   end)


LSpec:teardown()

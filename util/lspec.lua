LSpec = {}

local function WriteVerbosity(text, level)
   if _test_verbosity >= level then
      io.write(text)
   end
end

function LSpec:setup(name)
   _test_verbosity = _test_verbosity or 1
   self.test_results = ""
   self.errors = ""
   self.num_tests = 0
   self.num_failing = 0
   WriteVerbosity("Starting test suite "..(name or "").."\n", 1)
end

function LSpec:teardown()
   local passed = self.num_tests - self.num_failing
   io.write("Passed "..passed.." / "..self.num_tests, "\n")
   WriteVerbosity(LSpec.test_results.."\n", 0)
   WriteVerbosity(LSpec.errors.."\n", 1)
   LSpec.test_results = ""
   LSpec.errors = ""
end

function TEST(text, block)
   local lspec_env_missing = "LSpec not initialized. Call LSpec:setup() and LSpec:teardown()."
   if LSpec.test_results == nil or LSpec.errors == nil then
      error(lspec_env_missing)
   end

   LSpec.num_tests = LSpec.num_tests + 1
   if string.match(text, "should") then
      WriteVerbosity("it "..text, 2)
   else
      WriteVerbosity(text, 2)
   end

   stat, err = pcall(block)
   if stat == true then
      if err == nil or err == true then
	 WriteVerbosity("[OK]\n", 2)
         LSpec.test_results = LSpec.test_results.."."
      else
	 WriteVerbosity("[FAIL]\n", 2)
	 print("true expected as return but received"..tostring(err))
	 LSpec.num_failing = LSpec.num_failing + 1
         LSpec.test_results = LSpec.test_results .. "F"
      end
   else
      WriteVerbosity("[ERROR]\n", 2)
      WriteVerbosity(err, 2)
      LSpec.errors = LSpec.errors..err.."\n"
      LSpec.num_failing = LSpec.num_failing + 1
      LSpec.test_results = LSpec.test_results .. "E"
   end
end


----------------------------------------------------------------------------------

function CHECK_EQ(left, right, comment)
   if left ~= right then
      error(comment)
   end
end
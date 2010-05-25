LSpec = {
   _class = LSpec
}
function LSpec:setup()
   LSpec.test_results = ""
   LSpec.errors = ""
   print("Starting test suite")
end

function LSpec:teardown()
   print(LSpec.test_results)
   print(LSpec.errors)
   LSpec.test_results = ""
   LSpec.errors = ""
end

function it(text, block)
   code, ErrorString = pcall(block)
   local lspec_env_missing = "LSpec: initialize the test block with LSpec:setup() and end it with LSpec:teardown()"
   if LSpec.test_results == nil or LSpec.errors == nil then
      error(lspec_env_missing)
   end
   if code then
      if ErrorString then
         LSpec.test_results = LSpec.test_results .. "."
      else
         LSpec.test_results = LSpec.test_results .. "F"
         LSpec.errors = LSpec.errors .. "\nFailure: \"" .. text .. "\"\n" .. tostring(ErrorString) .. "\n"
      end
   else
      LSpec.errors = LSpec.errors .. "\nError: \"" .. text .. "\"\n" .. ErrorString .. "\n"
      LSpec.test_results = LSpec.test_results .. "E"
   end
end
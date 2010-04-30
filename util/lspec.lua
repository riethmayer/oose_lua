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

function test = testNumericInput
test = functiontests(localfunctions);

function testNumericInput(testcase)
cmd = @() sqrt("hello");
verifyError(testcase,cmd,"MATLAB:UndefinedFunction")
end

end

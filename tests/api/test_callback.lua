--
-- tests/api/test_callback.lua
-- Tests the main API value-setting callback.
-- Copyright (c) 2012 Jason Perkins and the Premake project
--

	T.api_callback = {}
	local suite = T.api_callback
	local api = premake.api


--
-- Setup and teardown
--

	function suite.setup()
		api.settest = function(target, field, value) 
			test_args = {
				["target"] = target,
				["field"] = field,
				["value"] = value
			}
		end
	end


	function suite.teardown()
		_G["testapi"] = nil
		test_args = nil
		api.settest = nil
	end

	

	
--
-- Verify that the callback hands off control to setter for
-- the field's value kind.
--

	function suite.callsSetter_onFieldKind()
		api.register { name = "testapi", kind = "test", scope = "project" }
		solution "MySolution"
		testapi "test"
		test.isnotnil(test_args)
	end


-- 
-- Verify that the field description is passed along to the setter.
--

	function suite.setterGetsFieldDescription()
		api.register { name = "testapi", kind = "test", scope = "project" }
		solution "MySolution"
		testapi "test"
		test.isequal("testapi", test_args.field.name)
	end


-- 
-- Verify that the value is passed along to the setter.
--

	function suite.setterGetsFieldDescription()
		api.register { name = "testapi", kind = "test", scope = "project" }
		solution "MySolution"
		testapi "test"
		test.isequal("test", test_args.value)
	end


--
-- If the field scope is "project", and there is no active solution
-- or project, an error should be raised.
--

	function suite.errorRaised_onProjectScopeWithNoProject()
		api.register { name = "testapi", kind = "test", scope = "project" }
		ok, err = pcall(function () 
			testapi "test"
		end)
		test.isfalse(ok)
	end


--
-- If the field scope is "configuration" and there is no active configuration,
-- an error should be raised.
--

	function suite.errorRaised_onConfigScopeWithNoConfig()
		api.register { name = "testapi", kind = "test", scope = "configuration" }
		ok, err = pcall(function () 
			testapi "test"
		end)
		test.isfalse(ok)
	end


--
-- If the field scope is "project" and there is an active solution, but not an
-- active project, the solution should be the target.
--

	function suite.solutionTarget_onProjectScopeWithActiveSolution()
		api.register { name = "testapi", kind = "test", scope = "project" }
		local sln = solution "MySolution"
		testapi "test"
		test.istrue(sln == test_args.target)
	end


--
-- If the field scope is "project" and there is an active project, it should
-- be the target.
--

	function suite.projectTarget_onProjectScopeWithActiveProject()
		api.register { name = "testapi", kind = "test", scope = "project" }
		local sln = solution "MySolution"
		local prj = project "MyProject"
		testapi "test"
		test.istrue(prj == test_args.target)
	end


--
-- If the field scope is "configuration" and there is an active configuration, 
-- it should be the target.
--

	function suite.configTarget_onConfigScopeWithActiveConfig()
		api.register { name = "testapi", kind = "test", scope = "configuration" }
		local sln = solution "MySolution"
		local cfg = configuration {}
		testapi "test"
		test.istrue(cfg == test_args.target)
	end
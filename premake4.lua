solution "AmazonRobots"
	configurations { "Debug", "DebugOpt", "Release", "Retail" }
	platforms { "x64" }

	-- include the fuji project...
	dofile  "../fuji/Fuji/Project/fujiproj.lua"

	-- include the Haku project...
	dofile "../fuji/Haku/Project/hakuproj.lua"

	project "AmazonRobots"
		kind "WindowedApp"
		language "C++"
		files { "src/**.h", "src/**.cpp" }
		files { "data/**" }

		includedirs { "src/" }
		objdir "build/"
		targetdir "./"

		flags { "StaticRuntime", "NoExceptions", "NoRTTI", "WinMain" }

		links { "Fuji", "Haku" }

		dofile "../fuji/dist/Project/fujiconfig.lua"
		dofile "../fuji/dist/Project/hakuconfig.lua"

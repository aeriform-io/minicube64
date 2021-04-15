

solution "Project"
--------------------------------------------------------------------------
configurations	{ "Release","Debug" }
	targetdir			""
	debugdir			""
	configuration "Debug"
		defines				{ "DEBUG", "_CRT_SECURE_NO_WARNINGS", "_WINSOCK_DEPRECATED_NO_WARNINGS" }
		flags					{ "Symbols","SEH" }
	configuration "Release"
		defines				{ "NDEBUG", "_CRT_SECURE_NO_WARNINGS", "_WINSOCK_DEPRECATED_NO_WARNINGS" ,"NoImportLib","NoIncrementalLink"}
		flags					{ "OptimizeSize","StaticRuntime" }


project	"MiniCube"
--	kind		"WindowedApp"
	kind		"ConsoleApp"

	language			"C++"
	objdir				"_build"
	targetprefix	""
	defines					{"ASM_LIB","NES_APU"}
	files						{"main.c","cpu/fake6502.c","assembler/asm6f.c","machine/machine.c","apu/wsg.c","apu/nes_apu.c","utils/MiniFB_prim.c"} 
	files						{"minifb/src/*.c"} 
	includedirs			{"minifb/include","minifb/src","cpu","sokol","assembler","apu","utils",".","machine"}

	if os.is("linux")==true then 
		links					{ "m" }
		defines				{"_GLFW_X11"}
--		files         { "3rdParty/glfw/src/x11_*.c","3rdParty/glfw/src/glx_context.c","3rdParty/glfw/src/posix_time.c","3rdParty/glfw/src/posix_thread.c","3rdParty/glfw/src/linux_joystick.c","3rdParty/glfw/src/xkb_unicode.c","3rdParty/glfw/src/egl_context.c"}
--		links					{ "X11","GL","Xrandr","Xext","Xcursor","Xinerama","pthread"}
		includedirs   { "3rdParty/glfw/include" }												
		links					{ "X11","GL","Xrandr","Xext","Xcursor","Xinerama","pthread","m","dl"}
	elseif os.is("macosx")==true then 
		defines				{"USE_METAL_API"}
		files						{"minifb/src/macosx/*.m"} 
		links				{ "m","Cocoa.framework","QuartzCore.framework","Metal.framework","MetalKit.framework","AudioToolbox.framework" }
	else
		files					{"minifb/src/windows/WinMiniFB.c"}
--		files       	{ "3rdParty/glfw/src/win32*.c","3rdParty/glfw/src/wgl_context.c","3rdParty/glfw/src/egl_context.c"}
--		links					{ "opengl32","gdi32","comdlg32","ole32","Psapi"}

		links					{ "gdi32","ole32"}
--		files					{"assets/resources.rc"}
	end
--	links {"ceres","gflags","glog"}



	

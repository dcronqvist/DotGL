# 👾 DotGL

A low level OpenGL 4.6 binding for C#. Contains exact function signatures (unsafe with pointers) and safe wrappers for all OpenGL functions. Allows for configuring which functions to expose (unsafe/safe or both) and which OpenGL version to target.

## How to use

#### Include script

The easiest way to include this binding in your project is to use the [Include.ps1](Include.ps1) script. The script will download the latest [GL.cs](/GL.cs) file, and put it next to your `.csproj` file. It will also add the necessary configuration to your `.csproj` file.

The following command can be run either in the same directory as the `.csproj` file you wish to include it for, or next to the `.sln` file, where it will be simply include it in the first `.csproj` file it finds. 

```powershell
$(iwr https://raw.githubusercontent.com/dcronqvist/DotGL/master/Include.ps1).Content | iex
```

#### Manually

1. Download the [GL.cs](/GL.cs) file and add it to your project somewhere.
2. Include the following in your `.csproj` file.
    - Configure `OpenGLVersionMajor` and `OpenGLVersionMinor` to your desired OpenGL version.
    - Configure `OpenGLProfile` to either `CORE` or `COMPAT`. (`COMPAT` not implemented yet)
    - Configure `OpenGLWrapperAPI` to either `SAFE`, `UNSAFE` or `BOTH`.

```xml
<Project ...>
    ...
    <PropertyGroup>
        <!-- GL.cs configuration options! -->

        <!-- Profile: CORE/COMPAT -->
        <!-- COMPAT not implemented yet -->
        <OpenGLProfile>CORE</OpenGLProfile>

        <!-- Version: Any valid OpenGL version from 1.0-4.6 -->
        <OpenGLVersionMajor>3</OpenGLVersionMajor>
        <OpenGLVersionMinor>3</OpenGLVersionMinor>

        <!-- Defining exposed wrapper API (SAFE/UNSAFE/BOTH) -->
        <!-- SAFE: Only safe functions are exposed -->
        <!-- UNSAFE: Only unsafe functions are exposed -->
        <!-- BOTH: Both safe and unsafe functions are exposed -->
        <OpenGLWrapperAPI>BOTH</OpenGLWrapperAPI>

        <!-- Defining constants for compile time availability of APIs -->
        <DefineConstants>$(DefineConstants);OGL_V_$(OpenGLVersionMajor)_$(OpenGLVersionMinor);OGL_P_$(OpenGLProfile);OGL_WRAPPER_API_$(OpenGLWrapperAPI)</DefineConstants>
    </PropertyGroup>
    ...
</Project>
```

3. Done!

## Example with [DotGLFW](https://github.com/dcronqvist/DotGLFW)

The following example shows how to use this binding with [DotGLFW](https://github.com/dcronqvist/DotGLFW). The example is not complete, but should give a good idea of how this binding is supposed to be set up and used.

```csharp
// Gives access to all OpenGL functions without the `GL.` prefix
using static DotGL.GL; 

// Retrieve OpenGL version and profile from `.csproj` file
// Does some switching depending on which constants are defined
int glMajor = GL.GetProjectOpenGLVersionMajor();
int glMinor = GL.GetProjectOpenGLVersionMinor();
string glProfile = GL.GetProjectOpenGLProfile();

// Normal GLFW window creation
Glfw.Init();
Glfw.WindowHint(Hint.ClientAPI, ClientAPI.OpenGLAPI);
Glfw.WindowHint(Hint.ContextVersionMajor, glMajor);
Glfw.WindowHint(Hint.ContextVersionMinor, glMinor);
OpenGLProfile profile = glProfile switch
{
    "CORE" => OpenGLProfile.CoreProfile,
    "COMPAT" => OpenGLProfile.CompatProfile,
    _ => throw new Exception("Invalid OpenGL profile!")
}
Glfw.WindowHint(Hint.OpenGLProfile, profile);
Window window = Glfw.CreateWindow(800, 600, "DotGL", Monitor.NULL, Window.NULL);

// Set the current context to the newly created window
Glfw.MakeContextCurrent(window);

// Load all OpenGL functions for the given version and profile
GL.Import(Glfw.GetProcAddress);

// OpenGL functions now working!
glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
glClear(GL_COLOR_BUFFER_BIT);
```
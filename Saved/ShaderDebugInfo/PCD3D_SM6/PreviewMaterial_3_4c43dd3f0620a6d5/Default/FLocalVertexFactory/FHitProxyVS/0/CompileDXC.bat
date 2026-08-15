@ECHO OFF
SET DXC="D:\Program Files\Epic Games\UE_5.2\Engine\Binaries\ThirdParty\ShaderConductor\Win64\dxc.exe"
IF NOT EXIST %DXC% (
	ECHO Couldn't find dxc.exe under "D:\Program Files\Epic Games\UE_5.2\Engine\Binaries\ThirdParty\ShaderConductor\Win64"
	GOTO :END
)
%DXC% /auto-binding-space 0 /Zpr /O3 -Wno-parentheses-equality -disable-lifetime-markers /T vs_6_6 /E Main /Fc HitProxyVertexShader.d3dasm /Fo HitProxyVertexShader.dxil HitProxyVertexShader.usf
:END
PAUSE

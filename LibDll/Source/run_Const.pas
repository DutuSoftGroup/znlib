{*******************************************************************************
  作者: dmzn 2007-01-09
  描述: 通用运行时函数库常量协商单元
*******************************************************************************}
unit run_Const;

interface

var
  gPath: string;
  //调用者路径

Resourcestring
  sSkinFile = 'Skin.skn';
  //默认皮肤文件
  sConfigFile = 'Config.Ini';
  //主配置文件
  sCodeKey = 'dmzn_run';
  //加密密钥
  sSkinRegKey = '\Software\RunSoft\CommRunLib';
  //皮肤对应注册表键
  sSkinRegValue = 'SkinFile';
  //皮肤对应注册表值

implementation

end.

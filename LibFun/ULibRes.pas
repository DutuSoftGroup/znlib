{*******************************************************************************
  作者: dmzn@163.com 2007-10-09
  描述: 项目通用函数资源定义单元

  备注:
  &.前缀"sVar_"表示变量定义,通用函数库需要这些参数才能运行.例如:sVar_AppPath表
    示程序所在的路径,任何需要这个路径的函数都会读取该参数.
  &.任何"文件"必须是全路径,不允许使用相对路径.
*******************************************************************************}
unit ULibRes;

interface

ResourceString
  sVerifyCode             = ';Verify:';       //校验码标记

  sVar_DlgMsg             = 'DlgMsg';
  sVar_DlgMsgDef          = 'DlgMsg.dll';

  sVar_DlgMsgLocked       = 'PosMsgLock';
  sVar_DlgMsgLockFlag     = 'Locked';         //禁用提示框

  sVar_DlgHintStr         = 'StrHint';
  sVar_DlgHintStrDef      = '提示';

  sVar_DlgAskStr          = 'StrAsk';
  sVar_DlgAskStrDef       = '询问';

  sVar_DlgWarnStr         = 'StrWarn';
  sVar_DlgWarnStrDef      = '警告';

  sVar_AppPath            = 'AppPath';        //程序路径
  sVar_SysConfig          = 'ConfigFile';     //系统配置文件
  sVar_FormConfig         = 'FormConfig';     //窗体配置文件
  sVar_ConnDBConfig       = 'ConnDBFile';     //数据库配置文件
  
implementation

end.



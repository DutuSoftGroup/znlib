{*******************************************************************************
  作者: dmzn dmzn@163.com 2005.7
  描述: 提供文件的压缩/解压缩功能

  例程: nZip: TZnZip;
    nZip.SourceFile := 'C:\Text.Doc';
    nZip.DestFile := 'C:\Text.Doc.Bak'; nZip.ZipFile;

  更新:
  &.2006-02-06
  TZnZip添加Create,Destroy方法,解决压缩线程正在运行,而主程序要退出
  时分配的资源无法释放的问题.
  TZipThread修改了DoProcess,DoEnd方法,判断FOwner是否在Destrying状态,否则会
  导致内存读写错误.
  &.2006-06-13
  TZnZip修改StopZnZip方法,FThread.Free修改为FreeAndNil(FThread).
  TZipThread修改DoEnd和Execute,在Terminated为True时不设置FThread:=nil,否则导致
  StopZnZip的FThread.Free无法正确释放

  声明: 本单元公开源码,个人/商业可免费使用,不过请保留此处的说明文字.如果你
  对本单元作了合理修改,请邮件通知我,谢谢!
*******************************************************************************}

&.安装组件
启动Delphi,选择菜单Component -> Install Component -> Into Existing.. -> 在UnitFileName文本框中输入ZnZip单元的全路径,在SearchPath中输入ZnZip单元所在的目录,选择PackageFileName,点击Ok按钮.

&.使用说明
组件面板上找到RunSoft页面,拖一个ZnZip组件到工程窗体上.
TZnZip组件属性如下:
*.SourceFile: 压缩文件时,该属性为待压缩的文件全路径;解压缩时,该属性为待解压的文件全路径
*.DestFile: 压缩文件时,该属性为待压缩后的文件全路径;解压缩时,该属性为待解压后的文件全路径
*.ZipLevel: 压缩级别.zcNone:不压缩;zcDefault,标准压缩;zcFastest,快速压缩;zcMax,最大压缩比
*.Busy: 若值为True,表示组件正在运行压缩/解压操作

TZnZip组件方法如下:
*.ZipFile: 对SourceFile进行压缩操作,保存压缩后的文件到DestFile中
*.UnZipFile: 对SourceFile进行解压操作,保存解压后的文件到DestFile中
*.StopZnZip: 若Busy属性为True,则停止当前的操作

TZnZip组件事件如下:
*.OnBegin: 压缩/解压开始,参数nMax为文件的大小
*.OnProcess : 压缩/解压进度,参数nHasDone文已经完成的文件大小
*.OnEnd: 压缩/解压完成,参数nNormal标识压缩过程中是否出现错误,nNormal为True表示没有错误;nZipRate为压缩率,解压缩时无效

例程:
*.压缩c:\test.doc到c:\test.bak
ZnZip1.SourceFile := 'c:\test.doc';
ZnZip1.DestFile := 'c:\text.bak';
ZnZip1.ZipFile;

*.解压c:\test.bak到c:\test.doc
ZnZip1.SourceFile := 'c:\test.bak';
ZnZip1.DestFile := 'c:\text.doc';
ZnZip1.UnZipFile;

压缩/解压过程中需要一段时间,如果要停止,使用ZnZip.StopZnZip.

*******************************************************************************}
本组件使用RunSoft标志,源于RunSoft工作室(Running&我们一直在努力)
介绍:
  RunSoft是一个正在成长中的软件工作室,它的成员遍布各地,依靠国际互联网作为沟通手段.
如果您有基本的软件知识,有足够的闲暇时间,即可参与RunSoft.
  当有项目需要您参与时,依据需求文档和您填写的资料,符合要求后会与您取得联系.研发过程
使用QQ群和E-mail来控制.测试版本完成后,支付您全部应得的10%,两个稳定版本后全部支付.源
码由您自愿交给RunSoft来管理,或者自己保留,在稳定版本发布后一年内,提供软件维护!
  当您有项目需要外协时,可以联系RunSoft.确定我们有能力来研发时,会编写需求文档和组织人员,
测试版本完成后,支付项目预算的20%,两个稳定版本后全部支付.源码有RunSoft管理,提供一年的
软件维护!

QQ群: 10904845 
E-Mail: dmzn@163.com (资料注册可发送到该邮箱)
*******************************************************************************}

{*******************************************************************************
  ����: dmzn dmzn@163.com 2005.7
  ����: �ṩ�ļ���ѹ��/��ѹ������

  ����: nZip: TZnZip;
    nZip.SourceFile := 'C:\Text.Doc';
    nZip.DestFile := 'C:\Text.Doc.Bak'; nZip.ZipFile;

  ����:
  &.2006-02-06
  TZnZip���Create,Destroy����,���ѹ���߳���������,��������Ҫ�˳�
  ʱ�������Դ�޷��ͷŵ�����.
  TZipThread�޸���DoProcess,DoEnd����,�ж�FOwner�Ƿ���Destrying״̬,�����
  �����ڴ��д����.
  &.2006-06-13
  TZnZip�޸�StopZnZip����,FThread.Free�޸�ΪFreeAndNil(FThread).
  TZipThread�޸�DoEnd��Execute,��TerminatedΪTrueʱ������FThread:=nil,������
  StopZnZip��FThread.Free�޷���ȷ�ͷ�

  ����: ����Ԫ����Դ��,����/��ҵ�����ʹ��,�����뱣���˴���˵������.�����
  �Ա���Ԫ���˺����޸�,���ʼ�֪ͨ��,лл!
*******************************************************************************}

&.��װ���
����Delphi,ѡ��˵�Component -> Install Component -> Into Existing.. -> ��UnitFileName�ı���������ZnZip��Ԫ��ȫ·��,��SearchPath������ZnZip��Ԫ���ڵ�Ŀ¼,ѡ��PackageFileName,���Ok��ť.

&.ʹ��˵��
���������ҵ�RunSoftҳ��,��һ��ZnZip��������̴�����.
TZnZip�����������:
*.SourceFile: ѹ���ļ�ʱ,������Ϊ��ѹ�����ļ�ȫ·��;��ѹ��ʱ,������Ϊ����ѹ���ļ�ȫ·��
*.DestFile: ѹ���ļ�ʱ,������Ϊ��ѹ������ļ�ȫ·��;��ѹ��ʱ,������Ϊ����ѹ����ļ�ȫ·��
*.ZipLevel: ѹ������.zcNone:��ѹ��;zcDefault,��׼ѹ��;zcFastest,����ѹ��;zcMax,���ѹ����
*.Busy: ��ֵΪTrue,��ʾ�����������ѹ��/��ѹ����

TZnZip�����������:
*.ZipFile: ��SourceFile����ѹ������,����ѹ������ļ���DestFile��
*.UnZipFile: ��SourceFile���н�ѹ����,�����ѹ����ļ���DestFile��
*.StopZnZip: ��Busy����ΪTrue,��ֹͣ��ǰ�Ĳ���

TZnZip����¼�����:
*.OnBegin: ѹ��/��ѹ��ʼ,����nMaxΪ�ļ��Ĵ�С
*.OnProcess : ѹ��/��ѹ����,����nHasDone���Ѿ���ɵ��ļ���С
*.OnEnd: ѹ��/��ѹ���,����nNormal��ʶѹ���������Ƿ���ִ���,nNormalΪTrue��ʾû�д���;nZipRateΪѹ����,��ѹ��ʱ��Ч

����:
*.ѹ��c:\test.doc��c:\test.bak
ZnZip1.SourceFile := 'c:\test.doc';
ZnZip1.DestFile := 'c:\text.bak';
ZnZip1.ZipFile;

*.��ѹc:\test.bak��c:\test.doc
ZnZip1.SourceFile := 'c:\test.bak';
ZnZip1.DestFile := 'c:\text.doc';
ZnZip1.UnZipFile;

ѹ��/��ѹ��������Ҫһ��ʱ��,���Ҫֹͣ,ʹ��ZnZip.StopZnZip.

*******************************************************************************}
�����ʹ��RunSoft��־,Դ��RunSoft������(Running&����һֱ��Ŭ��)
����:
  RunSoft��һ�����ڳɳ��е����������,���ĳ�Ա�鲼����,�������ʻ�������Ϊ��ͨ�ֶ�.
������л��������֪ʶ,���㹻����Ͼʱ��,���ɲ���RunSoft.
  ������Ŀ��Ҫ������ʱ,���������ĵ�������д������,����Ҫ��������ȡ����ϵ.�з�����
ʹ��QQȺ��E-mail������.���԰汾��ɺ�,֧����ȫ��Ӧ�õ�10%,�����ȶ��汾��ȫ��֧��.Դ
��������Ը����RunSoft������,�����Լ�����,���ȶ��汾������һ����,�ṩ���ά��!
  ��������Ŀ��Ҫ��Эʱ,������ϵRunSoft.ȷ���������������з�ʱ,���д�����ĵ�����֯��Ա,
���԰汾��ɺ�,֧����ĿԤ���20%,�����ȶ��汾��ȫ��֧��.Դ����RunSoft����,�ṩһ���
���ά��!

QQȺ: 10904845 
E-Mail: dmzn@163.com (����ע��ɷ��͵�������)
*******************************************************************************}
